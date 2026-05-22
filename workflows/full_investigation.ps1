# Full Investigation - runs all workflows from targets.yaml
# Usage: .\workflows\full_investigation.ps1

$ScriptDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

Write-Host "============================================"
Write-Host "  FULL INVESTIGATION"
Write-Host "  Using config\targets.yaml"
Write-Host "============================================"
Write-Host ""

python (Join-Path $ScriptDir "osint.py") --full
