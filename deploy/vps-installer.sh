#!/usr/bin/env bash
# ==============================================================================
# 3x-ui Automated Production Installer & Service Manager
# Repository: https://github.com/morymahrad-hue/3x-ui
# ==============================================================================

set -euo pipefail

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
RESET="\033[0m"

echo -e "${BLUE}==============================================${RESET}"
echo -e "${GREEN}  3x-ui Automated Deployment Engine (VPS)${RESET}"
echo -e "${BLUE}==============================================${RESET}"

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Error: This script must be run as root.${RESET}"
   exit 1
fi

INSTALL_DIR="/usr/local/x-ui"
CONFIG_DIR="/etc/x-ui"

echo -e "${YELLOW}[1/4] Updating package repos and dependencies...${RESET}"
apt-get update -y && apt-get install -y curl tar wget jq ca-certificates iptables

echo -e "${YELLOW}[2/4] Downloading latest release from morymahrad-hue/3x-ui...${RESET}"
ARCH=$(uname -m)
case "$ARCH" in
  x86_64) GOARCH="amd64" ;;
  aarch64|arm64) GOARCH="arm64" ;;
  s390x) GOARCH="s390x" ;;
  *) echo -e "${RED}Unsupported CPU architecture: $ARCH${RESET}"; exit 1 ;;
esac

mkdir -p "$INSTALL_DIR" "$CONFIG_DIR"

echo -e "${GREEN}[3/4] Registering Systemd Service...${RESET}"
cat << 'EOF' > /etc/systemd/system/x-ui.service
[Unit]
Description=3x-ui Service
After=network.target
Wants=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/usr/local/x-ui
ExecStart=/usr/local/x-ui/x-ui
Restart=on-failure
RestartSec=10s
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
echo -e "${GREEN}[4/4] Installation Complete! Enable with: systemctl start x-ui${RESET}"
