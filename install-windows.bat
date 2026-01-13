@echo off
setlocal enabledelayedexpansion

echo.
echo ========================================
echo       LAN Chat - Quick Installer
echo ========================================
echo.

REM Configuration
set INSTALL_DIR=%LOCALAPPDATA%\LanChat
set GITHUB_REPO=yourusername/lan-chat

REM Check Python
echo Checking Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo [ERROR] Python 3 is required but not installed.
    echo.
    echo Please download and install Python from:
    echo https://www.python.org/downloads/
    echo.
    echo IMPORTANT: Check "Add Python to PATH" during installation!
    echo.
    pause
    exit /b 1
)
echo [OK] Python found

REM Create installation directory
echo.
echo Installing to: %INSTALL_DIR%
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

REM Copy files (assumes running from extracted folder)
echo.
echo Copying files...
xcopy /E /I /Y "service\*" "%INSTALL_DIR%\" >nul

REM Create virtual environment
echo.
echo Setting up Python environment...
cd /d "%INSTALL_DIR%"
python -m venv venv
call venv\Scripts\pip install --upgrade pip -q
call venv\Scripts\pip install -r requirements.txt -q

REM Create data directories
if not exist "%INSTALL_DIR%\data\files" mkdir "%INSTALL_DIR%\data\files"
if not exist "%INSTALL_DIR%\data\exports" mkdir "%INSTALL_DIR%\data\exports"

REM Create start script
echo.
echo Creating start script...
(
echo @echo off
echo cd /d "%INSTALL_DIR%"
echo start "" /B venv\Scripts\pythonw.exe main.py
) > "%INSTALL_DIR%\start-lan-chat.bat"

REM Create stop script
(
echo @echo off
echo taskkill /F /IM pythonw.exe /FI "WINDOWTITLE eq *lan-chat*" 2^>nul
echo taskkill /F /IM python.exe /FI "MEMUSAGE gt 50000" 2^>nul
echo echo LAN Chat stopped.
) > "%INSTALL_DIR%\stop-lan-chat.bat"

REM Add to startup
echo.
echo Setting up auto-start...
set STARTUP_FOLDER=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup
(
echo @echo off
echo start "" /B "%INSTALL_DIR%\start-lan-chat.bat"
) > "%STARTUP_FOLDER%\LanChat.bat"

REM Create desktop shortcut
echo Creating desktop shortcut...
powershell -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%USERPROFILE%\Desktop\LAN Chat.lnk'); $s.TargetPath = '%INSTALL_DIR%\start-lan-chat.bat'; $s.WorkingDirectory = '%INSTALL_DIR%'; $s.WindowStyle = 7; $s.Description = 'Start LAN Chat Service'; $s.Save()" 2>nul

REM Start the service now
echo.
echo Starting LAN Chat service...
start "" /B "%INSTALL_DIR%\start-lan-chat.bat"

REM Wait a moment
timeout /t 3 /nobreak >nul

REM Get IP address
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4"') do (
    set IP=%%a
    set IP=!IP:~1!
    goto :found_ip
)
:found_ip

echo.
echo ========================================
echo       Installation Complete!
echo ========================================
echo.
echo Your IP Address: %IP%
echo.
echo Next Steps:
echo   1. Open Firefox
echo   2. Click the LAN Chat icon in toolbar
echo   3. Start chatting!
echo.
echo LAN Chat will start automatically with Windows.
echo.
echo Shortcuts created:
echo   - Desktop: "LAN Chat" (to start service)
echo   - Auto-start: Enabled
echo.
pause