#!/bin/bash
# PHISH-BOT v2.0.0 Installation Script for Linux/macOS
# Author: Ian Carter Kulani

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║     🐋 PHISH-BOT v2.0.0 - Installation Script               ║
║     Author: Ian Carter Kulani                                ║
╚══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check Python version
echo -e "${GREEN}[1/8] Checking Python version...${NC}"
python_version=$(python3 --version 2>&1 | cut -d' ' -f2)
if [[ $(echo "$python_version" | cut -d'.' -f2) -lt 7 ]]; then
    echo -e "${RED}Python 3.7+ required. Found $python_version${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Python $python_version found${NC}"

# Detect OS
echo -e "${GREEN}[2/8] Detecting operating system...${NC}"
OS="$(uname -s)"
case "${OS}" in
    Linux*)     OS_TYPE="Linux";;
    Darwin*)    OS_TYPE="macOS";;
    *)          OS_TYPE="Unknown";;
esac
echo -e "${GREEN}✓ OS: $OS_TYPE${NC}"

# Install system dependencies
echo -e "${GREEN}[3/8] Installing system dependencies...${NC}"
if [[ "$OS_TYPE" == "Linux" ]]; then
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y \
            python3-pip python3-dev \
            nmap hping3 dsniff macchanger \
            net-tools iproute2 iptables \
            tcpdump traceroute dnsutils \
            whois curl wget git \
            nikto sqlmap gobuster dirb \
            chromium-browser chromium-chromedriver \
            libpcap-dev build-essential
    elif command -v yum &> /dev/null; then
        sudo yum install -y epel-release
        sudo yum install -y \
            python3-pip python3-devel \
            nmap hping3 dsniff macchanger \
            net-tools iproute iptables \
            tcpdump traceroute bind-utils \
            whois curl wget git \
            nikto sqlmap gobuster \
            chromium chromium-driver \
            libpcap-devel gcc gcc-c++
    fi
elif [[ "$OS_TYPE" == "macOS" ]]; then
    if ! command -v brew &> /dev/null; then
        echo -e "${YELLOW}Homebrew not found. Installing...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew update
    brew install python@3.11 nmap hping3 dsniff macchanger \
         net-tools tcpdump traceroute bind whois curl wget \
         git nikto sqlmap gobuster chromium chromedriver \
         libpcap
fi

# Create virtual environment
echo -e "${GREEN}[4/8] Creating virtual environment...${NC}"
python3 -m venv .venv
source .venv/bin/activate

# Upgrade pip
echo -e "${GREEN}[5/8] Upgrading pip...${NC}"
pip install --upgrade pip setuptools wheel

# Install Python dependencies
echo -e "${GREEN}[6/8] Installing Python dependencies...${NC}"
pip install -r requirements.txt

# Create configuration directories
echo -e "${GREEN}[7/8] Creating configuration directories...${NC}"
mkdir -p .phishbot/{data,logs,wordlists,phishing_templates,captured_credentials,ssh_keys,workspaces,traffic_logs,reports}
mkdir -p wordlists captured reports

# Create .env file from example
if [ ! -f .env ]; then
    echo -e "${GREEN}[8/8] Creating .env configuration...${NC}"
    cat > .env << 'EOF'
# PHISH-BOT Environment Configuration
PHISHBOT_ENV=development
LOG_LEVEL=INFO
DATABASE_PATH=.phishbot/phishbot.db
CONFIG_PATH=.phishbot/config.json
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
EOF
fi

# Set permissions
chmod +x phishbot.py
chmod -R 755 .phishbot

echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║     ✅ PHISH-BOT Installation Complete!                      ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║  Run the bot:                                                ║"
echo "║    source .venv/bin/activate                                 ║"
echo "║    python phishbot.py                                        ║"
echo "║                                                              ║"
echo "║  Or with sudo (for full functionality):                      ║"
echo "║    sudo .venv/bin/python phishbot.py                         ║"
echo "║                                                              ║"
echo "║  Configuration: .env                                         ║"
echo "║  Data directory: .phishbot/                                  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Ask to run
read -p "Do you want to start PHISH-BOT now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo .venv/bin/python phishbot.py
fi