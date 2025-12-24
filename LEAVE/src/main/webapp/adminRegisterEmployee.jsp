<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%
    if (session.getAttribute("empid") == null || session.getAttribute("role") == null ||
        !"ADMIN".equalsIgnoreCase(String.valueOf(session.getAttribute("role")))) {
        response.sendRedirect("login.jsp?error=Please login as admin.");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Register Employee</title>
    <style>
        :root{
            --bg:#f4f6fb;
            --card:#ffffff;
            --border:#e5e7eb;
            --text:#0f172a;
            --muted:#64748b;
            --primary:#2563eb;
            --primary2:#1d4ed8;
            --dangerBg:#fee2e2;
            --dangerBorder:#fecaca;
            --infoBg:#ecfeff;
            --infoBorder:#a5f3fc;
            --shadow:0 10px 25px rgba(0,0,0,0.06);
            --radius:16px;
        }

        *{box-sizing:border-box}
        body{font-family:Arial, sans-serif;background:var(--bg);margin:0;color:var(--text);}
      .layout{min-height:100vh;}

.content{
  padding:24px;
  padding-left: calc(24px + 300px);
}

body.sidebar-collapsed .content{
  padding-left: calc(24px + 86px);
}

@media (max-width: 979px){
  .content{ padding-left: 24px; }
}



        /* Content area */
        .content{
            flex:1;
            padding:24px;
            min-width: 0;
        }

        /* Center container */
        .container{
            max-width: 980px;
            margin: 0 auto;
        }

        /* Page header */
        .pageHeader{
            display:flex;
            justify-content:space-between;
            align-items:flex-start;
            gap:16px;
            margin-bottom:16px;
        }
        .pageTitle{
            margin:0;
            font-size:22px;
            font-weight:800;
            letter-spacing:0.2px;
        }
        .pageSub{
            margin:6px 0 0;
            color:var(--muted);
            font-size:13px;
            line-height:1.4;
        }

        /* Top nav (tab-like) */
        .tabs{
            display:flex;
            gap:10px;
            margin: 14px 0 18px;
        }
        .tab{
            text-decoration:none;
            font-weight:800;
            font-size:13px;
            padding:10px 12px;
            border-radius:12px;
            border:1px solid var(--border);
            background:#fff;
            color:var(--text);
        }
        .tab.active{
            border-color: rgba(37,99,235,0.35);
            background: rgba(37,99,235,0.08);
            color: var(--primary);
        }

        /* Alerts */
        .msg, .err{
            padding:10px 12px;
            border-radius:12px;
            font-size:13px;
            margin-bottom:12px;
        }
        .msg{background:var(--infoBg);border:1px solid var(--infoBorder);color:#0e7490;}
        .err{background:var(--dangerBg);border:1px solid var(--dangerBorder);color:#b91c1c;}

        /* Card */
        .card{
            background:var(--card);
            border:1px solid var(--border);
            border-radius:var(--radius);
            box-shadow:var(--shadow);
            overflow:hidden;
        }

        .cardHead{
            padding:16px 18px;
            border-bottom:1px solid #eef2f7;
            display:flex;
            justify-content:space-between;
            align-items:center;
            gap:12px;
        }
        .cardHead b{font-size:14px;}
        .hint{font-size:12px;color:var(--muted);}

        .cardBody{padding:18px;}

        /* Form layout */
        .grid{
            display:grid;
            grid-template-columns: 1fr 1fr;
            gap:14px;
        }
        .field{display:flex;flex-direction:column;gap:6px;}
        label{font-size:12px;font-weight:800;color:#334155;}
        input, select{
            width:100%;
            padding:11px 12px;
            border:1px solid #cbd5e1;
            border-radius:12px;
            font-size:14px;
            background:#fff;
        }
        input:focus, select:focus{
            outline:none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(37,99,235,0.18);
        }
        .span2{grid-column: span 2;}

        .actions{
            display:flex;
            justify-content:flex-end;
            gap:10px;
            margin-top: 6px;
        }
        .btn{
            padding:11px 14px;
            border:none;
            border-radius:12px;
            font-weight:900;
            cursor:pointer;
            font-size:13px;
        }
        .btnPrimary{background:var(--primary);color:#fff;}
        .btnPrimary:hover{background:var(--primary2);}
        .btnGhost{
            background:#fff;
            border:1px solid var(--border);
            color:var(--text);
        }

        /* Responsive */
        @media (max-width: 860px){
            .grid{grid-template-columns: 1fr;}
            .span2{grid-column: span 1;}
            .pageHeader{flex-direction:column;}
        }
        
        /* ✅ Reserve space for sidebar (desktop) */
.content{
  margin-left: 300px; /* same as --sb-w */
}

/* bila sidebar collapsed */
body.sidebar-collapsed .content{
  margin-left: 86px; /* same as --sb-collapsed */
}

/* mobile: content full width */
@media (max-width: 979px){
  .content{ margin-left: 0; }
}
        
        
    </style>
</head>

<body>
<div class="layout">
<jsp:include page="sidebar.jsp" />
<jsp:include page="topbar.jsp" />


    <div class="content">
        <div class="container">

            <div class="pageHeader">
                <div>
                    <h2 class="pageTitle">Register Employee</h2>
                    <p class="pageSub">Create a new employee/admin account. Use a valid email because it will be used for login.</p>
                </div>
            </div>

            <div class="tabs">
                <a class="tab active" href="RegisterEmployeeServlet">Register Employee</a>
                <a class="tab" href="EmployeeDirectoryServlet">Employee Directory</a>
            </div>

            <c:if test="${not empty param.msg}">
                <div class="msg">${param.msg}</div>
            </c:if>
            <c:if test="${not empty param.error}">
                <div class="err">${param.error}</div>
            </c:if>

            <div class="card">
                <div class="cardHead">
                    <div>
                        <b>Employee Details</b><br>
                        <span class="hint">Fields marked required must be filled.</span>
                    </div>
                    <span class="hint">Role-based access: Admin only</span>
                </div>

                <div class="cardBody">
                    <form action="RegisterEmployeeServlet" method="post">
                        <div class="grid">
                            <div class="field span2">
                                <label>Full Name *</label>
                                <input type="text" name="fullname" placeholder="e.g., Ali Bin Abu" required>
                            </div>

                            <div class="field">
                                <label>Email *</label>
                                <input type="email" name="email" placeholder="e.g., ali@company.com" required>
                            </div>

                            <div class="field">
                                <label>Password *</label>
                                <input type="password" name="password" placeholder="Create a password" required>
                            </div>

                            <div class="field">
                                <label>IC Number *</label>
                                <input type="text" name="icNumber" placeholder="e.g., 010203041234" required>
                            </div>

                            <div class="field">
                                <label>Gender *</label>
                                <select name="gender" required>
                                    <option value="M">Male</option>
                                    <option value="F">Female</option>
                                </select>
                            </div>

                            <div class="field">
                                <label>Phone No</label>
                                <input type="text" name="phoneNo" placeholder="e.g., 01xxxxxxxx">
                            </div>

                            <div class="field">
                                <label>Hire Date *</label>
                                <input type="date" name="hireDate" required>
                            </div>

                            <div class="field span2">
                                <label>Address</label>
                                <input type="text" name="address" placeholder="e.g., Melaka">
                            </div>

                            <div class="field span2">
                                <label>Role *</label>
                                <select name="role" required>
                                    <option value="EMPLOYEE">EMPLOYEE</option>
                                    <option value="ADMIN">ADMIN</option>
                                </select>
                            </div>
                        </div>

                        <div class="actions">
                            <a class="btn btnGhost" href="EmployeeDirectoryServlet" style="text-decoration:none;display:inline-flex;align-items:center;">
                                View Directory
                            </a>
                            <button class="btn btnPrimary" type="submit">Create Account</button>
                        </div>
                    </form>
                </div>
            </div>

        </div><!-- /container -->
    </div><!-- /content -->
</div><!-- /layout -->
</body>
</html>
