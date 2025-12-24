<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%
    if (session.getAttribute("empid") == null) {
        response.sendRedirect("login.jsp?error=Please login.");
        return;
    }

    boolean editMode = "1".equals(request.getParameter("edit"));

    // for avatar initial
    String nm = (request.getAttribute("fullname") != null) ? request.getAttribute("fullname").toString() : "User";
    String init = (!nm.isBlank()) ? (""+nm.charAt(0)).toUpperCase() : "U";

    String profilePic = (request.getAttribute("profilePic") != null) ? String.valueOf(request.getAttribute("profilePic")) : null;
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>My Profile</title>
  <style>
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
      --sb-w: 300px;
      --sb-collapsed: 86px;
      --lockbg:#f1f5f9;
      --lockborder:#e2e8f0;
    }
    *{box-sizing:border-box}
    body{margin:0;font-family:Arial, sans-serif;background:var(--bg);color:var(--text);}

    .content{
     padding:24px;
            padding-left: calc(24px + 300px);
            min-width:0;
    }
    body.sidebar-collapsed .content{
      padding-left: calc(18px + var(--sb-collapsed));
    }
    @media (max-width: 979px){
      .content{ padding-left: 18px; }
    }

    .container{ max-width: 1100px; margin: 0 auto; }

    .headRow{
      display:flex;
      justify-content:space-between;
      align-items:flex-start;
      gap:14px;
      margin:18px 0 14px;
    }
    .pageTitle{ margin:0; font-size:26px; font-weight:900; }
    .pageSub{ margin:6px 0 0; color:var(--muted); }

    .btn{
      border:none;
      border-radius:12px;
      padding:10px 14px;
      font-weight:400;
      cursor:pointer;
      font-size:15px;
      text-decoration:none;
      display:inline-flex;
      align-items:center;
      gap:8px;
    }
    .btnPrimary{ background:var(--primary); color:#fff; }
    .btnPrimary:hover{ background:var(--primary2); }
    .btnGhost{ background:#fff; border:1px solid var(--border); color:var(--text); }
    .btnDanger{ background:#fff; border:1px solid #fecaca; color:#dc2626; }

    .grid{
      display:grid;
      grid-template-columns: 360px 1fr;
      gap: 18px;
      align-items:start;
    }
    @media (max-width: 980px){
      .grid{ grid-template-columns: 1fr; }
    }

    .card{
      background:var(--card);
      border:1px solid var(--border);
      border-radius: var(--radius);
      box-shadow: var(--shadow);
      overflow:hidden;
    }
    .cardPad{ padding:18px; }

    .identity{ text-align:center; }
    .avatar{
      width:120px;height:120px;border-radius:999px;
      margin: 6px auto 12px;
      border:4px solid rgba(37,99,235,0.12);
      display:flex;align-items:center;justify-content:center;
      font-weight:900;font-size:40px;
      background:#2563eb;color:#fff;
      overflow:hidden;
    }
    .avatar img{ width:100%; height:100%; object-fit:cover; display:block; }
    .rolePill{
      display:inline-block;
      margin-top: 10px;
      padding:6px 10px;
      border-radius:999px;
      background: rgba(37,99,235,0.12);
      color: var(--primary);
      font-size:12px;
      font-weight:900;
      letter-spacing:0.3px;
    }

    .sectionHead{
      padding:16px 18px;
      border-bottom:1px solid #eef2f7;
      display:flex;justify-content:space-between;align-items:center;
      gap:12px;
    }
    .sectionHead b{font-size:14px;}
    .hint{font-size:12px;color:var(--muted);}

    .formGrid{
      padding:18px;
      display:grid;
      grid-template-columns: 1fr 1fr;
      gap: 14px 18px;
    }
    @media (max-width: 720px){
      .formGrid{ grid-template-columns: 1fr; }
    }

    .field{display:flex;flex-direction:column;gap:10px;}
    .label{ font-size:13px; line-height: 2.2; font-weight:800; color:#94a3b8; text-transform:uppercase; }
    input, textarea{
      width:100%;
      padding:11px 12px;
      border:1px solid #cbd5e1;
      border-radius:12px;
      font-size:14px;
      background:#fff;
      resize: vertical;
      min-height: 44px;
    }
    textarea{ min-height: 90px; }

    .locked input, .locked textarea{
      background: var(--lockbg);
      border-color: var(--lockborder);
      color:#64748b;
      cursor:not-allowed;
    }

    .span2{ grid-column: span 2; }
    @media (max-width: 720px){
      .span2{ grid-column: span 1; }
    }

    .alerts{ padding: 14px 18px 0; }
    .msg,.err{
      padding:10px 12px;
      border-radius:12px;
      font-size:13px;
      margin-bottom:10px;
    }
    .msg{background:#ecfeff;border:1px solid #a5f3fc;color:#0e7490;}
    .err{background:#fee2e2;border:1px solid #fecaca;color:#b91c1c;}

    .actionsRow{
      padding: 0 18px 18px;
      display:flex;
      justify-content:flex-end;
      gap:10px;
    }
/* ===== VIEW MODE DISPLAY (clean, no grey box) ===== */
.dgrid{
  padding:18px;
  display:grid;
  grid-template-columns:1fr 1fr;
  gap:18px;
}
@media (max-width:720px){
  .dgrid{ grid-template-columns:1fr; }
}
.ditem .label{
  font-size:13px;
  font-weight:900;
  color:#94a3b8;
  text-transform:uppercase;
  margin-bottom:6px;
}
.ditem .value{
  font-weight:400;
  color:#0f172a;
  line-height:1.35;
}
.dspan2{ grid-column:span 2; }
@media (max-width:720px){
  .dspan2{ grid-column:span 1; }
}


    .helpText{ font-size:12px; color:var(--muted); margin-top:6px; }
  </style>
</head>
<body>

<jsp:include page="sidebar.jsp" />
  <jsp:include page="topbar.jsp" />

<div class="content">


  <div class="container">

    <div class="headRow">
      <div>
        <h1 class="pageTitle">My Profile</h1>
        <p class="pageSub">
          <%= editMode ? "Edit your contact information and profile picture." : "View your profile details." %>
        </p>
      </div>

      <div>
        <% if (!editMode) { %>
          <a class="btn btnPrimary" href="ProfileServlet?edit=1">✏️ Edit Profile</a>
        <% } %>
      </div>
    </div>

    <div class="grid">

      <!-- Left column -->
      <div class="card">
        <div class="cardPad identity">
          <div class="avatar">
            <% if (profilePic != null && !profilePic.isBlank()) { %>
              <img src="<%= profilePic %>" alt="Profile">
            <% } else { %>
              <%= init %>
            <% } %>
          </div>

          <div style="font-size:20px;font-weight:700;">
            <c:out value="${fullname}"/>
          </div>
          <div style="color:var(--muted);font-size:13px;margin-top:4px;">
            <c:out value="${email}"/>
          </div>

          <div class="rolePill"><c:out value="${role}"/></div>
        </div>

        <div class="cardPad">
          <div style="font-weight:900;margin:0 0 10px;padding-bottom:10px;border-bottom:1px solid #eef2f7;">
            Official Details
          </div>

          <div style="display:grid; gap:20px;">
            <div>
              <div class="label">Employee ID</div>
              <div style="font-weight:500;"><c:out value="${empid}"/></div>
            </div>
            <div>
              <div class="label">Hire Date</div>
              <div style="font-weight:500;"><c:out value="${hireDate}"/></div>
            </div>
            <c:if test="${not empty icNumber}">
              <div>
                <div class="label">IC Number</div>
                <div style="font-weight:500;"><c:out value="${icNumber}"/></div>
              </div>
            </c:if>
          </div>
        </div>
      </div>

      <!-- Right column -->
      <div class="card">

        <div class="sectionHead">
          <div>
            <b>Personal Information</b><br/>
            <span class="hint">Only Email, Phone, Address & Profile Picture can be edited.</span>
          </div>
          <div class="hint">
            <%= editMode ? "Edit Mode" : "View Mode" %>
          </div>
        </div>

        <div class="alerts">
          <c:if test="${not empty param.msg}">
            <div class="msg">${param.msg}</div>
          </c:if>
          <c:if test="${not empty param.error}">
            <div class="err">${param.error}</div>
          </c:if>
        </div>

        <% if (!editMode) { %>

        <!-- ✅ VIEW MODE (clean display, no boxes) -->
        <div class="dgrid">

          <div class="ditem">
            <div class="label">Full Name</div>
            <div class="value"><c:out value="${fullname}"/></div>
          </div>

          <div class="ditem">
            <div class="label">Role</div>
            <div class="value"><c:out value="${role}"/></div>
          </div>

          <div class="ditem">
            <div class="label">Email</div>
            <div class="value"><c:out value="${email}"/></div>
          </div>

          <div class="ditem">
            <div class="label">Phone</div>
            <div class="value"><c:out value="${phone}"/></div>
          </div>

          <div class="ditem dspan2">
            <div class="label">Address</div>
            <div class="value"><c:out value="${address}"/></div>
          </div>

          <c:if test="${not empty gender}">
            <div class="ditem">
              <div class="label">Gender</div>
              <div class="value"><c:out value="${gender}"/></div>
            </div>
          </c:if>

          <c:if test="${not empty icNumber}">
            <div class="ditem">
              <div class="label">IC Number</div>
              <div class="value"><c:out value="${icNumber}"/></div>
            </div>
          </c:if>

        </div>

      <%
          } else {
        %>
          <!-- EDIT MODE -->
          <form action="ProfileServlet" method="post" enctype="multipart/form-data">
            <div class="formGrid">

              <!-- locked fields -->
              <div class="field locked">
                <div class="label">Full Name</div>
                <input value="<c:out value='${fullname}'/>" disabled>
              </div>

              <div class="field locked">
                <div class="label">Role </div>
                <input value="<c:out value='${role}'/>" disabled>
              </div>

              <div class="field">
                <div class="label">Email *</div>
                <input name="email" type="email" value="<c:out value='${email}'/>" required>
              </div>

              <div class="field">
                <div class="label">Phone</div>
                <input name="phone" type="text" value="<c:out value='${phone}'/>" placeholder="e.g., 01xxxxxxxx">
              </div>

              <div class="field span2">
                <div class="label">Address</div>
                <textarea name="address" placeholder="e.g., Melaka"><c:out value="${address}"/></textarea>
              </div>

              <div class="field span2">
                <div class="label">Profile Picture (Upload)</div>
                <input name="profilePic" type="file" accept="image/*">
                <div class="helpText">Allowed: image files only. Max 5MB.</div>
              </div>

              <c:if test="${not empty gender}">
                <div class="field locked">
                  <div class="label">Gender</div>
                  <input value="<c:out value='${gender}'/>" disabled>
                </div>
              </c:if>

              <c:if test="${not empty icNumber}">
                <div class="field locked">
                  <div class="label">IC Number</div>
                  <input value="<c:out value='${icNumber}'/>" disabled>
                </div>
              </c:if>

            </div>

            <div class="actionsRow">
              <a class="btn btnGhost" href="ProfileServlet">Cancel</a>
              <button class="btn btnPrimary" type="submit">💾 Save Changes</button>
            </div>
          </form>
        <%
          }
        %>

      </div>

    </div>
  </div>
</div>
</body>
</html>
