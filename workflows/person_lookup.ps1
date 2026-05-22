# Person Lookup Workflow
# Usage: .\workflows\person_lookup.ps1 <username> [-Email <email>]
param(
    [Parameter(Mandatory=$true)]
    [string]$Username,
    [string]$Email = ""
)

$ErrorActionPreference = "Continue"
$ScriptDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$OutDir = Join-Path $ScriptDir "results\person_$Username\$Timestamp"
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null

Write-Host "============================================"
Write-Host "  PERSON LOOKUP: $Username"
Write-Host "  Output: $OutDir"
Write-Host "============================================"
Write-Host ""

# 1. Sherlock - username across social networks
if (Get-Command sherlock -ErrorAction SilentlyContinue) {
    Write-Host "[*] Running Sherlock..." -ForegroundColor Cyan
    $sherlockOut = Join-Path $OutDir "sherlock_$Username.txt"
    sherlock $Username --output $sherlockOut --print-found 2>$null
    Write-Host "[+] Sherlock complete" -ForegroundColor Green
} else {
    Write-Host "[!] Sherlock not installed. Run: pip install sherlock-project" -ForegroundColor Yellow
}

# 2. Holehe - email to registered accounts
if ($Email) {
    if (Get-Command holehe -ErrorAction SilentlyContinue) {
        Write-Host "[*] Running Holehe for $Email..." -ForegroundColor Cyan
        $holeheOut = Join-Path $OutDir "holehe_$Email.txt"
        holehe $Email --no-color > $holeheOut 2>&1
        Write-Host "[+] Holehe complete" -ForegroundColor Green
    } else {
        Write-Host "[!] Holehe not installed. Run: pip install holehe" -ForegroundColor Yellow
    }
} else {
    Write-Host "[*] No email provided - skipping Holehe" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "============================================"
Write-Host "  PERSON LOOKUP COMPLETE"
Write-Host "  Results: $OutDir"
Write-Host "============================================"
