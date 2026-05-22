# Domain Reconnaissance Workflow
# Usage: .\workflows\domain_recon.ps1 <domain>
param(
    [Parameter(Mandatory=$true)]
    [string]$Domain
)

$ErrorActionPreference = "Continue"
$ScriptDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$ToolsDir = Join-Path $ScriptDir "tools"
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$OutDir = Join-Path $ScriptDir "results\domain_$Domain\$Timestamp"
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null

Write-Host "============================================"
Write-Host "  DOMAIN RECON: $Domain"
Write-Host "  Output: $OutDir"
Write-Host "============================================"
Write-Host ""

# 1. theHarvester
$ThScript = Join-Path $ToolsDir "theHarvester\theHarvester.py"
if (Test-Path $ThScript) {
    Write-Host "[*] Running theHarvester..." -ForegroundColor Cyan
    python $ThScript -d $Domain -b all -l 500 > (Join-Path $OutDir "theharvester.txt") 2>&1
    Write-Host "[+] theHarvester complete" -ForegroundColor Green
} else {
    Write-Host "[!] theHarvester not installed" -ForegroundColor Yellow
}

# 2. Amass (passive)
if (Get-Command amass -ErrorAction SilentlyContinue) {
    Write-Host "[*] Running Amass (passive)..." -ForegroundColor Cyan
    amass enum -passive -d $Domain -o (Join-Path $OutDir "amass_subdomains.txt") 2>$null
    Write-Host "[+] Amass complete" -ForegroundColor Green
} else {
    Write-Host "[!] Amass not installed" -ForegroundColor Yellow
}

# 3. WHOIS
if (Get-Command whois -ErrorAction SilentlyContinue) {
    Write-Host "[*] Running WHOIS..." -ForegroundColor Cyan
    whois $Domain > (Join-Path $OutDir "whois.txt") 2>$null
    Write-Host "[+] WHOIS complete" -ForegroundColor Green
}

# 4. DNS records
Write-Host "[*] Querying DNS records..." -ForegroundColor Cyan
$dnsFile = Join-Path $OutDir "dns_records.txt"
try {
    $records = @()
    $records += "=== A Records ==="
    $records += (Resolve-DnsName -Name $Domain -Type A -ErrorAction SilentlyContinue | ForEach-Object { $_.IPAddress }) -join "`n"
    $records += ""
    $records += "=== MX Records ==="
    $records += (Resolve-DnsName -Name $Domain -Type MX -ErrorAction SilentlyContinue | ForEach-Object { "$($_.Preference) $($_.NameExchange)" }) -join "`n"
    $records += ""
    $records += "=== NS Records ==="
    $records += (Resolve-DnsName -Name $Domain -Type NS -ErrorAction SilentlyContinue | ForEach-Object { $_.NameHost }) -join "`n"
    $records += ""
    $records += "=== TXT Records ==="
    $records += (Resolve-DnsName -Name $Domain -Type TXT -ErrorAction SilentlyContinue | ForEach-Object { $_.Strings }) -join "`n"
    $records | Out-File -FilePath $dnsFile -Encoding utf8
    Write-Host "[+] DNS records complete" -ForegroundColor Green
} catch {
    Write-Host "[!] DNS lookup failed: $_" -ForegroundColor Yellow
}

# 5. Wayback Machine
Write-Host "[*] Querying Wayback Machine..." -ForegroundColor Cyan
$waybackFile = Join-Path $OutDir "wayback.txt"
try {
    $response = Invoke-WebRequest -Uri "https://web.archive.org/cdx/search/cdx?url=$Domain&output=text&fl=timestamp,original,statuscode&limit=100" -UseBasicParsing -TimeoutSec 30
    $response.Content | Out-File -FilePath $waybackFile -Encoding utf8
    $snapCount = ($response.Content -split "`n" | Where-Object { $_.Trim() }).Count
    Write-Host "[+] Wayback: $snapCount snapshots found" -ForegroundColor Green
} catch {
    Write-Host "[!] Wayback lookup failed: $_" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "============================================"
Write-Host "  DOMAIN RECON COMPLETE"
Write-Host "  Results: $OutDir"
Write-Host "============================================"
