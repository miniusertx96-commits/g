#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${SCRIPT_DIR}/tools"
VENV_DIR="${SCRIPT_DIR}/.venv"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${CYAN}[*]${NC} $*"; }
ok()    { echo -e "${GREEN}[+]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
fail()  { echo -e "${RED}[-]${NC} $*"; }

banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
  ___  ____ ___ _   _ _____   _____           _ _    _ _
 / _ \/ ___|_ _| \ | |_   _| |_   _|__   ___ | | | _(_) |_
| | | \___ \| ||  \| | | |     | |/ _ \ / _ \| | |/ / | __|
| |_| |___) | || |\  | | |     | | (_) | (_) | |   <| | |_
 \___/|____/___|_| \_| |_|     |_|\___/ \___/|_|_|\_\_|\__|
EOF
    echo -e "${NC}"
    echo "Complete OSINT Investigation Stack"
    echo "==================================="
    echo
}

check_deps() {
    info "Checking system dependencies..."
    local missing=()
    for cmd in python3 pip3 git curl wget; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        warn "Missing dependencies: ${missing[*]}"
        info "Installing missing dependencies..."
        if command -v apt-get &>/dev/null; then
            sudo apt-get update -qq
            sudo apt-get install -y -qq python3 python3-pip python3-venv git curl wget
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y python3 python3-pip git curl wget
        elif command -v brew &>/dev/null; then
            brew install python3 git curl wget
        else
            fail "Cannot auto-install dependencies. Install manually: ${missing[*]}"
            exit 1
        fi
    fi
    ok "System dependencies satisfied"
}

setup_venv() {
    info "Setting up Python virtual environment..."
    if [ ! -d "$VENV_DIR" ]; then
        python3 -m venv "$VENV_DIR"
    fi
    # shellcheck disable=SC1091
    source "${VENV_DIR}/bin/activate"
    pip install --upgrade pip -q
    pip install -r "${SCRIPT_DIR}/requirements.txt" -q
    ok "Python environment ready"
}

setup_configs() {
    info "Setting up configuration files..."
    if [ ! -f "${SCRIPT_DIR}/config/api_keys.yaml" ]; then
        cp "${SCRIPT_DIR}/config/api_keys.example.yaml" "${SCRIPT_DIR}/config/api_keys.yaml"
        warn "Created config/api_keys.yaml — edit it to add your API keys"
    fi
    if [ ! -f "${SCRIPT_DIR}/config/targets.yaml" ]; then
        cp "${SCRIPT_DIR}/config/targets.example.yaml" "${SCRIPT_DIR}/config/targets.yaml"
        warn "Created config/targets.yaml — edit it to configure investigation targets"
    fi
    ok "Configuration ready"
}

create_dirs() {
    info "Creating directory structure..."
    mkdir -p "$INSTALL_DIR"
    mkdir -p "${SCRIPT_DIR}/results"
    mkdir -p "${SCRIPT_DIR}/results/archives"
    mkdir -p "${SCRIPT_DIR}/results/reports"
    mkdir -p "${SCRIPT_DIR}/results/screenshots"
    ok "Directory structure ready"
}

install_tools() {
    info "Installing OSINT tools..."
    echo

    local scripts_dir="${SCRIPT_DIR}/scripts"

    for installer in \
        install_sherlock.sh \
        install_holehe.sh \
        install_spiderfoot.sh \
        install_recon_ng.sh \
        install_theharvester.sh \
        install_amass.sh; do
        if [ -f "${scripts_dir}/${installer}" ]; then
            info "Running ${installer}..."
            bash "${scripts_dir}/${installer}" "$INSTALL_DIR" "$VENV_DIR" || warn "${installer} had issues — check output above"
            echo
        fi
    done

    ok "Tool installation complete"
}

print_summary() {
    echo
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  OSINT Toolkit Setup Complete${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo
    echo "  Next steps:"
    echo "    1. Edit config/api_keys.yaml with your API keys"
    echo "    2. Edit config/targets.yaml with investigation targets"
    echo "    3. Run: python3 osint.py"
    echo
    echo "  Or run individual workflows:"
    echo "    bash workflows/domain_recon.sh <domain>"
    echo "    bash workflows/person_lookup.sh <username>"
    echo "    bash workflows/infra_scan.sh <ip>"
    echo "    bash workflows/full_investigation.sh"
    echo
    echo "  Documentation:"
    echo "    docs/STACK_OVERVIEW.md   — Full stack reference"
    echo "    docs/WORKFLOW.md         — Investigation methodology"
    echo "    docs/TOOLS.md            — Tool details & API keys"
    echo "    docs/AI_INTEGRATION.md   — AI-assisted analysis"
    echo
}

main() {
    banner
    check_deps
    create_dirs
    setup_venv
    setup_configs
    install_tools
    print_summary
}

main "$@"
