<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>

<%
  // =========================
  // SECURITY CHECK
  // =========================
  HttpSession ses = request.getSession(false);
  if (ses == null || ses.getAttribute("empid") == null ||
      ses.getAttribute("role") == null ||
      !"EMPLOYEE".equalsIgnoreCase(String.valueOf(ses.getAttribute("role")))) {
    response.sendRedirect("login.jsp?error=Please+login+as+employee");
    return;
  }

  // Data from Servlet
  List<Map<String,Object>> leaveTypes = (List<Map<String,Object>>) request.getAttribute("leaveTypes");
  if (leaveTypes == null) leaveTypes = new ArrayList<>();

  String typeError = (String) request.getAttribute("typeError");
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>LMS | Apply Leave</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
  
  <style>
    :root {
      --bg: #f8fafc;
      --card: #ffffff;
      --primary: #2563eb;
      --primary-hover: #1d4ed8;
      --text-main: #1e293b;
      --text-muted: #64748b;
      --border: #e2e8f0;
      --radius: 16px;
      --shadow: 0 10px 25px rgba(0,0,0,0.06);
      --sb-w: 300px;
    }

    * { box-sizing: border-box; }
    body { 
      margin: 0; 
      font-family: 'Inter', sans-serif; 
      background: var(--bg); 
      color: var(--text-main); 
      line-height: 1.5;
    }

    .content {
      min-height: 100vh;
      padding: 32px 40px;
      margin-left: var(--sb-w);
      transition: margin-left 0.3s;
    }
    @media (max-width: 1024px) { .content { margin-left: 0; padding: 24px 20px; } }

    .pageWrap { max-width: 900px; margin: 0 auto; }
    
    .header-section { margin-bottom: 32px; }
    .header-section h1 { font-size: 26px; font-weight: 800; color: var(--text-main); margin: 0; }
    .header-section p { color: var(--text-muted); margin-top: 6px; font-size: 15px; }

    .card {
      background: var(--card);
      border: 1px solid var(--border);
      border-radius: var(--radius);
      box-shadow: var(--shadow);
      padding: 32px;
    }

    .form-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 24px;
      margin-bottom: 24px;
    }
    @media (max-width: 768px) { .form-grid { grid-template-columns: 1fr; } }

    label { 
      display: block; 
      font-size: 13px; 
      font-weight: 700; 
      color: #475569; 
      margin-bottom: 8px;
      text-transform: uppercase;
      letter-spacing: 0.025em;
    }

    input, select, textarea {
      width: 100%;
      border: 1px solid #cbd5e1;
      border-radius: 12px;
      padding: 12px 16px;
      font-size: 14px;
      background: #fff;
      color: var(--text-main);
      transition: border-color 0.2s, box-shadow 0.2s;
    }
    input:focus, select:focus, textarea:focus {
      outline: none;
      border-color: var(--primary);
      box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.1);
    }

    textarea { min-height: 120px; resize: vertical; }

    /* Duration Selector Styling */
    .duration-options {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 10px;
    }
    .duration-tile {
      border: 1px solid #cbd5e1;
      border-radius: 12px;
      padding: 10px;
      text-align: center;
      cursor: pointer;
      transition: 0.2s;
      background: #fff;
    }
    .duration-tile:hover { border-color: var(--primary); background: #f8fafc; }
    .duration-tile input { display: none; }
    .duration-tile span { font-size: 13px; font-weight: 600; color: var(--text-muted); }
    
    .duration-tile.selected {
      border-color: var(--primary);
      background: #eff6ff;
    }
    .duration-tile.selected span { color: var(--primary); }

    .btn-submit {
      background: var(--primary);
      color: #fff;
      font-weight: 700;
      font-size: 15px;
      border: none;
      border-radius: 12px;
      padding: 14px 28px;
      cursor: pointer;
      width: 100%;
      transition: 0.2s;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 10px;
    }
    .btn-submit:hover { background: var(--primary-hover); transform: translateY(-1px); }

    .errBox {
      background: #fef2f2; border: 1px solid #fee2e2; color: #991b1b;
      padding: 14px 16px; border-radius: 12px; margin-bottom: 24px; font-size: 14px;
      display: flex; align-items: center; gap: 10px;
    }

    .hint { color: var(--text-muted); font-size: 12px; margin-top: 6px; }
    .req-star { color: #ef4444; margin-left: 2px; }

    /* Modal Styling */
    .overlay {
      position: fixed; inset: 0; background: rgba(15, 23, 42, 0.5);
      display: none; align-items: center; justify-content: center; z-index: 9999; backdrop-filter: blur(4px);
    }
    .overlay.show { display: flex; }
    .modal {
      width: 450px; background: #fff; border-radius: 20px; padding: 32px; text-align: center;
      box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1);
    }
    .modal i { font-size: 48px; color: #10b981; margin-bottom: 16px; }
    .modal h3 { margin: 0 0 8px; font-size: 22px; font-weight: 800; }
    .modal p { color: var(--text-muted); margin-bottom: 24px; }
  </style>
</head>
<body>

  <jsp:include page="sidebar.jsp" />

  <div class="content">
    <jsp:include page="topbar.jsp" />

    <div class="pageWrap">
      <div class="header-section">
        <h1>Apply for Leave</h1>
        <p>Submit your leave request below. Half-day requests will deduct <b>0.5 days</b> from your balance.</p>
      </div>

      <% if (typeError != null && !typeError.isEmpty()) { %>
        <div class="errBox"><i class="fas fa-exclamation-circle"></i> Error loading leave types: <%= typeError %></div>
      <% } %>

      <% if (request.getParameter("error") != null) { %>
        <div class="errBox"><i class="fas fa-exclamation-triangle"></i> <%= request.getParameter("error") %></div>
      <% } %>

      <div class="card">
        <form action="ApplyLeaveServlet" method="post" enctype="multipart/form-data" id="applyForm">
          
          <div class="form-grid">
            <div>
              <label for="leaveTypeId">Leave Type <span class="req-star">*</span></label>
              <select name="leaveTypeId" id="leaveTypeId" required onchange="handleTypeChange()">
                <option value="" disabled selected>-- Select Leave Type --</option>
                <%
                  for (Map<String,Object> t : leaveTypes) {
                    String id = String.valueOf(t.get("id"));
                    String code = String.valueOf(t.get("code"));
                    String desc = String.valueOf(t.get("desc"));
                %>
                  <option value="<%= id %>" data-code="<%= code %>"><%= code %> - <%= desc %></option>
                <% } %>
              </select>
            </div>

            <div>
              <label>Duration <span class="req-star">*</span></label>
              <div class="duration-options">
                <label class="duration-tile selected" onclick="selectDuration(this)">
                  <input type="radio" name="duration" value="FULL_DAY" checked onchange="syncDates()">
                  <span>Full Day</span>
                </label>
                <label class="duration-tile" onclick="selectDuration(this)">
                  <input type="radio" name="duration" value="HALF_DAY_AM" onchange="syncDates()">
                  <span>Half Day (AM)</span>
                </label>
                <label class="duration-tile" onclick="selectDuration(this)">
                  <input type="radio" name="duration" value="HALF_DAY_PM" onchange="syncDates()">
                  <span>Half Day (PM)</span>
                </label>
              </div>
            </div>
          </div>

          <div class="form-grid">
            <div>
              <label for="startDate">Start Date <span class="req-star">*</span></label>
              <input type="date" name="startDate" id="startDate" required onchange="syncDates()" />
            </div>
            <div>
              <label for="endDate">End Date <span class="req-star">*</span></label>
              <input type="date" name="endDate" id="endDate" required />
            </div>
          </div>

          <div style="margin-bottom: 24px;">
            <label for="reason">Reason for Leave <span class="req-star">*</span></label>
            <textarea name="reason" id="reason" required placeholder="Briefly describe why you are taking this leave..."></textarea>
          </div>

          <div style="margin-bottom: 32px;">
            <label id="docLabel">Supporting Document <span id="docRequired" style="display:none;" class="req-star">(Required *)</span></label>
            <input type="file" name="attachment" id="attachment"
                   accept=".pdf,.png,.jpg,.jpeg" />
            <div class="hint">Recommended for all leaves. <b>Mandatory for Sick/Hospitalization</b>. (PDF, PNG, JPG - Max 5MB)</div>
          </div>

          <button type="submit" class="btn-submit">
            <i class="fas fa-paper-plane"></i> Submit Leave Application
          </button>
        </form>
      </div>
    </div>
  </div>

  <!-- SUCCESS MODAL -->
  <div class="overlay" id="overlay">
    <div class="modal">
      <i class="fas fa-check-circle"></i>
      <h3>Application Sent</h3>
      <p id="popupMsg"></p>
      <button class="btn-submit" onclick="closePopup()" style="width: auto; margin: 0 auto; padding: 10px 30px;">Great!</button>
    </div>
  </div>

  <script>
    const form = document.getElementById('applyForm');
    const startEl = document.getElementById('startDate');
    const endEl = document.getElementById('endDate');
    const typeEl = document.getElementById('leaveTypeId');
    const attachmentEl = document.getElementById('attachment');

    // Handle selection UI for duration tiles
    function selectDuration(element) {
      document.querySelectorAll('.duration-tile').forEach(t => t.classList.remove('selected'));
      element.classList.add('selected');
    }

    // Lock dates for Half Day
    function syncDates() {
      const duration = document.querySelector('input[name="duration"]:checked').value;
      if (duration !== 'FULL_DAY') {
        endEl.value = startEl.value;
        endEl.readOnly = true;
        endEl.style.background = '#f1f5f9';
      } else {
        endEl.readOnly = false;
        endEl.style.background = '#fff';
      }
    }

    // Dynamic UI for Mandatory Document
    function handleTypeChange() {
      const selectedOption = typeEl.options[typeEl.selectedIndex];
      const code = selectedOption.getAttribute('data-code') || "";
      const isMandatory = code.includes("SICK") || code.includes("HOSPITAL");
      
      document.getElementById('docRequired').style.display = isMandatory ? 'inline' : 'none';
    }

    // Form Validation Logic
    form.onsubmit = function(e) {
      const selectedOption = typeEl.options[typeEl.selectedIndex];
      const code = selectedOption.getAttribute('data-code') || "";
      const isMandatory = code.includes("SICK") || code.includes("HOSPITAL");

      if (isMandatory && attachmentEl.files.length === 0) {
        e.preventDefault();
        alert("Supporting document is REQUIRED for Sick or Hospitalization leave.");
        return false;
      }
      return true;
    };

    // Modal Handling
    const params = new URLSearchParams(window.location.search);
    if(params.get("msg")) {
      document.getElementById("popupMsg").textContent = params.get("msg");
      document.getElementById("overlay").classList.add("show");
    }

    function closePopup() {
      document.getElementById("overlay").classList.remove("show");
      const url = new URL(window.location.href);
      url.searchParams.delete("msg");
      window.history.replaceState({}, "", url.toString());
    }
  </script>
</body>
</html>