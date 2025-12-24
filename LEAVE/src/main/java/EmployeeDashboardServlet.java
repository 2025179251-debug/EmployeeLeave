import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.*;

@WebServlet("/EmployeeDashboardServlet")
public class EmployeeDashboardServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ✅ SECURITY: employee only
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("empid") == null ||
                session.getAttribute("role") == null ||
                !"EMPLOYEE".equalsIgnoreCase(String.valueOf(session.getAttribute("role")))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=" + enc("Please login as employee."));
            return;
        }

        int empId = Integer.parseInt(String.valueOf(session.getAttribute("empid")));
        LocalDate today = LocalDate.now();

        // ✅ calendar month/year from URL (default current)
        int calYear = parseInt(request.getParameter("year"), today.getYear());
        int calMonth = parseInt(request.getParameter("month"), today.getMonthValue());
        if (calMonth < 1) calMonth = 1;
        if (calMonth > 12) calMonth = 12;

        YearMonth ym = YearMonth.of(calYear, calMonth);

        LocalDate monthStart = ym.atDay(1);
        LocalDate monthEnd = ym.atEndOfMonth(); // inclusive

        // ✅ upcoming 6 months window based on displayed month
        LocalDate rangeStart6 = monthStart;
        LocalDate rangeEnd6Exclusive = ym.plusMonths(6).atDay(1);

        Map<LocalDate, List<Map<String, Object>>> monthHolidaysMap = new HashMap<>();
        List<Map<String, Object>> holidayUpcoming6 = new ArrayList<>();
        List<Map<String, Object>> balances = new ArrayList<>();
        Integer unreadNotif = 0;

        String dbError = null;
        String balanceError = null;

        try (Connection con = DatabaseConnection.getConnection()) {

            // =====================================================
            // A) HOLIDAYS for CALENDAR MONTH
            // =====================================================
            String sqlMonth =
                    "SELECT HOLIDAY_ID, HOLIDAY_NAME, HOLIDAY_TYPE, HOLIDAY_DATE " +
                    "FROM HOLIDAYS " +
                    "WHERE TRUNC(HOLIDAY_DATE) >= ? AND TRUNC(HOLIDAY_DATE) <= ? " +
                    "ORDER BY HOLIDAY_DATE ASC";

            try (PreparedStatement ps = con.prepareStatement(sqlMonth)) {
                ps.setDate(1, java.sql.Date.valueOf(monthStart));
                ps.setDate(2, java.sql.Date.valueOf(monthEnd));
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        LocalDate d = rs.getDate("HOLIDAY_DATE").toLocalDate();
                        Map<String, Object> h = new HashMap<>();
                        h.put("id", rs.getInt("HOLIDAY_ID"));
                        h.put("name", rs.getString("HOLIDAY_NAME"));
                        h.put("type", rs.getString("HOLIDAY_TYPE"));
                        h.put("date", d);
                        monthHolidaysMap.computeIfAbsent(d, k -> new ArrayList<>()).add(h);
                    }
                }
            }

            // =====================================================
            // B) HOLIDAYS upcoming 6 months
            // =====================================================
            String sqlUpcoming6 =
                    "SELECT HOLIDAY_ID, HOLIDAY_NAME, HOLIDAY_TYPE, HOLIDAY_DATE " +
                    "FROM HOLIDAYS " +
                    "WHERE TRUNC(HOLIDAY_DATE) >= ? AND TRUNC(HOLIDAY_DATE) < ? " +
                    "ORDER BY HOLIDAY_DATE ASC";

            try (PreparedStatement ps = con.prepareStatement(sqlUpcoming6)) {
                ps.setDate(1, java.sql.Date.valueOf(rangeStart6));
                ps.setDate(2, java.sql.Date.valueOf(rangeEnd6Exclusive));
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        LocalDate d = rs.getDate("HOLIDAY_DATE").toLocalDate();
                        Map<String, Object> h = new HashMap<>();
                        h.put("id", rs.getInt("HOLIDAY_ID"));
                        h.put("name", rs.getString("HOLIDAY_NAME"));
                        h.put("type", rs.getString("HOLIDAY_TYPE"));
                        h.put("date", d);
                        holidayUpcoming6.add(h);
                    }
                }
            }

            // =====================================================
            // C) LEAVE BALANCE (ikut schema kau)
            // USERS.HIREDATE, USERS.GENDER
            // LEAVE_STATUSES.STATUS_CODE
            // =====================================================
            try {
                // 1) employee hire date + gender
                LocalDate hireDate = null;
                String gender = null;

                String empSql = "SELECT HIREDATE, GENDER FROM USERS WHERE EMPID = ?";
                try (PreparedStatement ps = con.prepareStatement(empSql)) {
                    ps.setInt(1, empId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            java.sql.Date hd = rs.getDate("HIREDATE");
                            if (hd != null) hireDate = hd.toLocalDate();
                            gender = rs.getString("GENDER"); // 'M' or 'F'
                        }
                    }
                }
                if (hireDate == null) hireDate = LocalDate.now();

                // 2) load leave types
                class LeaveTypeRow {
                    int id; String code; String desc;
                    LeaveTypeRow(int id, String code, String desc){
                        this.id=id; this.code=code; this.desc=desc;
                    }
                }
                List<LeaveTypeRow> types = new ArrayList<>();
                String typeSql = "SELECT LEAVE_TYPE_ID, TYPE_CODE, DESCRIPTION FROM LEAVE_TYPES ORDER BY TYPE_CODE";
                try (PreparedStatement ps = con.prepareStatement(typeSql);
                     ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        types.add(new LeaveTypeRow(
                                rs.getInt("LEAVE_TYPE_ID"),
                                rs.getString("TYPE_CODE"),
                                rs.getString("DESCRIPTION")
                        ));
                    }
                }

                // 3) used & pending (current year) - join LEAVE_STATUSES + STATUS_CODE
                Map<Integer, Double> usedMap = new HashMap<>();
                Map<Integer, Double> pendingMap = new HashMap<>();

                String aggSql =
                        "SELECT lr.LEAVE_TYPE_ID, " +
                        "  SUM(CASE WHEN UPPER(s.STATUS_CODE) = 'APPROVED' THEN NVL(lr.DURATION_DAYS,0) ELSE 0 END) AS USED_DAYS, " +
                        "  SUM(CASE WHEN UPPER(s.STATUS_CODE) = 'PENDING'  THEN NVL(lr.DURATION_DAYS,0) ELSE 0 END) AS PENDING_DAYS " +
                        "FROM LEAVE_REQUESTS lr " +
                        "JOIN LEAVE_STATUSES s ON s.STATUS_ID = lr.STATUS_ID " +
                        "WHERE lr.EMPID = ? " +
                        "  AND EXTRACT(YEAR FROM lr.START_DATE) = EXTRACT(YEAR FROM SYSDATE) " +
                        "GROUP BY lr.LEAVE_TYPE_ID";

                try (PreparedStatement ps = con.prepareStatement(aggSql)) {
                    ps.setInt(1, empId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            int leaveTypeId = rs.getInt("LEAVE_TYPE_ID");
                            usedMap.put(leaveTypeId, rs.getDouble("USED_DAYS"));
                            pendingMap.put(leaveTypeId, rs.getDouble("PENDING_DAYS"));
                        }
                    }
                }

                // 4) carry forward from LEAVE_BALANCE (column: CARRIED_FWD)
                Map<Integer, Integer> carryMap = new HashMap<>();
                String carrySql =
                        "SELECT LEAVE_TYPE_ID, NVL(CARRIED_FWD,0) AS CARRIED_FWD " +
                        "FROM LEAVE_BALANCE WHERE EMPID = ?";

                try (PreparedStatement ps = con.prepareStatement(carrySql)) {
                    ps.setInt(1, empId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            carryMap.put(rs.getInt("LEAVE_TYPE_ID"), rs.getInt("CARRIED_FWD"));
                        }
                    }
                } catch (SQLException ignore) {
                    // if no rows, carried = 0
                }

                // 5) compute
                for (LeaveTypeRow t : types) {

                    LeaveBalanceEngine.EntitlementResult er =
                            LeaveBalanceEngine.computeEntitlement(t.code, hireDate, gender);

                    int entitlement = er.proratedEntitlement;
                    int carried = carryMap.getOrDefault(t.id, 0);

                    double used = usedMap.getOrDefault(t.id, 0.0);
                    double pending = pendingMap.getOrDefault(t.id, 0.0);

                    double available = LeaveBalanceEngine.availableDays(entitlement, carried, used, pending);

                    Map<String, Object> m = new HashMap<>();
                    m.put("leaveTypeId", t.id);
                    m.put("typeCode", t.code);
                    m.put("desc", t.desc);

                    m.put("entitlement", entitlement);
                    m.put("carriedForward", carried);

                    m.put("used", used);
                    m.put("pending", pending);
                    m.put("total", available);

                    balances.add(m);
                }

            } catch (Exception ex) {
                balanceError = ex.getMessage();
            }

        } catch (Exception e) {
            dbError = e.getMessage();
        }

        request.setAttribute("calYear", calYear);
        request.setAttribute("calMonth", calMonth);
        request.setAttribute("monthHolidaysMap", monthHolidaysMap);
        request.setAttribute("holidayUpcoming", holidayUpcoming6);

        request.setAttribute("balances", balances);
        request.setAttribute("unreadNotif", unreadNotif);

        request.setAttribute("dbError", dbError);
        request.setAttribute("balanceError", balanceError);

        request.getRequestDispatcher("/employeeDashboard.jsp").forward(request, response);
    }

    private int parseInt(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
    }

    private String enc(String s) {
        return java.net.URLEncoder.encode(s, java.nio.charset.StandardCharsets.UTF_8);
    }
}
