#!/usr/bin/env bash
# Domain Reconnaissance Workflow
# Usage: bash workflows/domain_recon.sh <domain>
set -euo pipefail

DOMAIN="${1:?Usage: $0 <domain>}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOLS_DIR="${SCRIPT_DIR}/tools"
OUT_DIR="${SCRIPT_DIR}/results/domain_${DOMAIN}/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUT_DIR"

echo "============================================"
echo "  DOMAIN RECON: ${DOMAIN}"
echo "  Output: ${OUT_DIR}"
echo "============================================"
echo

# 1. theHarvester
TH="${TOOLS_DIR}/theHarvester/theHarvester.py"
if [ -f "$TH" ]; then
    echo "[*] Running theHarvester..."
    python3 "$TH" -d "$DOMAIN" -b all -l 500 > "${OUT_DIR}/theharvester.txt" 2>&1 || true
    echo "[+] theHarvester complete"
else
    echo "[!] theHarvester not installed"
fi

# 2. Amass (passive)
if command -v amass &>/dev/null; then
    echo "[*] Running Amass (passive)..."
    amass enum -passive -d "$DOMAIN" -o "${OUT_DIR}/amass_subdomains.txt" 2>/dev/null || true
    echo "[+] Amass complete"
else
    echo "[!] Amass not installed"
fi

# 3. WHOIS
if command -v whois &>/dev/null; then
    echo "[*] Running WHOIS..."
    whois "$DOMAIN" > "${OUT_DIR}/whois.txt" 2>/dev/null || true
    echo "[+] WHOIS complete"
fi

# 4. DNS records
if command -v dig &>/dev/null; then
    echo "[*] Querying DNS records..."
    {
        echo "=== A Records ==="
        dig +short A "$DOMAIN"
        echo
        echo "=== MX Records ==="
        dig +short MX "$DOMAIN"
        echo
        echo "=== NS Records ==="
        dig +short NS "$DOMAIN"
        echo
        echo "=== TXT Records ==="
        dig +short TXT "$DOMAIN"
        echo
        echo "=== CNAME ==="
        dig +short CNAME "$DOMAIN"
    } > "${OUT_DIR}/dns_records.txt" 2>/dev/null
    echo "[+] DNS records complete"
fi

# 5. Wayback Machine
echo "[*] Querying Wayback Machine..."
curl -s "https://web.archive.org/cdx/search/cdx?url=${DOMAIN}&output=text&fl=timestamp,original,statuscode&limit=100" \
    > "${OUT_DIR}/wayback.txt" 2>/dev/null || true
SNAP_COUNT=$(wc -l < "${OUT_DIR}/wayback.txt" 2>/dev/null || echo 0)
echo "[+] Wayback: ${SNAP_COUNT} snapshots found"

echo
echo "============================================"
echo "  DOMAIN RECON COMPLETE"
echo "  Results: ${OUT_DIR}"
echo "============================================"
