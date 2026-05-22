#!/usr/bin/env bash
# Person Lookup Workflow
# Usage: bash workflows/person_lookup.sh <username> [email]
set -euo pipefail

USERNAME="${1:?Usage: $0 <username> [email]}"
EMAIL="${2:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${SCRIPT_DIR}/results/person_${USERNAME}/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUT_DIR"

echo "============================================"
echo "  PERSON LOOKUP: ${USERNAME}"
echo "  Output: ${OUT_DIR}"
echo "============================================"
echo

# 1. Sherlock — username across social networks
if command -v sherlock &>/dev/null; then
    echo "[*] Running Sherlock..."
    sherlock "$USERNAME" --output "${OUT_DIR}/sherlock_${USERNAME}.txt" --print-found 2>/dev/null || true
    echo "[+] Sherlock complete"
else
    echo "[!] Sherlock not installed. Run: pip install sherlock-project"
fi

# 2. Holehe — email to registered accounts
if [ -n "$EMAIL" ]; then
    if command -v holehe &>/dev/null; then
        echo "[*] Running Holehe for ${EMAIL}..."
        holehe "$EMAIL" --no-color > "${OUT_DIR}/holehe_${EMAIL}.txt" 2>&1 || true
        echo "[+] Holehe complete"
    else
        echo "[!] Holehe not installed. Run: pip install holehe"
    fi
else
    echo "[*] No email provided — skipping Holehe"
fi

echo
echo "============================================"
echo "  PERSON LOOKUP COMPLETE"
echo "  Results: ${OUT_DIR}"
echo "============================================"
