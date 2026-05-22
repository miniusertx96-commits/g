# Investigation Workflow Guide

## The Case-Building Methodology

This is how professional investigators work — not by opening one tool, but by following a structured pipeline.

```
1. Define Target & Scope
        |
        v
2. SpiderFoot Automation (first-pass recon)
        |
        v
3. Maltego Graphing (link analysis)
        |
        v
4. Shodan / Censys (infrastructure pivots)
        |
        v
5. Sherlock / Holehe (people pivots)
        |
        v
6. Wayback + Metadata Analysis
        |
        v
7. Archive Evidence
        |
        v
8. AI Summarization / Reporting
```

---

## Phase 1 — Define Target & Scope

Before touching any tool:

- **What do you know?** List every piece of starting data (domain, email, username, IP, phone, company name)
- **What do you need to find?** Define your investigation goals
- **What are the boundaries?** Legal/ethical scope, jurisdictions, data handling requirements

Create a case file using `templates/case_template.md`.

---

## Phase 2 — Automated First-Pass (SpiderFoot)

Run SpiderFoot with all known seeds to surface the broadest picture:

```bash
bash workflows/domain_recon.sh example.com
# or
bash workflows/person_lookup.sh johndoe
```

SpiderFoot queries 200+ sources. Let it run — this is your broadest net.

**What to look for:**
- Unexpected domains/subdomains
- Leaked credentials or breach mentions
- Social media profiles
- Related infrastructure (shared IPs, ASNs)
- Historical DNS records

---

## Phase 3 — Link Analysis (Maltego)

Import SpiderFoot results into Maltego and visualize relationships:

1. Create a new Maltego graph
2. Add seed entities (domains, emails, IPs from Phase 2)
3. Run transforms to expand the graph
4. Look for **clusters** — groups of connected entities suggest organizational structure
5. Look for **bridges** — single entities connecting two otherwise separate clusters are high-value pivot points

**Key pivot patterns:**

| From          | Pivot to              | Using                     |
| ------------- | --------------------- | ------------------------- |
| Domain        | IPs, subdomains       | DNS transforms            |
| Email         | Breaches, social accts| HIBP, Holehe              |
| IP            | Other domains, ASN    | Reverse DNS, BGP          |
| Username      | Social profiles       | Sherlock transforms       |
| Company       | People, domains       | WHOIS, LinkedIn           |
| Phone         | Social accounts       | Holehe, social transforms |

---

## Phase 4 — Infrastructure Pivots (Shodan / Censys)

For every IP and domain discovered:

```bash
bash workflows/infra_scan.sh <target_ip>
```

**What to look for:**
- Open ports and services (especially non-standard ports)
- Software versions (outdated = interesting)
- SSL/TLS certificate details (organization names, SANs, issue dates)
- Shared hosting (what else is on this IP?)
- Historical changes (when did services appear/disappear?)

---

## Phase 5 — People Pivots (Sherlock / Holehe)

For every username and email discovered:

```bash
# Username across social networks
sherlock <username>

# Email to registered services
holehe <email>
```

**What to look for:**
- Profile consistency (same username = likely same person)
- Bio text, profile pictures (reverse image search)
- Activity patterns (timezone, posting schedule)
- Connections/followers (social graph expansion)

---

## Phase 6 — Historical & Metadata Analysis

### Wayback Machine

Check historical snapshots of discovered websites:

```
https://web.archive.org/web/*/<target_domain>
```

**What to look for:**
- Old contact pages (removed email addresses, phone numbers)
- Technology changes (old software versions)
- Content changes (removed pages, edited text)
- Old sitemap.xml and robots.txt entries

### Metadata Extraction

Download public documents (PDFs, DOCXs) from target domains and extract metadata:

```bash
exiftool document.pdf
# Look for: Author, Creator, Producer, GPS data, timestamps
```

---

## Phase 7 — Archive Evidence

**Before you report, archive everything.**

- Save webpage snapshots (Hunchly, Archive.today, local MHTML)
- Screenshot key findings with timestamps
- Export Maltego graphs
- Export SpiderFoot scan results
- Save raw API responses

Evidence disappears. Archive first, analyze second.

---

## Phase 8 — AI Summarization & Reporting

Use AI to synthesize findings:

1. Feed structured data into OpenAI / NotebookLM
2. Generate an executive summary
3. Create a timeline of events
4. Highlight key findings and relationships
5. Identify gaps requiring further investigation

Use `templates/report_template.md` for the final report.

---

## Common Investigation Patterns

### Domain Investigation

```
domain → WHOIS → registrant email → other domains
domain → DNS records → IPs → reverse DNS → related domains
domain → subdomains → exposed services → version info
domain → web content → linked resources → third-party services
domain → SSL cert → organization → other certs
```

### Person Investigation

```
name → social profiles → usernames → more profiles
email → breaches → passwords → password patterns → more accounts
username → social profiles → bio/about → real name / location
profile photo → reverse image search → other profiles
phone → social accounts → messaging apps → contacts
```

### Infrastructure Investigation

```
IP → open ports → service banners → software versions
IP → reverse DNS → hostname → related domains
IP → ASN → CIDR block → other hosts in range
IP → SSL cert → SANs → related domains
IP → Shodan history → changes over time
```

---

## Key Principles

1. **Cast a wide net first, then narrow.** SpiderFoot automation before targeted manual work.
2. **Pivot constantly.** Every piece of data is a potential pivot to new data.
3. **Archive before it disappears.** Screenshots, snapshots, exports.
4. **Verify everything.** Cross-reference findings across multiple sources.
5. **Document your methodology.** Reproducibility matters.
6. **Know your limits.** Legal boundaries, ethical considerations, scope.
