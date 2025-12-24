<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<%
    if (session.getAttribute("empid") == null ||
        session.getAttribute("role") == null ||
        !"ADMIN".equalsIgnoreCase(String.valueOf(session.getAttribute("role")))) {
        response.sendRedirect("login.jsp?error=Please login as admin.");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Employee Directory</title>

    <!-- Sidebar CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">

    <style>
        /* ===== SAME DESIGN SYSTEM AS RegisterEmployee ===== */
        :root{
            --bg:#f4f6fb;
            --card:#ffffff;
            --border:#e5e7eb;
            --text:#0f172a;
            --muted:#64748b;
            --primary:#2563eb;
            --primary2:#1d4ed8;
            --shadow:0 10px 25px rgba(0,0,0,0.06);
            --radius:16px;
        }

        *{box-sizing:border-box}
        body{margin:0;font-family:Arial;background:var(--bg);color:var(--text);}
        .layout{min-height:100vh;}

        .content{
            padding:24px;
            padding-left: calc(24px + 300px);
        }
        body.sidebar-collapsed .content{
            padding-left: calc(24px + 86px);
        }
        @media (max-width:979px){
            .content{padding-left:24px;}
        }

        .container{
            max-width: 980px;
            margin: 0 auto;
        }

        .pageHeader{
            margin-bottom: 16px;
        }
        .pageTitle{
            margin:0;
            font-size:22px;
            font-weight:800;
        }
        .pageSub{
            margin-top:6px;
            font-size:13px;
            color:var(--muted);
        }

        /* Tabs */
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

        /* Card */
        .card{
            background:#fff;
            border:1px solid var(--border);
            border-radius:var(--radius);
            box-shadow:var(--shadow);
            overflow:hidden;
        }
        .cardHead{
            padding:16px 18px;
            border-bottom:1px solid #eef2f7;
            font-weight:800;
            font-size:14px;
        }
        .cardBody{
            padding:0;
        }

        /* Table */
        table{
            width:100%;
            border-collapse:collapse;
        }
        th,td{
            border-bottom:1px solid #eef2f7;
            padding:14px;
            text-align:left;
            vertical-align:top;
        }
        th{
            background:#f8fafc;
            font-size:12px;
            text-transform:uppercase;
            color:#334155;
        }
        .small{
            font-size:12px;
            color:#64748b;
        }

        .btnDel{
            border:1px solid #fecaca;
            background:#fff;
            color:#dc2626;
            font-weight:800;
            padding:6px 10px;
            border-radius:10px;
            cursor:pointer;
        }
    </style>
</head>

<body>
<div class="layout">

    <!-- Sidebar -->
    <jsp:include page="sidebar.jsp" />
<jsp:include page="topbar.jsp" />
    

    <div class="content">
        <div class="container">

            <div class="pageHeader">
                <h2 class="pageTitle">Employee Directory</h2>
                <p class="pageSub">View and manage registered employees.</p>
            </div>

            <!-- SAME TABS -->
            <div class="tabs">
                <a class="tab" href="RegisterEmployeeServlet">Register Employee</a>
                <a class="tab active" href="EmployeeDirectoryServlet">Employee Directory</a>
            </div>

            <c:if test="${not empty param.msg}">
                <div class="msg">${param.msg}</div>
            </c:if>
            <c:if test="${not empty param.error}">
                <div class="err">${param.error}</div>
            </c:if>

            <div class="card">
                <div class="cardHead">Employees</div>
                <div class="cardBody">
                    <table>
                        <thead>
                        <tr>
                            <th>Name / Role</th>
                            <th>Contact</th>
                            <th>Hire Date</th>
                            <th style="width:140px;">Action</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                            List<Map<String,Object>> users =
                                    (List<Map<String,Object>>) request.getAttribute("users");

                            if (users == null || users.isEmpty()) {
                        %>
                            <tr>
                                <td colspan="4" style="padding:18px;">No users found.</td>
                            </tr>
                        <%
                            } else {
                                for (Map<String,Object> u : users) {
                                    int empid = (Integer) u.get("empid");
                                    String fullname = String.valueOf(u.get("fullname"));
                                    String email = String.valueOf(u.get("email"));
                                    String role = String.valueOf(u.get("role"));
                                    String phone = String.valueOf(u.get("phone"));
                                    Object hiredate = u.get("hiredate");

                                    boolean isAdmin = "ADMIN".equalsIgnoreCase(role);
                        %>
                            <tr>
                                <td>
                                    <b><%= fullname %></b><br>
                                    <span class="small"><%= role %></span><br>
                                    <span class="small">EMPID: <%= empid %></span>
                                </td>
                                <td>
                                    <div><%= email %></div>
                                    <div class="small"><%= phone==null?"":phone %></div>
                                </td>
                                <td><%= hiredate %></td>
                                <td>
                                    <% if (!isAdmin) { %>
                                        <form action="DeleteEmployeeServlet" method="post"
                                              onsubmit="return confirm('Delete this employee?');">
                                            <input type="hidden" name="empid" value="<%= empid %>">
                                            <button class="btnDel" type="submit">Delete</button>
                                        </form>
                                    <% } else { %>
                                        <span class="small">Protected</span>
                                    <% } %>
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
    </div>
</div>
</body>
</html>
