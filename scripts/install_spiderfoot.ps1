# Install SpiderFoot - automated OSINT recon (200+ data sources)
param(
    [string]$InstallDir = ".\tools",
    [string]$VenvDir = ".\.venv"
)

$SfDir = Join-Path $InstallDir "spiderfoot"

if (Test-Path $SfDir) {
    Write-Host "[*] SpiderFoot already installed, updating..." -ForegroundColor Cyan
    Push-Location $SfDir
    git pull --quiet
    Pop-Location
} else {
    Write-Host "[*] Cloning SpiderFoot..." -ForegroundColor Cyan
    git clone --depth 1 https://github.com/smicallef/spiderfoot.git $SfDir
}

Write-Host "[*] Installing SpiderFoot dependencies..." -ForegroundColor Cyan
$activateScript = Join-Path $VenvDir "Scripts\Activate.ps1"
if (Test-Path $activateScript) { & $activateScript }
$reqFile = Join-Path $SfDir "requirements.txt"
if (Test-Path $reqFile) {
    pip install -r $reqFile -q 2>$null
} else {
    Write-Host "[!] Some SpiderFoot deps may need manual install" -ForegroundColor Yellow
}

Write-Host "[+] SpiderFoot installed." -ForegroundColor Green
Write-Host "    Web UI:  cd $SfDir; python sf.py -l 127.0.0.1:5001"
Write-Host "    CLI:     cd $SfDir; python sfcli.py"
