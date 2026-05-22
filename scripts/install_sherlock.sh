#!/usr/bin/env bash
# Install Sherlock — username search across social networks
set -euo pipefail

INSTALL_DIR="${1:-./tools}"
VENV_DIR="${2:-./.venv}"
SHERLOCK_DIR="${INSTALL_DIR}/sherlock"

if [ -d "$SHERLOCK_DIR" ]; then
    echo "[*] Sherlock already installed, updating..."
    cd "$SHERLOCK_DIR" && git pull --quiet
else
    echo "[*] Cloning Sherlock..."
    git clone --depth 1 https://github.com/sherlock-project/sherlock.git "$SHERLOCK_DIR"
fi

echo "[*] Installing Sherlock dependencies..."
# shellcheck disable=SC1091
source "${VENV_DIR}/bin/activate" 2>/dev/null || true
pip install -e "$SHERLOCK_DIR" -q 2>/dev/null || pip install sherlock-project -q

echo "[+] Sherlock installed. Usage: sherlock <username>"
