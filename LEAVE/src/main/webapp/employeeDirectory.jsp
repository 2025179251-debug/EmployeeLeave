<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ include file="icon.jsp"%>

<%
    if (session.getAttribute("empid") == null ||
        session.getAttribute("role") == null ||
        !"ADMIN".equalsIgnoreCase(String.valueOf(session.getAttribute("role")))) {
        response.sendRedirect("login.jsp?error=Please login as admin.");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Employee Directory | Admin Access</title>

<script src="https://cdn.tailwindcss.com"></script>
<link
	href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap"
	rel="stylesheet">

<style>
:root {
	--bg: #f1f5f9;
	--card: #fff;
	--border: #cbd5e1;
	--text: #1e293b;
	--muted: #64748b;
	--blue-primary: #2563eb;
	--blue-light: #eff6ff;
	--red: #ef4444;
	--green: #10b981;
	--shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1);
	--radius: 16px;
}

* {
	box-sizing: border-box;
	font-family: 'Inter', sans-serif !important;
}

body {
	background: var(--bg);
	color: var(--text);
	margin: 0;
}

.pageWrap {
	padding: 32px 40px;
	max-width: 1240px;
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

.card {
	background: var(--card);
	border: 1px solid var(--border);
	border-radius: var(--radius);
	box-shadow: var(--shadow);
	overflow: hidden;
}

.cardHead {
	padding: 20px 24px;
	border-bottom: 1px solid #f1f5f9;
	display: flex;
	justify-content: space-between;
	align-items: center;
}

.cardHead span {
	font-weight: 800;
	font-size: 15px;
	color: var(--text);
	text-transform: uppercase;
}

table {
	width: 100%;
	border-collapse: collapse;
}

th, td {
	border-bottom: 1px solid #f1f5f9;
	padding: 18px 24px;
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

.row-inactive {
	background-color: #f8fafc;
	opacity: 0.6;
	filter: grayscale(1);
}

.badge {
	padding: 4px 10px;
	border-radius: 8px;
	font-size: 10px;
	font-weight: 800;
	text-transform: uppercase;
	border: 1px solid transparent;
}

.badge-admin {
	background: #eff6ff;
	color: var(--blue-primary);
	border-color: #dbeafe;
}

.badge-active {
	background: #ecfdf5;
	color: var(--green);
	border-color: #d1fae5;
}

.badge-inactive {
	background: #fef2f2;
	color: var(--red);
	border-color: #fee2e2;
}

.btnAction {
	font-weight: 800;
	font-size: 11px;
	padding: 8px 16px;
	border-radius: 8px;
	cursor: pointer;
	transition: 0.2s;
	text-transform: uppercase;
	display: inline-flex;
	align-items: center;
	gap: 6px;
	border: 1px solid transparent;
}

.btnDeactivate {
	color: var(--red);
	border-color: #fee2e2;
	background: #fff;
}

.btnDeactivate:hover {
	background: var(--red);
	color: #fff;
	border-color: var(--red);
}

.btnActivate {
	color: var(--green);
	border-color: #d1fae5;
	background: #fff;
}

.btnActivate:hover {
	background: var(--green);
	color: #fff;
	border-color: var(--green);
}

.modal-overlay {
	position: fixed;
	top: 0;
	left: 0;
	width: 100%;
	height: 100%;
	background: rgba(15, 23, 42, 0.6);
	backdrop-filter: blur(4px);
	display: none;
	align-items: center;
	justify-content: center;
	z-index: 1000;
}

.modal-content {
	background: white;
	width: 400px;
	border-radius: 16px;
	padding: 32px;
	box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
	text-align: center;
}

/* ✅ RESOLVED SPECIFICATION FOR THE MODAL STRUCTURE AND ROUNDED RADIUS */
.detail-modal-content {
	background: white;
	width: 100%;
	max-width: 750px;
	max-height: 90vh;
	border-radius: 32px;
	box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.3);
	overflow: hidden;
	display: flex;
	flex-direction: column;
	position: relative;
	animation: slideUp 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.modal-active {
	display: flex;
}

.msg-fade {
	transition: opacity 0.5s ease, transform 0.5s ease;
	opacity: 1;
}

.msg-hidden {
	opacity: 0;
	transform: translateY(-10px);
	pointer-events: none;
}

.btn-cancel {
	background: #f1f5f9;
	color: #475569;
}

.btn-cancel:hover {
	background: #e2e8f0;
}

@keyframes slideUp {
	from {
		opacity: 0;
		transform: translateY(30px);
	}
	to {
		opacity: 1;
		transform: translateY(0);
	}
}
</style>
</head>

<body class="flex">
	<jsp:include page="sidebar.jsp" />

	<main
		class="flex-1 ml-20 lg:ml-64 min-h-screen transition-all duration-300">
		<jsp:include page="topbar.jsp" />

		<div class="pageWrap">
            <!-- Header section with new Registration Button -->
			<div class="flex justify-between items-center mb-8">
				<div>
					<h2 class="title">Employee Directory</h2>
					<span class="sub-label">List of employee record account permissions and status</span>
				</div>
                <a href="RegisterEmployee" class="bg-blue-600 text-white px-6 py-3.5 rounded-2xl font-bold text-xs uppercase hover:bg-blue-700 transition-all flex items-center gap-3 shadow-lg hover:shadow-blue-200 active:scale-95 transform">
                    <%= PlusIcon("w-4 h-4") %> Register New Employee
                </a>
			</div>

			<c:if test="${not empty param.msg}">
				<div id="statusMsg"
					class="msg-fade bg-emerald-50 border border-emerald-100 p-4 rounded-xl text-emerald-700 font-bold mb-6 flex items-center gap-2 shadow-sm">
					<%= CheckCircleIcon("w-5 h-5") %>
					${param.msg}
				</div>
			</c:if>

			<div class="card">
				<div class="cardHead">
					<span>Staff Records</span>
					<%= BriefcaseIcon("w-6 h-6 text-blue-200") %>
				</div>

				<div class="overflow-x-auto">
					<table>
						<thead>
							<tr>
								<th>Staff Profile</th>
								<th>Contact & Access</th>
								<th>Join Date</th>
								<th style="text-align: center;">Status</th>
								<th style="text-align: right;">Actions</th>
							</tr>
						</thead>
						<tbody>
							<%
                            List<Map<String,Object>> users = (List<Map<String,Object>>) request.getAttribute("users");
                            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
                            Calendar cal = Calendar.getInstance();

                            if (users == null || users.isEmpty()) {
                        %>
							<tr>
								<td colspan="5"
									style="text-align: center; padding: 48px; color: var(--muted);">
									<%= InfoIcon("w-10 h-10 mx-auto mb-2 opacity-20") %> No
									database entries found.
								</td>
							</tr>
							<%
                            } else {
                                for (Map<String,Object> u : users) {
                                    int empid = (Integer) u.get("empid");
                                    String fullname = String.valueOf(u.get("fullname"));
                                    String email = String.valueOf(u.get("email"));
                                    String role = String.valueOf(u.get("role"));
                                    String phone = String.valueOf(u.get("phone"));
                                    String status = String.valueOf(u.get("status") != null ? u.get("status") : "ACTIVE");
                                    Date hiredate = (Date) u.get("hiredate");
                                    
                                    // Extract register details safely
                                    String icNumber = String.valueOf(u.get("icNumber") != null ? u.get("icNumber") : "---");
                                    String gender = String.valueOf(u.get("gender") != null ? u.get("gender") : "---");
                                    String street = String.valueOf(u.get("street") != null ? u.get("street") : "---");
                                    String city = String.valueOf(u.get("city") != null ? u.get("city") : "---");
                                    String postalCode = String.valueOf(u.get("postalCode") != null ? u.get("postalCode") : "---");
                                    String state = String.valueOf(u.get("state") != null ? u.get("state") : "---");
                                    String profilePic = String.valueOf(u.get("profilePic") != null ? u.get("profilePic") : "---");

                                    // Replace double quotes with safe HTML attributes
                                    String escFullname = fullname.replace("\"", "&quot;");
                                    String escStreet = street.replace("\"", "&quot;");
                                    String escCity = city.replace("\"", "&quot;");
                                    String escState = state.replace("\"", "&quot;");

                                    String joinYear = "0000";
                                    if (hiredate != null) {
                                        cal.setTime(hiredate);
                                        joinYear = String.valueOf(cal.get(Calendar.YEAR));
                                    }
                                    String customId = "EMP-" + joinYear + "-0" + empid;

                                    boolean isActive = "ACTIVE".equalsIgnoreCase(status);
                                    boolean isAdmin = "ADMIN".equalsIgnoreCase(role);
                        %>
							<tr class="<%= !isActive ? "row-inactive" : "" %>">
								<td>
									<!-- Configured name hyperlink to trigger detailed Modal profile popup -->
									<div class="font-bold text-slate-800 uppercase text-sm">
										<a href="javascript:void(0)" 
										   class="text-slate-800 hover:text-blue-600 hover:underline transition-colors cursor-pointer"
										   onclick="showDetailModal(this)"
										   data-empid="<%= empid %>"
										   data-customid="<%= customId %>"
										   data-fullname="<%= escFullname %>"
										   data-email="<%= email %>"
										   data-role="<%= role %>"
										   data-phone="<%= (phone == null || phone.isBlank()) ? "---" : phone %>"
										   data-ic="<%= icNumber %>"
										   data-gender="<%= "M".equalsIgnoreCase(gender) ? "MALE" : ("F".equalsIgnoreCase(gender) ? "FEMALE" : "---") %>"
										   data-hiredate="<%= hiredate != null ? sdf.format(hiredate) : "---" %>"
										   data-street="<%= escStreet %>"
										   data-city="<%= escCity %>"
										   data-postalcode="<%= postalCode %>"
										   data-state="<%= escState %>"
										   data-status="<%= status %>"
										   data-profilepic="<%= profilePic %>">
											<%= fullname %>
										</a>
									</div>
									<div class="mt-1 flex items-center gap-2">
										<span
											class="badge <%= isAdmin ? "badge-admin" : "bg-slate-100 text-slate-500 border-slate-200" %>">
											<%= role %>
										</span> <span
											class="text-[10px] font-bold text-slate-400 uppercase tracking-tighter"><%= customId %></span>
									</div>
								</td>
								<td>
									<div class="text-[13px] font-semibold text-slate-700"><%= email %></div>
									<div class="text-[11px] text-slate-400 mt-1 font-medium"><%= (phone == null || phone.isBlank()) ? "---" : phone %></div>
								</td>
								<td class="text-[13px] font-bold text-slate-600"><%= hiredate != null ? sdf.format(hiredate) : "---" %>
								</td>
								<td style="text-align: center;"><span
									class="badge <%= isActive ? "badge-active" : "badge-inactive" %>">
										<%= status %>
								</span></td>
								<td style="text-align: right;">
									<% if (!isAdmin) { %>
									<button
										class="btnAction <%= isActive ? "btnDeactivate" : "btnActivate" %>"
										onclick="showConfirmModal('<%= empid %>', '<%= isActive ? "INACTIVE" : "ACTIVE" %>', '<%= fullname %>')">
										<%= isActive ? XCircleIcon("w-3.5 h-3.5") + " Deactivate" : CheckCircleIcon("w-3.5 h-3.5") + " Reactivate" %>
									</button> <% } else { %> <span
									class="text-[10px] font-black text-blue-300 uppercase italic tracking-widest">
										<%= ShieldCheckIcon("w-3.5 h-3.5 inline mr-1") %>System Root
								</span> <% } %>
								</td>
							</tr>
							<%
                                }
                            }
                        %>
						</tbody>
					</table>
				</div>
			</div>
		</div>

		<!-- Confirmation Modal -->
		<div id="confirmModal" class="modal-overlay">
			<div class="modal-content">
				<div id="modalIconContainer"
					class="w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4"></div>
				<h3 id="modalTitle"
					class="text-xl font-black text-slate-800 mb-2 uppercase tracking-tight">Are
					you sure?</h3>
				<p id="modalBody"
					class="text-slate-500 text-sm mb-8 font-medium leading-relaxed"></p>

				<form id="modalForm" action="ToggleEmployeeStatus" method="post">
					<input type="hidden" name="empid" id="modalEmpId"> <input
						type="hidden" name="targetStatus" id="modalTargetStatus">
					<div class="flex gap-3">
						<button type="button"
							class="flex-1 px-4 py-3 rounded-xl border border-slate-200 font-bold text-xs uppercase btn-cancel"
							onclick="closeModal()">Cancel</button>
						<button type="submit" id="modalSubmitBtn"
							class="flex-1 px-4 py-3 rounded-xl font-bold text-xs uppercase text-white shadow-lg">Confirm</button>
					</div>
				</form>
			</div>
		</div>

		<!-- Detailed Profile Modal -->
		<div id="detailModal" class="modal-overlay">
			<div class="detail-modal-content">
				<!-- Header Graphic Band with Title inside the solid Blue area -->
				<div class="bg-[#2563eb] h-28 relative flex items-start pt-6 px-8 shrink-0">
					<span class="text-white font-extrabold text-xxl uppercase tracking-widest">Profile Details</span>
					<button type="button" onclick="closeDetailModal()" class="absolute top-5 right-6 bg-white/20 hover:bg-white/30 text-white rounded-full p-2 transition-all">
						<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M6 18L18 6M6 6l12 12"></path></svg>
					</button>
				</div>
				
				<!-- Avatar, Name & Overall Badges (Positioned cleanly below the banner) -->
				<div class="px-8 pt-4 pb-4 border-b border-slate-100 bg-white shrink-0 relative">
					<div class="flex flex-col sm:flex-row sm:items-start justify-between gap-4">
						<div class="flex items-start gap-4">
							<div id="detailAvatarContainer" class="-mt-14 relative z-10 w-24 h-24 bg-white rounded-2xl p-1.5 shadow-md flex items-center justify-center border border-slate-100 overflow-hidden shrink-0">
								<!-- Dynamic image or vector SVG loaded here -->
							</div>
							<div class="text-left pt-1 min-w-0">
								<!-- Name Styled EXACTLY as requested: Slate 800, tight tracking, uppercase, font-black, size 2xl, and tight line height -->
								<h3 id="detailFullname" class="text-2xl font-black text-slate-800 uppercase tracking-tight leading-tight mb-2 break-words"></h3>
								<div class="flex flex-wrap items-center gap-2">
									<span id="detailRoleBadge" class="badge"></span>
									<span id="detailCustomId" class="text-xs font-bold text-slate-400 uppercase tracking-wider"></span>
								</div>
							</div>
						</div>
						<div class="pt-1 shrink-0">
							<span id="detailStatusBadge" class="badge"></span>
						</div>
					</div>
				</div>

				<!-- Detailed Field Data (Scroll Container is isolated from headers to prevent name shifts from altering heights) -->
				<div id="detailScrollContainer" class="flex-1 overflow-y-auto p-8 space-y-4 text-left">
					<!-- Personal Secure Data Section -->
					<div class="bg-slate-50 rounded-2xl p-4 border border-slate-100">
						<h4 class="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-3">SECURE IDENTIFICATION</h4>
						<div class="grid grid-cols-2 gap-4">
							<div>
								<label class="block text-[10px] font-extrabold text-slate-400 uppercase tracking-wider mb-1">IC Number</label>
								<span id="detailIC" class="text-xs font-semibold text-slate-700"></span>
							</div>
							<div>
								<label class="block text-[10px] font-extrabold text-slate-400 uppercase tracking-wider mb-1">Gender</label>
								<span id="detailGender" class="text-xs font-semibold text-slate-700"></span>
							</div>
						</div>
					</div>

					<!-- Contact Channels -->
					<div class="bg-slate-50 rounded-2xl p-4 border border-slate-100">
						<h4 class="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-3">CONTACT INFO</h4>
						<div class="grid grid-cols-2 gap-4">
							<div>
								<label class="block text-[10px] font-extrabold text-slate-400 uppercase tracking-wider mb-1">Work Email</label>
								<span id="detailEmail" class="text-xs font-semibold text-slate-700 break-all"></span>
							</div>
							<div>
								<label class="block text-[10px] font-extrabold text-slate-400 uppercase tracking-wider mb-1">Phone Contact</label>
								<span id="detailPhone" class="text-xs font-semibold text-slate-700"></span>
							</div>
						</div>
					</div>

					<!-- Employment Data -->
					<div class="bg-slate-50 rounded-2xl p-4 border border-slate-100">
						<h4 class="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-3">EMPLOYMENT PERMISSIONS</h4>
						<div class="grid grid-cols-2 gap-4">
							<div>
								<label class="block text-[10px] font-extrabold text-slate-400 uppercase tracking-wider mb-1">Role Type</label>
								<span id="detailRole" class="text-xs font-bold text-slate-700"></span>
							</div>
							<div>
								<label class="block text-[10px] font-extrabold text-slate-400 uppercase tracking-wider mb-1">Date Joined</label>
								<span id="detailHireDate" class="text-xs font-semibold text-slate-700"></span>
							</div>
						</div>
					</div>

					<!-- Complete Addresses -->
					<div class="bg-slate-50 rounded-2xl p-4 border border-slate-100">
						<h4 class="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-3">RESIDENTIAL ADDRESS</h4>
						<div class="space-y-3">
							<div>
								<label class="block text-[10px] font-extrabold text-slate-400 uppercase tracking-wider mb-1">Street Address</label>
								<span id="detailStreet" class="text-xs font-semibold text-slate-700 uppercase"></span>
							</div>
							<div class="grid grid-cols-3 gap-4">
								<div class="col-span-2">
									<label class="block text-[10px] font-extrabold text-slate-400 uppercase tracking-wider mb-1">City</label>
									<span id="detailCity" class="text-xs font-semibold text-slate-700 uppercase"></span>
								</div>
								<div>
									<label class="block text-[10px] font-extrabold text-slate-400 uppercase tracking-wider mb-1">Postal Code</label>
									<span id="detailPostalCode" class="text-xs font-semibold text-slate-700"></span>
								</div>
							</div>
							<div>
								<label class="block text-[10px] font-extrabold text-slate-400 uppercase tracking-wider mb-1">State</label>
								<span id="detailState" class="text-xs font-semibold text-slate-700 uppercase"></span>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</main>

	<script>
        window.onload = function() {
            const statusMsg = document.getElementById('statusMsg');
            if (statusMsg) {
                setTimeout(() => {
                    statusMsg.classList.add('msg-hidden');
                    setTimeout(() => statusMsg.remove(), 500);
                }, 3000);
            }
        };

        function showConfirmModal(id, target, name) {
            const modal = document.getElementById('confirmModal');
            const formId = document.getElementById('modalEmpId');
            const formStatus = document.getElementById('modalTargetStatus');
            const body = document.getElementById('modalBody');
            const submitBtn = document.getElementById('modalSubmitBtn');
            const iconBox = document.getElementById('modalIconContainer');
            const title = document.getElementById('modalTitle');

            formId.value = id;
            formStatus.value = target;

            const upperName = name.toUpperCase();

            if (target === 'INACTIVE') {
                title.innerText = "DEACTIVATE STAFF?";
                body.innerHTML = "Are you sure you want to deactivate <b class='text-slate-900'>" + upperName + "</b>? Access will be revoked immediately.";
                submitBtn.style.backgroundColor = "#ef4444";
                iconBox.style.backgroundColor = "#fee2e2";
                iconBox.innerHTML = `<%= XCircleIcon("w-8 h-8 text-red-500") %>`;
            } else {
                title.innerText = "REACTIVATE STAFF?";
                body.innerHTML = "Are you sure you want to reactivate <b class='text-slate-900'>" + upperName + "</b>? System access will be restored.";
                submitBtn.style.backgroundColor = "#10b981";
                iconBox.style.backgroundColor = "#ecfdf5";
                iconBox.innerHTML = `<%= CheckCircleIcon("w-8 h-8 text-emerald-500") %>`;
            }
            modal.classList.add('modal-active');
        }

        function closeModal() {
            document.getElementById('confirmModal').classList.remove('modal-active');
        }

        /* Displays the Detailed Profile Modal & injects dynamic vector avatars based on employee registration details */
        function showDetailModal(element) {
            const modal = document.getElementById('detailModal');
            
            // Extract from dataset
            const fullname = element.getAttribute('data-fullname');
            const customid = element.getAttribute('data-customid');
            const email = element.getAttribute('data-email');
            const role = element.getAttribute('data-role');
            const phone = element.getAttribute('data-phone');
            const ic = element.getAttribute('data-ic');
            const gender = element.getAttribute('data-gender');
            const hiredate = element.getAttribute('data-hiredate');
            const street = element.getAttribute('data-street');
            const city = element.getAttribute('data-city');
            const postalcode = element.getAttribute('data-postalcode');
            const state = element.getAttribute('data-state');
            const status = element.getAttribute('data-status');
            const profilePic = element.getAttribute('data-profilepic');

            // Force resetting scroll position back to the top
            const scrollContainer = document.getElementById('detailScrollContainer');
            if (scrollContainer) {
                scrollContainer.scrollTop = 0;
            }

            // Map data to DOM Elements
            document.getElementById('detailFullname').innerText = fullname;
            document.getElementById('detailCustomId').innerText = customid;
            document.getElementById('detailIC').innerText = ic;
            document.getElementById('detailGender').innerText = gender;
            document.getElementById('detailEmail').innerText = email;
            document.getElementById('detailPhone').innerText = phone;
            document.getElementById('detailRole').innerText = role;
            document.getElementById('detailHireDate').innerText = hiredate;
            document.getElementById('detailStreet').innerText = street;
            document.getElementById('detailCity').innerText = city;
            document.getElementById('detailPostalCode').innerText = postalcode;
            document.getElementById('detailState').innerText = state;

            // Role Badge styling
            const roleBadge = document.getElementById('detailRoleBadge');
            roleBadge.innerText = role;
            roleBadge.className = "badge";
            if (role === 'ADMIN') {
                roleBadge.classList.add('badge-admin');
            } else {
                roleBadge.classList.add('bg-slate-100', 'text-slate-500', 'border-slate-200');
            }

            // Status Badge styling
            const statusBadge = document.getElementById('detailStatusBadge');
            statusBadge.innerText = status;
            statusBadge.className = "badge";
            if (status === 'ACTIVE') {
                statusBadge.classList.add('badge-active');
            } else {
                statusBadge.classList.add('badge-inactive');
            }

            // Avatar Container Logic
            const avatarBox = document.getElementById('detailAvatarContainer');
            
            // Checking if profilePic exists and is not empty or "---"
            if (profilePic && profilePic !== "---" && profilePic !== "null" && profilePic.trim() !== "") {
                const imgNode = document.createElement('img');
                imgNode.src = profilePic;
                imgNode.className = "w-full h-full object-cover rounded-xl";
                imgNode.onerror = function() {
                    // Fallback if image fails to load
                    loadDefaultAvatar(gender, avatarBox, fullname);
                };
                avatarBox.innerHTML = "";
                avatarBox.appendChild(imgNode);
            } else {
                loadDefaultAvatar(gender, avatarBox, fullname);
            }

            modal.classList.add('modal-active');
        }

        // Generates dynamic gender SVG or initials fallback avatar
        function loadDefaultAvatar(gender, container, fullname) {
            const maleAvatar = `
                <svg class="w-full h-full" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <rect width="100" height="100" rx="16" fill="#EFF6FF"/>
                    <circle cx="50" cy="40" r="18" fill="#DBEAFE"/>
                    <path d="M50 22C41 22 39 28 39 31C41 31 43 27 50 27C57 27 59 31 61 31C61 28 59 22 50 22Z" fill="#1E40AF"/>
                    <path d="M22 85C22 65.5 34.5 58 50 58C65.5 58 78 65.5 78 85V100H22V85Z" fill="#2563EB"/>
                    <path d="M42 58L50 68L58 58H42Z" fill="#FFFFFF"/>
                    <path d="M48 64V80H52V64H48Z" fill="#EF4444"/>
                </svg>
            `;
            const femaleAvatar = `
                <svg class="w-full h-full" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <rect width="100" height="100" rx="16" fill="#FDF2F8"/>
                    <circle cx="50" cy="41" r="17" fill="#FCE7F3"/>
                    <path d="M30 35C30 20 40 18 50 18C60 18 70 20 70 35C70 42 67 47 67 47C64 43 61 32 50 32C39 32 36 43 33 47C33 47 30 42 30 35Z" fill="#475569"/>
                    <path d="M22 85C22 66 34.5 59 50 59C65.5 59 78 66 78 85V100H22V85Z" fill="#4F46E5"/>
                    <path d="M40 59L50 71L60 59H40Z" fill="#FFFFFF"/>
                    <circle cx="50" cy="78" r="3" fill="#FACC15"/>
                </svg>
            `;
            
            if (gender === 'MALE') {
                container.innerHTML = maleAvatar;
            } else if (gender === 'FEMALE') {
                container.innerHTML = femaleAvatar;
            } else {
                // Generates dynamic initials text fallback
                let initials = "U";
                if (fullname && fullname.trim() !== "") {
                    let parts = fullname.trim().split(" ");
                    if (parts.length > 1) {
                        initials = (parts[0].charAt(0) + parts[1].charAt(0)).toUpperCase();
                    } else {
                        initials = parts[0].charAt(0).toUpperCase();
                    }
                }
                container.innerHTML = `
                    <div class="w-full h-full bg-gradient-to-br from-blue-600 to-indigo-700 flex items-center justify-center font-black text-2xl text-white rounded-xl">
                        \${initials}
                    </div>
                `;
            }
        }

        function closeDetailModal() {
            document.getElementById('detailModal').classList.remove('modal-active');
        }

        window.onclick = function(event) {
            const confirmModal = document.getElementById('confirmModal');
            const detailModal = document.getElementById('detailModal');
            if (event.target == confirmModal) closeModal();
            if (event.target == detailModal) closeDetailModal();
        }
    </script>
</body>
</html>