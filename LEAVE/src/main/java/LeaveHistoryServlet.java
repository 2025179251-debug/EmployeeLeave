

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;


import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.*;
import java.util.*;

@WebServlet("/LeaveHistoryServlet")
public class LeaveHistoryServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private String enc(String s) {
        return URLEncoder.encode(s, StandardCharsets.UTF_8);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ✅ Security: employee only
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("empid") == null ||
            session.getAttribute("role") == null ||
            !"EMPLOYEE".equalsIgnoreCase(String.valueOf(session.getAttribute("role")))) {
            response.sendRedirect("login.jsp?error=" + enc("Please login as employee."));
            return;
        }

        int empId = Integer.parseInt(String.valueOf(session.getAttribute("empid")));
        String statusFilter = request.getParameter("status"); // ALL / PENDING / APPROVED / REJECTED / CANCELLED
        String yearFilter = request.getParameter("year");     // e.g., 2025

        List<Map<String, Object>> leaves = new ArrayList<>();
        List<String> years = new ArrayList<>();
        String error = null;

        try (Connection conn = DatabaseConnection.getConnection()) {

            // ✅ Fetch distinct years for the filter dropdown
            String yearSql =
                "SELECT DISTINCT EXTRACT(YEAR FROM START_DATE) AS YR " +
                "FROM LEAVE_REQUESTS WHERE EMPID = ? ORDER BY YR DESC";

            try (PreparedStatement psYear = conn.prepareStatement(yearSql)) {
                psYear.setInt(1, empId);
                try (ResultSet rsYear = psYear.executeQuery()) {
                    while (rsYear.next()) {
                        years.add(rsYear.getString("YR"));
                    }
                }
            }

            // ✅ Main query: Get leave details, types, status codes, and attachment filename
            StringBuilder sql = new StringBuilder();
            sql.append(
                "SELECT " +
                "  lr.LEAVE_ID, lr.START_DATE, lr.END_DATE, lr.DURATION, lr.DURATION_DAYS, lr.HALF_SESSION, " +
                "  lr.REASON, lr.APPLIED_ON, lr.ADMIN_COMMENT, " +
                "  lt.TYPE_CODE, " +
                "  ls.STATUS_CODE, " +
                "  (SELECT a.FILE_NAME " +
                "     FROM LEAVE_REQUEST_ATTACHMENTS a " +
                "    WHERE a.LEAVE_ID = lr.LEAVE_ID " +
                "    ORDER BY a.UPLOADED_ON DESC FETCH FIRST 1 ROW ONLY) AS FILE_NAME " +
                "FROM LEAVE_REQUESTS lr " +
                "JOIN LEAVE_TYPES lt ON lr.LEAVE_TYPE_ID = lt.LEAVE_TYPE_ID " +
                "JOIN LEAVE_STATUSES ls ON lr.STATUS_ID = ls.STATUS_ID " +
                "WHERE lr.EMPID = ? "
            );

            if (statusFilter != null && !statusFilter.isBlank() && !"ALL".equalsIgnoreCase(statusFilter)) {
                sql.append(" AND UPPER(ls.STATUS_CODE) = ? ");
            }
            if (yearFilter != null && !yearFilter.isBlank()) {
                sql.append(" AND EXTRACT(YEAR FROM lr.START_DATE) = ? ");
            }

            sql.append(" ORDER BY lr.APPLIED_ON DESC");

            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                int idx = 1;
                ps.setInt(idx++, empId);

                if (statusFilter != null && !statusFilter.isBlank() && !"ALL".equalsIgnoreCase(statusFilter)) {
                    ps.setString(idx++, statusFilter.trim().toUpperCase());
                }
                if (yearFilter != null && !yearFilter.isBlank()) {
                    ps.setInt(idx++, Integer.parseInt(yearFilter));
                }

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        int leaveId = rs.getInt("LEAVE_ID");
                        java.sql.Date sd = rs.getDate("START_DATE");
                        java.sql.Date ed = rs.getDate("END_DATE");
                        String durationType = rs.getString("DURATION"); 
                        double durationDays = rs.getDouble("DURATION_DAYS");
                        String halfSession = rs.getString("HALF_SESSION"); 

                        // ✅ Format Duration display text (e.g., "HALF DAY AM")
                        String durationDisplay;
                        if ("HALF_DAY".equalsIgnoreCase(durationType)) {
                            String sess = (halfSession == null ? "" : (" " + halfSession));
                            durationDisplay = "HALF DAY" + sess;
                        } else {
                            durationDisplay = "FULL DAY";
                        }

                        // ✅ Calculate total days for display (fallback logic included)
                        Double totalDays = durationDays;
                        if (totalDays <= 0) {
                            if (sd != null && ed != null) {
                                long diff = (ed.toLocalDate().toEpochDay() - sd.toLocalDate().toEpochDay()) + 1;
                                totalDays = (double) Math.max(diff, 1);
                            } else {
                                totalDays = 0.0;
                            }
                        }

                        String statusCode = rs.getString("STATUS_CODE");
                        String fileName = rs.getString("FILE_NAME");
                        boolean hasFile = (fileName != null && !fileName.isBlank());

                        // ✅ Build data map for JSP
                        Map<String, Object> l = new HashMap<>();
                        l.put("id", leaveId);
                        l.put("type", rs.getString("TYPE_CODE"));
                        l.put("duration", durationDisplay);
                        l.put("start", sd);
                        l.put("end", ed);
                        l.put("totalDays", totalDays);
                        l.put("statusCode", statusCode);
                        l.put("status", statusCode);
                        l.put("appliedOn", rs.getTimestamp("APPLIED_ON"));
                        l.put("hasFile", hasFile);
                        l.put("fileName", fileName);
                        l.put("reason", rs.getString("REASON"));
                        l.put("adminComment", rs.getString("ADMIN_COMMENT"));

                        leaves.add(l);
                    }
                }
            }

        } catch (Exception e) {
            error = e.getMessage();
        }

        request.setAttribute("leaves", leaves);
        request.setAttribute("years", years);
        request.setAttribute("error", error);

        request.getRequestDispatcher("leaveHistory.jsp").forward(request, response);
    }
}