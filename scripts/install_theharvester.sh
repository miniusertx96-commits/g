#!/usr/bin/env bash
# Install theHarvester — email/subdomain/IP enumeration
set -euo pipefail

INSTALL_DIR="${1:-./tools}"
VENV_DIR="${2:-./.venv}"
TH_DIR="${INSTALL_DIR}/theHarvester"

if [ -d "$TH_DIR" ]; then
    echo "[*] theHarvester already installed, updating..."
    cd "$TH_DIR" && git pull --quiet
else
    echo "[*] Cloning theHarvester..."
    git clone --depth 1 https://github.com/laramies/theHarvester.git "$TH_DIR"
fi

echo "[*] Installing theHarvester dependencies..."
# shellcheck disable=SC1091
source "${VENV_DIR}/bin/activate" 2>/dev/null || true
pip install -r "${TH_DIR}/requirements.txt" -q 2>/dev/null || pip install theHarvester -q 2>/dev/null || echo "[!] Check theHarvester requirements"

echo "[+] theHarvester installed."
echo "    Usage: cd ${TH_DIR} && python3 theHarvester.py -d <domain> -b all"
