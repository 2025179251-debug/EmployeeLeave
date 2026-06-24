<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ include file="icon.jsp"%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Employee Login | Klinik Dr Mohamad</title>
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">

<style>
:root {
	--bg-gradient: radial-gradient(circle at top right, #eff6ff 0%, #e0f2fe 30%, #f1f5f9 100%);
	--primary: #2563eb;
	--primary-hover: #1d4ed8;
	--card-bg: rgba(255, 255, 255, 0.95);
	--text-primary: #0f172a;
	--text-secondary: #475569;
}

* {
	box-sizing: border-box;
	font-family: 'Inter', sans-serif !important;
}

body {
	margin: 0;
	padding: 0;
	background: var(--bg-gradient);
	min-height: 100vh;
	display: flex;
	align-items: center;
	justify-content: center;
	position: relative;
	overflow-x: hidden;
}

/* Abstract Clinical Background Shapes */
.bg-circle-1 {
	position: absolute;
	width: 500px;
	height: 500px;
	border-radius: 50%;
	background: radial-gradient(circle, rgba(14, 165, 233, 0.15) 0%, rgba(255, 255, 255, 0) 70%);
	top: -10%;
	right: -5%;
	z-index: 1;
	pointer-events: none;
}

.bg-circle-2 {
	position: absolute;
	width: 600px;
	height: 600px;
	border-radius: 50%;
	background: radial-gradient(circle, rgba(37, 99, 235, 0.1) 0%, rgba(255, 255, 255, 0) 70%);
	bottom: -15%;
	left: -10%;
	z-index: 1;
	pointer-events: none;
}

.card {
	background: var(--card-bg);
	width: 440px;
	border-radius: 24px;
	border: 1px solid rgba(255, 255, 255, 0.7);
	box-shadow: 0 25px 50px -12px rgba(15, 23, 42, 0.08), 0 0 0 1px rgba(15, 23, 42, 0.02);
	overflow: hidden;
	z-index: 10;
	backdrop-filter: blur(8px);
	transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.card:hover {
	transform: translateY(-2px);
	box-shadow: 0 30px 60px -15px rgba(15, 23, 42, 0.12), 0 0 0 1px rgba(15, 23, 42, 0.02);
}

.card-header {
	background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 100%);
	padding: 40px 32px 32px;
	text-align: center;
	position: relative;
	overflow: hidden;
}

/* Subtle diagnostic lines behind card header */
.card-header::before {
	content: '';
	position: absolute;
	inset: 0;
	background: linear-gradient(rgba(255, 255, 255, 0.05) 1px, transparent 1px),
	            linear-gradient(90deg, rgba(255, 255, 255, 0.05) 1px, transparent 1px);
	background-size: 20px 20px;
	pointer-events: none;
}

.card-header h1 {
	margin: 0;
	font-size: 22px;
	font-weight: 850;
	letter-spacing: -0.03em;
	color: #ffffff;
}

.card-header p {
	margin: 6px 0 0;
	font-size: 13px;
	font-weight: 500;
	color: rgba(255, 255, 255, 0.85);
}

.card-body {
	padding: 36px 36px 40px;
}

.form-group {
	margin-bottom: 20px;
}

label {
	display: block;
	margin-bottom: 6px;
	font-size: 11px;
	color: #1e293b;
	font-weight: 850;
	text-transform: uppercase;
	letter-spacing: 0.05em;
}

input[type="email"], input[type="password"], input[type="text"] {
	width: 100% !important;
	height: 50px;
	padding: 0 16px;
	border-radius: 12px;
	border: 2px solid #e2e8f0;
	font-size: 14px;
	font-weight: 550;
	color: var(--text-primary);
	transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
	background: #ffffff;
}

input[type="email"]::placeholder, input[type="password"]::placeholder {
	color: #94a3b8;
}

input[type="email"]:focus, input[type="password"]:focus, input[type="text"]:focus {
	outline: none;
	border-color: var(--primary);
	box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.1);
	background: #ffffff;
}

.password-wrapper {
	position: relative;
	width: 100%;
}

.password-wrapper input {
	padding-right: 48px !important;
}

.toggle-btn {
	position: absolute;
	right: 14px;
	top: 50%;
	transform: translateY(-50%);
	background: none;
	border: none;
	cursor: pointer;
	color: #64748b;
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 4px;
	outline: none;
	transition: color 0.2s;
}

.toggle-btn:hover {
	color: var(--primary);
}

.btn-primary {
	width: 100%;
	height: 50px;
	border-radius: 12px;
	border: none;
	background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
	color: white;
	font-size: 14px;
	font-weight: 800;
	text-transform: uppercase;
	letter-spacing: 0.05em;
	cursor: pointer;
	margin-top: 10px;
	transition: all 0.2s ease;
	box-shadow: 0 4px 12px rgba(37, 99, 235, 0.15);
}

.btn-primary:hover {
	transform: translateY(-1px);
	box-shadow: 0 6px 20px rgba(37, 99, 235, 0.25);
}

.btn-primary:active {
	transform: translateY(0);
}

.alert-error {
	background: #fff5f5;
	color: #e11d48;
	border: 1px solid #ffe4e6;
	padding: 12px 16px;
	border-radius: 12px;
	font-size: 13px;
	font-weight: 600;
	margin-bottom: 20px;
	display: flex;
	align-items: center;
	gap: 10px;
	box-shadow: 0 4px 6px -1px rgba(225, 29, 72, 0.05);
}

.demo-box {
	background: #f0fdf4;
	color: #166534;
	border: 1px solid #dcfce7;
	padding: 12px 16px;
	border-radius: 12px;
	font-size: 13px;
	font-weight: 600;
	margin-bottom: 20px;
	display: flex;
	align-items: center;
	gap: 10px;
	box-shadow: 0 4px 6px -1px rgba(22, 101, 52, 0.05);
}
</style>
</head>
<body>

	<!-- Ambient Medical Circles -->
	<div class="bg-circle-1"></div>
	<div class="bg-circle-2"></div>

	<div class="card">
		<div class="card-header flex flex-col items-center">
			<div class="flex justify-center mb-4 relative z-10">
				<!-- Brand Identity Profile Image with Double Soft Ring Shadow -->
				<div class="relative p-1.5 bg-white/10 rounded-2xl backdrop-blur-md">
					<img
						src="https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRNhLlRcJ19hFyLWQOGP3EWiaxRZiHWupjWp6xtRzs5cdMeCUzu"
						alt="Logo Klinik"
						class="w-16 h-16 object-contain bg-white rounded-xl p-1.5 shadow-sm">
				</div>
			</div>
			<h1>Klinik Dr Mohamad</h1>
			<p>Employee Portal Management</p>
		</div>

		<div class="card-body">
			<!-- Secure parameter outputs protected via JSTL escaping blocks and dot stripped dynamically -->
			<c:if test="${not empty param.error}">
				<div class="alert-error">
					<svg class="w-5 h-5 flex-shrink-0" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path>
					</svg>
					<span class="block uppercase text-xs font-bold tracking-wide">
						<c:out value="${fn:replace(param.error, '.', '')}" />
					</span>
				</div>
			</c:if>

			<c:if test="${not empty param.msg}">
				<div class="demo-box">
					<svg class="w-5 h-5 flex-shrink-0" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
					</svg>
					<span class="block uppercase text-xs font-bold tracking-wide">
						<c:out value="${fn:replace(param.msg, '.', '')}" />
					</span>
				</div>
			</c:if>

			<form action="LoginServlet" method="post">
				<div class="form-group">
					<label for="email">Work Email Address</label> 
					<input type="email" id="email" name="email" placeholder="you@klinik.com" required />
				</div>

				<div class="form-group">
					<label for="password">System Password</label>
					<div class="password-wrapper">
						<input type="password" id="password" name="password" placeholder="Enter your password" required />

						<button type="button" class="toggle-btn" onclick="togglePasswordVisibility()" title="Toggle password visibility">
							<!-- Eye Open Icon (Visible by Default) -->
							<svg id="eyeOpenIcon" class="w-5 h-5" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
								<path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
								<path stroke-linecap="round" stroke-linejoin="round" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
							</svg>
							<!-- Eye Closed Slashed Icon (Initially Hidden) -->
							<svg id="eyeCloseIcon" class="w-5 h-5 hidden" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
								<path stroke-linecap="round" stroke-linejoin="round" d="M3.98 8.223A10.477 10.477 0 001.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.45 10.45 0 0112 4.5c4.756 0 8.773 3.162 10.065 7.498a10.523 10.523 0 01-4.293 5.774M6.228 6.228L3 3m3.228 3.228l3.65 3.65m7.894 7.894L21 21m-3.228-3.228l-3.65-3.65m0 0a3 3 0 10-4.243-4.243m4.242 4.242L9.88 9.88" />
							</svg>
						</button>
					</div>
				</div>

				<button type="submit" class="btn-primary">Log In</button>
			</form>
		</div>
	</div>

	<script>
		// Dynamic client-side eye visibility switcher routine
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
	</script>
</body>
</html>