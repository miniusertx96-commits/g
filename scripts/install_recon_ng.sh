#!/usr/bin/env bash
# Install Recon-ng — the Metasploit of OSINT
set -euo pipefail

INSTALL_DIR="${1:-./tools}"
VENV_DIR="${2:-./.venv}"
RNG_DIR="${INSTALL_DIR}/recon-ng"

if [ -d "$RNG_DIR" ]; then
    echo "[*] Recon-ng already installed, updating..."
    cd "$RNG_DIR" && git pull --quiet
else
    echo "[*] Cloning Recon-ng..."
    git clone --depth 1 https://github.com/lanmaster53/recon-ng.git "$RNG_DIR"
fi

echo "[*] Installing Recon-ng dependencies..."
# shellcheck disable=SC1091
source "${VENV_DIR}/bin/activate" 2>/dev/null || true
pip install -r "${RNG_DIR}/REQUIREMENTS" -q 2>/dev/null || pip install -r "${RNG_DIR}/requirements.txt" -q 2>/dev/null || echo "[!] Check Recon-ng requirements manually"

echo "[+] Recon-ng installed."
echo "    Usage: cd ${RNG_DIR} && python3 recon-ng"
