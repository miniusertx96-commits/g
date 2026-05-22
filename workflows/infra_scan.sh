#!/usr/bin/env bash
# Infrastructure Scanning Workflow
# Usage: bash workflows/infra_scan.sh <ip_or_domain>
set -euo pipefail

TARGET="${1:?Usage: $0 <ip_or_domain>}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${SCRIPT_DIR}/results/infra_${TARGET}/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUT_DIR"

echo "============================================"
echo "  INFRA SCAN: ${TARGET}"
echo "  Output: ${OUT_DIR}"
echo "============================================"
echo

# 1. Shodan CLI lookup
if command -v shodan &>/dev/null; then
    echo "[*] Running Shodan host lookup..."
    shodan host "$TARGET" > "${OUT_DIR}/shodan.txt" 2>&1 || true
    echo "[+] Shodan complete"
else
    echo "[!] Shodan CLI not installed. Run: pip install shodan"
fi

# 2. Censys CLI lookup
if command -v censys &>/dev/null; then
    echo "[*] Running Censys host lookup..."
    censys view "$TARGET" > "${OUT_DIR}/censys.txt" 2>&1 || true
    echo "[+] Censys complete"
else
    echo "[!] Censys CLI not installed. Run: pip install censys"
fi

# 3. Nmap (if available — basic service detection)
if command -v nmap &>/dev/null; then
    echo "[*] Running Nmap service scan (top 100 ports)..."
    nmap -sV --top-ports 100 -T4 "$TARGET" -oN "${OUT_DIR}/nmap.txt" 2>/dev/null || true
    echo "[+] Nmap complete"
else
    echo "[!] Nmap not installed"
fi

# 4. WHOIS
if command -v whois &>/dev/null; then
    echo "[*] Running WHOIS..."
    whois "$TARGET" > "${OUT_DIR}/whois.txt" 2>/dev/null || true
    echo "[+] WHOIS complete"
fi

# 5. Reverse DNS
if command -v dig &>/dev/null; then
    echo "[*] Running reverse DNS..."
    dig +short -x "$TARGET" > "${OUT_DIR}/reverse_dns.txt" 2>/dev/null || true
    echo "[+] Reverse DNS complete"
fi

echo
echo "============================================"
echo "  INFRA SCAN COMPLETE"
echo "  Results: ${OUT_DIR}"
echo "============================================"
