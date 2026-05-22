# OSINT Toolkit

A layered, modular OSINT investigation stack covering case management, automation, entity correlation, infrastructure recon, people lookup, archiving, and AI-assisted analysis.

> The best OSINT investigators rely less on "magic tools" and more on **correlation, hypothesis building, behavioral analysis, and pivots between datasets.** Tools matter less than workflow and thinking.

---

## Quick Start

```bash
# Clone and install
git clone https://github.com/YOUR_USER/osint-toolkit.git
cd osint-toolkit
chmod +x setup.sh
./setup.sh

# Launch the CLI
python3 osint.py
```

Or use Docker:

```bash
docker-compose up -d
```

---

## Architecture

```
Target
  |
  v
SpiderFoot automation        (first-pass recon)
  |
  v
Maltego graphing              (link analysis / entity correlation)
  |
  v
Shodan / Censys               (infrastructure pivots)
  |
  v
Sherlock / Holehe             (people pivots)
  |
  v
Wayback + metadata analysis   (archiving / historical)
  |
  v
Archive evidence              (Hunchly / local archiver)
  |
  v
AI summarization / reporting  (OpenAI / NotebookLM / Obsidian)
```

---

## Stack Overview

### Layer 1 — Link Analysis & Investigations: Maltego

The king of OSINT investigations. Turns raw data into relationship graphs across:

- Emails, domains, usernames, IPs
- Companies, social accounts, breach data

Uses **transforms** to pivot between datasets automatically. Investigators and threat intel teams use it heavily.

**Recommended transforms:**

| Transform Source | Purpose                  |
| ---------------- | ------------------------ |
| Shodan           | Exposed services         |
| Censys           | Cert + internet scans    |
| Have I Been Pwned| Breach lookup            |
| IntelX           | Deep/dark web data       |
| VirusTotal       | Malware / file analysis  |

### Layer 2 — Automated Recon: SpiderFoot

Automatically scans domains, usernames, IPs, emails, phone numbers, infrastructure, and leaks from **200+ sources**.

Enter a domain, email, username, or IP and it builds:

- DNS history, WHOIS, exposed services
- Social links, breaches, metadata
- Associated infrastructure

**Best use:** First-pass recon before deep investigation.

### Layer 3 — Terminal Workflows: Recon-ng

Think **Metasploit for OSINT**. Strong for:

- Repeatable investigations
- API automation & scripting
- Exporting findings

Popular with red teamers and advanced analysts.

### Layer 4 — Infrastructure: Shodan

Indexes webcams, routers, servers, databases, ICS systems, and exposed panels. Search by:

- Software versions, open ports, countries
- Vulnerabilities, banners

```
# Example: Find exposed Apache servers in the UK
apache country:"GB"
```

Massive for attack surface mapping, threat intel, exposed databases, and ransomware research.

---

## People Lookup Tools

| Purpose              | Tool           |
| -------------------- | -------------- |
| Username search      | Sherlock       |
| Email enumeration    | Holehe         |
| Phone/email intel    | IntelX         |
| Social graphing      | Social Links   |
| Metadata extraction  | FOCA           |
| Archived websites    | Wayback Machine|

## Infrastructure Recon Stack

| Tool          | Use                    |
| ------------- | ---------------------- |
| Shodan        | Exposed services       |
| Censys        | Cert + internet scans  |
| Amass         | Subdomain mapping      |
| theHarvester  | Emails / subdomains    |
| BuiltWith     | Tech stack intel       |

## AI Integration

| AI Tool      | Purpose                |
| ------------ | ---------------------- |
| OpenAI       | Report generation      |
| NotebookLM   | Evidence summarization |
| Perplexity   | Fast research          |
| Obsidian     | Knowledge graph        |
| Hunchly      | Evidence capture       |

---

## Skill Levels

### Beginner

- SpiderFoot, Sherlock, Wayback Machine, Shodan (free tier)

### Intermediate

- Maltego, Recon-ng, Amass, Censys, HIBP

### Advanced

- Self-hosted SpiderFoot
- Elasticsearch + Kibana
- Custom Maltego transforms
- AI reporting pipeline
- Dockerized recon stack (see `docker-compose.yml`)

---

## Project Structure

```
osint-toolkit/
  README.md                    # This file
  setup.sh                     # One-command installer
  osint.py                     # Main CLI launcher
  requirements.txt             # Python dependencies
  Dockerfile                   # Containerized stack
  docker-compose.yml           # Multi-service orchestration
  config/
    api_keys.example.yaml      # API key template
    targets.example.yaml       # Target config template
  scripts/
    install_tools.sh           # Bulk tool installer
    install_spiderfoot.sh      # SpiderFoot setup
    install_sherlock.sh        # Sherlock setup
    install_recon_ng.sh        # Recon-ng setup
    install_theharvester.sh    # theHarvester setup
    install_amass.sh           # Amass setup
    install_holehe.sh          # Holehe setup
  docs/
    STACK_OVERVIEW.md          # Full OSINT stack deep-dive
    WORKFLOW.md                # Investigation workflow guide
    TOOLS.md                   # Detailed tool reference
    SKILL_LEVELS.md            # Setup guides by experience
    AI_INTEGRATION.md          # AI tools integration
  workflows/
    domain_recon.sh            # Domain recon pipeline
    person_lookup.sh           # People investigation
    infra_scan.sh              # Infrastructure scanning
    full_investigation.sh      # End-to-end investigation
  templates/
    report_template.md         # Investigation report
    case_template.md           # Case file template
```

---

## Configuration

Copy the example configs and add your API keys:

```bash
cp config/api_keys.example.yaml config/api_keys.yaml
# Edit config/api_keys.yaml with your keys
```

See `docs/TOOLS.md` for where to get API keys for each service.

---

## License

MIT
