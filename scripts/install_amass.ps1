# Install Amass - subdomain enumeration and network mapping
param(
    [string]$InstallDir = ".\tools"
)

Write-Host "[*] Installing Amass..." -ForegroundColor Cyan

# Try Go install first
if (Get-Command go -ErrorAction SilentlyContinue) {
    Write-Host "[*] Installing Amass via Go..." -ForegroundColor Cyan
    go install -v github.com/owasp-amass/amass/v4/...@master 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[+] Amass installed via Go" -ForegroundColor Green
        return
    }
}

# Fallback: download prebuilt release for Windows
$AmassDir = Join-Path $InstallDir "amass"
if (-not (Test-Path $AmassDir)) {
    New-Item -ItemType Directory -Path $AmassDir -Force | Out-Null
}

Write-Host "[*] Downloading Amass prebuilt binary for Windows..." -ForegroundColor Cyan

try {
    $releasePage = "https://github.com/owasp-amass/amass/releases/latest"
    $response = Invoke-WebRequest -Uri $releasePage -MaximumRedirection 0 -ErrorAction SilentlyContinue 2>$null
} catch {
    # Get redirect URL from the exception
    $redirectUrl = $_.Exception.Response.Headers.Location
}

if ($redirectUrl) {
    $dlBase = $redirectUrl -replace "/tag/", "/download/"
    $filename = "amass_windows_amd64.zip"
    $dlUrl = "$dlBase/$filename"
    $zipPath = Join-Path $env:TEMP $filename

    try {
        Invoke-WebRequest -Uri $dlUrl -OutFile $zipPath -UseBasicParsing
        Expand-Archive -Path $zipPath -DestinationPath $AmassDir -Force
        Remove-Item $zipPath -Force
        Write-Host "[+] Amass downloaded to $AmassDir" -ForegroundColor Green
    } catch {
        Write-Host "[!] Could not download Amass. Install manually:" -ForegroundColor Yellow
        Write-Host "    https://github.com/owasp-amass/amass/releases" -ForegroundColor Yellow
    }
} else {
    Write-Host "[!] Could not determine latest Amass release. Install manually:" -ForegroundColor Yellow
    Write-Host "    https://github.com/owasp-amass/amass/releases" -ForegroundColor Yellow
}

Write-Host "    Usage: amass enum -d <domain>" -ForegroundColor White
