# Install Sherlock - username search across social networks
param(
    [string]$InstallDir = ".\tools",
    [string]$VenvDir = ".\.venv"
)

$SherlockDir = Join-Path $InstallDir "sherlock"

if (Test-Path $SherlockDir) {
    Write-Host "[*] Sherlock already installed, updating..." -ForegroundColor Cyan
    Push-Location $SherlockDir
    git pull --quiet
    Pop-Location
} else {
    Write-Host "[*] Cloning Sherlock..." -ForegroundColor Cyan
    git clone --depth 1 https://github.com/sherlock-project/sherlock.git $SherlockDir
}

Write-Host "[*] Installing Sherlock dependencies..." -ForegroundColor Cyan
$activateScript = Join-Path $VenvDir "Scripts\Activate.ps1"
if (Test-Path $activateScript) { & $activateScript }
pip install -e $SherlockDir -q 2>$null
if ($LASTEXITCODE -ne 0) { pip install sherlock-project -q 2>$null }

Write-Host "[+] Sherlock installed. Usage: sherlock <username>" -ForegroundColor Green
