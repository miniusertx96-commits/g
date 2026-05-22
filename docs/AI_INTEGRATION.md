# AI-Assisted OSINT Analysis

## Overview

AI tools accelerate OSINT workflows at three stages:

1. **Research** — Fast information gathering and hypothesis generation
2. **Analysis** — Pattern recognition across large datasets
3. **Reporting** — Structured summaries and executive reports

---

## Recommended AI Tools

| Tool         | Best For                         | URL                              |
| ------------ | -------------------------------- | -------------------------------- |
| OpenAI       | Report generation, data parsing  | https://platform.openai.com/     |
| NotebookLM   | Evidence summarization           | https://notebooklm.google.com/   |
| Perplexity   | Fast research with citations     | https://www.perplexity.ai/       |
| Obsidian     | Knowledge graph / note linking   | https://obsidian.md/             |
| Hunchly      | Evidence capture & timelines     | https://hunchly.com/             |

---

## OpenAI Integration

### Report Generation

Feed investigation data to OpenAI for structured report generation:

```python
import openai
import yaml
import json

def load_api_key():
    with open("config/api_keys.yaml") as f:
        config = yaml.safe_load(f)
    return config["openai"]["api_key"]

def generate_report(findings: dict) -> str:
    client = openai.OpenAI(api_key=load_api_key())

    prompt = f"""You are an OSINT analyst. Based on the following investigation
findings, generate a structured intelligence report.

Findings:
{json.dumps(findings, indent=2)}

Include:
1. Executive Summary
2. Key Findings
3. Entity Relationships
4. Infrastructure Analysis
5. Timeline of Events
6. Recommendations for Further Investigation
7. Confidence Levels for Each Finding
"""

    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.3,
    )
    return response.choices[0].message.content
```

### Data Parsing

Use AI to extract structured data from unstructured text:

```python
def extract_entities(raw_text: str) -> dict:
    client = openai.OpenAI(api_key=load_api_key())

    prompt = f"""Extract all OSINT-relevant entities from this text.
Return JSON with these categories:
- emails, domains, ips, usernames, phone_numbers,
  companies, people, locations, technologies

Text:
{raw_text}
"""

    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": prompt}],
        response_format={"type": "json_object"},
        temperature=0,
    )
    return json.loads(response.choices[0].message.content)
```

---

## NotebookLM Workflow

Google's NotebookLM is excellent for evidence summarization:

1. Upload investigation documents (PDFs, text files, web pages)
2. Ask questions across all sources simultaneously
3. Generate summaries with source citations
4. Create audio overviews for team briefings

**Best for:** Large-volume evidence review where you need to find patterns across many documents.

---

## Obsidian as a Knowledge Graph

Obsidian turns your investigation notes into a linked knowledge graph:

### Setup

1. Create a vault for each investigation
2. Use a consistent note template:

```markdown
# Entity: {{name}}

**Type:** domain | email | person | ip | company
**First seen:** {{date}}
**Source:** {{source}}

## Raw Data
- ...

## Connections
- [[Related Entity 1]]
- [[Related Entity 2]]

## Notes
- ...
```

3. Use the Graph View to visualize relationships
4. Install plugins:
   - **Dataview** — Query your notes like a database
   - **Templater** — Consistent note templates
   - **Excalidraw** — Visual diagrams

### Why Obsidian over other tools

- Works offline (important for sensitive investigations)
- Markdown-based (future-proof, portable)
- Free for personal use
- The graph view surfaces connections you might miss

---

## Hunchly — Evidence Preservation

Hunchly is a Chrome extension built for investigators:

- **Auto-captures** every page you visit during an investigation
- **Timestamps** everything with tamper-evident hashing
- **Tags and notes** for organization
- **Case exports** for reporting and legal proceedings
- **Selectors** to highlight and annotate specific content

### Workflow

1. Start a Hunchly case before beginning your investigation
2. Browse normally — Hunchly captures everything
3. Tag pages with case-relevant labels
4. Add notes to specific captures
5. Export the case when complete

**Why it matters:** Web pages disappear. Screenshots can be edited. Hunchly creates a verifiable evidence chain.

---

## Perplexity for Fast Research

Use Perplexity when you need quick, citation-backed answers:

- Company background checks
- Technology identification
- Historical context
- News article discovery
- Regulatory/legal research

**Advantage over ChatGPT:** Perplexity cites its sources, making it easier to verify claims.

---

## Building an AI Reporting Pipeline

For advanced users, combine tools into an automated pipeline:

```
SpiderFoot scan results
        |
        v
Parse & structure (Python)
        |
        v
Entity extraction (OpenAI)
        |
        v
Store in Elasticsearch
        |
        v
Visualize in Kibana
        |
        v
Generate report (OpenAI)
        |
        v
Review & edit (analyst)
        |
        v
Final report (Markdown/PDF)
```

The `osint.py` CLI supports this workflow with the `--report` flag:

```bash
python3 osint.py --target example.com --full --report
```
