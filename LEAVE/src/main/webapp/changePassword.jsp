<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ include file="icon.jsp"%>

<%
if (session.getAttribute("empid") == null) {
	response.sendRedirect("login.jsp?error=Please+login.");
	return;
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Security Settings | Klinik Dr Mohamad</title>
<script src="https://cdn.tailwindcss.com"></script>
<link
	href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap"
	rel="stylesheet">

<style>
:root {
	--bg: #f1f5f9;
	--card: #ffffff;
	--border: #e2e8f0;
	--text: #1e293b;
	--muted: #64748b;
	--blue: #2563eb;
	--blue-hover: #1d4ed8;
	--radius: 20px;
}

* {
	box-sizing: border-box;
	font-family: 'Inter', sans-serif !important;
}

body {
	margin: 0;
	background: var(--bg);
	color: var(--text);
	overflow-x: hidden;
	-webkit-font-smoothing: antialiased;
}

/* Consistent PageWrap matching your other pages */
.pageWrap {
	padding: 32px 40px;
	max-width: 1300px;
	margin: 0;
}

/* Consistent Title & Sub-label styles */
.title {
	font-size: 26px;
	font-weight: 800;
	margin: 0;
	text-transform: uppercase;
	color: var(--text);
	letter-spacing: -0.02em;
}

.sub-label {
	color: var(--blue);
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
	box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.04);
	overflow: visible; /* Changed to visible to let password requirement tooltip overlap nicely if needed */
	margin-top: 24px;
	max-width: 550px;
}

.label-xs {
	font-size: 10px;
	font-weight: 900;
	color: var(--muted);
	text-transform: uppercase;
	letter-spacing: 0.1em;
	margin-bottom: 8px;
	display: block;
}

/* THE FIX: Specificity override for Tailwind Reset */
.pageWrap input {
	width: 100% !important;
	padding: 0 54px 0 18px !important; /* Leaves room for eye icons on the right */
	height: 52px !important;
	border: 2px solid #cbd5e1 !important;
	border-radius: 12px !important;
	font-size: 14px !important;
	font-weight: 600 !important;
	background: #fff !important;
	color: var(--text) !important;
	outline: none !important;
	display: block !important;
	box-sizing: border-box !important;
	transition: all 0.2s;
}

.pageWrap input::placeholder {
	color: #94a3b8;
	font-weight: 400;
}

.pageWrap input:focus {
	border-color: var(--blue) !important;
	box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.08) !important;
}

/* Invalid form field borders */
.pageWrap input.invalid-field {
	border-color: #ef4444 !important;
	background-color: #fff1f2 !important;
}

.btn-blue {
	width: 100%;
	height: 50px;
	border-radius: 14px;
	font-weight: 800;
	font-size: 12px;
	transition: 0.2s;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	gap: 10px;
	cursor: pointer;
	text-transform: uppercase;
	letter-spacing: 0.05em;
	background: var(--blue);
	color: #fff;
	border: none;
}

.btn-blue:hover {
	background: var(--blue-hover);
	transform: translateY(-1px);
}

.msg-box {
	padding: 12px 16px;
	border-radius: 12px;
	font-size: 12px;
	font-weight: 700;
	margin-bottom: 20px;
	display: flex;
	align-items: center;
	gap: 10px;
	transition: opacity 0.5s ease;
}

.icon-sm {
	width: 20px;
	height: 20px;
}

/* Password strength elements */
.strength-bar-container {
	height: 6px;
	background: #f1f5f9;
	border-radius: 3px;
	overflow: hidden;
	margin-top: 8px;
}

.strength-bar {
	height: 100%;
	width: 0%;
	transition: all 0.3s ease-in-out;
}

/* Shaking animation for validation triggers */
@keyframes shake {
	0%, 100% { transform: translateX(0); }
	20%, 60% { transform: translateX(-6px); }
	40%, 80% { transform: translateX(6px); }
}

.shake-it {
	animation: shake 0.4s ease-in-out;
}
</style>
</head>
<body class="flex">

	<jsp:include page="sidebar.jsp" />

	<main
		class="ml-20 lg:ml-64 min-h-screen flex-1 transition-all duration-300">
		<jsp:include page="topbar.jsp" />

		<div class="pageWrap">
			<div class="mb-4">
				<h2 class="title">CHANGE PASSWORD</h2>
				<span class="sub-label">Maintain account security with a
					unique password</span>
			</div>

			<div class="card" id="formCard">
				<div class="px-8 py-4 border-b border-slate-50 bg-slate-50/30">
					<span
						class="text-[9px] font-black text-slate-400 uppercase tracking-widest">Security
						Credentials</span>
				</div>

				<form action="ChangePassword" method="post" class="p-8 space-y-6" id="passwordForm" onsubmit="return validateForm(event)">

					<!-- JS Dynamic Error Notice Bar (Replacing alerts) -->
					<div id="jsErrorAlert" class="msg-box bg-red-50 text-red-600 border border-red-100 hidden">
						<%=AlertIcon("icon-sm")%>
						<span id="jsErrorText"></span>
					</div>

					<c:if test="${not empty param.error}">
						<div id="statusAlert"
							class="msg-box bg-red-50 text-red-600 border border-red-100">
							<%=AlertIcon("icon-sm")%>
							${param.error}
						</div>
					</c:if>
					<c:if test="${not empty param.msg}">
						<div id="statusAlert"
							class="msg-box bg-emerald-50 text-emerald-600 border border-emerald-100">
							<%=CheckCircleIcon("icon-sm")%>
							${param.msg}
						</div>
					</c:if>

					<!-- Old/Current Password Field -->
					<div class="space-y-2">
						<span class="label-xs">Current Password</span> 
						<div class="relative">
							<input type="password" name="oldPassword" id="oldPassword" required
								placeholder="Enter current password" oninput="this.classList.remove('invalid-field')">
							<button type="button" onclick="togglePassword('oldPassword')"
								class="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 hover:text-blue-600 transition-colors">
								<span class="show-eye">
									<svg class="icon-sm" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
										<path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
										<path stroke-linecap="round" stroke-linejoin="round" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
									</svg>
								</span>
								<span class="hide-eye hidden">
									<svg class="icon-sm" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
										<path stroke-linecap="round" stroke-linejoin="round" d="M3.98 8.223A10.477 10.477 0 001.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.45 10.45 0 0112 4.5c4.756 0 8.773 3.162 10.065 7.498a10.523 10.476 0 01-4.293 5.774M6.228 6.228L3 3m3.228 3.228l3.65 3.65m7.894 7.894L21 21m-3.228-3.228l-3.65-3.65m0 0a3 3 0 10-4.243-4.243m4.242 4.242L9.88 9.88" />
									</svg>
								</span>
							</button>
						</div>
					</div>

					<!-- New Password Field with dynamic tooltip and strength bar -->
					<div class="pt-4 border-t border-slate-100 space-y-4 relative">
						<div class="space-y-2">
							<span class="label-xs">New Password</span>
							<div class="relative">
								<input type="password" id="newPassword" name="newPassword"
									required placeholder="Enter strong new password" oninput="checkPasswordRequirements(this)">
								<button type="button" onclick="togglePassword('newPassword')"
									class="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 hover:text-blue-600 transition-colors">
									<span class="show-eye">
										<svg class="icon-sm" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
											<path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
											<path stroke-linecap="round" stroke-linejoin="round" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
										</svg>
									</span>
									<span class="hide-eye hidden">
										<svg class="icon-sm" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
											<path stroke-linecap="round" stroke-linejoin="round" d="M3.98 8.223A10.477 10.477 0 001.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.45 10.45 0 0112 4.5c4.756 0 8.773 3.162 10.065 7.498a10.523 10.476 0 01-4.293 5.774M6.228 6.228L3 3m3.228 3.228l3.65 3.65m7.894 7.894L21 21m-3.228-3.228l-3.65-3.65m0 0a3 3 0 10-4.243-4.243m4.242 4.242L9.88 9.88" />
										</svg>
									</span>
								</button>
							</div>
							
							<!-- Dynamic Strength Bar indicators beneath field -->
							<div class="flex items-center justify-between mt-2">
								<div class="flex-1 mr-3">
									<div class="strength-bar-container">
										<div id="strengthProgress" class="strength-bar"></div>
									</div>
								</div>
								<span id="strengthText" class="text-[10px] font-black uppercase text-slate-400">NONE</span>
							</div>
						</div>

						<!-- PREMIUM TOOLTIP CHECKLIST - Styled exactly as image_27a898.png & image_27a115.png -->
						<div id="requirementsTooltip" class="bg-white border border-slate-200 rounded-2xl shadow-xl p-5 w-full mt-4 space-y-3 transition-all duration-300 hidden">
							<span class="text-xs font-bold text-slate-700 block mb-1">PASSWORD MUST INCLUDE:</span>
							<ul class="space-y-2 text-xs">
								<li id="reqLength" class="flex items-center gap-2 font-semibold text-red-500">
									<span class="req-icon text-sm">✕</span>
									<span>8-20 Characters</span>
								</li>
								<li id="reqCapital" class="flex items-center gap-2 font-semibold text-red-500">
									<span class="req-icon text-sm">✕</span>
									<span>At least one capital letter</span>
								</li>
								<li id="reqNumber" class="flex items-center gap-2 font-semibold text-red-500">
									<span class="req-icon text-sm">✕</span>
									<span>At least one number</span>
								</li>
								<li id="reqSymbol" class="flex items-center gap-2 font-semibold text-red-500">
									<span class="req-icon text-sm">✕</span>
									<span>At least one symbol</span>
								</li>
							</ul>
						</div>

						<!-- Confirm Password Field -->
						<div class="space-y-2">
							<span class="label-xs">Confirm New Password</span>
							<div class="relative">
								<input type="password" id="confirmPassword"
									name="confirmPassword" required
									placeholder="Repeat new password" oninput="checkMatch()">
								
								<!-- Dynamic Mismatch / Toggle Password Buttons container -->
								<div class="absolute right-4 top-1/2 -translate-y-1/2 flex items-center gap-2">
									<!-- Red invalid indicator cross icon shown on mismatch as in image_27a115.png -->
									<span id="confirmErrorIcon" class="text-red-500 hidden" title="Passwords do not match">
										<%= XCircleIcon("icon-sm") %>
									</span>
									<button type="button" id="confirmEyeBtn" onclick="togglePassword('confirmPassword')"
										class="text-slate-400 hover:text-blue-600 transition-colors">
										<span class="show-eye">
											<svg class="icon-sm" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
												<path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
												<path stroke-linecap="round" stroke-linejoin="round" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
											</svg>
										</span>
										<span class="hide-eye hidden">
											<svg class="icon-sm" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
												<path stroke-linecap="round" stroke-linejoin="round" d="M3.98 8.223A10.477 10.477 0 001.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.45 10.45 0 0112 4.5c4.756 0 8.773 3.162 10.065 7.498a10.523 10.476 0 01-4.293 5.774M6.228 6.228L3 3m3.228 3.228l3.65 3.65m7.894 7.894L21 21m-3.228-3.228l-3.65-3.65m0 0a3 3 0 10-4.243-4.243m4.242 4.242L9.88 9.88" />
											</svg>
										</span>
									</button>
								</div>
							</div>
						</div>
					</div>

					<div class="pt-4">
						<button type="submit" id="submitBtn"
							class="btn-blue shadow-lg shadow-blue-500/20">
							<%=LockIcon("icon-sm")%>
							Update Password
						</button>
						<a href="Profile"
							class="block text-center mt-5 text-[10px] font-black text-slate-400 hover:text-blue-600 uppercase tracking-widest transition-colors">
							Return to Profile </a>
					</div>
				</form>
			</div>
		</div>
	</main>

	<script>
	// Flag states tracking requirement validity
	let hasMinLength = false;
	let hasCapital = false;
	let hasNumber = false;
	let hasSymbol = false;

	// Checks password parameters against rules to produce image_27a898.png state
	function checkPasswordRequirements(input) {
		const val = input.value;
		const tooltip = document.getElementById('requirementsTooltip');

		// 1. Length check: 8-20 Characters
		hasMinLength = val.length >= 8 && val.length <= 20;
		updateRuleUI('reqLength', hasMinLength);

		// 2. Capital Letter Check: At least one uppercase character
		hasCapital = /[A-Z]/.test(val);
		updateRuleUI('reqCapital', hasCapital);

		// 3. Number check: At least one integer digit
		hasNumber = /[0-9]/.test(val);
		updateRuleUI('reqNumber', hasNumber);

		// 4. Symbol check: At least one symbol character
		hasSymbol = /[!@#$%^&*(),.?":{}|<>_+\-=\[\]\\';`\/~]/.test(val);
		updateRuleUI('reqSymbol', hasSymbol);

		// ✅ REQUIREMENTS COLLAPSE CRITERIA: Tooltip is hidden if password is empty OR meets all 4 rules
		const allMet = hasMinLength && hasCapital && hasNumber && hasSymbol;
		if (val.length === 0 || allMet) {
			tooltip.classList.add('hidden');
		} else {
			tooltip.classList.remove('hidden');
		}

		// Dynamic strength status assessment
		let passedRules = 0;
		if (hasMinLength) passedRules++;
		if (hasCapital) passedRules++;
		if (hasNumber) passedRules++;
		if (hasSymbol) passedRules++;

		const progressBar = document.getElementById('strengthProgress');
		const progressText = document.getElementById('strengthText');

		if (val.length === 0) {
			progressBar.style.width = '0%';
			progressBar.style.backgroundColor = '#f1f5f9';
			progressText.textContent = 'NONE';
			progressText.className = 'text-[10px] font-black uppercase text-slate-400';
		} else if (passedRules < 2) {
			progressBar.style.width = '33%';
			progressBar.style.backgroundColor = '#ef4444'; // Red
			progressText.textContent = 'WEAK';
			progressText.className = 'text-[10px] font-black uppercase text-red-500';
		} else if (passedRules < 4) {
			progressBar.style.width = '66%';
			progressBar.style.backgroundColor = '#f59e0b'; // Yellow (Medium as per image)
			progressText.textContent = 'MEDIUM';
			progressText.className = 'text-[10px] font-black uppercase text-amber-500';
		} else {
			progressBar.style.width = '100%';
			progressBar.style.backgroundColor = '#10b981'; // Green
			progressText.textContent = 'STRONG';
			progressText.className = 'text-[10px] font-black uppercase text-emerald-500';
		}

		checkMatch();
	}

	function updateRuleUI(elementId, isPassed) {
		const element = document.getElementById(elementId);
		if (!element) return;
		const icon = element.querySelector('.req-icon');

		if (isPassed) {
			element.className = 'flex items-center gap-2 font-semibold text-emerald-600';
			icon.innerHTML = '✓';
		} else {
			element.className = 'flex items-center gap-2 font-semibold text-red-500';
			icon.innerHTML = '✕';
		}
	}

	function checkMatch() {
		const newPass = document.getElementById('newPassword').value;
		const confirmPass = document.getElementById('confirmPassword').value;
		const confirmInput = document.getElementById('confirmPassword');
		const errorIcon = document.getElementById('confirmErrorIcon');

		if (confirmPass.length > 0) {
			if (newPass === confirmPass) {
				confirmInput.classList.remove('invalid-field');
				errorIcon.classList.add('hidden');
			} else {
				// ✅ MISMATCH STYLING MATCHES image_27a115.png
				confirmInput.classList.add('invalid-field');
				errorIcon.classList.remove('hidden');
			}
		} else {
			confirmInput.classList.remove('invalid-field');
			errorIcon.classList.add('hidden');
		}
	}

	// Dynamic validateForm block checks fields without system popup windows
	function validateForm(event) {
		const oldPass = document.getElementById('oldPassword').value;
		const newPass = document.getElementById('newPassword').value;
		const confirmPass = document.getElementById('confirmPassword').value;
		
		const alertBox = document.getElementById('jsErrorAlert');
		const alertText = document.getElementById('jsErrorText');
		const card = document.getElementById('formCard');

		let isValid = true;
		let errorMessage = "";

		// Check Old Password Mismatch with New Password
		if (newPass === oldPass && oldPass.length > 0) {
			errorMessage = "NEW PASSWORD CANNOT BE THE SAME AS YOUR CURRENT PASSWORD!";
			isValid = false;
			document.getElementById('newPassword').classList.add('invalid-field');
		} else {
			document.getElementById('newPassword').classList.remove('invalid-field');
		}

		// Check Password Requirements Checklist Validation
		if (isValid && (!hasMinLength || !hasCapital || !hasNumber || !hasNoSpaces)) {
			errorMessage = "PASSWORD DOES NOT MEET ALL SECURITY GUIDELINES!";
			isValid = false;
			document.getElementById('newPassword').classList.add('invalid-field');
		}

		// Check New password matching
		if (isValid && newPass !== confirmPass) {
			errorMessage = "NEW CONFIRMED PASSWORDS DO NOT MATCH!";
			isValid = false;
			document.getElementById('confirmPassword').classList.add('invalid-field');
		} else {
			document.getElementById('confirmPassword').classList.remove('invalid-field');
		}

		if (!isValid) {
			event.preventDefault(); // Stop Jsp submission

			// Show standard customized error notice block (no system alerts)
			alertText.textContent = errorMessage;
			alertBox.classList.remove('hidden');

			// Trigger card shake animation
			card.classList.remove('shake-it');
			card.offsetHeight; // force reflow
			card.classList.add('shake-it');

			// Scroll dynamically to the alert box
			alertBox.scrollIntoView({ behavior: 'smooth', block: 'center' });
			return false;
		}

		return true;
	}

    // Toggles visibility types and flips eye inline icons
    function togglePassword(inputId) {
        const input = document.getElementById(inputId);
        const button = input.nextElementSibling;
        
        let showEye = null;
        let hideEye = null;

        // Custom search to handle confirm input structures cleanly
        if (inputId === 'confirmPassword') {
            const eyeBtn = document.getElementById('confirmEyeBtn');
            showEye = eyeBtn.querySelector('.show-eye');
            hideEye = eyeBtn.querySelector('.hide-eye');
        } else {
            showEye = button.querySelector('.show-eye');
            hideEye = button.querySelector('.hide-eye');
        }

        if (input.type === 'password') {
            input.type = 'text';
            showEye.classList.add('hidden');
            hideEye.classList.remove('hidden');
        } else {
            input.type = 'password';
            showEye.classList.remove('hidden');
            hideEye.classList.add('hidden');
        }
    }

    // Dynamic auto-dismiss notification timer (3 seconds)
    window.addEventListener('DOMContentLoaded', () => {
        const alert = document.getElementById('statusAlert');
        if (alert) {
            setTimeout(() => {
                alert.style.opacity = '0';
                setTimeout(() => { alert.style.display = 'none'; }, 500);
            }, 3000);
        }

        // ✅ CURRENT PASSWORD ERROR MATCH FEEDBACK: If error contains current password mismatch markers, highlight it red immediately on load
        const urlParams = new URLSearchParams(window.location.search);
        const errParam = urlParams.get('error') || "";
        if (errParam.toLowerCase().includes("current") || errParam.toLowerCase().includes("old") || errParam.toLowerCase().includes("login")) {
            const oldPassInput = document.getElementById('oldPassword');
            if (oldPassInput) {
                oldPassInput.classList.add('invalid-field');
                const card = document.getElementById('formCard');
                card.classList.add('shake-it');
            }
        }
    });
</script>

</body>
</html>