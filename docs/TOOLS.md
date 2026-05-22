# Tool Reference & API Key Guide

## Quick Reference

| Tool           | Category          | Install               | API Key Required | Free Tier |
| -------------- | ----------------- | --------------------- | ---------------- | --------- |
| Sherlock       | People Lookup     | `pip install sherlock-project` | No       | Yes       |
| Holehe         | People Lookup     | `pip install holehe`  | No               | Yes       |
| SpiderFoot     | Automation        | Git clone + pip       | Optional         | Yes       |
| Recon-ng       | Automation        | Git clone + pip       | Per module       | Yes       |
| theHarvester   | Infra Recon       | Git clone + pip       | Optional         | Yes       |
| Amass          | Infra Recon       | Go install / binary   | Optional         | Yes       |
| Shodan         | Infra Recon       | `pip install shodan`  | Yes              | Limited   |
| Censys         | Infra Recon       | `pip install censys`  | Yes              | Limited   |
| Maltego        | Link Analysis     | Desktop app           | Yes (CE free)    | CE free   |
| FOCA           | Metadata          | Windows app           | No               | Yes       |
| Hunchly        | Archiving         | Browser extension     | Yes (paid)       | No        |
| BuiltWith      | Infra Recon       | Web-based             | Optional         | Limited   |

---

## API Key Sources

### Shodan

- **URL:** https://account.shodan.io/
- **Free tier:** 100 results/search, 1 scan credit/month
- **Membership ($49/lifetime):** Unlimited searches, scan credits, filters
- **Config key:** `shodan.api_key`

### Censys

- **URL:** https://search.censys.io/account/api
- **Free tier:** 250 queries/month
- **Config keys:** `censys.api_id`, `censys.api_secret`

### VirusTotal

- **URL:** https://www.virustotal.com/gui/my-apikey
- **Free tier:** 500 lookups/day, 4 req/min
- **Config key:** `virustotal.api_key`

### Have I Been Pwned

- **URL:** https://haveibeenpwned.com/API/Key
- **Pricing:** $3.50/month
- **Config key:** `haveibeenpwned.api_key`

### Intelligence X (IntelX)

- **URL:** https://intelx.io/account?tab=developer
- **Free tier:** 10 searches/day
- **Config key:** `intelx.api_key`

### OpenAI

- **URL:** https://platform.openai.com/api-keys
- **Pricing:** Pay-per-use
- **Config key:** `openai.api_key`

### SecurityTrails

- **URL:** https://securitytrails.com/app/account
- **Free tier:** 50 queries/month
- **Config key:** `securitytrails.api_key`

### IPinfo

- **URL:** https://ipinfo.io/account/token
- **Free tier:** 50,000 req/month
- **Config key:** `ipinfo.token`

---

## Tool Details

### Sherlock

**Purpose:** Search 400+ social networks for a username.

```bash
# Basic search
sherlock johndoe

# Multiple usernames
sherlock johndoe janedoe

# Output to file
sherlock johndoe --output results.txt

# Only show found accounts
sherlock johndoe --print-found
```

### Holehe

**Purpose:** Check which online services an email is registered on.

```bash
# Basic lookup
holehe user@example.com

# CSV output
holehe user@example.com --csv
```

### SpiderFoot

**Purpose:** Automated OSINT scanning from 200+ sources.

```bash
# Web UI
cd tools/spiderfoot && python3 sf.py -l 127.0.0.1:5001

# CLI scan
python3 sfcli.py -s example.com -t all

# Specific scan types
python3 sfcli.py -s example.com -t DOMAIN_WHOIS,DNS_RESOLVE,SUBDOMAIN
```

### Recon-ng

**Purpose:** Modular OSINT framework (Metasploit-style).

```bash
cd tools/recon-ng && python3 recon-ng

# Inside the framework:
workspaces create mycase
marketplace search
marketplace install recon/domains-hosts/hackertarget
modules load recon/domains-hosts/hackertarget
options set SOURCE example.com
run
show hosts
```

### theHarvester

**Purpose:** Email addresses, subdomains, IPs from public sources.

```bash
cd tools/theHarvester

# All sources
python3 theHarvester.py -d example.com -b all

# Specific sources
python3 theHarvester.py -d example.com -b google,bing,dnsdumpster

# Limit results
python3 theHarvester.py -d example.com -b all -l 200
```

### Amass

**Purpose:** Subdomain enumeration and network mapping.

```bash
# Passive enum (no direct contact with target)
amass enum -passive -d example.com -o subs.txt

# Active enum (includes DNS brute-force)
amass enum -d example.com -o subs.txt

# Intel mode (discover root domains for an org)
amass intel -org "Company Name"
```

### Shodan (CLI)

```bash
# Search
shodan search "apache country:GB"

# Host info
shodan host 8.8.8.8

# Scan a network (requires credits)
shodan scan submit 192.168.1.0/24

# Download results
shodan download results.json.gz "apache country:GB"
```

### Censys (CLI)

```bash
# Search hosts
censys search "services.http.response.body: login"

# View host details
censys view 8.8.8.8

# Search certificates
censys search --index certs "parsed.subject.common_name: example.com"
```
