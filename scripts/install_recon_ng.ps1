# Install Recon-ng - the Metasploit of OSINT
param(
    [string]$InstallDir = ".\tools",
    [string]$VenvDir = ".\.venv"
)

$RngDir = Join-Path $InstallDir "recon-ng"

if (Test-Path $RngDir) {
    Write-Host "[*] Recon-ng already installed, updating..." -ForegroundColor Cyan
    Push-Location $RngDir
    git pull --quiet
    Pop-Location
} else {
    Write-Host "[*] Cloning Recon-ng..." -ForegroundColor Cyan
    git clone --depth 1 https://github.com/lanmaster53/recon-ng.git $RngDir
}

Write-Host "[*] Installing Recon-ng dependencies..." -ForegroundColor Cyan
$activateScript = Join-Path $VenvDir "Scripts\Activate.ps1"
if (Test-Path $activateScript) { & $activateScript }

$reqFiles = @("REQUIREMENTS", "requirements.txt")
$installed = $false
foreach ($reqFile in $reqFiles) {
    $reqPath = Join-Path $RngDir $reqFile
    if (Test-Path $reqPath) {
        pip install -r $reqPath -q 2>$null
        $installed = $true
        break
    }
}
if (-not $installed) {
    Write-Host "[!] Check Recon-ng requirements manually" -ForegroundColor Yellow
}

Write-Host "[+] Recon-ng installed." -ForegroundColor Green
Write-Host "    Usage: cd $RngDir; python recon-ng"
