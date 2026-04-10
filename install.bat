@echo off
REM PHISH-BOT v2.0.0 Installation Script for Windows
REM Author: Ian Carter Kulani

setlocal enabledelayedexpansion

title PHISH-BOT Installer

echo.
echo ============================================================
echo     🐋 PHISH-BOT v2.0.0 - Windows Installation Script
echo     Author: Ian Carter Kulani
echo ============================================================
echo.

REM Check Python
echo [1/6] Checking Python installation...
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python not found. Please install Python 3.7+ from python.org
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

python --version
echo [OK] Python found

REM Check pip
echo.
echo [2/6] Checking pip...
pip --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] pip not found. Installing...
    python -m ensurepip --upgrade
)

REM Create virtual environment
echo.
echo [3/6] Creating virtual environment...
if exist ".venv" (
    echo Virtual environment already exists
) else (
    python -m venv .venv
    echo [OK] Virtual environment created
)

REM Activate and install dependencies
echo.
echo [4/6] Installing Python dependencies...
call .venv\Scripts\activate.bat
python -m pip install --upgrade pip setuptools wheel

REM Install requirements with retry
for /f "tokens=*" %%i in (requirements.txt) do (
    echo Installing: %%i
    pip install %%i
    if errorlevel 1 (
        echo [WARNING] Failed to install %%i, retrying...
        pip install --no-cache-dir %%i
    )
)

REM Create directories
echo.
echo [5/6] Creating configuration directories...
if not exist ".phishbot" mkdir ".phishbot"
if not exist ".phishbot\data" mkdir ".phishbot\data"
if not exist ".phishbot\logs" mkdir ".phishbot\logs"
if not exist ".phishbot\wordlists" mkdir ".phishbot\wordlists"
if not exist ".phishbot\phishing_templates" mkdir ".phishbot\phishing_templates"
if not exist ".phishbot\captured_credentials" mkdir ".phishbot\captured_credentials"
if not exist ".phishbot\ssh_keys" mkdir ".phishbot\ssh_keys"
if not exist ".phishbot\workspaces" mkdir ".phishbot\workspaces"
if not exist ".phishbot\traffic_logs" mkdir ".phishbot\traffic_logs"
if not exist "wordlists" mkdir "wordlists"
if not exist "captured" mkdir "captured"
if not exist "reports" mkdir "reports"

REM Create .env file
echo.
echo [6/6] Creating configuration file...
if not exist ".env" (
    echo PHISHBOT_ENV=development > .env
    echo LOG_LEVEL=INFO >> .env
    echo DATABASE_PATH=.phishbot\phishbot.db >> .env
    echo CONFIG_PATH=.phishbot\config.json >> .env
    echo TRAFFIC_MAX_DURATION=300 >> .env
    echo PHISHING_DEFAULT_PORT=8080 >> .env
    echo CRUNCH_MAX_SIZE_MB=1024 >> .env
    echo SSH_DEFAULT_TIMEOUT=30 >> .env
    echo SSH_MAX_CONNECTIONS=5 >> .env
    echo DISCORD_ENABLED=false >> .env
    echo TELEGRAM_ENABLED=false >> .env
    echo SLACK_ENABLED=false >> .env
    echo WHATSAPP_ENABLED=false >> .env
    echo IMESSAGE_ENABLED=false >> .env
)

echo.
echo ============================================================
echo     ✅ PHISH-BOT Installation Complete!
echo ============================================================
echo.
echo   Run the bot:
echo     .venv\Scripts\activate.bat
echo     python phishbot.py
echo.
echo   Or run as Administrator (for full functionality):
echo     Right-click Command Prompt -> Run as Administrator
echo     cd %CD%
echo     .venv\Scripts\python.exe phishbot.py
echo.
echo   Configuration: .env
echo   Data directory: .phishbot\
echo.
echo ============================================================
echo.

set /p run="Do you want to start PHISH-BOT now? (y/n): "
if /i "%run%"=="y" (
    python phishbot.py
)

pause