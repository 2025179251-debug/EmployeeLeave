<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ include file="icon.jsp"%>
<%
if (session.getAttribute("empid") == null || session.getAttribute("role") == null
		|| !"ADMIN".equalsIgnoreCase(String.valueOf(session.getAttribute("role")))) {
	response.sendRedirect("login.jsp?error=Please+login+as+admin.");
	return;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Register Employee | Admin Access</title>

<script src="https://cdn.tailwindcss.com"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">

<style>
:root {
	--bg: #f1f5f9;
	--card: #ffffff;
	--border: #e2e8f0;
	--text: #1e293b;
	--muted: #475569;
	--blue-primary: #2563eb;
	--blue-light: #eff6ff;
	--blue-hover: #1d4ed8;
	--shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.04);
	--radius: 20px;
}

* {
	box-sizing: border-box;
	font-family: 'Inter', Arial, sans-serif !important;
}

body {
	margin: 0;
	background: var(--bg);
	color: var(--text);
	overflow-x: hidden;
	-webkit-font-smoothing: antialiased;
}

.pageWrap {
	padding: 24px 40px;
	max-width: 1100px;
	margin: 0 auto;
}

h2.title {
	font-size: 26px;
	font-weight: 800;
	margin: 0;
	color: var(--text);
	text-transform: uppercase;
	letter-spacing: -0.02em;
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
	transition: all 0.3s ease;
}

.cardHead {
	padding: 20px 32px;
	border-bottom: 1px solid #f1f5f9;
	display: flex;
	justify-content: space-between;
	align-items: center;
	background: #fcfcfd;
}

.cardHead span {
	font-weight: 900;
	font-size: 14px;
	color: #64748b;
	text-transform: uppercase;
	letter-spacing: 0.05em;
}

.cardBody {
	padding: 40px;
}

.grid-form {
	display: grid;
	grid-template-columns: 1fr 1fr;
	gap: 24px;
}

.field {
	display: flex;
	flex-direction: column;
	gap: 8px;
}

.span2 {
	grid-column: span 2;
}

label {
	font-size: 13px;
	font-weight: 900;
	color: #233f66;
	text-transform: uppercase;
	letter-spacing: 0.05em;
	margin-left: 2px;
}

input, select {
	width: 100% !important;
	height: 54px !important;
	padding: 0 20px !important;
	border: 2px solid #e2e8f0 !important;
	border-radius: 14px !important;
	font-size: 14px !important;
	font-weight: 600 !important;
	background: #fff !important;
	color: var(--text) !important;
	outline: none !important;
	display: block !important;
	box-sizing: border-box !important;
	transition: all 0.2s;
	text-transform: uppercase;
}

input:focus, select:focus {
	border-color: var(--blue-primary) !important;
	box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.08) !important;
	background: #fff !important;
}

input::placeholder {
	color: #cbd5e1;
	text-transform: none;
	font-weight: 500;
}

input[type="email"], input[type="password"] {
	text-transform: none !important;
}

/* ERROR VISUAL STATES FOR INPUTS & SHAKE ANIMATION */
input.invalid-field, select.invalid-field {
	border-color: #ef4444 !important;
	background-color: #fff1f2 !important;
}

.input-hint {
	font-size: 10px;
	font-weight: 850;
	text-transform: uppercase;
	margin-top: 4px;
	display: block;
	transition: color 0.2s;
}

@keyframes shake {
	0%, 100% { transform: translateX(0); }
	20%, 60% { transform: translateX(-6px); }
	40%, 80% { transform: translateX(6px); }
}

.shake-it {
	animation: shake 0.4s ease-in-out;
}

.actions {
	display: flex;
	justify-content: flex-end;
	gap: 12px;
	margin-top: 40px;
	padding-top: 32px;
	border-top: 1px solid #f1f5f9;
}

.btn {
	padding: 0 32px;
	height: 50px;
	border-radius: 14px;
	cursor: pointer;
	font-weight: 800;
	font-size: 13px;
	text-decoration: none;
	text-transform: uppercase;
	transition: 0.2s;
	border: none;
	display: inline-flex;
	align-items: center;
	gap: 10px;
	letter-spacing: 0.05em;
}

.btnPrimary {
	background: var(--blue-primary);
	color: #fff;
}

.btnPrimary:hover {
	background: var(--blue-hover);
	transform: translateY(-1px);
	box-shadow: 0 10px 20px -5px rgba(37, 99, 235, 0.3);
}

.btnGhost {
	background: #f1f5f9;
	color: #64748b;
}

.btnGhost:hover {
	background: #e2e8f0;
	color: var(--text);
}

.confirm-overlay {
	position: fixed;
	inset: 0;
	background: rgba(15, 23, 42, 0.6);
	backdrop-filter: blur(4px);
	z-index: 9999;
	display: none;
	align-items: center;
	justify-content: center;
	padding: 20px;
}

.confirm-overlay.show {
	display: flex;
}

.confirm-modal {
	background: white;
	width: 100%;
	max-width: 450px;
	border-radius: 24px;
	box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
	overflow: hidden;
	animation: slideUp 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}

@keyframes slideUp {from { opacity:0; transform: translateY(30px); } to { opacity: 1; transform: translateY(0); }}

.confirm-body {
	padding: 40px 32px;
	text-align: center;
}

.confirm-footer {
	padding: 20px 32px;
	background: #f8fafc;
	display: flex;
	justify-content: center;
	gap: 12px;
	border-top: 1px solid #f1f5f9;
}

@media ( max-width : 768px) {
	.grid-form {
		grid-template-columns: 1fr;
	}
	.span2 {
		grid-column: span 1;
	}
	.pageWrap {
		padding: 20px;
	}
}
</style>
</head>

<body class="flex">
	<jsp:include page="sidebar.jsp" />

	<main class="flex-1 ml-20 lg:ml-64 min-h-screen transition-all duration-300">
		<jsp:include page="topbar.jsp" />

		<div class="pageWrap">
			<div class="flex justify-between items-center mb-10">
				<div>
					<h2 class="title">REGISTER EMPLOYEE</h2>
					<span class="sub-label">Complete the fields below to create a secure employee profile</span>
				</div>
                <a href="EmployeeDirectory" class="btn btnGhost text-xs">
                    <%=UsersIcon("w-4 h-4 mr-2")%> Back to Directory
                </a>
			</div>

			<!-- Dynamic Client-side JavaScript Validation Error Notice Container -->
			<div id="jsErrorAlert" class="bg-red-50 border border-red-100 p-4 rounded-xl text-red-700 font-bold mb-6 flex items-center gap-2 shadow-sm uppercase text-xs hidden">
				<%=AlertIcon("w-5 h-5")%> <span id="jsErrorText"></span>
			</div>

			<c:if test="${not empty param.msg}">
				<div class="bg-emerald-50 border border-emerald-100 p-4 rounded-xl text-emerald-700 font-bold mb-6 flex items-center gap-2 shadow-sm uppercase text-xs">
                    <%=CheckCircleIcon("w-5 h-5")%> ${param.msg}
				</div>
			</c:if>
			<c:if test="${not empty param.error}">
				<div class="bg-red-50 border border-red-100 p-4 rounded-xl text-red-700 font-bold mb-6 flex items-center gap-2 shadow-sm uppercase text-xs">
                    <%=AlertIcon("w-5 h-5")%> ${param.error}
				</div>
			</c:if>

			<div class="card">
				<div class="cardHead">
					<span>Account Identification</span>
					<%=BriefcaseIcon("w-6 h-6 text-blue-400 opacity-20")%>
				</div>

				<div class="cardBody">
					<form id="registrationForm" action="RegisterEmployee" method="post" onsubmit="return showConfirmModal(event)">
						<div class="grid-form">
							<div class="field span2">
								<label>Full Name as per IC *</label> 
                                <input type="text" name="fullname" id="fullname" placeholder="AHMAD BIN ABDULLAH" 
                                       required pattern="^[A-Za-z\s']+$" title="FULL NAME CAN ONLY CONTAIN LETTERS, SPACES, AND APOSTROPHES">
							</div>

							<div class="field">
								<label>Work Email Address *</label> <input type="email"
									name="email" placeholder="ahmad@klinik.com" required>
							</div>

							<!-- System Password Field with Interactive Visibility Toggler -->
							<div class="field">
								<label>System Password *</label>
								<div class="relative w-full">
									<input type="password" name="password" id="password" placeholder="••••••••" required class="pr-12">
									<button type="button" onclick="togglePasswordVisibility()" class="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 focus:outline-none transition-colors" title="Toggle visibility">
										<!-- Open Eye Icon -->
										<svg id="eyeOpenIcon" class="w-5 h-5" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
											<path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
											<path stroke-linecap="round" stroke-linejoin="round" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
										</svg>
										<!-- Slashed Closed Eye Icon (Initially Hidden) -->
										<svg id="eyeCloseIcon" class="w-5 h-5 hidden" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
											<path stroke-linecap="round" stroke-linejoin="round" d="M3.98 8.223A10.477 10.477 0 001.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.45 10.45 0 0112 4.5c4.756 0 8.773 3.162 10.065 7.498a10.523 10.523 0 01-4.293 5.774M6.228 6.228L3 3m3.228 3.228l3.65 3.65m7.894 7.894L21 21m-3.228-3.228l-3.65-3.65m0 0a3 3 0 10-4.243-4.243m4.242 4.242L9.88 9.88" />
										</svg>
									</button>
								</div>
							</div>

							<div class="field">
								<label>IC Number *</label> 
								<input type="text" name="icNumber" id="icNumber" placeholder="900101-04-5566" maxlength="14" required>
								<span id="icHint" class="input-hint text-red-500 font-bold hidden">PLEASE FILL OUT THIS FIELD WITH IC NUMBER (EXACTLY 12 DIGITS)</span>
							</div>

							<div class="field">
								<label>Gender Selection *</label> <select name="gender" required>
									<option value="" disabled selected>SELECT GENDER</option>
									<option value="M">MALE</option>
									<option value="F">FEMALE</option>
								</select>
							</div>

							<div class="field">
								<label>Phone Contact</label> <input type="text" name="phoneNo"
									id="phoneNo" placeholder="01X-XXXXXXX" maxlength="12">
							</div>

							<div class="field">
								<label>Date of Joining *</label> <input type="date"
									name="hireDate" required>
							</div>

							<div class="field span2">
								<label>Street Address *</label> <input type="text" name="street"
									placeholder="NO. 12, JALAN MERLIMAU" required>
							</div>

							<div class="field">
								<label>City *</label> 
                                <input type="text" name="city" id="city"
									placeholder="JASIN" required pattern="^[A-Za-z\s]+$"
									title="CITY CAN ONLY CONTAIN LETTERS AND SPACES.">
							</div>

							<div class="field">
								<label>Postal Code *</label> 
								<input type="text" name="postalCode" id="postalCode" placeholder="77300" maxlength="5" required>
								<span id="postalHint" class="input-hint text-red-500 font-bold hidden">PLEASE FILL OUT THIS FIELD WITH POSTAL CODE (EXACTLY 5 DIGITS)</span>
							</div>

							<div class="field span2">
								<label>State *</label> <select name="state" required>
									<option value="" disabled selected>SELECT STATE</option>
                                    <option value="Johor">JOHOR</option>
                                    <option value="Kedah">KEDAH</option>
                                    <option value="Kelantan">KELANTAN</option>
                                    <option value="Melaka">MELAKA</option>
                                    <option value="Negeri Sembilan">NEGERI SEMBILAN</option>
                                    <option value="Pahang">PAHANG</option>
                                    <option value="Perak">PERAK</option>
                                    <option value="Perlis">PERLIS</option>
                                    <option value="Penang">PENANG</option>
                                    <option value="Selangor">SELANGOR</option>
                                    <option value="Terengganu">TERENGGANU</option>
                                    <option value="Kuala Lumpur">KUALA LUMPUR</option>
                                    <option value="Putrajaya">PUTRAJAYA</option>
                                    <option value="Labuan">LABUAN</option>
                                    <option value="Sabah">SABAH</option>
                                    <option value="Sarawak">SARAWAK</option>
								</select>
							</div>
						</div>

						<div class="actions">
							<button type="reset" class="btn btnGhost">
								<%=RefreshIcon("w-4 h-4 mr-2")%> Reset
							</button>

							<button class="btn btnPrimary" type="submit">
								<%=SaveIcon("w-4 h-4 mr-2")%> Create Account
							</button>
						</div>
					</form>
				</div>
			</div>
		</div>
	</main>

	<!-- Confirmation overlay dialog module -->
	<div id="confirmOverlay" class="confirm-overlay">
		<div class="confirm-modal">
			<div class="confirm-body">
				<div class="w-20 h-20 bg-blue-50 rounded-full flex items-center justify-center mx-auto mb-6">
					<%=UsersIcon("w-10 h-10 text-blue-600")%>
				</div>
				<h3 class="text-xl font-black text-slate-900 uppercase mb-3">Confirm Registration</h3>
				<p class="text-sm text-slate-500 font-bold leading-relaxed px-4">
					ARE YOU SURE WANT TO REGISTER <br> <span id="confirmNameText"
						class="text-blue-600 font-black"></span> <br> AS A NEW EMPLOYEE?
				</p>
			</div>
			<div class="confirm-footer">
				<button type="button" onclick="closeConfirmModal()" class="btn btnGhost">No, Cancel</button>
				<button type="button" onclick="proceedWithRegistration()" class="btn btnPrimary">Yes, Register</button>
			</div>
		</div>
	</div>

	<script>
		// 1. Password Visibility Handler toggler routine
		function togglePasswordVisibility() {
			const passwordInput = document.getElementById('password');
			const eyeOpenIcon = document.getElementById('eyeOpenIcon');
			const eyeCloseIcon = document.getElementById('eyeCloseIcon');

			if (passwordInput.type === 'password') {
				passwordInput.type = 'text';
				eyeOpenIcon.classList.add('hidden');
				eyeCloseIcon.classList.remove('hidden');
			} else {
				passwordInput.type = 'password';
				eyeOpenIcon.classList.remove('hidden');
				eyeCloseIcon.classList.add('hidden');
			}
		}

		// 2. Real-time form listeners and formatting rules
        document.querySelectorAll('input, select').forEach(el => {
            el.addEventListener('input', function() {
                // Auto Uppercase for text input fields (excluding sensitive system entries)
                if (this.tagName === 'INPUT' && this.type !== 'password' && this.type !== 'email') {
                    this.value = this.value.toUpperCase();
                }

                this.classList.remove('invalid-field');

                // Constraint: Full Name (Only letters, spaces, and apostrophe allowed)
                if (this.id === 'fullname') {
                    this.value = this.value.replace(/[^A-Za-z\s']/g, '');
                }

                // Format IC input dynamically and handle hidden descriptive cues
                if (this.id === 'icNumber') {
                    let val = this.value.replace(/\D/g, '');
                    if (val.length > 12) val = val.slice(0, 12);
                    let formatted = "";
                    if (val.length > 0) formatted += val.substring(0, 6);
                    if (val.length > 6) formatted += '-' + val.substring(6, 8);
                    if (val.length > 8) formatted += '-' + val.substring(8);
                    this.value = formatted;

                    // Update hint style dynamically (hidden by default, shown on incomplete entries)
                    const hint = document.getElementById('icHint');
                    if (val.length > 0 && val.length < 12) {
                        hint.classList.remove('hidden');
                        this.classList.add('invalid-field');
                    } else {
                        hint.classList.add('hidden');
                        this.classList.remove('invalid-field');
                    }
                }

                // Format Mobile Contact
                if (this.id === 'phoneNo') {
                    let val = this.value.replace(/\D/g, '');
                    if (val.length > 11) val = val.slice(0, 11);
                    if (val.length > 3) {
                        this.value = val.substring(0, 3) + '-' + val.substring(3);
                    } else {
                        this.value = val;
                    }
                }
                
                // City Validation Constraint (No special symbols or numbers)
                if (this.id === 'city') {
                    this.value = this.value.replace(/[^A-Za-z\s]/g, '');
                }

                // Postal code digits restrictions
                if (this.id === 'postalCode') {
                    this.value = this.value.replace(/\D/g, '').slice(0, 5);

                    // Sync helper cue indicators
                    const hint = document.getElementById('postalHint');
                    if (this.value.length > 0 && this.value.length < 5) {
                        hint.classList.remove('hidden');
                        this.classList.add('invalid-field');
                    } else {
                        hint.classList.add('hidden');
                        this.classList.remove('invalid-field');
                    }
                }
            });
        });

        // 3. Client-side submit constraints validation
        function showConfirmModal(event) {
            event.preventDefault();

            const fullname = document.getElementById('fullname');
            const icInput = document.getElementById('icNumber');
            const postalInput = document.getElementById('postalCode');
            const alertBox = document.getElementById('jsErrorAlert');
            const alertText = document.getElementById('jsErrorText');
            const card = document.querySelector('.card');

            const icHint = document.getElementById('icHint');
            const postalHint = document.getElementById('postalHint');

            let isValid = true;
            let errorMessage = "";

            // Reset field states
            icInput.classList.remove('invalid-field');
            postalInput.classList.remove('invalid-field');
            alertBox.classList.add('hidden');

            // 1. Strict IC digits check
            const rawIc = icInput.value.replace(/-/g, '').trim();
            if (rawIc.length !== 12) {
                isValid = false;
                icInput.classList.add('invalid-field');
                icHint.classList.remove('hidden');
                errorMessage = "IC number must contain exactly 12 digits!";
            }

            // 2. Strict Postal Code digits check
            const rawPostal = postalInput.value.trim();
            if (rawPostal.length !== 5) {
                isValid = false;
                postalInput.classList.add('invalid-field');
                postalHint.classList.remove('hidden');
                errorMessage = errorMessage ? errorMessage + " & postal code must contain exactly 5 digits!" : "Postal code must contain exactly 5 digits!";
            }

            if (!isValid) {
                // Show standard customized alert notice block (no browser alerts used)
                alertText.textContent = errorMessage.toUpperCase();
                alertBox.classList.remove('hidden');

                // Trigger card shake animation
                card.classList.remove('shake-it');
                card.offsetHeight; // force reflow
                card.classList.add('shake-it');

                // Scroll smoothly to alert box
                alertBox.scrollIntoView({ behavior: 'smooth', block: 'center' });
                return false;
            }

            const name = fullname ? fullname.value.trim() : "THIS USER";
            document.getElementById('confirmNameText').textContent = name.toUpperCase();
            document.getElementById('confirmOverlay').classList.add('show');
            return false;
        }

        function closeConfirmModal() {
            document.getElementById('confirmOverlay').classList.remove('show');
        }

        function proceedWithRegistration() {
            // Clean IC for backend
            const icInput = document.getElementById('icNumber');
            if (icInput) {
                icInput.value = icInput.value.replace(/-/g, ''); 
            }
            document.getElementById('registrationForm').submit();
        }
	</script>
</body>
</html>