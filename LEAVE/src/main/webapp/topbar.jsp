<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>

<%
    String fullNameTB = (session.getAttribute("fullname") != null)
            ? session.getAttribute("fullname").toString()
            : "User";

    String roleTB = (session.getAttribute("role") != null)
            ? session.getAttribute("role").toString()
            : "EMPLOYEE";

    // optional kalau ada simpan URL gambar dalam session
    String profilePic = (session.getAttribute("profilePic") != null)
            ? session.getAttribute("profilePic").toString()
            : null;
    
    String initial = (fullNameTB != null && !fullNameTB.isBlank()) ? ("" + fullNameTB.charAt(0)).toUpperCase() : "U";
%>

<style>
 .topbar{
  height:64px;
  background:#fff;
  border-bottom:1px solid #e5e7eb;
  display:flex;
  align-items:center;
  justify-content:space-between;
  padding:0 18px;

  /* 🔥 ini yang betulkan */
  padding-left: calc(18px + var(--sb-w));
  position: sticky;
  top: 0;
  z-index: 20;
}

/* bila sidebar collapse */
body.sidebar-collapsed .topbar{
  padding-left: calc(18px + var(--sb-collapsed));
}

/* mobile: sidebar slide-in, topbar full */
@media (max-width: 979px){
  .topbar{
    padding-left: 18px;
  }
}
  .topbar-title{ font-weight:900; color:#334155; }
  .topbar-right{ display:flex; align-items:center; gap:14px; }
  .tb-bell{
    width:38px; height:38px;
    border-radius:999px;
    border:1px solid #e5e7eb;
    background:#fff;
    cursor:pointer;
  }
  .tb-profile{
    display:flex;
    align-items:center;
    gap:10px;
    padding-left:14px;
    border-left:1px solid #e5e7eb;
    text-decoration:none;
    color:inherit;
  }
  .tb-name{ text-align:right; line-height:1.1; }
  .tb-name .n{ font-weight:900; font-size:13px; color:#0f172a; }
  .tb-name .r{ font-size:11px; color:#64748b; font-weight:800; letter-spacing:0.4px; }
  .tb-avatar{
    width:40px; height:40px;
    border-radius:999px;
    overflow:hidden;
    border:2px solid #f1f5f9;
    display:flex;
    align-items:center;
    justify-content:center;
    font-weight:900;
    background:#2563eb;
    color:#fff;
  }
  .tb-avatar img{ width:100%; height:100%; object-fit:cover; display:block; }
</style>

<header class="topbar">
  <div class="topbar-title">
    <%= roleTB.equalsIgnoreCase("ADMIN") ? "Admin Portal" : "Employee Portal" %>
  </div>

  <div class="topbar-right">
    <button class="tb-bell" title="Notifications" type="button">🔔</button>

    <a class="tb-profile" href="ProfileServlet" title="Go to My Profile">
      <div class="tb-name">
        <div class="n"><%= fullNameTB %></div>
        <div class="r"><%= roleTB.toUpperCase() %></div>
      </div>

      <div class="tb-avatar">
        <% if (profilePic != null && !profilePic.isBlank()) { %>
          <img src="<%= profilePic %>" alt="Profile">
        <% } else { %>
          <%= initial %>
        <% } %>
      </div>
    </a>
  </div>
</header>
