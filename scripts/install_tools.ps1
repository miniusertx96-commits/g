# Bulk installer - runs all individual tool installers
param(
    [string]$InstallDir = (Join-Path (Split-Path -Parent $PSScriptRoot) "tools"),
    [string]$VenvDir = (Join-Path (Split-Path -Parent $PSScriptRoot) ".venv")
)

Write-Host "[*] Running all OSINT tool installers..." -ForegroundColor Cyan
Write-Host "[*] Install directory: $InstallDir"
Write-Host "[*] Virtual env: $VenvDir"
Write-Host ""

$scripts = @(
    "install_sherlock.ps1",
    "install_holehe.ps1",
    "install_spiderfoot.ps1",
    "install_recon_ng.ps1",
    "install_theharvester.ps1",
    "install_amass.ps1"
)

foreach ($script in $scripts) {
    $scriptPath = Join-Path $PSScriptRoot $script
    if (Test-Path $scriptPath) {
        Write-Host "=== $script ===" -ForegroundColor Cyan
        & $scriptPath $InstallDir $VenvDir
        Write-Host ""
    } else {
        Write-Host "[!] Skipping $script (not found)" -ForegroundColor Yellow
    }
}

Write-Host "[+] All tools installed." -ForegroundColor Green
