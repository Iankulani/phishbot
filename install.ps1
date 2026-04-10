# PHISH-BOT v2.0.0 Installation Script for PowerShell
# Author: Ian Carter Kulani

Write-Host @"
============================================================
    🐋 PHISH-BOT v2.0.0 - PowerShell Installation Script
    Author: Ian Carter Kulani
============================================================
"@ -ForegroundColor Cyan

# Set error handling
$ErrorActionPreference = "Stop"

# Function to check admin rights
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Check Python
Write-Host "`n[1/7] Checking Python installation..." -ForegroundColor Green
try {
    $pythonVersion = python --version 2>&1
    Write-Host "[OK] $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Python not found. Please install Python 3.7+ from python.org" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Check pip
Write-Host "`n[2/7] Checking pip..." -ForegroundColor Green
try {
    pip --version 2>&1 | Out-Null
    Write-Host "[OK] pip found" -ForegroundColor Green
} catch {
    Write-Host "Installing pip..." -ForegroundColor Yellow
    python -m ensurepip --upgrade
}

# Create virtual environment
Write-Host "`n[3/7] Creating virtual environment..." -ForegroundColor Green
if (Test-Path ".venv") {
    Write-Host "Virtual environment already exists" -ForegroundColor Yellow
} else {
    python -m venv .venv
    Write-Host "[OK] Virtual environment created" -ForegroundColor Green
}

# Activate and install dependencies
Write-Host "`n[4/7] Installing Python dependencies..." -ForegroundColor Green
& .venv\Scripts\Activate.ps1

# Upgrade pip
python -m pip install --upgrade pip setuptools wheel

# Install requirements
$requirements = Get-Content requirements.txt
foreach ($req in $requirements) {
    if ($req -and $req -notmatch '^#') {
        Write-Host "  Installing: $req" -ForegroundColor Cyan
        try {
            pip install $req --no-cache-dir
        } catch {
            Write-Host "  [WARNING] Retrying $req..." -ForegroundColor Yellow
            pip install $req --no-cache-dir --force-reinstall
        }
    }
}

# Create directories
Write-Host "`n[5/7] Creating configuration directories..." -ForegroundColor Green
$directories = @(
    ".phishbot", ".phishbot\data", ".phishbot\logs", ".phishbot\wordlists",
    ".phishbot\phishing_templates", ".phishbot\captured_credentials",
    ".phishbot\ssh_keys", ".phishbot\workspaces", ".phishbot\traffic_logs",
    "wordlists", "captured", "reports"
)

foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "  Created: $dir" -ForegroundColor Gray
    }
}

# Create .env file
Write-Host "`n[6/7] Creating configuration file..." -ForegroundColor Green
if (-not (Test-Path ".env")) {
    $envContent = @'
PHISHBOT_ENV=development
LOG_LEVEL=INFO
DATABASE_PATH=.phishbot\phishbot.db
CONFIG_PATH=.phishbot\config.json
TRAFFIC_MAX_DURATION=300
PHISHING_DEFAULT_PORT=8080
CRUNCH_MAX_SIZE_MB=1024
SSH_DEFAULT_TIMEOUT=30
SSH_MAX_CONNECTIONS=5
DISCORD_ENABLED=false
TELEGRAM_ENABLED=false
SLACK_ENABLED=false
WHATSAPP_ENABLED=false
IMESSAGE_ENABLED=false
'@
    $envContent | Out-File -FilePath ".env" -Encoding UTF8
    Write-Host "[OK] .env file created" -ForegroundColor Green
} else {
    Write-Host ".env file already exists" -ForegroundColor Yellow
}

# Install Chocolatey and system tools (optional)
Write-Host "`n[7/7] Installing optional system tools..." -ForegroundColor Green
$installTools = Read-Host "Install network tools (nmap, wireshark, etc.)? (y/n)"
if ($installTools -eq 'y') {
    if (-not (Test-Administrator)) {
        Write-Host "Please run PowerShell as Administrator to install system tools" -ForegroundColor Yellow
    } else {
        # Install Chocolatey if not present
        if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        }
        
        # Install tools
        choco install nmap wireshark curl wget git python -y
    }
}

# Completion message
Write-Host @"
`n============================================================
    ✅ PHISH-BOT Installation Complete!
============================================================

  Run the bot:
    .venv\Scripts\Activate.ps1
    python phishbot.py

  Or run as Administrator (for full functionality):
    Right-click PowerShell -> Run as Administrator
    cd $PWD
    .venv\Scripts\python.exe phishbot.py

  Configuration: .env
  Data directory: .phishbot\

============================================================
"@ -ForegroundColor Green

# Ask to run
$run = Read-Host "Do you want to start PHISH-BOT now? (y/n)"
if ($run -eq 'y') {
    if (Test-Administrator) {
        & .venv\Scripts\python.exe phishbot.py
    } else {
        Write-Host "Warning: Running without Administrator privileges" -ForegroundColor Yellow
        & .venv\Scripts\python.exe phishbot.py
    }
}