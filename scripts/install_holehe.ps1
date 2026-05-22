# Install Holehe - email to registered accounts lookup
param(
    [string]$InstallDir = ".\tools",
    [string]$VenvDir = ".\.venv"
)

Write-Host "[*] Installing Holehe..." -ForegroundColor Cyan
$activateScript = Join-Path $VenvDir "Scripts\Activate.ps1"
if (Test-Path $activateScript) { & $activateScript }
pip install holehe -q 2>$null

Write-Host "[+] Holehe installed. Usage: holehe <email>" -ForegroundColor Green
