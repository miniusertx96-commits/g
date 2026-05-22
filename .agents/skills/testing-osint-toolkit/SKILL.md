---
name: testing-osint-toolkit
description: Test the OSINT Toolkit GUI installer (setup.py) and CLI launcher (osint.py). Use when verifying UI rendering, tool installation, or CLI functionality.
---

# Testing the OSINT Toolkit

## Prerequisites
- Python 3 with tkinter (`sudo apt-get install -y python3-tk` on Linux)
- X display available (DISPLAY=:0) for GUI testing
- `wmctrl` for window management (`sudo apt-get install -y wmctrl`)

## GUI Installer (setup.py)

### Launch
```bash
cd <repo-root>
DISPLAY=:0 /usr/bin/python3 setup.py
```

### Platform Note: Scroll Binding
The `<MouseWheel>` event in setup.py is Windows-specific. On Linux/X11, canvas scrolling may not work because Linux uses `<Button-4>` / `<Button-5>` for scroll events. To work around this for testing, create a wrapper script that monkey-patches the Canvas to bind Linux scroll events before launching setup.py:

```python
import tkinter as tk
_orig = tk.Canvas.__init__
def _patched(self, *a, **kw):
    _orig(self, *a, **kw)
    self.bind_all("<Button-4>", lambda e: self.yview_scroll(-3, "units"))
    self.bind_all("<Button-5>", lambda e: self.yview_scroll(3, "units"))
tk.Canvas.__init__ = _patched
```

### Key Test Points
1. **Window title**: "OSINT Toolkit — Installer"
2. **Categories**: People Lookup, Automation, Infrastructure, Core
3. **Tools**: 10 tools total (Sherlock, Holehe, SpiderFoot, Recon-ng, theHarvester, Shodan CLI, Censys CLI, Rich, PyYAML, Requests)
4. **Checkboxes**: All checked by default
5. **Select All / Deselect All**: Links below tool list
6. **Install button**: Scroll down to find it. Triggers threaded install with progress bar, timestamped log, and green status labels on completion
7. **Button state**: Disabled (gray) during install, changes to "Installation Complete" (green) when done

### Quick Install Test
Select only "Rich" and "Requests" (fast pip installs) to verify the install workflow without waiting for large tools.

## CLI Launcher (osint.py)

### Commands
```bash
python osint.py --status   # Shows 8-tool status table
python osint.py --help     # Shows all flags and examples
python osint.py            # Interactive menu (requires terminal input)
```

### Expected --status Output
- ASCII OSINT banner
- "Complete OSINT Investigation Stack" subtitle
- Table with 8 tools: Sherlock, Holehe, Amass, Shodan CLI, Censys CLI, SpiderFoot, Recon-ng, theHarvester
- Each shows "Installed" or "Not Found"

### Expected --help Flags
--domain, --username, --email, --ip, --full, --status, --wayback, --sherlock, --holehe

## Devin Secrets Needed
None for basic testing. API keys (Shodan, Censys, etc.) needed only for live tool execution tests.
