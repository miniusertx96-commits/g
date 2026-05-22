# OSINT Setup by Skill Level

## Beginner

Start here. These tools are free, easy to install, and cover the basics.

| Tool               | What it does                     | Install                         |
| ------------------ | -------------------------------- | ------------------------------- |
| SpiderFoot         | Automated recon (200+ sources)   | `bash scripts/install_spiderfoot.sh` |
| Sherlock           | Username search (400+ sites)     | `pip install sherlock-project`  |
| Wayback Machine    | Archived web pages               | https://web.archive.org/        |
| Shodan (free)      | Internet device search           | https://www.shodan.io/          |

### Beginner Workflow

```
1. Got a domain? → SpiderFoot scan
2. Got a username? → Sherlock search
3. Got a URL? → Wayback Machine lookup
4. Got an IP? → Shodan lookup
```

### Time to learn: 1–2 hours

---

## Intermediate

You understand the basics. Now add structure, correlation, and more data sources.

| Tool               | What it does                     | Install                         |
| ------------------ | -------------------------------- | ------------------------------- |
| Maltego CE         | Link analysis & graphing         | https://www.maltego.com/        |
| Recon-ng           | Modular OSINT framework          | `bash scripts/install_recon_ng.sh` |
| Amass              | Subdomain enumeration            | `bash scripts/install_amass.sh` |
| Censys             | Certificate & service search     | https://search.censys.io/       |
| HIBP               | Breach checking                  | https://haveibeenpwned.com/     |
| Holehe             | Email → registered accounts      | `pip install holehe`            |
| theHarvester       | Email & subdomain harvesting     | `bash scripts/install_theharvester.sh` |

### Intermediate Workflow

```
1. Start with SpiderFoot automation
2. Import results into Maltego for graphing
3. Use Recon-ng for repeatable/scripted lookups
4. Add Amass for deep subdomain enumeration
5. Cross-reference with Censys and HIBP
6. Use Holehe for email pivot investigation
```

### Time to proficiency: 2–4 weeks

---

## Advanced

Self-hosted infrastructure, custom pipelines, AI integration.

| Component                  | Purpose                          |
| -------------------------- | -------------------------------- |
| Self-hosted SpiderFoot     | Full control, no rate limits     |
| Elasticsearch + Kibana     | Index and visualize OSINT data   |
| Custom Maltego transforms  | Proprietary data source access   |
| AI reporting pipeline      | Automated summarization          |
| Dockerized recon stack     | Reproducible, portable setup     |
| Hunchly                    | Evidence preservation            |

### Advanced Architecture

```
                    ┌─────────────────────┐
                    │   Case Management   │
                    │   (Maltego / CaseFile)│
                    └──────────┬──────────┘
                               │
              ┌────────────────┼────────────────┐
              │                │                │
     ┌────────▼─────┐  ┌──────▼──────┐  ┌──────▼──────┐
     │  SpiderFoot  │  │  Recon-ng   │  │  Custom     │
     │  (automated) │  │  (scripted) │  │  Scripts    │
     └──────┬───────┘  └──────┬──────┘  └──────┬──────┘
            │                 │                │
            └────────┬────────┘                │
                     │                         │
            ┌────────▼─────────────────────────▼──┐
            │         Elasticsearch               │
            │         (data indexing)              │
            └────────────────┬────────────────────┘
                             │
                    ┌────────▼────────┐
                    │     Kibana      │
                    │  (dashboards)   │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │   AI Pipeline   │
                    │  (OpenAI, etc.) │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │     Reports     │
                    └─────────────────┘
```

### Dockerized Stack

Use the included `docker-compose.yml` to spin up:

```bash
docker-compose up -d
```

This starts:
- SpiderFoot (port 5001)
- Elasticsearch (port 9200)
- Kibana (port 5601)

### Time to mastery: Ongoing
