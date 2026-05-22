#!/usr/bin/env bash
# Install Amass — subdomain enumeration and network mapping
set -euo pipefail

echo "[*] Installing Amass..."

# Try snap first, then Go install, then prebuilt binary
if command -v snap &>/dev/null; then
    sudo snap install amass 2>/dev/null && echo "[+] Amass installed via snap" && exit 0
fi

if command -v go &>/dev/null; then
    echo "[*] Installing Amass via Go..."
    go install -v github.com/owasp-amass/amass/v4/...@master 2>/dev/null && echo "[+] Amass installed via Go" && exit 0
fi

# Fallback: download prebuilt release
ARCH="$(uname -m)"
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"

case "$ARCH" in
    x86_64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
esac

INSTALL_DIR="${1:-./tools}"
AMASS_DIR="${INSTALL_DIR}/amass"
mkdir -p "$AMASS_DIR"

echo "[*] Downloading Amass prebuilt binary..."
RELEASE_URL="https://github.com/owasp-amass/amass/releases/latest"
DL_URL=$(curl -sL -o /dev/null -w '%{url_effective}' "$RELEASE_URL" | sed 's|/tag/|/download/|')
FILENAME="amass_${OS}_${ARCH}.zip"

curl -sL "${DL_URL}/${FILENAME}" -o "/tmp/${FILENAME}" 2>/dev/null
if [ -f "/tmp/${FILENAME}" ]; then
    unzip -qo "/tmp/${FILENAME}" -d "$AMASS_DIR" 2>/dev/null || true
    rm -f "/tmp/${FILENAME}"
    echo "[+] Amass downloaded to ${AMASS_DIR}"
else
    echo "[!] Could not download Amass. Install manually:"
    echo "    https://github.com/owasp-amass/amass/releases"
fi

echo "    Usage: amass enum -d <domain>"
