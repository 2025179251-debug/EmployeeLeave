import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;

@WebServlet("/EditLeaveServlet")
public class EditLeaveServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("empid") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized");
            return;
        }

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isBlank()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing id");
            return;
        }

        int leaveId;
        try { leaveId = Integer.parseInt(idParam); }
        catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid id");
            return;
        }

        int empId = Integer.parseInt(String.valueOf(session.getAttribute("empid")));

        String sql =
            "SELECT lr.LEAVE_ID, lr.LEAVE_TYPE_ID, lr.START_DATE, lr.END_DATE, lr.DURATION, lr.REASON, ls.STATUS_CODE " +
            "FROM LEAVE_REQUESTS lr " +
            "JOIN LEAVE_STATUSES ls ON lr.STATUS_ID = ls.STATUS_ID " +
            "WHERE lr.LEAVE_ID = ? AND lr.EMPID = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, leaveId);
            ps.setInt(2, empId);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Request not found.");
                    return;
                }

                String status = rs.getString("STATUS_CODE");
                if (status == null || !"PENDING".equalsIgnoreCase(status)) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only PENDING requests can be edited.");
                    return;
                }

                // ✅ normalize duration so it matches your dropdown values
                String duration = normalizeDuration(rs.getString("DURATION"));

                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");

                StringBuilder json = new StringBuilder("{");
                json.append("\"leaveId\":").append(rs.getInt("LEAVE_ID")).append(",");
                json.append("\"leaveTypeId\":").append(rs.getInt("LEAVE_TYPE_ID")).append(",");
                json.append("\"startDate\":\"").append(rs.getDate("START_DATE")).append("\",");
                json.append("\"endDate\":\"").append(rs.getDate("END_DATE")).append("\",");
                json.append("\"duration\":\"").append(esc(duration)).append("\",");
                json.append("\"reason\":\"").append(esc(rs.getString("REASON"))).append("\",");

                // leaveTypes dropdown
                json.append("\"leaveTypes\":[");
                try (Statement st = conn.createStatement();
                     ResultSet rsTypes = st.executeQuery(
                         "SELECT LEAVE_TYPE_ID, TYPE_CODE FROM LEAVE_TYPES ORDER BY TYPE_CODE")) {

                    boolean first = true;
                    while (rsTypes.next()) {
                        if (!first) json.append(",");
                        json.append("{\"value\":").append(rsTypes.getInt("LEAVE_TYPE_ID"))
                            .append(",\"label\":\"").append(esc(rsTypes.getString("TYPE_CODE"))).append("\"}");
                        first = false;
                    }
                }
                json.append("]}");

                response.getWriter().print(json.toString());
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("empid") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=Please+login");
            return;
        }

        int empId = Integer.parseInt(String.valueOf(session.getAttribute("empid")));

        int leaveId = Integer.parseInt(request.getParameter("leaveId"));
        int typeId  = Integer.parseInt(request.getParameter("leaveType"));
        String start = request.getParameter("startDate");
        String end   = request.getParameter("endDate");
        String duration = request.getParameter("duration");
        String reason   = request.getParameter("reason");

        duration = normalizeDuration(duration);

        // ✅ half day rule: end must equal start for AM/PM/legacy HALF_DAY
        if (isHalfDay(duration)) {
            end = start;
        }

        String sql =
            "UPDATE LEAVE_REQUESTS " +
            "SET LEAVE_TYPE_ID=?, START_DATE=?, END_DATE=?, DURATION=?, REASON=? " +
            "WHERE LEAVE_ID=? AND EMPID=? AND STATUS_ID=(" +
            "  SELECT STATUS_ID FROM LEAVE_STATUSES WHERE UPPER(STATUS_CODE)='PENDING'" +
            ")";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, typeId);
            ps.setDate(2, java.sql.Date.valueOf(start));
            ps.setDate(3, java.sql.Date.valueOf(end));
            ps.setString(4, duration);
            ps.setString(5, reason);
            ps.setInt(6, leaveId);
            ps.setInt(7, empId);

            int rows = ps.executeUpdate();
            if (rows > 0) {
                response.sendRedirect(request.getContextPath() + "/LeaveHistoryServlet?msg=Updated+successfully");
            } else {
                response.sendRedirect(request.getContextPath() + "/LeaveHistoryServlet?error=Update+failed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/LeaveHistoryServlet?error=DB+error");
        }
    }

    // ---------- helpers ----------

    private boolean isHalfDay(String d) {
        if (d == null) return false;
        d = d.trim().toUpperCase();
        return d.startsWith("HALF_DAY"); // covers HALF_DAY, HALF_DAY_AM, HALF_DAY_PM
    }

    // Ensure values always match dropdown options
    private String normalizeDuration(String d) {
        if (d == null) return "FULL_DAY";
        d = d.trim().toUpperCase();

        // legacy
        if ("HALF_DAY".equals(d)) return "HALF_DAY_AM";

        // allowed
        if ("FULL_DAY".equals(d) || "HALF_DAY_AM".equals(d) || "HALF_DAY_PM".equals(d)) return d;

        // fallback
        return "FULL_DAY";
    }

    private String esc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "")
                .replace("\n", " ");
    }
}
