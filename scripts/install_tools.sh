#!/usr/bin/env bash
# Bulk installer — runs all individual tool installers
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${1:-$(dirname "$SCRIPT_DIR")/tools}"
VENV_DIR="${2:-$(dirname "$SCRIPT_DIR")/.venv}"

echo "[*] Running all OSINT tool installers..."
echo "[*] Install directory: ${INSTALL_DIR}"
echo "[*] Virtual env: ${VENV_DIR}"
echo

for script in \
    install_sherlock.sh \
    install_holehe.sh \
    install_spiderfoot.sh \
    install_recon_ng.sh \
    install_theharvester.sh \
    install_amass.sh; do
    if [ -f "${SCRIPT_DIR}/${script}" ]; then
        echo "=== ${script} ==="
        bash "${SCRIPT_DIR}/${script}" "$INSTALL_DIR" "$VENV_DIR"
        echo
    else
        echo "[!] Skipping ${script} (not found)"
    fi
done

echo "[+] All tools installed."
