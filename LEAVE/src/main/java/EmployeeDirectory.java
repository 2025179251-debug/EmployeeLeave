import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/EmployeeDirectory")
public class EmployeeDirectory extends HttpServlet {

	private static final long serialVersionUID = 1L;

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("role") == null
				|| !"ADMIN".equalsIgnoreCase(String.valueOf(session.getAttribute("role")))) {
			response.sendRedirect("login.jsp?error=Please login as admin.");
			return;
		}

		List<Map<String, Object>> users = new ArrayList<>();
		
		// Updated Query: Now includes PROFILE_PICTURE column to load within the detailed profile cards
		String sql = "SELECT EMPID, FULLNAME, EMAIL, ROLE, PHONENO, HIREDATE, STATUS, "
				+ "IC_NUMBER, GENDER, STREET, CITY, POSTAL_CODE, STATE, PROFILE_PICTURE "
				+ "FROM USERS ORDER BY STATUS ASC, FULLNAME ASC";

		try (Connection con = DatabaseConnection.getConnection();
				PreparedStatement ps = con.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {

			while (rs.next()) {
				Map<String, Object> u = new HashMap<>();
				u.put("empid", rs.getInt("EMPID"));
				u.put("fullname", rs.getString("FULLNAME"));
				u.put("email", rs.getString("EMAIL"));
				u.put("role", rs.getString("ROLE"));
				u.put("phone", rs.getString("PHONENO"));
				u.put("hiredate", rs.getDate("HIREDATE"));
				u.put("status", rs.getString("STATUS") != null ? rs.getString("STATUS") : "ACTIVE");
				
				// Secure registration details retrieved using database-aligned column names
				u.put("icNumber", rs.getString("IC_NUMBER"));
				u.put("gender", rs.getString("GENDER"));
				u.put("street", rs.getString("STREET"));
				u.put("city", rs.getString("CITY"));
				u.put("postalCode", rs.getString("POSTAL_CODE"));
				u.put("state", rs.getString("STATE"));
				
				// Extract the Profile Picture URL or Base64 string from the database
				u.put("profilePic", rs.getString("PROFILE_PICTURE"));
				
				users.add(u);
			}
		} catch (Exception e) {
			throw new ServletException("Error loading directory", e);
		}

		request.setAttribute("users", users);
		request.getRequestDispatcher("employeeDirectory.jsp").forward(request, response);
	}
}