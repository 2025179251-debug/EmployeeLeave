<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.time.*"%>
<%@ page import="java.time.format.TextStyle"%>
<%@ page import="bean.LeaveRecord"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ include file="icon.jsp"%>

<%! 
    public String CancelRequestIcon(String cls) {
        return "<svg class='" + cls + "' xmlns='http://www.w3.org/2000/svg' fill='none' stroke='currentColor' stroke-width='2' viewBox='0 0 24 24'><path d='M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z'/><polyline points='14 2 14 8 20 8'/><path d='m9.5 13.5 5 5'/><path d='m14.5 13.5-5 5'/></svg>";
    }
%>

<%
    // MANAGER GUARD
    HttpSession ses = request.getSession(false);
    if (ses == null || ses.getAttribute("empid") == null || !"MANAGER".equalsIgnoreCase(String.valueOf(ses.getAttribute("role")))) {
        response.sendRedirect("login.jsp?error=AccessDenied"); return;
    }

    // DATA RETRIEVAL
    List<LeaveRecord> allLeaves = (List<LeaveRecord>) request.getAttribute("leaves");
    if (allLeaves == null) allLeaves = new ArrayList<>();
    
    // FILTER LOGIC
    String filterStatus = request.getParameter("status");
    if (filterStatus != null && !filterStatus.isEmpty()) {
        List<LeaveRecord> filtered = new ArrayList<>();
        for (LeaveRecord r : allLeaves) {
            if (filterStatus.equalsIgnoreCase(r.getStatusCode())) {
                filtered.add(r);
            }
        }
        allLeaves = filtered;
    }

    Integer pendingCount = (Integer) request.getAttribute("pendingCount") != null ? (Integer) request.getAttribute("pendingCount") : 0;
    Integer cancelReqCount = (Integer) request.getAttribute("cancelReqCount") != null ? (Integer) request.getAttribute("cancelReqCount") : 0;
    
    String msg = request.getParameter("msg");
    String error = request.getParameter("error");

    // PAGINATION LOGIC
    int pageSize = 10;
    int totalRecords = allLeaves.size();
    int currentPage = 1;
    try {
        if(request.getParameter("page") != null) currentPage = Integer.parseInt(request.getParameter("page"));
    } catch(NumberFormatException e) { currentPage = 1; }

    int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
    if (currentPage > totalPages && totalPages > 0) currentPage = totalPages;
    if (currentPage < 1) currentPage = 1;
    
    int startIndex = (currentPage - 1) * pageSize;
    int endIndex = Math.min(startIndex + pageSize, totalRecords);
    
    List<LeaveRecord> leaves = new ArrayList<>();
    if (!allLeaves.isEmpty() && startIndex < totalRecords) {
        leaves = allLeaves.subList(startIndex, endIndex);
    }
    
    Calendar cal = Calendar.getInstance();
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Manager | Review Applications</title>
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<script src="https://cdn.tailwindcss.com"></script>
<link
	href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap"
	rel="stylesheet">

<style>
:root {
	--bg: #f8fafc;
	--card: #fff;
	--border: #cbd5e1;
	--text: #1e293b;
	--muted: #64748b;
	--blue-primary: #2563eb;
	--radius: 20px;
	--shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1);
}

* {
	box-sizing: border-box;
	font-family: 'Inter', sans-serif;
}

.fas, .fab, .far, .fa-solid, .fa {
	font-family: "Font Awesome 6 Free" !important;
	font-weight: 900;
}

body {
	background: var(--bg);
	color: var(--text);
	margin: 0;
}

.pageWrap {
	padding: 32px 40px;
	max-width: 1300px;
	margin: 0 auto;
}

.title {
	font-size: 26px;
	font-weight: 800;
	margin: 0;
	text-transform: uppercase;
	color: var(--text);
}

.sub-label {
	color: var(--blue-primary);
	font-size: 11px;
	font-weight: 800;
	text-transform: uppercase;
	letter-spacing: 0.1em;
	margin-top: 4px;
	display: block;
}

.stat-card {
	background: var(--card);
	border: 1px solid var(--border);
	border-radius: 16px;
	padding: 18px 24px;
	display: flex;
	align-items: center;
	justify-content: space-between;
	border-left: 5px solid var(--blue-primary);
	box-shadow: var(--shadow);
	transition: all 0.2s;
	cursor: pointer;
	text-decoration: none;
}

.stat-card:hover {
	transform: translateY(-2px);
	border-color: var(--blue-primary);
}

.stat-card.orange {
	border-left-color: #f97316;
}

.stat-card.active {
	outline: 2px solid var(--blue-primary);
	outline-offset: 2px;
}

select {
	height: 45px !important;
	padding: 10px !important;
	width: 100%;
	border-radius: 12px;
	border: 1px solid var(--border);
	outline: none;
	font-size: 13px;
	font-weight: 600;
	background: #fff;
	transition: all 0.2s;
	cursor: pointer;
}

select:focus {
	border-color: var(--blue-primary);
	box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.08);
}

.card {
	background: var(--card);
	border: 1px solid var(--border);
	border-radius: var(--radius);
	box-shadow: var(--shadow);
	overflow: hidden;
}

/* FIXED TABLE LAYOUT FOR CONSISTENT SIZING */
table {
	width: 100%;
	border-collapse: collapse;
	table-layout: fixed;
}

th, td {
	border-bottom: 1px solid #f1f5f9;
	padding: 18px 15px;
	text-align: left;
	vertical-align: middle;
}

th {
	background: #f8fafc;
	font-size: 11px;
	text-transform: uppercase;
	color: var(--muted);
	font-weight: 800;
	letter-spacing: 0.05em;
}

/* Optimized Column Widths */
.col-emp {
	width: 30%;
}

.col-type {
	width: 17%;
}

.col-dates {
	width: 14%;
}

.col-days {
	width: 11%;
	text-align: center;
}

.col-status {
	width: 15%;
}

.col-action {
	width: 18%;
	text-align: center;
}

.badge {
	padding: 4px 12px;
	border-radius: 20px;
	font-size: 10px;
	font-weight: 800;
	text-transform: uppercase;
	display: inline-flex;
	align-items: center;
	gap: 6px;
}

.status-pending {
	background: #fffbeb;
	color: #b45309;
	border: 1px solid #fde68a;
}

.status-cancellation-requested {
	background: #fff7ed;
	color: #c2410c;
	border: 1px solid #fdba74;
}

.pagination-btn {
	padding: 8px 14px;
	border-radius: 10px;
	border: 1px solid var(--border);
	font-size: 12px;
	font-weight: 800;
	transition: 0.2s;
	color: var(--muted);
	background: white;
}

.pagination-btn.active {
	background: var(--blue-primary);
	color: #fff;
	border-color: var(--blue-primary);
}

.modal-overlay {
	position: fixed;
	inset: 0;
	background: rgba(15, 23, 42, 0.6);
	display: none;
	align-items: center;
	justify-content: center;
	z-index: 9999;
	backdrop-filter: blur(4px);
	padding: 20px;
}

.modal-overlay.show {
	display: flex;
}

.modal-content {
	background: white;
	width: 100%;
	max-width: 750px;
	max-height: 90vh;
	border-radius: 32px;
	padding: 40px;
	position: relative;
	box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
	display: flex;
	flex-direction: column;
	overflow: hidden;
	animation: slideUp 0.3s ease;
}

@
keyframes slideUp {
	from {opacity: 0;
	transform: translateY(20px);
}

to {
	opacity: 1;
	transform: translateY(0);
}

}
.modal-body {
	overflow-y: auto;
	padding-right: 8px;
	flex: 1;
}

.info-label {
	font-size: 10px;
	font-weight: 800;
	color: #94a3b8;
	text-transform: uppercase;
	display: block;
	margin-bottom: 4px;
	letter-spacing: 0.05em;
}

.info-value {
	font-size: 14px;
	font-weight: 700;
	color: #1e293b;
	display: block;
	margin-bottom: 18px;
}

.btn-close {
	position: absolute;
	top: 24px;
	right: 24px;
	width: 40px;
	height: 40px;
	border-radius: 12px;
	border: 1px solid var(--border);
	background: #fff;
	cursor: pointer;
	display: flex;
	align-items: center;
	justify-content: center;
	color: #94a3b8;
	transition: 0.2s;
	z-index: 10;
}

.decision-box {
	background: #f8fafc;
	border: 1px solid var(--border);
	border-radius: 24px;
	padding: 20px;
	margin-top: 24px;
}

/* FIX TEXTAREA PADDING: Text won't touch border anymore */
textarea {
	width: 100%;
	padding: 10px !important;
	border-radius: 12px;
	border: 1px solid var(--border);
	outline: none;
	font-size: 14px;
	font-weight: 600;
	background: #fff;
	min-height: 120px;
	display: block;
	line-height: 1.6;
}

.button-group {
	display: flex;
	gap: 12px;
	width: 100%;
	margin-top: 24px;
}

.btn-cancel {
	width: 140px;
	background: #f1f5f9;
	color: #64748b;
	padding: 16px;
	border-radius: 14px;
	font-weight: 800;
	text-transform: uppercase;
	cursor: pointer;
	font-size: 12px;
	display: flex;
	align-items: center;
	justify-content: center;
	gap: 10px;
	transition: 0.2s;
	border: none;
}

.btn-submit {
	flex: 1;
	background: var(--blue-primary);
	color: white;
	padding: 16px;
	border-radius: 14px;
	font-weight: 800;
	text-transform: uppercase;
	cursor: pointer;
	border: none;
	font-size: 13px;
	display: flex;
	align-items: center;
	justify-content: center;
	gap: 10px;
	transition: 0.2s;
	letter-spacing: 0.1em;
}

.btn-submit:hover {
	opacity: 0.9;
	transform: translateY(-1px);
}

.btn-cancel:hover {
	background: #e2e8f0;
	color: #0f172a;
}

.dynamic-meta-container {
	background: #f8fafc;
	border: 1px solid var(--border);
	border-radius: 16px;
	padding: 20px;
	margin-top: 10px;
	margin-bottom: 10px;
}
</style>
</head>
<body>

	<div class="flex">
		<jsp:include page="sidebar.jsp" />

		<main
			class="ml-20 lg:ml-64 min-h-screen w-full transition-all duration-300">
			<jsp:include page="topbar.jsp" />

			<div class="pageWrap">
				<div class="flex justify-between items-end mb-8">
					<div>
						<h2 class="title">REVIEW APPLICATIONS</h2>
						<span class="sub-label">Manage pending staff absences and
							evaluate cancellation appeals</span>
					</div>
					<% if (filterStatus != null) { %>
					<a href="?page=1"
						class="text-[10px] font-black text-blue-600 hover:text-blue-800 uppercase tracking-widest bg-blue-50 px-4 py-2 rounded-lg border border-blue-100 flex items-center gap-2 transition-all">
						<i class="fas fa-filter-circle-xmark"></i> Show All Status
					</a>
					<% } %>
				</div>

				<%-- Alerts --%>
				<% if (msg != null) { %>
				<div id="statusAlert"
					class="bg-emerald-50 border-2 border-emerald-100 text-emerald-700 p-5 rounded-2xl mb-8 flex items-center gap-4 font-black text-sm transition-all duration-500">
					<i class="fas fa-check-circle text-lg"></i>
					<%= msg %>
				</div>
				<% } %>
				<% if (error != null) { %>
				<div id="statusAlert"
					class="bg-red-50 border-2 border-red-100 text-red-700 p-5 rounded-2xl mb-8 flex items-center gap-4 font-black text-sm transition-all duration-500">
					<i class="fas fa-exclamation-circle text-lg"></i>
					<%= error %>
				</div>
				<% } %>

				<div class="grid grid-cols-1 md:grid-cols-2 gap-x-10 mb-8">
					<a href="?status=PENDING"
						class="stat-card flex justify-between items-center <%= "PENDING".equalsIgnoreCase(filterStatus) ? "active" : "" %>">
						<div>
							<span class="info-label">Pending Approval</span>
							<div class="text-2xl font-black text-slate-800 mt-1"><%= pendingCount %></div>
						</div>
						<div class="bg-blue-50 p-3 rounded-2xl text-blue-600">
							<%= ClipboardListIcon("w-6 h-6") %>
						</div>
					</a> <a href="?status=CANCELLATION_REQUESTED"
						class="stat-card orange flex justify-between items-center <%= "CANCELLATION_REQUESTED".equalsIgnoreCase(filterStatus) ? "active" : "" %>">
						<div>
							<span class="info-label">Cancellation Requested</span>
							<div class="text-2xl font-black text-slate-800 mt-1"><%= cancelReqCount %></div>
						</div>
						<div class="bg-orange-50 p-3 rounded-2xl text-orange-600">
							<%= CancelRequestIcon("w-6 h-6") %>
						</div>
					</a>
				</div>


				<div class="card">
					<div class="overflow-x-auto">
						<table style="min-width: 900px;">
							<thead>
								<tr>
									<th class="col-emp">Employee</th>
									<th class="col-type">Type</th>
									<th class="col-dates">Dates</th>
									<th class="col-days">Days</th>
									<th class="col-status">Status</th>
									<th class="col-action">Action</th>
								</tr>
							</thead>
							<tbody>
								<% if (leaves.isEmpty()) { %>
								<tr>
									<td colspan="6"
										class="text-center py-24 text-slate-300 font-bold uppercase text-xs italic tracking-widest">No
										pending applications found.</td>
								</tr>
								<% } else { for (LeaveRecord r : leaves) { 
                                String status = r.getStatusCode();
                                boolean isCancel = "CANCELLATION_REQUESTED".equalsIgnoreCase(status);
                                String badgeClass = isCancel ? "status-cancellation-requested" : "status-pending";
                                String joinYear = (r.getHireDate() != null) ? String.valueOf(LocalDate.parse(r.getHireDate().toString()).getYear()) : "0000";
                                String displayEmpId = "EMP-" + joinYear + "-" + String.format("%02d", r.getEmpId());
                            %>
								<tr class="hover:bg-slate-50/50 transition-colors">
									<td class="col-emp">
										<div class="flex items-center gap-3">
											<div
												class="w-10 h-10 rounded-lg bg-slate-100 overflow-hidden flex-shrink-0 border border-slate-200 flex items-center justify-center">
												<% if (r.getProfilePic() != null && !r.getProfilePic().isEmpty()) { %>
												<img
													src="<%= request.getContextPath() + "/" + r.getProfilePic() %>"
													class="w-full h-full object-cover">
												<% } else { %>
												<div class="text-slate-400 font-bold text-xs uppercase"><%= (r.getFullName() != null) ? r.getFullName().substring(0,1) : "?" %></div>
												<% } %>
											</div>
											<%-- Name allowed to wrap into multiple lines --%>
											<div class="overflow-hidden">
												<div
													class="font-bold text-slate-800 text-sm uppercase pr-2 leading-tight break-words"><%= r.getFullName() %></div>
												<div
													class="text-[10px] text-blue-600 font-bold uppercase tracking-tighter mt-1"><%= displayEmpId %></div>
											</div>
										</div>
									</td>
									<td class="col-type"><span
										class="bg-slate-100 text-slate-500 px-3 py-1 rounded-lg text-[12px] font-black uppercase border border-slate-200"><%= r.getTypeCode() %></span></td>
									<%-- Compact dates stacking vertically centered as per image_9b979a.png --%>
									<td class="col-dates">
										<div
											class="flex flex-col items-center justify-center text-center">
											<span
												class="text-[12px] text-slate-700 font-bold uppercase tracking-tight"><%= r.getStartDate() %></span>
											<span
												class="text-[10px] text-slate-700 font-bold uppercase tracking-tight py-0.5">to</span>
											<span
												class="text-[12px] text-slate-700 font-bold uppercase tracking-tight"><%= r.getEndDate() %></span>
										</div>
									</td>
									<td class="col-days font-bold text-slate-800 text-sm"><%= r.getDurationDays() %></td>
									<td class="col-status"><span
										class="badge <%= badgeClass %>"> <span
											class="w-1.5 h-1.5 rounded-full bg-current"></span> <%= status.replace("_", " ") %>
									</span></td>
									<td class="col-action">
										<button onclick="viewDetails(this)"
											class="bg-white border border-slate-200 text-slate-600 px-4 py-2 rounded-xl text-[10px] font-black hover:bg-slate-900 hover:text-white transition-all uppercase tracking-widest shadow-sm flex items-center gap-2 ml-auto"
											data-id="<%= r.getLeaveId() %>"
											data-name="<%= r.getFullName() %>"
											data-idcode="<%= displayEmpId %>"
											data-type="<%= r.getTypeCode() %>"
											data-start="<%= r.getStartDate() %>"
											data-end="<%= r.getEndDate() %>"
											data-days="<%= r.getDurationDays() %>"
											data-duration="<%= r.getDuration() %>"
											data-applied="<%= r.getAppliedOn() %>"
											data-reason="<%= (r.getReason() != null) ? r.getReason() : "" %>"
											data-status="<%= status %>"
											data-attachment="<%= r.getAttachment() != null ? r.getAttachment() : "" %>"
											data-med="<%= r.getMedicalFacility() %>"
											data-ref="<%= r.getRefSerialNo() %>"
											data-pre="<%= r.getWeekPregnancy() %>"
											data-evt="<%= r.getEventDate() %>"
											data-dis="<%= r.getDischargeDate() %>"
											data-cat="<%= r.getEmergencyCategory() %>"
											data-cnt="<%= r.getEmergencyContact() %>"
											data-spo="<%= r.getSpouseName() %>"
											data-comment="<%= r.getManagerComment() != null ? r.getManagerComment() : "-" %>">
											<%= EyeIcon("w-3.5 h-3.5") %>
											Review
										</button>
									</td>
								</tr>
								<% } } %>
							</tbody>
						</table>
					</div>

					<!-- PAGINATION FOOTER -->
					<div
						class="px-6 py-5 bg-slate-50 border-t border-slate-100 flex items-center justify-between">
						<div
							class="text-[11px] font-bold text-slate-400 uppercase tracking-widest">
							Showing
							<%= totalRecords == 0 ? 0 : startIndex + 1 %>
							to
							<%= endIndex %>
							of
							<%= totalRecords %>
							entries
						</div>
						<% if (totalPages > 1) { %>
						<div class="flex items-center gap-2">
							<button type="button" class="pagination-btn"
								onclick="goToPage(<%= currentPage - 1 %>)"
								<%= currentPage == 1 ? "disabled" : "" %>>
								<i class="fas fa-chevron-left"></i>
							</button>
							<% for(int p=1; p<=totalPages; p++) { %>
							<button type="button"
								class="pagination-btn <%= p == currentPage ? "active" : "" %>"
								onclick="goToPage(<%= p %>)"><%= p %></button>
							<% } %>
							<button type="button" class="pagination-btn"
								onclick="goToPage(<%= currentPage + 1 %>)"
								<%= currentPage == totalPages ? "disabled" : "" %>>
								<i class="fas fa-chevron-right"></i>
							</button>
						</div>
						<% } %>
					</div>
				</div>
			</div>
		</main>
	</div>

	<!-- POPUP MODAL -->
	<div class="modal-overlay" id="detailModal">
		<div class="modal-content">
			<button type="button" class="btn-close" onclick="closeModal()">
				<i class="fas fa-times"></i>
			</button>
			<div class="modal-body">
				<h3
					class="text-2xl font-black text-slate-800 tracking-tight uppercase mb-8 pr-12 border-b border-slate-100 pb-4">Application
					Details</h3>

				<div class="grid grid-cols-1 md:grid-cols-2 gap-x-12">
					<div class="info-item">
						<span class="info-label">Staff Name</span> <span
							class="info-value" id="popName"></span>
					</div>
					<div class="info-item">
						<span class="info-label">Staff ID</span> <span class="info-value"
							id="popId"></span>
					</div>
				</div>

				<div class="info-item">
					<span class="info-label">Leave Category</span> <span
						class="info-value text-blue-600 mb-0" id="popType"></span>
				</div>

				<div class="grid grid-cols-1 md:grid-cols-2 gap-x-12 mt-4">
					<div class="info-item">
						<span class="info-label">Start Date</span><span class="info-value"
							id="popStart"></span>
					</div>
					<div class="info-item">
						<span class="info-label">End Date</span><span class="info-value"
							id="popEnd"></span>
					</div>
				</div>

				<div class="grid grid-cols-1 md:grid-cols-2 gap-x-12">
					<div class="info-item">
						<span class="info-label">Duration Type</span><span
							class="info-value uppercase" id="popDuration"></span>
					</div>
					<div class="info-item">
						<span class="info-label">Total Days</span><span
							class="info-value font-black text-blue-600" id="popDays"></span>
					</div>
				</div>

				<div class="grid grid-cols-1 md:grid-cols-2 gap-x-12">
					<div class="info-item">
						<span class="info-label">Submission Date</span><span
							class="info-value" id="popApplied"></span>
					</div>
					<div class="info-item">
						<span class="info-label">Supportive Attachment</span>
						<div id="attachBox" class="hidden">
							<a id="modalAttachLink" href="#" target="_blank"
								class="inline-flex items-center gap-3 bg-white border-2 border-slate-100 px-5 py-3 rounded-2xl text-[11px] font-black text-slate-600 hover:border-blue-200 hover:text-blue-600 transition-all">
								<i class="fas fa-file-medical text-red-500 text-lg"></i> VIEW
								DOCUMENT <i
								class="fas fa-external-link-alt opacity-20 text-[9px]"></i>
							</a>
						</div>
						<div id="noAttachLabel"
							class="text-xs text-slate-300 font-bold italic py-2">No
							document attached</div>
					</div>
				</div>

				<div class="info-item">
					<span class="info-label">Employee Reason</span>
					<p
						class="text-sm text-slate-500 mb-6 bg-slate-50 p-5 rounded-2xl border border-slate-100 font-medium italic"
						id="popReason"></p>
				</div>

				<div id="dynamicBox" class="hidden">
					<div class="flex items-center gap-3 mb-4">
						<div class="w-1 h-4 bg-blue-600 rounded-full"></div>
						<h4
							class="text-[11px] font-black text-slate-400 uppercase tracking-widest">Additional
							Information</h4>
					</div>
					<div class="dynamic-meta-container space-y-4" id="dynamicGrid"></div>
				</div>

				<!-- Decision Form -->
				<form id="decisionForm" action="ReviewLeave" method="post"
					class="decision-box">
					<input type="hidden" name="leaveId" id="formLeaveId">
					<div class="flex items-center gap-3 mb-6">
						<i class="fas fa-gavel text-blue-600"></i>
						<h4
							class="text-[11px] font-black text-blue-600 uppercase tracking-widest">Decision
							Console</h4>
					</div>

					<div class="grid grid-cols-1 gap-8">
						<div>
							<span class="info-label">Select Action</span> <select
								name="action" id="decisionSelect" class="mt-3" required></select>
						</div>
						<div>
							<span class="info-label">Decision Remark</span>
							<textarea name="comment" rows="3" class="mt-3"
								placeholder="State reason for your decision"></textarea>
						</div>
					</div>

					<div class="button-group">
						<!-- Cancel Button on Left (Small) -->
						<button type="button" class="btn-cancel" onclick="closeModal()">
							<i class="fas fa-times-circle"></i> Cancel
						</button>
						<!-- Confirm Button on Right (Longer) -->
						<button type="submit" class="btn-submit">
							<i class="fas fa-check-circle"></i> Confirm Decision
						</button>
					</div>
				</form>
			</div>
		</div>
	</div>

	<script>
    const CTX = "<%=request.getContextPath()%>";

    window.onload = function() {
        const msg = document.getElementById('statusAlert');
        if (msg) {
            setTimeout(() => {
                msg.style.opacity = '0';
                setTimeout(() => msg.remove(), 500);
            }, 3000);
        }
    };

    function goToPage(pageNum) {
        const urlParams = new URLSearchParams(window.location.search);
        urlParams.set('page', pageNum);
        window.location.search = urlParams.toString();
    }

    function viewDetails(btn) {
        const d = btn.dataset;
        document.getElementById('popName').textContent = d.name;
        document.getElementById('popId').textContent = d.idcode;
        document.getElementById('popType').textContent = d.type;
        document.getElementById('popStart').textContent = d.start;
        document.getElementById('popEnd').textContent = d.end;
        document.getElementById('popDuration').textContent = d.duration.replace(/_/g, ' ');
        document.getElementById('popDays').textContent = d.days;
        document.getElementById('popApplied').textContent = d.applied;
        document.getElementById('popReason').textContent = d.reason || "No reason provided.";
        document.getElementById('formLeaveId').value = d.id;

        const sel = document.getElementById('decisionSelect');
        if (d.status === "CANCELLATION_REQUESTED") {
            sel.innerHTML = '<option value="APPROVE_CANCEL">Approve Cancellation</option><option value="REJECT_CANCEL">Maintain Leave (Reject Request)</option>';
        } else {
            sel.innerHTML = '<option value="APPROVE">Approve Request</option><option value="REJECT">Reject Request</option>';
        }

        const abox = document.getElementById('attachBox');
        const noAttach = document.getElementById('noAttachLabel');
        if(d.attachment && d.attachment !== "" && d.attachment !== "null") {
            abox.classList.remove('hidden');
            noAttach.classList.add('hidden');
            document.getElementById('modalAttachLink').href = CTX + "/ViewAttachment?id=" + d.id;
        } else { 
            abox.classList.add('hidden'); 
            noAttach.classList.remove('hidden');
        }

        const grid = document.getElementById('dynamicGrid');
        grid.innerHTML = "";
        let count = 0;
        
        const addAttr = (label, val) => {
            if(val && val !== "null" && val !== "" && val !== "undefined" && val !== "N/A" && val !== "0") {
                grid.innerHTML += '<div class="info-item border-b border-slate-100 pb-2 flex justify-between items-center"><span class="info-label text-slate-400 mb-0 font-bold uppercase" style="font-size:12px;">' + label + '</span><span class="info-value mb-0 text-slate-600 font-bold uppercase" style="font-size:14px;">' + val + '</span></div>';
                count++;
            }
        };

        const code = (d.type || "").toUpperCase();
        if (code.includes("SICK")) { 
            addAttr("Clinic Name", d.med); 
            addAttr("MC Serial No", d.ref); 
        } else if (code.includes("HOSPITAL")) { 
            addAttr("Hospital Name", d.med); 
            addAttr("Admit Date", d.evt); 
            addAttr("Discharge Date", d.dis); 
        } else if (code.includes("MATERNITY")) { 
            addAttr("Consulation Clinic", d.med); 
            addAttr("Expected Due Date", d.evt); 
            addAttr("Week Pregenancy", d.pre); 
        } else if (code.includes("PATERNITY")) { 
            addAttr("Spouse Name", d.spo); 
            addAttr("Medical Location", d.med); 
            addAttr("Date of Birth", d.evt); 
        } else if (code.includes("EMERGENCY")) { 
            addAttr("Emergency Category", d.cat); 
            addAttr("Emergency Contact", d.cnt); 
        }

        document.getElementById('dynamicBox').classList.toggle('hidden', count === 0);
        document.getElementById('detailModal').classList.add('show');
    }
    
    function closeModal() { document.getElementById('detailModal').classList.remove('show'); }
    window.onclick = (e) => { if (e.target == document.getElementById('detailModal')) closeModal(); }
</script>

</body>
</html>