# Infrastructure Scanning Workflow
# Usage: .\workflows\infra_scan.ps1 <ip_or_domain>
param(
    [Parameter(Mandatory=$true)]
    [string]$Target
)

$ErrorActionPreference = "Continue"
$ScriptDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$OutDir = Join-Path $ScriptDir "results\infra_$Target\$Timestamp"
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null

Write-Host "============================================"
Write-Host "  INFRA SCAN: $Target"
Write-Host "  Output: $OutDir"
Write-Host "============================================"
Write-Host ""

# 1. Shodan CLI lookup
if (Get-Command shodan -ErrorAction SilentlyContinue) {
    Write-Host "[*] Running Shodan host lookup..." -ForegroundColor Cyan
    shodan host $Target > (Join-Path $OutDir "shodan.txt") 2>&1
    Write-Host "[+] Shodan complete" -ForegroundColor Green
} else {
    Write-Host "[!] Shodan CLI not installed. Run: pip install shodan" -ForegroundColor Yellow
}

# 2. Censys CLI lookup
if (Get-Command censys -ErrorAction SilentlyContinue) {
    Write-Host "[*] Running Censys host lookup..." -ForegroundColor Cyan
    censys view $Target > (Join-Path $OutDir "censys.txt") 2>&1
    Write-Host "[+] Censys complete" -ForegroundColor Green
} else {
    Write-Host "[!] Censys CLI not installed. Run: pip install censys" -ForegroundColor Yellow
}

# 3. Nmap (if available)
if (Get-Command nmap -ErrorAction SilentlyContinue) {
    Write-Host "[*] Running Nmap service scan (top 100 ports)..." -ForegroundColor Cyan
    nmap -sV --top-ports 100 -T4 $Target -oN (Join-Path $OutDir "nmap.txt") 2>$null
    Write-Host "[+] Nmap complete" -ForegroundColor Green
} else {
    Write-Host "[!] Nmap not installed. Download from https://nmap.org/download" -ForegroundColor Yellow
}

# 4. WHOIS
if (Get-Command whois -ErrorAction SilentlyContinue) {
    Write-Host "[*] Running WHOIS..." -ForegroundColor Cyan
    whois $Target > (Join-Path $OutDir "whois.txt") 2>$null
    Write-Host "[+] WHOIS complete" -ForegroundColor Green
}

# 5. Reverse DNS
Write-Host "[*] Running reverse DNS..." -ForegroundColor Cyan
try {
    $reverseDns = Resolve-DnsName -Name $Target -Type PTR -ErrorAction SilentlyContinue
    if ($reverseDns) {
        $reverseDns | Format-List | Out-File -FilePath (Join-Path $OutDir "reverse_dns.txt") -Encoding utf8
    }
    Write-Host "[+] Reverse DNS complete" -ForegroundColor Green
} catch {
    Write-Host "[!] Reverse DNS lookup failed" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "============================================"
Write-Host "  INFRA SCAN COMPLETE"
Write-Host "  Results: $OutDir"
Write-Host "============================================"
