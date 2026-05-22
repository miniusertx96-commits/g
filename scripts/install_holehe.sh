#!/usr/bin/env bash
# Install Holehe — email to registered accounts lookup
set -euo pipefail

VENV_DIR="${2:-./.venv}"

echo "[*] Installing Holehe..."
# shellcheck disable=SC1091
source "${VENV_DIR}/bin/activate" 2>/dev/null || true
pip install holehe -q

echo "[+] Holehe installed. Usage: holehe <email>"
