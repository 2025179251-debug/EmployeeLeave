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
      response.sendRedirect(request.getContextPath() + "/login.jsp?error=Please+login+as+employee");
      return;
    }

    // =========================
    // DATA RETRIEVAL
    // =========================
    List<Map<String, Object>> leaves = (List<Map<String, Object>>) request.getAttribute("leaves");
    List<String> years = (List<String>) request.getAttribute("years");
    String dbError = (String) request.getAttribute("error");

    if (leaves == null) leaves = new ArrayList<>();
    if (years == null) years = new ArrayList<>();

    String currentStatus = request.getParameter("status") != null ? request.getParameter("status") : "ALL";
    String currentYear = request.getParameter("year") != null ? request.getParameter("year") : "";
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>LMS | My Leave History</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">

<style>
:root {
  --bg: #f4f6fb;
  --card: #ffffff;
  --primary: #2563eb;
  --primary-hover: #1d4ed8;
  --text-main: #0f172a;
  --text-muted: #64748b;
  --border: #e5e7eb;
  --radius: 16px;
  --shadow: 0 10px 25px rgba(0, 0, 0, 0.06);
  --sb-w: 300px;
  --sb-collapsed: 86px;
}

* { box-sizing: border-box; }
body { font-family: 'Inter', sans-serif; background: var(--bg); color: var(--text-main); margin: 0; }

.content {
  min-height: 100vh;
  padding: 0 24px 32px;
  padding-left: calc(24px + var(--sb-w));
  transition: padding-left 0.3s ease;
}
body.sidebar-collapsed .content { padding-left: calc(24px + var(--sb-collapsed)); }
@media (max-width: 979px) { .content { padding-left: 24px; } }

.pageWrap { max-width: 1250px; margin: 20px auto 0; }

.title-area { margin-bottom: 24px; }
.title-area h1 { font-size: 28px; font-weight: 800; margin: 0; color: var(--text-main); }
.title-area p { color: var(--text-muted); font-size: 15px; margin-top: 4px; }

/* Filter Section */
.filter-card {
  background: var(--card);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 16px 24px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  box-shadow: var(--shadow);
}
.filter-group { display: flex; align-items: center; gap: 12px; }
.filter-group label {
  font-size: 12px; font-weight: 800; color: var(--text-muted);
  text-transform: uppercase; letter-spacing: 0.05em;
}

select {
  padding: 8px 12px;
  border-radius: 10px;
  border: 1px solid var(--border);
  background: #fff;
  font-size: 14px;
  outline: none;
  cursor: pointer;
  min-width: 140px;
}
.btn-filter {
  background: var(--primary);
  color: #fff;
  border: none;
  padding: 9px 18px;
  border-radius: 10px;
  font-weight: 700;
  cursor: pointer;
  transition: 0.2s;
}
.btn-filter:hover { background: var(--primary-hover); }

/* Table Design */
.table-card {
  background: var(--card);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  box-shadow: var(--shadow);
  overflow: hidden;
}
table { width: 100%; border-collapse: collapse; text-align: left; }
th {
  background: #f8fafc;
  padding: 16px 20px;
  font-size: 11px;
  font-weight: 800;
  color: var(--text-muted);
  text-transform: uppercase;
  border-bottom: 1px solid var(--border);
  letter-spacing: 0.025em;
}
td { padding: 18px 20px; border-bottom: 1px solid #f1f5f9; font-size: 14px; color: var(--text-main); }
tr:last-child td { border-bottom: none; }
tr:hover { background: #fafafa; }

/* Badges */
.badge {
  padding: 5px 12px; border-radius: 20px; font-size: 11px; font-weight: 700;
  display: inline-flex; align-items: center; gap: 6px; text-transform: uppercase;
}
.bg-pending { background: #fffbeb; color: #b45309; border: 1px solid #fde68a; }
.bg-approved { background: #ecfdf5; color: #047857; border: 1px solid #a7f3d0; }
.bg-rejected { background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; }
.bg-cancelled { background: #f1f5f9; color: #475569; border: 1px solid #e2e8f0; }

/* Action Buttons */
.action-group { display: flex; gap: 8px; justify-content: flex-end; }
.btn-circle {
  width: 34px; height: 34px; border-radius: 10px; border: 1px solid var(--border);
  background: #fff; color: var(--text-muted); cursor: pointer; transition: 0.2s;
  display: inline-flex; align-items: center; justify-content: center;
}
.btn-circle:hover { background: #eff6ff; color: var(--primary); border-color: var(--primary); }
.btn-cancel:hover { background: #fef2f2; color: #ef4444; border-color: #ef4444; }

/* Modals & Overlays */
.overlay {
  position: fixed; inset: 0; background: rgba(15, 23, 42, 0.6);
  display: none; align-items: center; justify-content: center; z-index: 1000;
  backdrop-filter: blur(4px);
}
.overlay.show { display: flex; }

.preview-modal {
  background: #fff; border-radius: 24px; width: 900px; max-width: 95%; height: 85vh;
  display: flex; flex-direction: column; overflow: hidden;
  box-shadow: 0 25px 50px -12px rgba(0,0,0,0.25);
}
.modal-header {
  padding: 18px 24px; border-bottom: 1px solid var(--border);
  display: flex; justify-content: space-between; align-items: center;
}
.modal-header h3 { margin: 0; font-size: 16px; font-weight: 700; }
.modal-body { flex-grow: 1; position: relative; padding: 18px 24px; }
iframe { width: 100%; height: 100%; border: none; }

/* Confirmation Modal */
.confirm-modal { background: #fff; border-radius: 24px; width: 420px; padding: 32px; text-align: center; }
.confirm-icon {
  width: 64px; height: 64px; background: #eff6ff; color: var(--primary);
  border-radius: 50%; display: flex; align-items: center; justify-content: center;
  font-size: 28px; margin: 0 auto 20px;
}
.btn-group { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-top: 24px; }
.btn-modal { padding: 12px; border-radius: 12px; font-weight: 700; cursor: pointer; border: none; transition: 0.2s; }
.btn-blue { background: var(--primary); color: #fff; }
.btn-gray { background: #f1f5f9; color: var(--text-muted); }

.err-banner {
  background: #fef2f2; color: #b91c1c;
  padding: 14px 20px; border-radius: 12px; border: 1px solid #fee2e2;
  margin-bottom: 16px; font-size: 14px; font-weight: 600;
  white-space: pre-wrap;
  word-break: break-word;
}

/* Edit form layout */
.edit-grid{
  display:grid;
  grid-template-columns: 1fr 1fr;
  gap: 14px 16px;
}
.edit-field label{
  display:block;
  font-size:12px;
  font-weight:800;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin-bottom: 6px;
}
.edit-field input, .edit-field select, .edit-field textarea{
  width:100%;
  border:1px solid var(--border);
  border-radius:12px;
  padding:10px 12px;
  outline:none;
  font-size:14px;
}
.edit-field textarea{ resize: vertical; min-height: 96px; }
.edit-actions{
  display:flex;
  justify-content:flex-end;
  gap:12px;
  margin-top:16px;
}
</style>
</head>

<body>
<jsp:include page="sidebar.jsp" />
<jsp:include page="topbar.jsp" />

<div class="content">
  <div class="pageWrap">
    <div class="title-area">
      <h1>My Leave History</h1>
      <p>Track your leave requests and review approval statuses.</p>
    </div>

    <% if (dbError != null && !dbError.isEmpty()) { %>
      <div class="err-banner"><i class="fas fa-exclamation-circle"></i> Error: <%= dbError %></div>
    <% } %>

    <!-- Filters -->
    <form action="<%=request.getContextPath()%>/LeaveHistoryServlet" method="get" class="filter-card">
      <div class="filter-group">
        <i class="fas fa-filter" style="color: var(--primary)"></i>
        <label>Status</label>
        <select name="status">
          <option value="ALL" <%= currentStatus.equals("ALL") ? "selected" : "" %>>All Statuses</option>
          <option value="PENDING" <%= currentStatus.equals("PENDING") ? "selected" : "" %>>Pending</option>
          <option value="APPROVED" <%= currentStatus.equals("APPROVED") ? "selected" : "" %>>Approved</option>
          <option value="REJECTED" <%= currentStatus.equals("REJECTED") ? "selected" : "" %>>Rejected</option>
          <option value="CANCELLED" <%= currentStatus.equals("CANCELLED") ? "selected" : "" %>>Cancelled</option>
        </select>

        <label style="margin-left: 10px;">Year</label>
        <select name="year">
          <option value="">All Years</option>
          <% for(String yr : years) { %>
            <option value="<%=yr%>" <%= yr.equals(currentYear) ? "selected" : "" %>><%=yr%></option>
          <% } %>
        </select>

        <button type="submit" class="btn-filter">Apply Filter</button>
      </div>

      <div style="font-size: 13px; color: var(--text-muted); font-weight: 600;">
        Records: <b><%= leaves.size() %></b>
      </div>
    </form>

    <!-- Table -->
    <div class="table-card">
      <table>
        <thead>
          <tr>
            <th>Applied On</th>
            <th>Leave Type</th>
            <th>Duration</th>
            <th>Start - End Date</th>
            <th>Total Days</th>
            <th style="text-align: center;">Doc</th>
            <th>Status</th>
            <th style="text-align: right;">Actions</th>
          </tr>
        </thead>
        <tbody>
        <% if (leaves.isEmpty()) { %>
          <tr>
            <td colspan="8" style="text-align: center; padding: 60px; color: var(--text-muted);">
              <i class="fas fa-inbox" style="font-size: 32px; display: block; margin-bottom: 10px; opacity: 0.3;"></i>
              No leave history found matching your filters.
            </td>
          </tr>
        <% } else {
            for (Map<String, Object> l : leaves) {
              String code = (String) l.get("statusCode");
              String badgeClass = "bg-" + (code != null ? code.toLowerCase() : "pending");

              String safeFileName = String.valueOf(l.get("fileName"))
                .replace("\\", "\\\\")
                .replace("'", "\\'")
                .replace("\"", "\\\"")
                .replace("\r", "")
                .replace("\n", "");
        %>
          <tr>
            <td style="font-size: 12px; color: var(--text-muted); font-weight: 500;">
              <%= l.get("appliedOn") %>
            </td>
            <td style="font-weight: 700; color: var(--primary);"><%= l.get("type") %></td>
            <td>
              <span style="background: #f1f5f9; padding: 4px 8px; border-radius: 6px; font-size: 11px; font-weight: 700; color: var(--text-muted);">
                <%= l.get("duration") %>
              </span>
            </td>
            <td>
              <div style="font-weight: 600; font-size: 13px;"><%= l.get("start") %></div>
              <div style="font-size: 11px; color: var(--text-muted);">to <%= l.get("end") %></div>
            </td>
            <td style="font-weight: 800; font-size: 15px;"><%= l.get("totalDays") %></td>
            <td style="text-align: center;">
              <% if (Boolean.TRUE.equals(l.get("hasFile"))) { %>
                <button type="button" class="btn-circle"
                        onclick="openDocPreview(<%= l.get("id") %>, '<%= safeFileName %>')"
                        title="View Supporting Document">
                  <i class="fas fa-file-pdf"></i>
                </button>
              <% } else { %>
                -
              <% } %>
            </td>
            <td>
              <span class="badge <%= badgeClass %>">
                <i class="fas fa-circle" style="font-size: 6px;"></i> <%= l.get("status") %>
              </span>
            </td>
            <td style="text-align: right;">
              <div class="action-group">
                <% if ("PENDING".equalsIgnoreCase(code)) { %>
                  <button type="button" class="btn-circle" title="Edit Request"
                          onclick="openEditModal(<%= l.get("id") %>)">
                    <i class="fas fa-edit"></i>
                  </button>

                  <button type="button" class="btn-circle btn-cancel" title="Delete Request"
                          onclick="triggerConfirm('CANCEL', <%= l.get("id") %>)">
                    <i class="fas fa-trash-alt"></i>
                  </button>
                <% } else if ("APPROVED".equalsIgnoreCase(code)) { %>
                  <button type="button" class="btn-circle btn-cancel" title="Request Cancellation"
                          onclick="triggerConfirm('REQ_CANCEL', <%= l.get("id") %>)">
                    <i class="fas fa-ban"></i>
                  </button>
                <% } else { %>
                  <span style="font-size: 11px; color: var(--text-muted); opacity: 0.5;">-</span>
                <% } %>
              </div>
            </td>
          </tr>
        <% } } %>
        </tbody>
      </table>
    </div>
  </div>
</div>

<!-- DOCUMENT PREVIEW MODAL -->
<div class="overlay" id="docOverlay">
  <div class="preview-modal">
    <div class="modal-header">
      <h3 id="modalFileName">Supporting Document View</h3>
      <button type="button" class="btn-circle" onclick="closeDocPreview()"><i class="fas fa-times"></i></button>
    </div>
    <div class="modal-body" style="background: #525659; padding:0;">
      <iframe id="docFrame" src=""></iframe>
    </div>
  </div>
</div>

<!-- EDIT MODAL -->
<div class="overlay" id="editOverlay">
  <div class="preview-modal">
    <div class="modal-header">
      <h3>Edit Leave Request</h3>
      <button type="button" class="btn-circle" onclick="closeEditModal()"><i class="fas fa-times"></i></button>
    </div>

    <div class="modal-body">
      <div id="editErr" class="err-banner" style="display:none;"></div>

      <!-- Submit to EditLeaveServlet POST -->
      <form id="editForm" action="<%=request.getContextPath()%>/EditLeaveServlet" method="post">
        <input type="hidden" id="editLeaveId" name="leaveId">

        <div class="edit-grid">
          <div class="edit-field" style="grid-column: 1 / -1;">
            <label>Leave Type</label>
            <select id="editLeaveType" name="leaveType" required></select>
          </div>

          <div class="edit-field">
            <label>Start Date</label>
            <input type="date" id="editStartDate" name="startDate" required>
          </div>

          <div class="edit-field">
            <label>End Date</label>
            <input type="date" id="editEndDate" name="endDate" required>
          </div>

          <div class="edit-field" style="grid-column: 1 / -1;">
            <label>Duration</label>
            <!-- match JSON & DB values: FULL_DAY / HALF_DAY -->
            <select id="editDuration" name="duration" required>
              <option value="FULL_DAY">Full Day</option>
              <option value="HALF_DAY">Half Day</option>
            </select>
          </div>

          <div class="edit-field" style="grid-column: 1 / -1;">
            <label>Reason</label>
            <textarea id="editReason" name="reason" required></textarea>
          </div>
        </div>

        <div class="edit-actions">
          <button type="button" class="btn-modal btn-gray" onclick="closeEditModal()">Cancel</button>
          <button type="submit" class="btn-modal btn-blue">Save Changes</button>
        </div>
      </form>
    </div>
  </div>
</div>

<!-- CONFIRMATION MODAL -->
<div class="overlay" id="confirmOverlay">
  <div class="confirm-modal">
    <div class="confirm-icon"><i class="fas fa-question-circle"></i></div>
    <h3 id="confirmTitle">Confirm Action</h3>
    <p id="confirmMsg"></p>

    <form id="confirmForm" action="<%=request.getContextPath()%>/CancelLeaveServlet" method="post">
      <input type="hidden" name="id" id="confirmLeaveId">
      <input type="hidden" name="actionType" id="confirmActionType">
      <div class="btn-group">
        <button type="button" class="btn-modal btn-gray" onclick="closeConfirm()">Cancel</button>
        <button type="submit" class="btn-modal btn-blue">Confirm Action</button>
      </div>
    </form>
  </div>
</div>

<script>
  // ✅ declare once only (no duplicate)
  const CTX = "<%=request.getContextPath()%>";

  // --------------------
  // Doc preview
  // --------------------
  function openDocPreview(id, name) {
    document.getElementById('modalFileName').innerText = "Preview: " + name;
    document.getElementById('docFrame').src = CTX + "/ViewAttachmentServlet?id=" + encodeURIComponent(id);
    document.getElementById('docOverlay').classList.add('show');
  }
  function closeDocPreview() {
    document.getElementById('docOverlay').classList.remove('show');
    document.getElementById('docFrame').src = "";
  }

  // --------------------
  // Confirm modal
  // --------------------
  function triggerConfirm(type, id) {
    const title = document.getElementById('confirmTitle');
    const msg = document.getElementById('confirmMsg');
    document.getElementById('confirmLeaveId').value = id;
    document.getElementById('confirmActionType').value = type;

    if(type === 'CANCEL') {
      title.innerText = "Delete Request?";
      msg.innerText = "Are you sure you want to permanently delete this pending leave request? This action cannot be undone.";
    } else {
      title.innerText = "Request Cancellation?";
      msg.innerText = "This leave is already approved. Would you like to submit a request to cancel it? An Admin will review your request.";
    }
    document.getElementById('confirmOverlay').classList.add('show');
  }
  function closeConfirm() {
    document.getElementById('confirmOverlay').classList.remove('show');
  }

  // --------------------
  // Edit modal (GET JSON)
  // --------------------
  async function openEditModal(leaveId){
    document.getElementById("editOverlay").classList.add("show");
    showEditError("Loading...");

    const url = CTX + "/EditLeaveServlet?id=" + encodeURIComponent(leaveId);

    try{
      const res = await fetch(url, { headers: { "Accept":"application/json" } });
      const raw = await res.text();

      if(!res.ok){
        showEditError("GET " + url + "\nStatus: " + res.status + "\n\n" + raw);
        return;
      }

      const data = JSON.parse(raw);

      // populate
      document.getElementById("editLeaveId").value = data.leaveId ?? leaveId;
      document.getElementById("editStartDate").value = data.startDate ?? "";
      document.getElementById("editEndDate").value   = data.endDate ?? "";
      document.getElementById("editReason").value    = data.reason ?? "";
      document.getElementById("editDuration").value  = data.duration ?? "FULL_DAY";

      // dropdown leave types
      const sel = document.getElementById("editLeaveType");
      sel.innerHTML = "";
      (data.leaveTypes || []).forEach(t=>{
        const opt = document.createElement("option");
        opt.value = String(t.value);   // IMPORTANT (string)
        opt.textContent = t.label;
        sel.appendChild(opt);
      });
      sel.value = String(data.leaveTypeId); // IMPORTANT (string)

      showEditError("");
      applyHalfDayRule();

    }catch(err){
      showEditError("Error: " + (err && err.message ? err.message : err));
    }
  }

  function closeEditModal(){
    document.getElementById("editOverlay").classList.remove("show");
    showEditError("");
  }

  function showEditError(msg){
    const box = document.getElementById("editErr");
    if(!msg){
      box.style.display = "none";
      box.textContent = "";
      return;
    }
    box.style.display = "block";
    box.textContent = msg;
  }

  // Half day rule: endDate = startDate (lock)
  function applyHalfDayRule(){
    const duration = document.getElementById("editDuration").value;
    const startEl = document.getElementById("editStartDate");
    const endEl   = document.getElementById("editEndDate");

    if(duration === "HALF_DAY"){
      endEl.value = startEl.value;
      endEl.readOnly = true;
      endEl.style.opacity = "0.7";
    } else {
      endEl.readOnly = false;
      endEl.style.opacity = "1";
    }
  }

  document.getElementById("editDuration").addEventListener("change", applyHalfDayRule);
  document.getElementById("editStartDate").addEventListener("change", ()=>{
    if(document.getElementById("editDuration").value === "HALF_DAY"){
      document.getElementById("editEndDate").value = document.getElementById("editStartDate").value;
    }
  });

</script>

</body>
</html>
