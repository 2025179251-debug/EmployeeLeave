<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>
<%@ include file="icon.jsp" %>

<%
    String fullName = (session.getAttribute("fullname") != null)
            ? session.getAttribute("fullname").toString()
            : "User";

    String role = (session.getAttribute("role") != null)
            ? session.getAttribute("role").toString()
            : "EMPLOYEE";
%>

<link rel="stylesheet" href="sidebar.css" />

<aside id="appSidebar" class="sidebar">
    <div class="sidebar-header">
        <div class="logo-box">
            <img src="https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRNhLlRcJ19hFyLWQOGP3EWiaxRZiHWupjWp6xtRzs5cdMeCUzu" alt="Clinic Logo" />
        </div>

        <div class="brand-text">
            <h1>KLINIK <br>DR MOHAMAD</h1>
        </div>
    </div>

    <div class="sidebar-section-title" style="padding-left:14px; font-size:10px; opacity:0.5; margin-bottom:10px; text-transform:uppercase;">
        <%= role.equalsIgnoreCase("ADMIN") ? "Admin Panel" : "Menu Utama" %>
    </div>

    <nav class="sidebar-nav">
        <% if (!role.equalsIgnoreCase("ADMIN")) { %>
            <a href="EmployeeDashboardServlet" class="nav-item">
                <span class="nav-icon"><%= HomeIcon("icon-sm") %></span>
                <span class="nav-label">Dashboard</span>
            </a>
            <a href="ApplyLeaveServlet" class="nav-item">
                <span class="nav-icon"><%= FilePlusIcon("icon-sm") %></span>
                <span class="nav-label">Apply Leave</span>
            </a>
            <a href="LeaveHistoryServlet" class="nav-item">
                <span class="nav-icon"><%= ListIcon("icon-sm") %></span>
                <span class="nav-label">My History</span>
            </a>
        <% } else { %>
            <a href="AdminDashboardServlet" class="nav-item">
                <span class="nav-icon"><%= BriefcaseIcon("icon-sm") %></span>
                <span class="nav-label">Admin Dashboard</span>
            </a>
            <a href="RegisterEmployeeServlet" class="nav-item">
                <span class="nav-icon"><%= UsersIcon("icon-sm") %></span>
                <span class="nav-label">Register Employee</span>
            </a>
            <a href="ManageHolidayServlet" class="nav-item">
                <span class="nav-icon"><%= CalendarIcon("icon-sm") %></span>
                <span class="nav-label">Manage Holidays</span>
            </a>
        <% } %>
    </nav>

    <div class="sidebar-footer">
        <a href="LogoutServlet" class="nav-item logout-btn">
            <span class="nav-icon"><%= LogOutIcon("icon-sm") %></span>
            <span class="nav-label">Sign Out</span>
        </a>
        <div class="version-box" style="font-size: 10px; opacity: 0.4; text-align: center; margin-top: 10px;">v1.2.1</div>
    </div>
</aside>

<div id="sidebarOverlay" class="sidebar-overlay" onclick="closeSidebar()" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.5); z-index:999;"></div>

<script>
  function toggleSidebar() {
    const sb = document.getElementById("appSidebar");
    const ov = document.getElementById("sidebarOverlay");

    if (window.innerWidth >= 980) {
      // Desktop: Pakai collapsed mode
      sb.classList.toggle("collapsed");
      document.body.classList.toggle("sidebar-collapsed");
    } else {
      // Mobile: Pakai slide-in drawer
      sb.classList.add("open");
      ov.style.display = "block";
    }
  }

  function closeSidebar() {
    const sb = document.getElementById("appSidebar");
    const ov = document.getElementById("sidebarOverlay");
    sb.classList.remove("open");
    ov.style.display = "none";
  }

  // Automatik tutup sidebar kalau user besarkan skrin balik
  window.addEventListener("resize", () => {
    if (window.innerWidth >= 980) closeSidebar();
  });
</script>