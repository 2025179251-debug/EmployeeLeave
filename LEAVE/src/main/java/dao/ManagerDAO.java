package dao;

import bean.LeaveRecord;
import util.DatabaseConnection;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

/**
 * ManagerDAO handles fetching pending requests and processing manager actions.
 * Optimized with explicit aliasing, case-insensitive type checking, and 
 * transactional auto-cancellation for expired leave requests.
 */
public class ManagerDAO {

	private final SimpleDateFormat sdfDate = new SimpleDateFormat("dd/MM/yyyy");
	private final SimpleDateFormat sdfTime = new SimpleDateFormat("dd/MM/yyyy HH:mm");

	/**
	 * Scans the database for PENDING or CANCELLATION_REQUESTED leave requests 
	 * where the start date has passed by more than 1 day (TRUNC(SYSDATE) > TRUNC(START_DATE) + 1).
	 * If any are found, updates their status to 'CANCELLED' and refunds the leave balances.
	 */
	public void autoCancelExpiredLeaves() throws Exception {
		// 1. Query to locate expired, unprocessed applications
		String selectSql = "SELECT lr.LEAVE_ID, lr.EMPID, lr.LEAVE_TYPE_ID, lr.DURATION_DAYS, ls.STATUS_CODE "
				+ "FROM LEAVE_REQUESTS lr "
				+ "JOIN LEAVE_STATUSES ls ON lr.STATUS_ID = ls.STATUS_ID "
				+ "WHERE ls.STATUS_CODE IN ('PENDING', 'CANCELLATION_REQUESTED') "
				+ "AND TRUNC(SYSDATE) > TRUNC(lr.START_DATE) + 1";

		// 2. Query to transition the status code to CANCELLED (using existing status to avoid ORA errors)
		String updateRequestSql = "UPDATE LEAVE_REQUESTS "
				+ "SET STATUS_ID = (SELECT STATUS_ID FROM LEAVE_STATUSES WHERE STATUS_CODE = 'CANCELLED'), "
				+ "MANAGER_COMMENT = 'SYSTEM AUTO-CANCELLED: EXPIRED' "
				+ "WHERE LEAVE_ID = ?";

		// 3. Balance refund query for expired PENDING applications (Restores PENDING to TOTAL)
		String refundPendingSql = "UPDATE LEAVE_BALANCES "
				+ "SET PENDING = PENDING - ?, TOTAL = TOTAL + ? "
				+ "WHERE EMPID = ? AND LEAVE_TYPE_ID = ?";

		// 4. Balance refund query for expired CANCELLATION_REQUESTED applications (Restores USED to TOTAL)
		String refundCancelSql = "UPDATE LEAVE_BALANCES "
				+ "SET USED = USED - ?, TOTAL = TOTAL + ? "
				+ "WHERE EMPID = ? AND LEAVE_TYPE_ID = ?";

		try (Connection con = DatabaseConnection.getConnection()) {
			con.setAutoCommit(false); // Begin Transaction block
			try {
				List<ExpiredRecord> expiredList = new ArrayList<>();
				try (PreparedStatement ps = con.prepareStatement(selectSql);
						ResultSet rs = ps.executeQuery()) {
					while (rs.next()) {
						ExpiredRecord rec = new ExpiredRecord();
						rec.leaveId = rs.getInt("LEAVE_ID");
						rec.empId = rs.getInt("EMPID");
						rec.leaveTypeId = rs.getInt("LEAVE_TYPE_ID");
						rec.durationDays = rs.getDouble("DURATION_DAYS");
						rec.statusCode = rs.getString("STATUS_CODE");
						expiredList.add(rec);
					}
				}

				for (ExpiredRecord rec : expiredList) {
					// Step A: Update the request status to CANCELLED
					try (PreparedStatement psUpdate = con.prepareStatement(updateRequestSql)) {
						psUpdate.setInt(1, rec.leaveId);
						psUpdate.executeUpdate();
					}

					// Step B: Refund employee leave balance based on original request status
					if ("PENDING".equalsIgnoreCase(rec.statusCode)) {
						try (PreparedStatement psRefund = con.prepareStatement(refundPendingSql)) {
							psRefund.setDouble(1, rec.durationDays);
							psRefund.setDouble(2, rec.durationDays);
							psRefund.setInt(3, rec.empId);
							psRefund.setInt(4, rec.leaveTypeId);
							psRefund.executeUpdate();
						}
					} else if ("CANCELLATION_REQUESTED".equalsIgnoreCase(rec.statusCode)) {
						try (PreparedStatement psRefund = con.prepareStatement(refundCancelSql)) {
							psRefund.setDouble(1, rec.durationDays);
							psRefund.setDouble(2, rec.durationDays);
							psRefund.setInt(3, rec.empId);
							psRefund.setInt(4, rec.leaveTypeId);
							psRefund.executeUpdate();
						}
					}
				}
				con.commit(); // Transaction success: commit all updates safely
			} catch (Exception e) {
				con.rollback(); // Transaction fail: rollback to keep balance integrity
				throw e;
			} finally {
				con.setAutoCommit(true);
			}
		}
	}

	public List<LeaveRecord> getRequestsForReview() throws Exception {
		List<LeaveRecord> list = new ArrayList<>();
		StringBuilder sql = new StringBuilder();

		sql.append("SELECT lr.*, u.FULLNAME, u.EMPID as USER_ID, u.HIREDATE, u.PROFILE_PICTURE, ")
				.append("lt.TYPE_CODE, ls.STATUS_CODE, ")
				// Added explicit aliases for Emergency columns to ensure data retrieval
				.append("e.EMERGENCY_CATEGORY as EMER_CAT, e.EMERGENCY_CONTACT as EMER_CON, ")
				.append("s.MEDICAL_FACILITY as SICK_FAC, s.REF_SERIAL_NO as SICK_REF, ")
				.append("h.HOSPITAL_NAME as HOSP_NAME, h.ADMIT_DATE as HOSP_ADMIT, h.DISCHARGE_DATE as HOSP_DIS, ")
				.append("m.CONSULTATION_CLINIC as MAT_CLINIC, m.EXPECTED_DUE_DATE as MAT_DUE, m.WEEK_PREGNANCY as MAT_WEEK, ")
				.append("p.SPOUSE_NAME as PAT_SPOUSE, p.MEDICAL_FACILITY as PAT_FAC, p.DELIVERY_DATE as PAT_DEL, ")
				.append("(SELECT a.FILE_NAME FROM LEAVE_REQUEST_ATTACHMENTS a WHERE a.LEAVE_ID = lr.LEAVE_ID FETCH FIRST 1 ROW ONLY) AS ATTACHMENT_NAME ")
				.append("FROM LEAVE_REQUESTS lr ").append("JOIN USERS u ON lr.EMPID = u.EMPID ")
				.append("JOIN LEAVE_TYPES lt ON lr.LEAVE_TYPE_ID = lt.LEAVE_TYPE_ID ")
				.append("JOIN LEAVE_STATUSES ls ON lr.STATUS_ID = ls.STATUS_ID ")
				.append("LEFT JOIN LR_EMERGENCY e ON lr.LEAVE_ID = e.LEAVE_ID ")
				.append("LEFT JOIN LR_SICK s ON lr.LEAVE_ID = s.LEAVE_ID ")
				.append("LEFT JOIN LR_HOSPITALIZATION h ON lr.LEAVE_ID = h.LEAVE_ID ")
				.append("LEFT JOIN LR_MATERNITY m ON lr.LEAVE_ID = m.LEAVE_ID ")
				.append("LEFT JOIN LR_PATERNITY p ON lr.LEAVE_ID = p.LEAVE_ID ")
				.append("WHERE ls.STATUS_CODE IN ('PENDING', 'CANCELLATION_REQUESTED') ")
				.append("ORDER BY lr.APPLIED_ON DESC");

		try (Connection con = DatabaseConnection.getConnection();
				PreparedStatement ps = con.prepareStatement(sql.toString());
				ResultSet rs = ps.executeQuery()) {
			while (rs.next()) {
				list.add(mapResultSetToRecord(rs));
			}
		}
		return list;
	}

	private LeaveRecord mapResultSetToRecord(ResultSet rs) throws SQLException {
		LeaveRecord r = new LeaveRecord();
		r.setLeaveId(rs.getInt("LEAVE_ID"));
		r.setEmpId(rs.getInt("USER_ID"));
		r.setFullName(rs.getString("FULLNAME"));
		r.setHireDate(rs.getDate("HIREDATE"));
		r.setProfilePic(rs.getString("PROFILE_PICTURE"));

		String typeCodeRaw = rs.getString("TYPE_CODE");
		r.setTypeCode(typeCodeRaw);
		r.setStatusCode(rs.getString("STATUS_CODE"));
		r.setDurationDays(rs.getDouble("DURATION_DAYS"));
		r.setDuration(rs.getString("DURATION"));
		r.setLeaveTypeId(rs.getString("LEAVE_TYPE_ID"));

		if (rs.getDate("START_DATE") != null)
			r.setStartDate(sdfDate.format(rs.getDate("START_DATE")));
		if (rs.getDate("END_DATE") != null)
			r.setEndDate(sdfDate.format(rs.getDate("END_DATE")));
		if (rs.getTimestamp("APPLIED_ON") != null)
			r.setAppliedOn(sdfTime.format(rs.getTimestamp("APPLIED_ON")));

		r.setReason(rs.getString("REASON"));
		r.setManagerComment(rs.getString("MANAGER_COMMENT"));
		r.setAttachment(rs.getString("ATTACHMENT_NAME"));

		// Crucial: Use toUpperCase() and trim() to ensure the comparison works
		// regardless of DB formatting
		String type = (typeCodeRaw != null) ? typeCodeRaw.trim().toUpperCase() : "";

		if (type.contains("SICK")) {
			r.setMedicalFacility(rs.getString("SICK_FAC"));
			r.setRefSerialNo(rs.getString("SICK_REF"));
		} else if (type.contains("EMERGENCY")) {
			// Updated to use the new EMER_CAT and EMER_CON aliases
			r.setEmergencyCategory(rs.getString("EMER_CAT"));
			r.setEmergencyContact(rs.getString("EMER_CON"));
		} else if (type.contains("HOSPITAL")) {
			r.setMedicalFacility(rs.getString("HOSP_NAME"));
			if (rs.getDate("HOSP_ADMIT") != null)
				r.setEventDate(sdfDate.format(rs.getDate("HOSP_ADMIT")));
			if (rs.getDate("HOSP_DIS") != null)
				r.setDischargeDate(sdfDate.format(rs.getDate("HOSP_DIS")));
		} else if (type.contains("MATERNITY")) {
			r.setMedicalFacility(rs.getString("MAT_CLINIC"));
			if (rs.getDate("MAT_DUE") != null)
				r.setEventDate(sdfDate.format(rs.getDate("MAT_DUE")));
			r.setWeekPregnancy(rs.getInt("MAT_WEEK"));
		} else if (type.contains("PATERNITY")) {
			r.setSpouseName(rs.getString("PAT_SPOUSE"));
			r.setMedicalFacility(rs.getString("PAT_FAC"));
			if (rs.getDate("PAT_DEL") != null)
				r.setEventDate(sdfDate.format(rs.getDate("PAT_DEL")));
		}

		return r;
	}

	public boolean processAction(int leaveId, String action, String comment) throws Exception {
		try (Connection con = DatabaseConnection.getConnection()) {
			con.setAutoCommit(false);
			try {
				int empId = 0, typeId = 0;
				double days = 0;
				try (PreparedStatement ps = con.prepareStatement(
						"SELECT EMPID, LEAVE_TYPE_ID, DURATION_DAYS FROM LEAVE_REQUESTS WHERE LEAVE_ID=?")) {
					ps.setInt(1, leaveId);
					try (ResultSet rs = ps.executeQuery()) {
						if (rs.next()) {
							empId = rs.getInt(1);
							typeId = rs.getInt(2);
							days = rs.getDouble(3);
						} else
							return false;
					}
				}

				String finalStatus = "";
				String balSql = "";

				if ("APPROVE".equals(action)) {
					finalStatus = "APPROVED";
					balSql = "UPDATE LEAVE_BALANCES SET PENDING = PENDING - ?, USED = USED + ? WHERE EMPID = ? AND LEAVE_TYPE_ID = ?";
				} else if ("REJECT".equals(action)) {
					finalStatus = "REJECTED";
					balSql = "UPDATE LEAVE_BALANCES SET PENDING = PENDING - ?, TOTAL = TOTAL + ? WHERE EMPID = ? AND LEAVE_TYPE_ID = ?";
				} else if ("APPROVE_CANCEL".equals(action)) {
					finalStatus = "CANCELLED";
					balSql = "UPDATE LEAVE_BALANCES SET USED = USED - ?, TOTAL = TOTAL + ? WHERE EMPID = ? AND LEAVE_TYPE_ID = ?";
				} else if ("REJECT_CANCEL".equals(action)) {
					finalStatus = "APPROVED";
					balSql = "";
				}

				String updSql = "UPDATE LEAVE_REQUESTS SET STATUS_ID = (SELECT STATUS_ID FROM LEAVE_STATUSES WHERE STATUS_CODE=?), MANAGER_COMMENT=? WHERE LEAVE_ID=?";
				try (PreparedStatement ps = con.prepareStatement(updSql)) {
					ps.setString(1, finalStatus);
					ps.setString(2, comment);
					ps.setInt(3, leaveId);
					ps.executeUpdate();
				}

				if (!balSql.isEmpty()) {
					try (PreparedStatement ps = con.prepareStatement(balSql)) {
						ps.setDouble(1, days);
						ps.setDouble(2, days);
						ps.setInt(3, empId);
						ps.setInt(4, typeId);
						ps.executeUpdate();
					}
				}

				con.commit();
				return true;
			} catch (Exception e) {
				con.rollback();
				throw e;
			} finally {
				con.setAutoCommit(true);
			}
		}
	}

	/**
	 * Helper class to encapsulate expired leave attributes inside 
	 * transactional iterations.
	 */
	private static class ExpiredRecord {
		int leaveId;
		int empId;
		int leaveTypeId;
		double durationDays;
		String statusCode;
	}
}