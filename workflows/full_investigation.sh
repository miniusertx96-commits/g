#!/usr/bin/env bash
# Full Investigation — runs all workflows from targets.yaml
# Usage: bash workflows/full_investigation.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "============================================"
echo "  FULL INVESTIGATION"
echo "  Using config/targets.yaml"
echo "============================================"
echo

# Use the Python CLI which parses YAML and orchestrates everything
python3 "${SCRIPT_DIR}/osint.py" --full
