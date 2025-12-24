import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet("/CancelLeaveServlet")
public class CancelLeaveServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("empid") == null ||
            session.getAttribute("role") == null ||
            !"EMPLOYEE".equalsIgnoreCase(String.valueOf(session.getAttribute("role")))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=Please+login");
            return;
        }

        int empId = Integer.parseInt(String.valueOf(session.getAttribute("empid")));
        String idParam = request.getParameter("id");
        String actionType = request.getParameter("actionType"); // CANCEL / REQ_CANCEL

        if (idParam == null || idParam.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/LeaveHistoryServlet?error=Missing+leave+id");
            return;
        }

        int leaveId;
        try { leaveId = Integer.parseInt(idParam); }
        catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/LeaveHistoryServlet?error=Invalid+leave+id");
            return;
        }

        if (actionType == null) actionType = "CANCEL";

        try (Connection conn = DatabaseConnection.getConnection()) {

            int affected = 0;

            if ("CANCEL".equalsIgnoreCase(actionType)) {
                // ✅ Delete ONLY if still PENDING and belongs to employee
                String sql =
                    "DELETE FROM LEAVE_REQUESTS " +
                    "WHERE LEAVE_ID=? AND EMPID=? AND STATUS_ID=(" +
                    "  SELECT STATUS_ID FROM LEAVE_STATUSES WHERE UPPER(STATUS_CODE)='PENDING'" +
                    ")";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, leaveId);
                    ps.setInt(2, empId);
                    affected = ps.executeUpdate();
                }

                if (affected == 1) {
                    response.sendRedirect(request.getContextPath() + "/LeaveHistoryServlet?msg=Deleted+successfully");
                } else {
                    response.sendRedirect(request.getContextPath() + "/LeaveHistoryServlet?error=Delete+failed+(not+pending+or+not+yours)");
                }
                return;

            } else if ("REQ_CANCEL".equalsIgnoreCase(actionType)) {
                // ✅ Request cancellation for APPROVED
                // Option 1: if you HAVE a status code 'CANCEL_REQUESTED'
                String sql =
                    "UPDATE LEAVE_REQUESTS " +
                    "SET STATUS_ID=(SELECT STATUS_ID FROM LEAVE_STATUSES WHERE UPPER(STATUS_CODE)='CANCEL_REQUESTED') " +
                    "WHERE LEAVE_ID=? AND EMPID=? AND STATUS_ID=(" +
                    "  SELECT STATUS_ID FROM LEAVE_STATUSES WHERE UPPER(STATUS_CODE)='APPROVED'" +
                    ")";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, leaveId);
                    ps.setInt(2, empId);
                    affected = ps.executeUpdate();
                }

                // If your DB doesn't have CANCEL_REQUESTED, use CANCELLED instead:
                if (affected == 0) {
                    String fallback =
                        "UPDATE LEAVE_REQUESTS " +
                        "SET STATUS_ID=(SELECT STATUS_ID FROM LEAVE_STATUSES WHERE UPPER(STATUS_CODE)='CANCELLED') " +
                        "WHERE LEAVE_ID=? AND EMPID=? AND STATUS_ID=(" +
                        "  SELECT STATUS_ID FROM LEAVE_STATUSES WHERE UPPER(STATUS_CODE)='APPROVED'" +
                        ")";
                    try (PreparedStatement ps2 = conn.prepareStatement(fallback)) {
                        ps2.setInt(1, leaveId);
                        ps2.setInt(2, empId);
                        affected = ps2.executeUpdate();
                    }
                }

                if (affected == 1) {
                    response.sendRedirect(request.getContextPath() + "/LeaveHistoryServlet?msg=Cancellation+requested");
                } else {
                    response.sendRedirect(request.getContextPath() + "/LeaveHistoryServlet?error=Request+cancel+failed+(not+approved+or+not+yours)");
                }
                return;

            } else {
                response.sendRedirect(request.getContextPath() + "/LeaveHistoryServlet?error=Unknown+action");
                return;
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/LeaveHistoryServlet?error=DB+error");
        }
    }
}
