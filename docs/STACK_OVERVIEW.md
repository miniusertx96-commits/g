# OSINT Stack — Deep Dive

## The Seven Layers

A serious OSINT setup is not one tool — it is a **layered stack**:

1. **Case Management** — Track targets, findings, evidence chains
2. **Automation** — Bulk recon across hundreds of sources
3. **Entity Correlation** — Graph relationships between data points
4. **Infrastructure Recon** — Map exposed services, certs, subdomains
5. **People Lookup** — Usernames, emails, phone numbers, social graphs
6. **Archiving** — Preserve evidence before it disappears
7. **AI-Assisted Analysis** — Summarize, correlate, generate reports

The strongest investigators combine **5–10 tools** instead of relying on one platform.

---

## 1. Maltego — Link Analysis & Investigations

**Category:** Entity Correlation / Case Management  
**License:** Community (free) / Pro / Enterprise  
**URL:** https://www.maltego.com/

Maltego is the king of OSINT investigations. It visualizes relationships as **graphs**:

- **Entities:** emails, domains, usernames, IPs, companies, social accounts, breach data
- **Transforms:** automated lookups that pivot from one entity to related ones
- **Hub:** marketplace of transform providers (Shodan, Censys, HIBP, IntelX, VirusTotal)

### Why it matters

Raw data is useless without context. Maltego turns a single email address into a web of connections — domain registrations, social profiles, company associations, IP addresses, breach appearances.

### Recommended transforms to install

| Provider         | What it adds                              |
| ---------------- | ----------------------------------------- |
| Shodan           | Open ports, services, banners, vulns      |
| Censys           | TLS certs, hosts, services                |
| Have I Been Pwned| Breach history for emails                 |
| IntelX           | Dark web mentions, pastes, leaks          |
| VirusTotal       | Malware associations, domain reputation   |
| SecurityTrails   | Historical DNS, WHOIS, subdomains         |

---

## 2. SpiderFoot — Automated Recon

**Category:** Automation  
**License:** Open Source (MIT)  
**URL:** https://github.com/smicallef/spiderfoot

SpiderFoot scans from **200+ data sources** automatically. You provide a seed (domain, email, username, IP, phone number) and it builds a full picture:

| Output               | Sources                              |
| -------------------- | ------------------------------------ |
| DNS history          | PassiveDNS, SecurityTrails           |
| WHOIS                | WHOIS servers, DomainTools           |
| Exposed services     | Shodan, Censys, ZoomEye              |
| Social links         | Username enumeration, social APIs    |
| Breaches             | HIBP, IntelX, DeHashed               |
| Metadata             | File analysis, EXIF, metatag parsing |
| Infrastructure       | ASN, BGP, subnet mapping             |

### Running SpiderFoot

```bash
# Web UI (recommended for interactive use)
cd tools/spiderfoot
python3 sf.py -l 127.0.0.1:5001

# CLI (for scripting / automation)
python3 sfcli.py -s <target> -t <scan_type>
```

### Best use

**First-pass recon** before deep investigation. Run SpiderFoot first to surface leads, then pivot into Maltego for link analysis.

---

## 3. Recon-ng — Terminal-Heavy Workflows

**Category:** Automation / Scripting  
**License:** Open Source (GPL)  
**URL:** https://github.com/lanmaster53/recon-ng

Think **Metasploit for OSINT**. Modular framework for:

- Repeatable investigations
- API-driven automation
- Structured data export (CSV, JSON, HTML, XML)
- Workspace-based case management

### Key concepts

- **Workspaces:** Isolate different investigations
- **Modules:** Individual recon tasks (subdomain enum, contact harvesting, etc.)
- **Keys:** API key management for data sources
- **Reporting:** Built-in report generators

```bash
# Start Recon-ng
cd tools/recon-ng
python3 recon-ng

# Inside recon-ng:
workspaces create mycase
marketplace install all
modules load recon/domains-hosts/hackertarget
options set SOURCE example.com
run
```

---

## 4. Shodan — Internet Infrastructure

**Category:** Infrastructure Recon  
**License:** Free tier / Membership / Enterprise  
**URL:** https://www.shodan.io/

Shodan indexes the entire internet. Every device with a public IP gets cataloged:

- Webcams, routers, servers, databases
- ICS/SCADA systems, exposed admin panels
- Software versions, open ports, vulnerabilities, banners

### Search syntax

```
# Apache servers in the UK
apache country:"GB"

# MongoDB databases with no auth
"MongoDB Server Information" port:27017

# Exposed Elasticsearch
port:9200 "cluster_name"

# Webcams
"Server: webcamXP"

# Industrial control systems
port:502 "Modbus"
```

### API usage

```python
import shodan
api = shodan.Shodan('YOUR_API_KEY')

# Search
results = api.search('apache country:"GB"')
for result in results['matches']:
    print(f"{result['ip_str']}:{result['port']} — {result.get('org', 'N/A')}")

# Host lookup
host = api.host('8.8.8.8')
print(host['ports'])  # Open ports
```

---

## 5. People Lookup Tools

### Sherlock — Username Search

Searches **400+ social networks** for a username.

```bash
sherlock johndoe
```

### Holehe — Email Account Lookup

Checks which services an email is registered on.

```bash
holehe user@example.com
```

### IntelX — Deep/Dark Web Intel

Intelligence X provides access to:
- Darknet data, paste sites
- Breach data, leaked databases
- Historical data preservation

### FOCA — Metadata Extraction

Extracts metadata from public documents (PDF, DOCX, XLSX):
- Author names, software versions
- Email addresses, usernames
- Network paths, printer names

---

## 6. Infrastructure Recon Stack

### Censys — Certificate & Service Discovery

```bash
# Search for services
censys search "services.http.response.body: 'login'"

# Lookup a host
censys view 8.8.8.8
```

### Amass — Subdomain Enumeration

```bash
amass enum -d example.com -o subdomains.txt
```

### theHarvester — Email & Subdomain Collection

```bash
theHarvester -d example.com -b all
```

### BuiltWith — Technology Stack Identification

Web-based tool: https://builtwith.com/  
Identifies frameworks, analytics, CDNs, hosting, CMS, and more.

---

## 7. Archiving & Evidence

### Wayback Machine

- URL: https://web.archive.org/
- API: `https://web.archive.org/web/timemap/link/<url>`
- Preserves historical snapshots of any webpage

### Hunchly

- URL: https://hunchly.com/
- Browser extension for investigators
- Automatically captures and timestamps every page visited during an investigation
- Creates tamper-evident evidence chains

### Archive.today

- URL: https://archive.ph/
- On-demand webpage archiving
- Useful when Wayback Machine doesn't have a snapshot
