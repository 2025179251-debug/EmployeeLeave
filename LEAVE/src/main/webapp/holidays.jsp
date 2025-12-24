<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>


<%
    // Admin guard
    if (session.getAttribute("empid") == null || session.getAttribute("role") == null ||
        !"ADMIN".equalsIgnoreCase(String.valueOf(session.getAttribute("role")))) {
        response.sendRedirect("login.jsp?error=Please login as admin.");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>

  <style>
    :root{
      --bg:#f4f6fb;
      --card:#ffffff;
      --border:#e5e7eb;
      --text:#0f172a;
      --muted:#64748b;
      --primary:#2563eb;
      --shadow:0 10px 25px rgba(0,0,0,0.06);
      --radius:16px;

      /* match sidebar.css variables */
      --sb-w: 300px;
      --sb-collapsed: 86px;
    }
    *{box-sizing:border-box}
    body{
      margin:0;
      font-family: Arial, sans-serif;
      background: var(--bg);
      color: var(--text);
    }

    /* ✅ content ikut sidebar width + NO GAP atas */

       .content{
            padding:24px;
            padding-left: calc(24px + 300px);
            min-width:0;
        }
    }
    body.sidebar-collapsed .content{
      padding-left: calc(24px + var(--sb-collapsed));
    }
    @media (max-width: 979px){
      .content{ padding-left: 18px; padding-right:18px; }
    }

    .container{ max-width: 1100px; margin: 0 auto; }

    
    .pageHeader{
      display:flex;
      align-items:flex-start;
      justify-content:space-between;
      gap:16px;
      margin-bottom: 16px;
    }
    .pageTitle{
      margin:0;
      font-size: 26px;
      font-weight: 900;
      letter-spacing: 0.2px;
    }    
    .pageSub{
      margin: 6px 0 0;
      color: var(--muted);
      font-size: 14px;
    }
    .pageHeader{margin-bottom:16px;}
        .pageTitle{margin:0;font-size:22px;font-weight:800;}
        .pageSub{margin-top:6px;font-size:13px;color:var(--muted);}

    .grid{
      display:grid;
      grid-template-columns: 380px 1fr;
      gap: 18px;
      align-items:start;
    }
    @media (max-width: 980px){
      .grid{ grid-template-columns: 1fr; }
    }

    .card{
      background: var(--card);
      border: 1px solid var(--border);
      border-radius: var(--radius);
      box-shadow: var(--shadow);
      overflow:hidden;
    }
    .cardPad{ padding: 18px; }

    .cardHead{
      padding: 14px 18px;
      border-bottom: 1px solid #eef2f7;
      display:flex;
      justify-content:space-between;
      align-items:center;
      gap:12px;
    }
    .cardHead .left{
      display:flex;
      align-items:center;
      gap:10px;
      font-weight: 900;
      font-size: 18px;
    }

    .muted{ color: var(--muted); font-size: 12px; }

    /* form */
    .field{ display:flex; flex-direction:column; gap:7px; margin-bottom: 14px; }
    label{ font-weight: 800; font-size: 14px; color:#0f172a; }
    input, select{
      padding: 12px 14px;
      border-radius: 12px;
      border: 1px solid #dbe3ef;
      background:#fff;
      font-size: 16px;
      outline:none;
    }
    input:focus, select:focus{
      border-color: rgba(37,99,235,0.55);
      box-shadow: 0 0 0 3px rgba(37,99,235,0.16);
    }

    .btnPrimary{
      width:100%;
      background:#1f2937;
      color:#fff;
      border:none;
      border-radius: 12px;
      padding: 12px 14px;
      font-weight: 900;
      font-size: 16px;
      cursor:pointer;
      margin-top: 6px;
    }
    .btnPrimary:hover{ filter: brightness(1.05); }

    .btnGhost{
      background:#fff;
      border:1px solid var(--border);
      color:#0f172a;
      border-radius: 12px;
      padding: 10px 12px;
      font-weight: 900;
      cursor:pointer;
    }

    /* table */
    .tableWrap{ overflow-x:auto; }
    table{ width:100%; border-collapse:collapse; }
    thead th{
      text-align:left;
      font-size: 13px;
      font-weight: 900;
      color:#0f172a;
      padding: 16px 18px;
      border-bottom: 1px solid #eef2f7;
      background:#fff;
    }
    tbody td{
      padding: 16px 18px;
      border-bottom: 1px solid #f0f3f8;
      color:#0f172a;
      font-size: 15px;
      vertical-align: middle;
    }
    tbody tr:hover{ background:#f8fafc; }
    .mono{ font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace; }

    .pill{
      display:inline-block;
      padding: 6px 10px;
      border-radius: 8px;
      font-weight: 900;
      font-size: 13px;
    }
    .pill.public{ background:#fee2e2; color:#b91c1c; }
    .pill.state{ background:#ffedd5; color:#c2410c; }
    .pill.company{ background:#dbeafe; color:#1d4ed8; }

    .actions{
      display:flex;
      justify-content:flex-end;
      gap: 10px;
    }
    .iconBtn{
      width: 34px; height:34px;
      border-radius: 10px;
      border:1px solid #e5e7eb;
      background:#fff;
      cursor:pointer;
      display:flex;
      align-items:center;
      justify-content:center;
      color:#64748b;
    }
    .iconBtn:hover{ background:#f8fafc; }
    .iconBtn.danger:hover{ background:#fee2e2; border-color:#fecaca; color:#b91c1c; }

    /* header row inside list card */
    .listTop{
      background:#f8fafc;
      border-bottom:1px solid #eef2f7;
      padding: 12px 18px;
      display:flex;
      align-items:center;
      justify-content:space-between;
      gap:12px;
    }
    .listTop .tag{
      font-size: 12px;
      letter-spacing: .8px;
      color:#64748b;
      font-weight:900;
      text-transform:uppercase;
    }

    /* simple alert */
    .msg, .err{
      margin: 14px 0 0;
      padding: 10px 12px;
      border-radius: 12px;
      font-size: 13px;
      border: 1px solid;
    }
    .msg{ background:#ecfeff; border-color:#a5f3fc; color:#0e7490; }
    .err{ background:#fee2e2; border-color:#fecaca; color:#b91c1c; }

    /* edit mode highlight */
    .editMode{
      border: 2px solid rgba(37,99,235,0.35) !important;
      box-shadow: 0 0 0 4px rgba(37,99,235,0.08);
    }

    /* small icons */
    .ico{ width:18px; height:18px; display:block; }
  </style>
</head>

<body>

<jsp:include page="sidebar.jsp" />
  <jsp:include page="topbar.jsp" />
  
<div class="content">
  <div class="container pageWrap">
    <div class="pageHeader">
      <div>
        <h2 class="pageTitle">Manage Holidays</h2>
       <p class="pageSub">Manage list of Holiday in Malaysia.</p>
      </div>
    </div>

    <c:if test="${not empty param.msg}">
      <div class="msg">${param.msg}</div>
    </c:if>
    <c:if test="${not empty param.error}">
      <div class="err">${param.error}</div>
    </c:if>

    <div class="grid">
       <!-- ================= LEFT: ADD/EDIT FORM ================= -->
      <div id="formCard" class="card">
        <div class="cardHead">
          <div class="left">
            <svg class="ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <rect x="3" y="4" width="18" height="18" rx="2"></rect>
              <path d="M16 2v4M8 2v4M3 10h18"></path>
            </svg>
            <span id="formTitle">Add New Holiday</span>
          </div>
          <button id="cancelEditBtn" type="button" class="btnGhost" style="display:none;" onclick="resetForm()">Cancel</button>
        </div>

        <div class="cardPad">
          <form id="holidayForm" action="AddHolidayServlet" method="post">
            <input type="hidden" name="holidayId" id="holidayId" value="">

            <div class="field">
              <label>Holiday Name</label>
              <input type="text" name="holidayName" id="holidayName" placeholder="e.g. Founder's Day" required>
            </div>

            <div class="field">
              <label>Date</label>
              <input type="date" name="holidayDate" id="holidayDate" required>
            </div>

            <div class="field">
              <label>Type</label>
              <select name="holidayType" id="holidayType" required>
                <option value="PUBLIC">Public Holiday</option>
                <option value="STATE">State</option>
                <option value="COMPANY">Company</option>
              </select>
            </div>

            <button id="submitBtn" class="btnPrimary" type="submit">Add Holiday</button>
          </form>
        </div>
      </div>

<!-- ================= RIGHT: LIST TABLE ================= -->
<div class="card">
  <div class="listTop">
    <span class="tag">HOLIDAY CALENDAR</span>
    <span class="muted">
      <c:choose>
        <c:when test="${empty holidays}">0 Records</c:when>
        <c:otherwise>${fn:length(holidays)} Records</c:otherwise>
      </c:choose>
    </span>
  </div>

  <div class="tableWrap">
    <table>
      <thead>
        <tr>
          <th style="width:160px;">DATE</th>
          <th>HOLIDAY NAME</th>
          <th style="width:140px;">TYPE</th>
          <th style="width:140px; text-align:right;">ACTIONS</th>
        </tr>
      </thead>

      <tbody>
      <%
        List<Map<String,Object>> holidays = (List<Map<String,Object>>) request.getAttribute("holidays");
        if (holidays == null || holidays.isEmpty()) {
      %>
        <tr>
          <td colspan="4" style="padding:22px; color:#64748b;">No holidays found. Add one to get started.</td>
        </tr>
      <%
        } else {
          for (Map<String,Object> h : holidays) {

            // ✅ from servlet: id (String), name, type, dateDisplay, dateIso
            String id = (h.get("id") == null) ? "" : String.valueOf(h.get("id"));
            String name = (h.get("name") == null) ? "" : String.valueOf(h.get("name"));
            String type = (h.get("type") == null) ? "" : String.valueOf(h.get("type"));

            String dateDisplay = (h.get("dateDisplay") == null) ? "-" : String.valueOf(h.get("dateDisplay"));
            if ("null".equalsIgnoreCase(dateDisplay)) dateDisplay = "-";

            String dateIso = (h.get("dateIso") == null) ? "" : String.valueOf(h.get("dateIso"));
            if ("null".equalsIgnoreCase(dateIso)) dateIso = "";

            // normalize type for pill class only
            String pillClass = "company";
            if ("Public".equalsIgnoreCase(type)) pillClass = "public";
            else if ("State".equalsIgnoreCase(type)) pillClass = "state";
      %>
        <tr>
          <td class="mono"><%= dateDisplay %></td>
          <td style="font-weight:400;"><%= name %></td>
          <td>
            <span class="pill <%= pillClass %>"><%= type %></span>
          </td>
          <td style="text-align:right;">
            <div class="actions">

              <!-- Edit -->
              <button type="button" class="iconBtn"
                title="Edit"
                onclick="editHoliday('<%= escapeJs(id) %>','<%= escapeJs(name) %>','<%= escapeJs(dateIso) %>','<%= escapeJs(type) %>')">
                <!-- pencil -->
                <svg class="ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M12 20h9"></path>
                  <path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4Z"></path>
                </svg>
              </button>

              <!-- Delete -->
              <form action="DeleteHolidayServlet" method="post" style="margin:0;"
                onsubmit="return confirm('Delete this holiday?');">
                <input type="hidden" name="holidayId" value="<%= id %>">
                <button type="submit" class="iconBtn danger" title="Delete">
                  <!-- trash -->
                  <svg class="ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M3 6h18"></path>
                    <path d="M8 6V4h8v2"></path>
                    <path d="M19 6l-1 14H6L5 6"></path>
                    <path d="M10 11v6"></path>
                    <path d="M14 11v6"></path>
                  </svg>
                </button>
              </form>

            </div>
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

<%-- helper for escaping JS string --%>
<%!
  public static String escapeJs(String s){
    if (s == null) return "";
    return s.replace("\\","\\\\").replace("'","\\'").replace("\"","\\\"");
  }
%>

<script>
  function editHoliday(id, name, dateIso, type){
    document.getElementById("holidayId").value = id || "";
    document.getElementById("holidayName").value = name || "";
    document.getElementById("holidayDate").value = dateIso || "";

    // ✅ penting: match value dalam <option value="Public/State/Company">
    if (!type) type = "Public";
    type = String(type).trim();
    // normalize jika DB simpan PUBLIC/STATE/COMPANY
    if (type.toUpperCase() === "PUBLIC") type = "Public";
    if (type.toUpperCase() === "STATE") type = "State";
    if (type.toUpperCase() === "COMPANY") type = "Company";

    document.getElementById("holidayType").value = type;

    document.getElementById("holidayForm").action = "UpdateHolidayServlet";
    document.getElementById("formTitle").textContent = "Edit Holiday";
    document.getElementById("submitBtn").textContent = "Update Holiday";
    document.getElementById("cancelEditBtn").style.display = "inline-block";
    document.getElementById("formCard").classList.add("editMode");

    window.scrollTo({ top: 0, behavior: "smooth" });
  }

  function resetForm(){
    document.getElementById("holidayId").value = "";
    document.getElementById("holidayName").value = "";
    document.getElementById("holidayDate").value = "";
    document.getElementById("holidayType").value = "Public"; // ✅ default ikut option

    document.getElementById("holidayForm").action = "AddHolidayServlet";
    document.getElementById("formTitle").textContent = "Add New Holiday";
    document.getElementById("submitBtn").textContent = "Add Holiday";
    document.getElementById("cancelEditBtn").style.display = "none";
    document.getElementById("formCard").classList.remove("editMode");
  }
</script>
</html>