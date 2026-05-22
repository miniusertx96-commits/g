# Install theHarvester - email/subdomain/IP enumeration
param(
    [string]$InstallDir = ".\tools",
    [string]$VenvDir = ".\.venv"
)

$ThDir = Join-Path $InstallDir "theHarvester"

if (Test-Path $ThDir) {
    Write-Host "[*] theHarvester already installed, updating..." -ForegroundColor Cyan
    Push-Location $ThDir
    git pull --quiet
    Pop-Location
} else {
    Write-Host "[*] Cloning theHarvester..." -ForegroundColor Cyan
    git clone --depth 1 https://github.com/laramies/theHarvester.git $ThDir
}

Write-Host "[*] Installing theHarvester dependencies..." -ForegroundColor Cyan
$activateScript = Join-Path $VenvDir "Scripts\Activate.ps1"
if (Test-Path $activateScript) { & $activateScript }

$reqFile = Join-Path $ThDir "requirements.txt"
if (Test-Path $reqFile) {
    pip install -r $reqFile -q 2>$null
} else {
    pip install theHarvester -q 2>$null
}

Write-Host "[+] theHarvester installed." -ForegroundColor Green
Write-Host "    Usage: cd $ThDir; python theHarvester.py -d <domain> -b all"
