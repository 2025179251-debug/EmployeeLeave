<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Employee Registration Result</title>

    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 40px;
        }

        h2 {
            margin-bottom: 10px;
        }

        .message {
            margin-bottom: 20px;
            font-weight: bold;
        }

        .success {
            color: green;
        }

        .error {
            color: red;
        }

        .result-box {
            max-width: 600px;
        }

        table.result-table {
            border-collapse: collapse;
            width: 100%;
            margin-top: 10px;
        }

        table.result-table th,
        table.result-table td {
            border: 1px solid #333;
            padding: 8px 12px;
        }

        table.result-table th {
            background-color: #f2f2f2;
            text-align: left;
            width: 35%;
        }

        a {
            display: inline-block;
            margin-top: 20px;
        }
    </style>
</head>
<body>
<div class="result-box">
    <h2>Employee Registration Result</h2>

    <!-- Display message (success / error) -->
    <c:choose>
        <c:when test="${not empty param.msg}">
            <p class="message success">
                <c:out value="${param.msg}" />
            </p>
        </c:when>
        <c:otherwise>
            <p class="message error">
                No status message received.
            </p>
        </c:otherwise>
    </c:choose>

    <!-- Employee details table (values will appear if passed to this page) -->
    <table class="result-table">
        <tr>
            <th>Employee ID</th>
            <td><c:out value="${param.empId}" /></td>
        </tr>
        <tr>
            <th>Full Name</th>
            <td><c:out value="${param.fullName}" /></td>
        </tr>
        <tr>
            <th>Email</th>
            <td><c:out value="${param.email}" /></td>
        </tr>
        <tr>
            <th>Gender</th>
            <td><c:out value="${param.gender}" /></td>
        </tr>
        <tr>
            <th>Hire Date</th>
            <td><c:out value="${param.hireDate}" /></td>
        </tr>
        <tr>
            <th>Phone Number</th>
            <td><c:out value="${param.phoneNo}" /></td>
        </tr>
        <tr>
            <th>Address</th>
            <td><c:out value="${param.address}" /></td>
        </tr>
        <tr>
            <th>IC Number</th>
            <td><c:out value="${param.icNumber}" /></td>
        </tr>
    </table>

    <a href="index.html">Back to Form</a>
</div>
</body>
</html>
