<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*,java.time.*,java.time.format.*" %>

<%
  // =========================
  // KAWALAN KESELAMATAN
  // =========================
  HttpSession ses = request.getSession(false);
  if (ses == null || ses.getAttribute("empid") == null ||
      ses.getAttribute("role") == null ||
      !"EMPLOYEE".equalsIgnoreCase(String.valueOf(ses.getAttribute("role")))) {
    response.sendRedirect(request.getContextPath() + "/login.jsp?error=Sila+log+masuk+sebagai+pekerja");
    return;
  }

  String fullname = String.valueOf(ses.getAttribute("fullname"));

  // =========================
  // DATA DARI SERVLET
  // =========================
  String dbError = (String) request.getAttribute("dbError");
  String balanceError = (String) request.getAttribute("balanceError");
  
  List<Map<String,Object>> balances = (List<Map<String,Object>>) request.getAttribute("balances");
  if (balances == null) balances = new ArrayList<>();

  // Map baki mengikut TypeCode untuk carian UI
  Map<String, Map<String,Object>> balByType = new HashMap<>();
  for (Map<String,Object> b : balances) {
    if (b == null) continue;
    Object tObj = b.get("typeCode"); 
    if (tObj != null) balByType.put(String.valueOf(tObj).trim().toUpperCase(), b);
  }

  Map<LocalDate, List<Map<String,Object>>> holidayMap = (Map<LocalDate, List<Map<String,Object>>>) request.getAttribute("monthHolidaysMap");
  if (holidayMap == null) holidayMap = new HashMap<>();

  List<Map<String,Object>> holidayUpcoming = (List<Map<String,Object>>) request.getAttribute("holidayUpcoming");
  if (holidayUpcoming == null) holidayUpcoming = new ArrayList<>();

  // =========================
  // PENGURUSAN KALENDAR
  // =========================
  LocalDate today = LocalDate.now();
  Integer calYearObj = (Integer) request.getAttribute("calYear");
  Integer calMonthObj = (Integer) request.getAttribute("calMonth");
  int calYear = (calYearObj != null ? calYearObj : today.getYear());
  int calMonth = (calMonthObj != null ? calMonthObj : today.getMonthValue());
  
  YearMonth ym = YearMonth.of(calYear, calMonth);
  LocalDate firstDay = ym.atDay(1);
  int daysInMonth = ym.lengthOfMonth();

  int firstDow = firstDay.getDayOfWeek().getValue() % 7; // Ahad=0
  LocalDate gridStart = firstDay.minusDays(firstDow);
  YearMonth prev = ym.minusMonths(1);
  YearMonth next = ym.plusMonths(1);

  String monthTitle = ym.getMonth().getDisplayName(TextStyle.FULL, Locale.ENGLISH) + " " + calYear;
  DateTimeFormatter fmtLong = DateTimeFormatter.ofPattern("dd MMM yyyy");
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Employee Portal | Dashboard</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <style>
    :root{
      --bg:#f8fafc;
      --card:#fff;
      --border:#e2e8f0;
      --text:#1e293b;
      --muted:#64748b;
      --shadow:0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06);
      --radius:16px;
      --sb-w:300px;
      --red: #ef4444;
      --orange: #f97316;
      --blue: #3b82f6;
      --teal: #14b8a6;
      --purple: #a855f7;
    }
    *{box-sizing:border-box}
    body{ margin:0; font-family: 'Inter', Arial, sans-serif; background:var(--bg); color:var(--text); }

    .content{
      min-height:100vh;
      padding: 32px 40px;
      padding-left: calc(18px + var(--sb-w));
    }
    @media (max-width:1024px){ .content{ padding-left: 20px; } }

    .pageWrap{ max-width:1200px; margin: 0 auto; }

    .title{ font-size:24px; font-weight:800; margin: 0 0 4px; color: #1e293b; }
    .sub{ color:var(--muted); margin:0 0 32px; font-size: 15px; }

    .err{ background:#fef2f2; border:1px solid #fee2e2; color:#991b1b; padding:12px 16px; border-radius:12px; margin-bottom:12px; font-size: 14px; }
    .warn{ background:#fff7ed; border:1px solid #fed7aa; color:#9a3412; padding:12px 16px; border-radius:12px; margin-bottom:12px; font-size: 14px; }

    /* Grid Setup: Fixed 3 Columns */
    .gridCards {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 20px;
      margin-bottom: 32px;
    }
    
    .card{
      background:var(--card);
      border:1px solid #f1f5f9;
      border-radius: var(--radius);
      box-shadow: var(--shadow);
      padding: 24px;
      position:relative;
      overflow:hidden;
      transition: all 0.3s ease;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      height: 100%;
    }
    .card:hover { transform: translateY(-4px); box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1); }

    /* Card Theming */
    .card.annual { border-top: 5px solid var(--blue); }
    .card.sick { border-top: 5px solid var(--teal); }
    .card.emergency { border-top: 5px solid var(--red); }
    .card.hospitalization { border-top: 5px solid var(--purple); }
    .card.unpaid { border-top: 5px solid var(--muted); }

    .card .label{ font-size:13px; font-weight:800; color:var(--text); text-transform:uppercase; letter-spacing:.05em; display:flex; justify-content:space-between; align-items:center; }
    .card .big{ font-size:28px; font-weight:800; margin: 8px 0 2px; color: #1e293b; }
    .card .big span{ font-size:14px; color:#94a3b8; font-weight:500; margin-left: 4px; }
    
    /* Progress Bar (Timeline) */
    .timeline-track { height: 10px; width: 100%; background: #f1f5f9; border-radius: 10px; margin: 14px 0; overflow: hidden; }
    .timeline-bar { height: 100%; border-radius: 10px; transition: width 0.8s ease; }
    
    .card.annual .timeline-bar { background: var(--blue); }
    .card.sick .timeline-bar { background: var(--teal); }
    .card.emergency .timeline-bar { background: var(--red); }
    .card.hospitalization .timeline-bar { background: var(--purple); }
    .card.unpaid .timeline-bar { background: var(--muted); }

    .card-footer { border-top: 1px solid #f1f5f9; padding-top: 16px; margin-top: auto; }
    .entitlement-text { font-size: 12px; color: var(--muted); margin-bottom: 10px; }
    .entitlement-text b { color: #475569; }

    .stats-row { display: flex; align-items: center; justify-content: space-between; font-size: 13px; }
    .stat-box { flex: 1; text-align: center; }
    .stat-box:first-child { text-align: left; }
    .stat-box:last-child { text-align: right; }
    .stat-box span { color: var(--muted); font-size: 10px; text-transform: uppercase; display: block; margin-bottom: 2px; font-weight: 700; }
    .stat-box b { color: #1e293b; font-size: 15px; }
    .divider { width: 1px; height: 18px; background: #e2e8f0; margin: 0 10px; }

    @media (max-width: 900px) { .gridCards { grid-template-columns: 1fr; } }

    /* Main Grid */
    .gridMain{ display:grid; grid-template-columns: 2fr 1.2fr; gap: 24px; margin-top: 8px; align-items: stretch; }
    @media(max-width: 1024px){ .gridMain{ grid-template-columns: 1fr; } }

    /* Nice Small Calendar */
    .cal-card { background: #fff; border: 1px solid #e2e8f0; border-radius: 16px; padding: 20px; box-shadow: var(--shadow); height: 100%; display: flex; flex-direction: column; }
    .calHeader{ display:flex; align-items:center; justify-content:space-between; margin-bottom: 20px; }
    .calTitle { font-weight:700; font-size:18px; color: #1e293b; }
    .calNav a{ text-decoration:none; padding:6px 10px; border:1px solid #e2e8f0; border-radius:10px; color:#64748b; font-size: 13px; font-weight: 600; }
    .calNav a:hover{ background:#f8fafc; color: #1e293b; }

    .calTable { width:100%; border-collapse:collapse; flex-grow: 1; }
    .calTable th{ font-size:11px; text-transform:uppercase; color:#94a3b8; text-align:center; padding:8px 0; font-weight: 700; }
    .calTable td{ text-align:center; padding:10px 0; border-bottom:1px solid #f8fafc; position: relative; }

    .dayBox{ display:inline-flex; align-items:center; justify-content:center; width:32px; height:32px; border-radius:10px; font-weight:700; font-size:12px; transition: 0.2s; cursor: pointer; }
    .mutedDay{ color:#cbd5e1; }
    .today{ background:#1e293b !important; color:#fff !important; }

    /* Holiday Indicators */
    .h-dot { width: 6px; height: 6px; border-radius: 50%; margin: 2px auto 0; }
    .h-public-dot { background: var(--red); }
    .h-state-dot { background: var(--orange); }
    .h-company-dot { background: var(--blue); }

    /* Hover Tooltip */
    .tipWrap { position:relative; display:inline-block; }
    .tip {
      position:absolute; bottom: 120%; left:50%; transform:translateX(-50%);
      background:#1e293b; color:#fff; padding:6px 12px; border-radius:8px; font-size:10px;
      white-space:nowrap; box-shadow:0 10px 15px rgba(0,0,0,0.2);
      opacity:0; pointer-events:none; transition:0.2s ease-in-out; z-index:100;
    }
    .tip:after { content: ""; position: absolute; top: 100%; left: 50%; margin-left: -6px; border-width: 6px; border-style: solid; border-color: #1e293b transparent transparent transparent; }
    .tipWrap:hover .tip{ opacity:1; bottom: 130%; }

    /* Upcoming Badge Style */
    .hListItem{ display:flex; gap:16px; align-items:center; padding:10px 0; border-bottom:1px solid #f1f5f9; }
    .dateBadge{
      width:50px; height:50px; border-radius:12px;
      display:flex; flex-direction:column; align-items:center; justify-content:center;
      background:#f8fafc; color:#1e293b; font-weight:800; border:1px solid #e2e8f0; flex-shrink:0;
    }
    .dateBadge span:first-child { font-size: 16px; line-height: 1; }
    .dateBadge span:last-child { font-size: 9px; text-transform: uppercase; margin-top: 2px; }
    
    .dateBadge.public { background:#fef2f2; border-color:#fee2e2; color: var(--red); }
    .dateBadge.public span:last-child { color: var(--red); }
    .dateBadge.state { background:#fffaf5; border-color:#ffedd5; color: var(--orange); }
    .dateBadge.state span:last-child { color: var(--orange); }
    .dateBadge.company { background:#f0f9ff; border-color:#dbeafe; color: var(--blue); }
    .dateBadge.company span:last-child { color: var(--blue); }

    .hName{ font-weight:700; font-size:14px; margin:0; color: #1e293b; }
    .hType{ color:var(--muted); font-size:12px; margin-top:2px; }
    
    .legend { display:flex; gap:14px; align-items:center; margin-top:20px; color:#64748b; font-size:11px; font-weight: 600; border-top: 1px solid #f1f5f9; padding-top: 15px; }
    .legend-item { display:flex; align-items:center; gap:6px; }
    .legend-dot { width:8px; height:8px; border-radius:3px; }
  </style>
</head>

<body>

  <jsp:include page="sidebar.jsp" />

  <div class="content">
    <jsp:include page="topbar.jsp" />

    <div class="pageWrap">
      
      <% if (dbError != null && !dbError.isBlank()) { %>
        <div class="err"><i class="fas fa-exclamation-circle"></i> DB ERROR: <%= dbError %></div>
      <% } %>
      <% if (balanceError != null && !balanceError.isBlank()) { %>
        <div class="warn"><i class="fas fa-exclamation-triangle"></i> BALANCE ERROR: <%= balanceError %></div>
      <% } %>

      <h2 style="margin:10px 0 6px;">Employee Dashboard</h2>
      <p class="sub">Welcome back, <b><%= fullname %></b>. Here is your leave summary.</p>

      <!-- ✅ Fixed 3-Column Grid for Leave Cards -->
      <div class="gridCards">
        <%
          String[] typesOrder = {"ANNUAL", "SICK", "EMERGENCY", "HOSPITALIZATION", "UNPAID"};
          for (int i = 0; i < typesOrder.length; i++) {
            String type = typesOrder[i];
            Map<String,Object> b = balByType.get(type);
            
            double entVal = 0, usedVal = 0, pendVal = 0, totalVal = 0;
            if(b != null) {
                try { entVal = Double.parseDouble(String.valueOf(b.get("entitlement"))); } catch(Exception e){}
                try { usedVal = Double.parseDouble(String.valueOf(b.get("used"))); } catch(Exception e){}
                try { pendVal = Double.parseDouble(String.valueOf(b.get("pending"))); } catch(Exception e){}
                try { totalVal = Double.parseDouble(String.valueOf(b.get("total"))); } catch(Exception e){}
            }
            
            String cardTheme = type.toLowerCase();
            // Percentage calculation for Timeline progress
            double availPercent = (entVal > 0) ? (totalVal / entVal) * 100 : 0;

            // Fungsi untuk membuang .0 jika nilai adalah bulat (cth: 5.0 -> 5)
            java.text.DecimalFormat df = new java.text.DecimalFormat("0.#");
        %>
          <div class="card <%= cardTheme %>">
            <div class="label">
              <%= type %> LEAVE
              <i class="fas fa-calendar-check" style="opacity: 0.15; font-size: 18px;"></i>
            </div>
            
            <div class="big">
              <%= df.format(totalVal) %> <span>Days Available</span>
            </div>

            <div class="timeline-track">
                <div class="timeline-bar" style="width: <%= Math.min(availPercent, 100) %>%;"></div>
            </div>

            <div class="card-footer">
                <div class="entitlement-text">Base Entitlement: <b><%= df.format(entVal) %></b> days/year</div>
                <div class="stats-row">
                    <div class="stat-box">
                        <span>USE</span>
                        <b><%= df.format(usedVal) %></b>
                    </div>
                    <div class="divider"></div>
                    <div class="stat-box">
                        <span>PENDING</span>
                        <b style="color:var(--orange);"><%= df.format(pendVal) %></b>
                    </div>
                </div>
            </div>
          </div>
        <% } %>
        <!-- Empty slot to maintain grid symmetry -->
        <div class="card-empty" style="opacity: 0;"></div>
      </div>

      <div class="gridMain">
        <!-- Small & Nice Calendar Section -->
        <div class="cal-card">
          <div class="calHeader">
            <div class="calTitle"><%= monthTitle %></div>
            <div class="calNav">
              <a href="EmployeeDashboardServlet?year=<%=prev.getYear()%>&month=<%=prev.getMonthValue()%>"><i class="fas fa-chevron-left"></i></a>
              <a href="EmployeeDashboardServlet?year=<%=next.getYear()%>&month=<%=next.getMonthValue()%>"><i class="fas fa-chevron-right"></i></a>
            </div>
          </div>

          <table class="calTable">
            <thead>
              <tr><th>SUN</th><th>MON</th><th>TUE</th><th>WED</th><th>THU</th><th>FRI</th><th>SAT</th></tr>
            </thead>
            <tbody>
            <%
              int dayCounter = 1;
              for (int row = 0; row < 6; row++) {
            %>
              <tr>
                <%
                  for (int col = 0; col < 7; col++) {
                    int cellIndex = row * 7 + col;
                    if (cellIndex < firstDow || dayCounter > daysInMonth) {
                %>
                    <td><span class="dayBox mutedDay">&nbsp;</span></td>
                <%
                    } else {
                      LocalDate cursor = ym.atDay(dayCounter);
                      boolean isToday = cursor.equals(today);
                      List<Map<String,Object>> hs = holidayMap.get(cursor);
                      boolean isHoliday = (hs != null && !hs.isEmpty());

                      String tipText = "";
                      String dotClass = ""; 

                      if (isHoliday) {
                        StringBuilder sb = new StringBuilder();
                        String hType = String.valueOf(hs.get(0).get("type")).toUpperCase();
                        for (int k=0; k<hs.size(); k++) {
                          sb.append(String.valueOf(hs.get(k).get("name")));
                          if (k < hs.size()-1) sb.append(" • ");
                        }
                        tipText = sb.toString();
                        if (hType.contains("PUBLIC")) dotClass = "h-public-dot";
                        else if (hType.contains("STATE")) dotClass = "h-state-dot";
                        else if (hType.contains("COMPANY")) dotClass = "h-company-dot";
                      }
                %>
                  <td>
                    <div class="tipWrap">
                      <span class="dayBox <%= isToday ? "today" : "" %>"><%= dayCounter %></span>
                      <% if (isHoliday) { %>
                        <div class="h-dot <%= dotClass %>"></div>
                        <span class="tip"><%= tipText %></span>
                      <% } %>
                    </div>
                  </td>
                <% dayCounter++; } } %>
              </tr>
            <% if (dayCounter > daysInMonth) break; } %>
            </tbody>
          </table>

          <div class="legend">
            <div class="legend-item"><div class="legend-dot" style="background:var(--red);"></div> Public</div>
            <div class="legend-item"><div class="legend-dot" style="background:var(--orange);"></div> State</div>
            <div class="legend-item"><div class="legend-dot" style="background:var(--blue);"></div> Company</div>
          </div>
        </div>

        <div style="display: flex; flex-direction: column; gap: 20px; justify-content: space-between;">
          <!-- Upcoming Holidays -->
          <div class="cal-card" style="flex-grow: 1;">
            <h3 style="font-weight:800; font-size:16px; margin: 0 0 16px 0; color: #1e293b; display: flex; align-items: center; gap: 8px;">
                <i class="far fa-calendar-check" style="color:#64748b;"></i> Upcoming Holidays
            </h3>
            <%
              int upCount = 0;
              for (Map<String,Object> h : holidayUpcoming) {
                if (upCount >= 4) break; // Reduced to 4 to save space
                LocalDate d = (LocalDate) h.get("date");
                String hType = String.valueOf(h.get("type")).toUpperCase();
                String badgeCls = hType.contains("PUBLIC") ? "public" : (hType.contains("STATE") ? "state" : "company");
            %>
                <div class="hListItem" style="padding: 8px 0;">
                  <div class="dateBadge <%= badgeCls %>" style="width:44px; height:44px;">
                    <span style="font-size:14px;"><%= d.getDayOfMonth() %></span>
                    <span style="font-size:8px;"><%= d.getMonth().getDisplayName(TextStyle.SHORT, Locale.ENGLISH).toUpperCase() %></span>
                  </div>
                  <div>
                    <p class="hName" style="font-size:13px;"><%= h.get("name") %></p>
                    <div class="hType" style="font-size:11px;"><%= h.get("type") %></div>
                  </div>
                </div>
            <% upCount++; } if (upCount == 0) { %>
                <div style="color: #64748b; font-size: 13px;">No upcoming holidays found.</div>
            <% } %>
          </div>

          <!-- Leave Guidelines - COMPACT & ALIGNED WITH LEGEND -->
          <div class="cal-card" style="background: #f8fafc; border: 1px dashed #e2e8f0; padding: 15px;">
            <h3 style="font-weight:800; font-size:14px; margin: 0 0 10px 0; color: #1e293b; text-transform: uppercase; letter-spacing: 0.5px;">Leave Guidelines</h3>
            <ul style="list-style: none; padding: 0; margin: 0;">
              <li style="display: flex; align-items: start; gap: 10px; font-size: 12px; color: #64748b; margin-bottom: 6px;">
                <div style="width: 5px; height: 5px; border-radius: 50%; background:var(--blue); flex-shrink: 0; margin-top: 4px;"></div> 
                Annual leave: 3 days notice.
              </li>
              <li style="display: flex; align-items: start; gap: 10px; font-size: 12px; color: #64748b; margin-bottom: 6px;">
                <div style="width: 5px; height: 5px; border-radius: 50%; background:var(--teal); flex-shrink: 0; margin-top: 4px;"></div> 
                Sick leave: MC required.
              </li>
              <li style="display: flex; align-items: start; gap: 10px; font-size: 12px; color: #64748b; margin-bottom: 6px;">
                <div style="width: 5px; height: 5px; border-radius: 50%; background:var(--purple); flex-shrink: 0; margin-top: 4px;"></div> 
                Hospitalization: Max 60 days.
              </li>
              <li style="display: flex; align-items: start; gap: 10px; font-size: 12px; color: #64748b;">
                <div style="width: 5px; height: 5px; border-radius: 50%; background:var(--red); flex-shrink: 0; margin-top: 4px;"></div> 
                Maternity: 98 days (Female).
              </li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </div>
</body>
</html>