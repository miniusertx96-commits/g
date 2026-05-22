#!/usr/bin/env python3
"""
OSINT Toolkit — Main CLI Launcher

A unified interface for running OSINT investigations using
a layered stack of tools.
"""

import argparse
import os
import subprocess
import sys
import shutil
from datetime import datetime
from pathlib import Path

try:
    from rich.console import Console
    from rich.table import Table
    from rich.panel import Panel
    from rich.prompt import Prompt, Confirm
    from rich import box
    HAS_RICH = True
except ImportError:
    HAS_RICH = False

ROOT = Path(__file__).resolve().parent
TOOLS_DIR = ROOT / "tools"
RESULTS_DIR = ROOT / "results"
VENV_DIR = ROOT / ".venv"
CONFIG_DIR = ROOT / "config"


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def banner():
    art = r"""
  ___  ____ ___ _   _ _____   _____           _ _    _ _
 / _ \/ ___|_ _| \ | |_   _| |_   _|__   ___ | | | _(_) |_
| | | \___ \| ||  \| | | |     | |/ _ \ / _ \| | |/ / | __|
| |_| |___) | || |\  | | |     | | (_) | (_) | |   <| | |_
 \___/|____/___|_| \_| |_|     |_|\___/ \___/|_|_|\_\_|\__|
"""
    if HAS_RICH:
        console = Console()
        console.print(art, style="cyan")
        console.print("Complete OSINT Investigation Stack\n", style="bold white")
    else:
        print(art)
        print("Complete OSINT Investigation Stack\n")


def run_cmd(cmd, cwd=None, capture=False):
    """Run a shell command, streaming output unless capture=True."""
    try:
        if capture:
            result = subprocess.run(
                cmd, shell=True, cwd=cwd,
                capture_output=True, text=True, timeout=300,
            )
            return result.stdout.strip()
        else:
            subprocess.run(cmd, shell=True, cwd=cwd, timeout=600)
    except subprocess.TimeoutExpired:
        print("[!] Command timed out")
    except FileNotFoundError:
        print(f"[!] Command not found: {cmd}")


def tool_available(name):
    """Check if a tool binary/script is available."""
    return shutil.which(name) is not None


def ensure_results_dir(subdir=""):
    """Create and return a timestamped results directory."""
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    d = RESULTS_DIR / subdir / ts
    d.mkdir(parents=True, exist_ok=True)
    return d


# ---------------------------------------------------------------------------
# Tool Runners
# ---------------------------------------------------------------------------

def run_sherlock(username, output_dir):
    """Run Sherlock username search."""
    if not tool_available("sherlock"):
        print("[!] Sherlock not installed. Run: bash scripts/install_sherlock.sh")
        return
    print(f"[*] Running Sherlock for: {username}")
    out = output_dir / f"sherlock_{username}.txt"
    run_cmd(f"sherlock {username} --output {out} --print-found")
    print(f"[+] Results saved to {out}")


def run_holehe(email, output_dir):
    """Run Holehe email lookup."""
    if not tool_available("holehe"):
        print("[!] Holehe not installed. Run: pip install holehe")
        return
    print(f"[*] Running Holehe for: {email}")
    out = output_dir / f"holehe_{email.replace('@', '_at_')}.txt"
    run_cmd(f"holehe {email} --no-color > {out} 2>&1")
    print(f"[+] Results saved to {out}")


def run_theharvester(domain, output_dir):
    """Run theHarvester domain recon."""
    th_dir = TOOLS_DIR / "theHarvester"
    th_script = th_dir / "theHarvester.py"
    if not th_script.exists():
        print("[!] theHarvester not installed. Run: bash scripts/install_theharvester.sh")
        return
    print(f"[*] Running theHarvester for: {domain}")
    out = output_dir / f"theharvester_{domain}.txt"
    run_cmd(
        f"python3 {th_script} -d {domain} -b all -l 500 > {out} 2>&1",
    )
    print(f"[+] Results saved to {out}")


def run_amass(domain, output_dir):
    """Run Amass subdomain enumeration."""
    if not tool_available("amass"):
        print("[!] Amass not installed. Run: bash scripts/install_amass.sh")
        return
    print(f"[*] Running Amass for: {domain}")
    out = output_dir / f"amass_{domain}.txt"
    run_cmd(f"amass enum -passive -d {domain} -o {out}")
    print(f"[+] Results saved to {out}")


def run_spiderfoot(target, output_dir):
    """Run SpiderFoot CLI scan."""
    sf_dir = TOOLS_DIR / "spiderfoot"
    sf_cli = sf_dir / "sfcli.py"
    if not sf_cli.exists():
        print("[!] SpiderFoot not installed. Run: bash scripts/install_spiderfoot.sh")
        return
    print(f"[*] Running SpiderFoot for: {target}")
    out = output_dir / f"spiderfoot_{target}.json"
    run_cmd(f"python3 {sf_cli} -s {target} -o json > {out} 2>&1", cwd=str(sf_dir))
    print(f"[+] Results saved to {out}")


def run_shodan_lookup(target, output_dir):
    """Run Shodan host lookup."""
    try:
        import shodan
        import yaml
    except ImportError:
        print("[!] shodan/pyyaml not installed. Run: pip install shodan pyyaml")
        return

    config_path = CONFIG_DIR / "api_keys.yaml"
    if not config_path.exists():
        print("[!] No api_keys.yaml found. Copy from api_keys.example.yaml and add your Shodan key.")
        return

    with open(config_path) as f:
        config = yaml.safe_load(f)

    api_key = config.get("shodan", {}).get("api_key", "")
    if not api_key:
        print("[!] Shodan API key not configured in config/api_keys.yaml")
        return

    print(f"[*] Running Shodan lookup for: {target}")
    api = shodan.Shodan(api_key)
    try:
        host = api.host(target)
        out = output_dir / f"shodan_{target}.txt"
        with open(out, "w") as f:
            f.write(f"IP: {host['ip_str']}\n")
            f.write(f"Org: {host.get('org', 'N/A')}\n")
            f.write(f"OS: {host.get('os', 'N/A')}\n")
            f.write(f"Ports: {host.get('ports', [])}\n")
            f.write(f"Hostnames: {host.get('hostnames', [])}\n")
            f.write(f"Vulns: {host.get('vulns', [])}\n\n")
            for item in host.get("data", []):
                f.write(f"Port {item['port']}/{item.get('transport', 'tcp')}:\n")
                f.write(f"  Banner: {item.get('data', '')[:200]}\n\n")
        print(f"[+] Results saved to {out}")
    except shodan.APIError as e:
        print(f"[!] Shodan error: {e}")


def run_wayback(url, output_dir):
    """Fetch Wayback Machine snapshots for a URL."""
    import requests
    print(f"[*] Querying Wayback Machine for: {url}")
    api_url = f"https://web.archive.org/cdx/search/cdx?url={url}&output=text&fl=timestamp,original,statuscode&limit=50"
    try:
        resp = requests.get(api_url, timeout=30)
        out = output_dir / f"wayback_{url.replace('/', '_').replace(':', '')}.txt"
        with open(out, "w") as f:
            f.write(resp.text)
        count = len(resp.text.strip().splitlines())
        print(f"[+] Found {count} snapshots. Saved to {out}")
    except Exception as e:
        print(f"[!] Wayback error: {e}")


# ---------------------------------------------------------------------------
# Workflow Orchestrators
# ---------------------------------------------------------------------------

def workflow_domain(domain):
    """Full domain reconnaissance workflow."""
    print(f"\n{'='*60}")
    print(f"  DOMAIN RECON: {domain}")
    print(f"{'='*60}\n")
    out = ensure_results_dir(f"domain_{domain}")
    run_theharvester(domain, out)
    run_amass(domain, out)
    run_spiderfoot(domain, out)
    run_wayback(domain, out)
    print(f"\n[+] Domain recon complete. Results in {out}")


def workflow_person(username, email=None):
    """People investigation workflow."""
    print(f"\n{'='*60}")
    print(f"  PERSON LOOKUP: {username}")
    print(f"{'='*60}\n")
    out = ensure_results_dir(f"person_{username}")
    run_sherlock(username, out)
    if email:
        run_holehe(email, out)
    print(f"\n[+] Person lookup complete. Results in {out}")


def workflow_infra(ip):
    """Infrastructure scanning workflow."""
    print(f"\n{'='*60}")
    print(f"  INFRA SCAN: {ip}")
    print(f"{'='*60}\n")
    out = ensure_results_dir(f"infra_{ip}")
    run_shodan_lookup(ip, out)
    print(f"\n[+] Infrastructure scan complete. Results in {out}")


def workflow_full():
    """Full investigation from config/targets.yaml."""
    try:
        import yaml
    except ImportError:
        print("[!] PyYAML not installed. Run: pip install pyyaml")
        return

    targets_path = CONFIG_DIR / "targets.yaml"
    if not targets_path.exists():
        print("[!] No targets.yaml found. Copy from targets.example.yaml and configure.")
        return

    with open(targets_path) as f:
        cfg = yaml.safe_load(f)

    case = cfg.get("case", {})
    targets = cfg.get("targets", {})

    case_name = case.get("name", "unnamed")
    print(f"\n{'='*60}")
    print(f"  FULL INVESTIGATION: {case_name}")
    print(f"  Case ID: {case.get('id', 'N/A')}")
    print(f"  Date: {datetime.now().isoformat()}")
    print(f"{'='*60}\n")

    for domain in targets.get("domains", []):
        workflow_domain(domain)

    for username in targets.get("usernames", []):
        emails = targets.get("emails", [])
        email = emails[0] if emails else None
        workflow_person(username, email)

    for ip in targets.get("ips", []):
        workflow_infra(ip)

    print(f"\n{'='*60}")
    print(f"  INVESTIGATION COMPLETE")
    print(f"  Results directory: {RESULTS_DIR}")
    print(f"{'='*60}")


# ---------------------------------------------------------------------------
# Interactive Menu
# ---------------------------------------------------------------------------

def interactive_menu():
    """Interactive CLI menu."""
    banner()

    if HAS_RICH:
        console = Console()
        table = Table(title="Available Operations", box=box.ROUNDED)
        table.add_column("#", style="cyan", width=4)
        table.add_column("Operation", style="bold")
        table.add_column("Description")
        table.add_row("1", "Domain Recon", "theHarvester + Amass + SpiderFoot + Wayback")
        table.add_row("2", "Person Lookup", "Sherlock + Holehe")
        table.add_row("3", "Infra Scan", "Shodan host lookup")
        table.add_row("4", "Full Investigation", "Run all workflows from targets.yaml")
        table.add_row("5", "Sherlock", "Username search only")
        table.add_row("6", "Holehe", "Email lookup only")
        table.add_row("7", "Wayback", "Archive lookup only")
        table.add_row("8", "SpiderFoot Web UI", "Launch SpiderFoot in browser")
        table.add_row("9", "Tool Status", "Check installed tools")
        table.add_row("0", "Exit", "")
        console.print(table)
        choice = Prompt.ask("\nSelect operation", choices=["0","1","2","3","4","5","6","7","8","9"])
    else:
        print("Operations:")
        print("  1) Domain Recon        5) Sherlock")
        print("  2) Person Lookup       6) Holehe")
        print("  3) Infra Scan          7) Wayback")
        print("  4) Full Investigation  8) SpiderFoot Web UI")
        print("  9) Tool Status         0) Exit")
        choice = input("\nSelect [0-9]: ").strip()

    if choice == "1":
        domain = input("Target domain: ").strip()
        if domain:
            workflow_domain(domain)
    elif choice == "2":
        username = input("Target username: ").strip()
        email = input("Target email (optional, press Enter to skip): ").strip() or None
        if username:
            workflow_person(username, email)
    elif choice == "3":
        ip = input("Target IP: ").strip()
        if ip:
            workflow_infra(ip)
    elif choice == "4":
        workflow_full()
    elif choice == "5":
        username = input("Username: ").strip()
        if username:
            out = ensure_results_dir("sherlock")
            run_sherlock(username, out)
    elif choice == "6":
        email = input("Email: ").strip()
        if email:
            out = ensure_results_dir("holehe")
            run_holehe(email, out)
    elif choice == "7":
        url = input("URL: ").strip()
        if url:
            out = ensure_results_dir("wayback")
            run_wayback(url, out)
    elif choice == "8":
        sf_dir = TOOLS_DIR / "spiderfoot"
        if (sf_dir / "sf.py").exists():
            print("[*] Launching SpiderFoot Web UI on http://127.0.0.1:5001")
            run_cmd(f"python3 {sf_dir / 'sf.py'} -l 127.0.0.1:5001")
        else:
            print("[!] SpiderFoot not installed.")
    elif choice == "9":
        check_tools()
    elif choice == "0":
        print("Bye.")
        sys.exit(0)


def check_tools():
    """Check which tools are installed."""
    tools = {
        "Sherlock": tool_available("sherlock"),
        "Holehe": tool_available("holehe"),
        "Amass": tool_available("amass"),
        "Shodan CLI": tool_available("shodan"),
        "Censys CLI": tool_available("censys"),
        "SpiderFoot": (TOOLS_DIR / "spiderfoot" / "sf.py").exists(),
        "Recon-ng": (TOOLS_DIR / "recon-ng" / "recon-ng").exists(),
        "theHarvester": (TOOLS_DIR / "theHarvester" / "theHarvester.py").exists(),
    }

    if HAS_RICH:
        console = Console()
        table = Table(title="Tool Status", box=box.ROUNDED)
        table.add_column("Tool", style="bold")
        table.add_column("Status")
        for name, installed in tools.items():
            status = "[green]Installed[/green]" if installed else "[red]Not Found[/red]"
            table.add_row(name, status)
        console.print(table)
    else:
        print("\nTool Status:")
        for name, installed in tools.items():
            status = "INSTALLED" if installed else "NOT FOUND"
            print(f"  {name:20s} {status}")
    print()


# ---------------------------------------------------------------------------
# CLI Entry Point
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="OSINT Toolkit — Complete Investigation Stack",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python3 osint.py                           # Interactive menu
  python3 osint.py --domain example.com      # Domain recon
  python3 osint.py --username johndoe        # Person lookup
  python3 osint.py --ip 8.8.8.8             # Infrastructure scan
  python3 osint.py --full                    # Full investigation
  python3 osint.py --status                  # Check installed tools
        """,
    )
    parser.add_argument("--domain", "-d", help="Run domain recon workflow")
    parser.add_argument("--username", "-u", help="Run person lookup workflow")
    parser.add_argument("--email", "-e", help="Email for person lookup (used with --username)")
    parser.add_argument("--ip", "-i", help="Run infrastructure scan workflow")
    parser.add_argument("--full", "-f", action="store_true", help="Run full investigation from targets.yaml")
    parser.add_argument("--status", "-s", action="store_true", help="Check installed tools")
    parser.add_argument("--wayback", "-w", help="Wayback Machine lookup for a URL")
    parser.add_argument("--sherlock", help="Sherlock username search")
    parser.add_argument("--holehe", help="Holehe email lookup")

    args = parser.parse_args()

    # If no args, launch interactive menu
    if len(sys.argv) == 1:
        while True:
            interactive_menu()
            print()
        return

    banner()

    if args.status:
        check_tools()
    if args.domain:
        workflow_domain(args.domain)
    if args.username:
        workflow_person(args.username, args.email)
    if args.ip:
        workflow_infra(args.ip)
    if args.full:
        workflow_full()
    if args.wayback:
        out = ensure_results_dir("wayback")
        run_wayback(args.wayback, out)
    if args.sherlock:
        out = ensure_results_dir("sherlock")
        run_sherlock(args.sherlock, out)
    if args.holehe:
        out = ensure_results_dir("holehe")
        run_holehe(args.holehe, out)


if __name__ == "__main__":
    main()
