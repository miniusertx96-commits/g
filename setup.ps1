# OSINT Toolkit — Windows Setup Script
# Run: powershell -ExecutionPolicy Bypass -File setup.ps1

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$InstallDir = Join-Path $ScriptDir "tools"
$VenvDir = Join-Path $ScriptDir ".venv"

function Write-Banner {
    Write-Host @"

  ___  ____ ___ _   _ _____   _____           _ _    _ _
 / _ \/ ___|_ _| \ | |_   _| |_   _|__   ___ | | | _(_) |_
| | | \___ \| ||  \| | | |     | |/ _ \ / _ \| | |/ / | __|
| |_| |___) | || |\  | | |     | | (_) | (_) | |   <| | |_
 \___/|____/___|_| \_| |_|     |_|\___/ \___/|_|_|\_\_|\__|

"@ -ForegroundColor Cyan
    Write-Host "Complete OSINT Investigation Stack (Windows)" -ForegroundColor White
    Write-Host "=============================================" -ForegroundColor White
    Write-Host ""
}

function Test-Dependencies {
    Write-Host "[*] Checking system dependencies..." -ForegroundColor Cyan
    $missing = @()

    foreach ($cmd in @("python", "git", "curl")) {
        if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
            $missing += $cmd
        }
    }

    if ($missing.Count -gt 0) {
        Write-Host "[!] Missing dependencies: $($missing -join ', ')" -ForegroundColor Yellow
        Write-Host "[!] Please install them manually:" -ForegroundColor Yellow
        Write-Host "    Python: https://www.python.org/downloads/" -ForegroundColor Yellow
        Write-Host "    Git:    https://git-scm.com/download/win" -ForegroundColor Yellow
        Write-Host "    Or use: winget install Python.Python.3 Git.Git" -ForegroundColor Yellow
        exit 1
    }

    Write-Host "[+] System dependencies satisfied" -ForegroundColor Green
}

function Initialize-Venv {
    Write-Host "[*] Setting up Python virtual environment..." -ForegroundColor Cyan

    if (-not (Test-Path $VenvDir)) {
        python -m venv $VenvDir
    }

    $activateScript = Join-Path $VenvDir "Scripts\Activate.ps1"
    & $activateScript

    pip install --upgrade pip -q 2>$null
    pip install -r (Join-Path $ScriptDir "requirements.txt") -q 2>$null

    Write-Host "[+] Python environment ready" -ForegroundColor Green
}

function Initialize-Configs {
    Write-Host "[*] Setting up configuration files..." -ForegroundColor Cyan

    $apiKeysYaml = Join-Path $ScriptDir "config\api_keys.yaml"
    $apiKeysExample = Join-Path $ScriptDir "config\api_keys.example.yaml"
    if (-not (Test-Path $apiKeysYaml)) {
        Copy-Item $apiKeysExample $apiKeysYaml
        Write-Host "[!] Created config\api_keys.yaml - edit it to add your API keys" -ForegroundColor Yellow
    }

    $targetsYaml = Join-Path $ScriptDir "config\targets.yaml"
    $targetsExample = Join-Path $ScriptDir "config\targets.example.yaml"
    if (-not (Test-Path $targetsYaml)) {
        Copy-Item $targetsExample $targetsYaml
        Write-Host "[!] Created config\targets.yaml - edit it to configure investigation targets" -ForegroundColor Yellow
    }

    Write-Host "[+] Configuration ready" -ForegroundColor Green
}

function New-Directories {
    Write-Host "[*] Creating directory structure..." -ForegroundColor Cyan

    $dirs = @(
        $InstallDir,
        (Join-Path $ScriptDir "results"),
        (Join-Path $ScriptDir "results\archives"),
        (Join-Path $ScriptDir "results\reports"),
        (Join-Path $ScriptDir "results\screenshots")
    )

    foreach ($dir in $dirs) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }

    Write-Host "[+] Directory structure ready" -ForegroundColor Green
}

function Install-Tools {
    Write-Host "[*] Installing OSINT tools..." -ForegroundColor Cyan
    Write-Host ""

    $scriptsDir = Join-Path $ScriptDir "scripts"

    $installers = @(
        "install_sherlock.ps1",
        "install_holehe.ps1",
        "install_spiderfoot.ps1",
        "install_recon_ng.ps1",
        "install_theharvester.ps1",
        "install_amass.ps1"
    )

    foreach ($installer in $installers) {
        $installerPath = Join-Path $scriptsDir $installer
        if (Test-Path $installerPath) {
            Write-Host "[*] Running $installer..." -ForegroundColor Cyan
            try {
                & $installerPath $InstallDir $VenvDir
            } catch {
                Write-Host "[!] $installer had issues: $_" -ForegroundColor Yellow
            }
            Write-Host ""
        }
    }

    Write-Host "[+] Tool installation complete" -ForegroundColor Green
}

function Write-Summary {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  OSINT Toolkit Setup Complete" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Next steps:"
    Write-Host "    1. Edit config\api_keys.yaml with your API keys"
    Write-Host "    2. Edit config\targets.yaml with investigation targets"
    Write-Host "    3. Run: python osint.py"
    Write-Host ""
    Write-Host "  Or run individual workflows:"
    Write-Host "    .\workflows\domain_recon.ps1 <domain>"
    Write-Host "    .\workflows\person_lookup.ps1 <username>"
    Write-Host "    .\workflows\infra_scan.ps1 <ip>"
    Write-Host "    .\workflows\full_investigation.ps1"
    Write-Host ""
    Write-Host "  Documentation:"
    Write-Host "    docs\STACK_OVERVIEW.md   - Full stack reference"
    Write-Host "    docs\WORKFLOW.md         - Investigation methodology"
    Write-Host "    docs\TOOLS.md            - Tool details & API keys"
    Write-Host "    docs\AI_INTEGRATION.md   - AI-assisted analysis"
    Write-Host ""
}

# Main
Write-Banner
Test-Dependencies
New-Directories
Initialize-Venv
Initialize-Configs
Install-Tools
Write-Summary
