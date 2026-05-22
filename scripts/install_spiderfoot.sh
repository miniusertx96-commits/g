#!/usr/bin/env bash
# Install SpiderFoot — automated OSINT recon (200+ data sources)
set -euo pipefail

INSTALL_DIR="${1:-./tools}"
VENV_DIR="${2:-./.venv}"
SF_DIR="${INSTALL_DIR}/spiderfoot"

if [ -d "$SF_DIR" ]; then
    echo "[*] SpiderFoot already installed, updating..."
    cd "$SF_DIR" && git pull --quiet
else
    echo "[*] Cloning SpiderFoot..."
    git clone --depth 1 https://github.com/smicallef/spiderfoot.git "$SF_DIR"
fi

echo "[*] Installing SpiderFoot dependencies..."
# shellcheck disable=SC1091
source "${VENV_DIR}/bin/activate" 2>/dev/null || true
pip install -r "${SF_DIR}/requirements.txt" -q 2>/dev/null || echo "[!] Some SpiderFoot deps may need manual install"

echo "[+] SpiderFoot installed."
echo "    Web UI:  cd ${SF_DIR} && python3 sf.py -l 127.0.0.1:5001"
echo "    CLI:     cd ${SF_DIR} && python3 sfcli.py"
