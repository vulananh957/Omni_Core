<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>400 - Yêu cầu không hợp lệ</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f5f5f5; display: flex; align-items: center; justify-content: center; height: 100vh; margin: 0; }
        .error-box { background: white; padding: 3rem; border-radius: 12px; box-shadow: 0 2px 12px rgba(0,0,0,0.1); text-align: center; max-width: 480px; }
        h1 { color: #e67e22; font-size: 5rem; margin: 0; }
        h2 { color: #333; margin: 0.5rem 0; }
        p { color: #666; }
        a { display: inline-block; margin-top: 1.5rem; padding: 0.75rem 2rem; background: #3498db; color: white; text-decoration: none; border-radius: 6px; }
        a:hover { background: #2980b9; }
    </style>
</head>
<body>
    <div class="error-box">
        <h1>400</h1>
        <h2>Yêu cầu không hợp lệ</h2>
        <p>Dữ liệu bạn gửi lên không đúng định dạng hoặc thiếu thông tin cần thiết.</p>
        <a href="${pageContext.request.contextPath}/login">Quay lại trang chính</a>
    </div>
</body>
</html>
