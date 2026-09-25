@echo off
chcp 65001 >nul
title [DEV] - QUẢN LÝ LINK TEST CHO QC

:MENU
cls
echo ===================================================================
echo             HỆ THỐNG PHÁT LINK TEST TỰ ĐỘNG CHO QC
echo ===================================================================
echo   [1] BẬT LINK TEST CHO QC (Tự động sinh link HTTPS & copy clipboard)
echo   [2] TẮT HỆ THỐNG (Đóng link, giải phóng 100%% RAM)
echo   [0] Thoát
echo ===================================================================
set /p choice="Nhập lựa chọn của bạn (Mặc định nhấn Enter để chạy [1]): "

if "%choice%"=="" set choice=1
if "%choice%"=="1" goto START_TUNNEL
if "%choice%"=="2" goto STOP_ALL
if "%choice%"=="0" exit /b
goto MENU

:START_TUNNEL
echo.
echo [*] Đang kiểm tra Docker Desktop...
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo [LỖI] Docker Desktop chưa được bật! Vui lòng bật Docker Desktop trước.
    pause
    goto MENU
)

echo [*] Đang khởi động App, MySQL và tạo đường truyền bảo mật Cloudflare...
docker compose up -d

echo [*] Đang lấy đường link HTTPS công khai...
powershell -NoProfile -Command ^
    "$stopwatch = [System.Diagnostics.Stopwatch]::StartNew();" ^
    "$url = $null;" ^
    "while ($stopwatch.Elapsed.TotalSeconds -lt 25) {" ^
    "    $logs = docker logs demo_tunnel_qc 2>&1;" ^
    "    $match = [regex]::Match($logs, 'https://[a-zA-Z0-9-]+\.trycloudflare\.com');" ^
    "    if ($match.Success) { $url = $match.Value; break; }" ^
    "    Start-Sleep -Seconds 1;" ^
    "};" ^
    "if ($url) {" ^
    "    Set-Content -Path '.qc_url.tmp' -Value $url -Encoding UTF8;" ^
    "    $url | Set-Clipboard;" ^
    "} else { exit 1 }"

if not exist ".qc_url.tmp" (
    echo [LỖI] Chưa lấy được link từ Cloudflare. Vui lòng thử lại.
    pause
    goto MENU
)

set /p QC_URL=<.qc_url.tmp
del .qc_url.tmp >nul 2>&1

echo.
echo ===================================================================
echo [THÀNH CÔNG] ĐÃ TẠO XONG LINK TEST HTTPS CÔNG KHAI!
echo.
echo   🔗 LINK DÀNH CHO QC TEST:
echo   --------------------------------------------------------------
echo   %QC_URL%
echo   --------------------------------------------------------------
echo.
echo   (*) Link đã được TỰ ĐỘNG COPY vào Clipboard! (Nhấn Ctrl + V gửi QC)
echo   (*) QC không cần cài bất kỳ thứ gì, chỉ cần click link để test.
echo ===================================================================
start %QC_URL%
echo.
pause
goto MENU

:STOP_ALL
echo.
echo [*] Đang tắt ứng dụng, MySQL và đóng link public...
docker compose down
echo.
echo [ĐÃ TẮT] Đã đóng toàn bộ container và giải phóng RAM!
pause
goto MENU
