"""
OSINT Toolkit — GUI Installer
A polished graphical installer for all OSINT investigation tools.
Targets Windows. Uses tkinter (ships with Python on Windows).

Run:  python setup.py
"""

import os
import sys
import subprocess
import threading
import shutil
from pathlib import Path
from datetime import datetime

import tkinter as tk
from tkinter import ttk, messagebox, font as tkfont

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
ROOT = Path(__file__).resolve().parent
TOOLS_DIR = ROOT / "tools"
VENV_DIR = ROOT / ".venv"
CONFIG_DIR = ROOT / "config"
RESULTS_DIR = ROOT / "results"
PYTHON = sys.executable

# ---------------------------------------------------------------------------
# Color Palette
# ---------------------------------------------------------------------------
BG_DARK = "#0d1117"
BG_CARD = "#161b22"
BG_INPUT = "#21262d"
FG_PRIMARY = "#e6edf3"
FG_SECONDARY = "#8b949e"
FG_DIM = "#484f58"
ACCENT = "#58a6ff"
ACCENT_HOVER = "#79c0ff"
GREEN = "#3fb950"
RED = "#f85149"
ORANGE = "#d29922"
BORDER = "#30363d"

# ---------------------------------------------------------------------------
# Tool Definitions
# ---------------------------------------------------------------------------
TOOLS = [
    {
        "name": "Sherlock",
        "desc": "Username search across 400+ social networks",
        "category": "People Lookup",
        "install": "pip",
        "pip_pkg": "sherlock-project",
        "git_url": "https://github.com/sherlock-project/sherlock.git",
    },
    {
        "name": "Holehe",
        "desc": "Check which services an email is registered on",
        "category": "People Lookup",
        "install": "pip",
        "pip_pkg": "holehe",
    },
    {
        "name": "SpiderFoot",
        "desc": "Automated OSINT recon from 200+ data sources",
        "category": "Automation",
        "install": "git+pip",
        "git_url": "https://github.com/smicallef/spiderfoot.git",
        "subdir": "spiderfoot",
    },
    {
        "name": "Recon-ng",
        "desc": "Modular OSINT framework (Metasploit-style)",
        "category": "Automation",
        "install": "git+pip",
        "git_url": "https://github.com/lanmaster53/recon-ng.git",
        "subdir": "recon-ng",
    },
    {
        "name": "theHarvester",
        "desc": "Email, subdomain, and IP enumeration",
        "category": "Infrastructure",
        "install": "git+pip",
        "git_url": "https://github.com/laramies/theHarvester.git",
        "subdir": "theHarvester",
    },
    {
        "name": "Shodan CLI",
        "desc": "Internet infrastructure search from the terminal",
        "category": "Infrastructure",
        "install": "pip",
        "pip_pkg": "shodan",
    },
    {
        "name": "Censys CLI",
        "desc": "Certificate and service discovery CLI",
        "category": "Infrastructure",
        "install": "pip",
        "pip_pkg": "censys",
    },
    {
        "name": "Rich",
        "desc": "Beautiful terminal formatting for the CLI launcher",
        "category": "Core",
        "install": "pip",
        "pip_pkg": "rich",
    },
    {
        "name": "PyYAML",
        "desc": "YAML config file support",
        "category": "Core",
        "install": "pip",
        "pip_pkg": "pyyaml",
    },
    {
        "name": "Requests",
        "desc": "HTTP library for Wayback Machine and API calls",
        "category": "Core",
        "install": "pip",
        "pip_pkg": "requests",
    },
]


# ---------------------------------------------------------------------------
# Installer Logic
# ---------------------------------------------------------------------------
class ToolInstaller:
    """Handles the actual installation of tools."""

    def __init__(self, venv_python: str):
        self.venv_python = venv_python

    def run(self, cmd, cwd=None):
        """Run a command and return (success, output)."""
        try:
            result = subprocess.run(
                cmd,
                cwd=cwd,
                capture_output=True,
                text=True,
                timeout=300,
            )
            return result.returncode == 0, result.stdout + result.stderr
        except Exception as e:
            return False, str(e)

    def create_venv(self):
        if not VENV_DIR.exists():
            ok, out = self.run([PYTHON, "-m", "venv", str(VENV_DIR)])
            if not ok:
                return False, out
        # Upgrade pip
        self.run([self.venv_python, "-m", "pip", "install", "--upgrade", "pip", "-q"])
        return True, "Virtual environment ready"

    def install_tool(self, tool):
        method = tool["install"]

        if method == "pip":
            pkg = tool["pip_pkg"]
            ok, out = self.run([self.venv_python, "-m", "pip", "install", pkg, "-q"])
            return ok, out

        elif method == "git+pip":
            subdir = tool.get("subdir", tool["name"].lower().replace(" ", ""))
            dest = TOOLS_DIR / subdir

            if dest.exists():
                ok, out = self.run(["git", "pull", "--quiet"], cwd=str(dest))
            else:
                ok, out = self.run(
                    ["git", "clone", "--depth", "1", tool["git_url"], str(dest)]
                )
                if not ok:
                    return False, out

            req_file = dest / "requirements.txt"
            if not req_file.exists():
                req_candidates = ["REQUIREMENTS", "requirements/base.txt"]
                for c in req_candidates:
                    if (dest / c).exists():
                        req_file = dest / c
                        break

            if req_file.exists():
                ok2, out2 = self.run(
                    [self.venv_python, "-m", "pip", "install", "-r", str(req_file), "-q"]
                )
                return ok2, out + "\n" + out2
            return True, out

        return False, f"Unknown install method: {method}"


# ---------------------------------------------------------------------------
# Rounded-Corner Card (canvas-based)
# ---------------------------------------------------------------------------
class RoundedFrame(tk.Canvas):
    """A canvas that draws a rounded-rectangle background."""

    def __init__(self, parent, radius=12, bg_color=BG_CARD, **kwargs):
        kwargs.setdefault("highlightthickness", 0)
        kwargs.setdefault("bg", BG_DARK)
        super().__init__(parent, **kwargs)
        self.radius = radius
        self.bg_color = bg_color
        self.inner = tk.Frame(self, bg=bg_color)
        self.create_window(0, 0, window=self.inner, anchor="nw")
        self.bind("<Configure>", self._on_resize)

    def _on_resize(self, event):
        self.delete("bg")
        w, h, r = event.width, event.height, self.radius
        self.create_rounded_rect(0, 0, w, h, r, fill=self.bg_color, outline=BORDER, tags="bg")
        self.tag_lower("bg")
        self.itemconfigure(self.find_withtag("bg"), width=1)
        self.coords(self.find_withtag(self.inner), r // 2, r // 2)
        self.inner.configure(width=w - r, height=h - r)

    def create_rounded_rect(self, x1, y1, x2, y2, r, **kwargs):
        points = [
            x1 + r, y1,
            x2 - r, y1,
            x2, y1,
            x2, y1 + r,
            x2, y2 - r,
            x2, y2,
            x2 - r, y2,
            x1 + r, y2,
            x1, y2,
            x1, y2 - r,
            x1, y1 + r,
            x1, y1,
            x1 + r, y1,
        ]
        return self.create_polygon(points, smooth=True, **kwargs)


# ---------------------------------------------------------------------------
# Main Application
# ---------------------------------------------------------------------------
class InstallerApp(tk.Tk):
    def __init__(self):
        super().__init__()

        self.title("OSINT Toolkit — Installer")
        self.configure(bg=BG_DARK)
        self.geometry("780x820")
        self.minsize(700, 700)
        self.resizable(True, True)

        # Icon (optional, skip if fails)
        try:
            self.iconbitmap(default="")
        except Exception:
            pass

        # Fonts
        self.title_font = tkfont.Font(family="Segoe UI", size=22, weight="bold")
        self.subtitle_font = tkfont.Font(family="Segoe UI", size=11)
        self.heading_font = tkfont.Font(family="Segoe UI", size=13, weight="bold")
        self.body_font = tkfont.Font(family="Segoe UI", size=10)
        self.small_font = tkfont.Font(family="Segoe UI", size=9)
        self.mono_font = tkfont.Font(family="Consolas", size=9)

        # State
        self.tool_vars = {}
        self.tool_status_labels = {}
        self.installing = False

        # Determine venv python path
        if sys.platform == "win32":
            self.venv_python = str(VENV_DIR / "Scripts" / "python.exe")
        else:
            self.venv_python = str(VENV_DIR / "bin" / "python3")

        self.installer = ToolInstaller(self.venv_python)

        self._build_ui()

    # ----- UI Construction -----

    def _build_ui(self):
        # Scrollable container
        outer = tk.Frame(self, bg=BG_DARK)
        outer.pack(fill="both", expand=True)

        canvas = tk.Canvas(outer, bg=BG_DARK, highlightthickness=0)
        scrollbar = ttk.Scrollbar(outer, orient="vertical", command=canvas.yview)
        self.scroll_frame = tk.Frame(canvas, bg=BG_DARK)

        self.scroll_frame.bind(
            "<Configure>",
            lambda e: canvas.configure(scrollregion=canvas.bbox("all")),
        )
        canvas.create_window((0, 0), window=self.scroll_frame, anchor="nw")
        canvas.configure(yscrollcommand=scrollbar.set)

        canvas.pack(side="left", fill="both", expand=True, padx=20)
        scrollbar.pack(side="right", fill="y")

        # Mousewheel scrolling
        def _on_mousewheel(event):
            canvas.yview_scroll(int(-1 * (event.delta / 120)), "units")

        canvas.bind_all("<MouseWheel>", _on_mousewheel)

        container = self.scroll_frame

        # ── Header ──
        header = tk.Frame(container, bg=BG_DARK)
        header.pack(fill="x", pady=(20, 5))

        ascii_art = r"""  ___  ____ ___ _   _ _____
 / _ \/ ___|_ _| \ | |_   _|
| | | \___ \| ||  \| | | |
| |_| |___) | || |\  | | |
 \___/|____/___|_| \_| |_|"""

        tk.Label(
            header, text=ascii_art, font=self.mono_font,
            fg=ACCENT, bg=BG_DARK, justify="left",
        ).pack(anchor="w")

        tk.Label(
            header, text="OSINT Toolkit Installer",
            font=self.title_font, fg=FG_PRIMARY, bg=BG_DARK,
        ).pack(anchor="w", pady=(8, 0))

        tk.Label(
            header,
            text="Select tools below and click Install to set up your investigation stack.",
            font=self.subtitle_font, fg=FG_SECONDARY, bg=BG_DARK,
        ).pack(anchor="w", pady=(2, 0))

        # ── Separator ──
        sep = tk.Frame(container, bg=BORDER, height=1)
        sep.pack(fill="x", pady=15)

        # ── Tool Cards by Category ──
        categories = {}
        for tool in TOOLS:
            cat = tool["category"]
            categories.setdefault(cat, []).append(tool)

        cat_icons = {
            "Core": "\u2699",           # gear
            "People Lookup": "\U0001F464",  # person silhouette
            "Automation": "\u26A1",     # lightning
            "Infrastructure": "\U0001F310",  # globe
        }

        for cat_name, cat_tools in categories.items():
            icon = cat_icons.get(cat_name, "\u2022")
            cat_frame = tk.Frame(container, bg=BG_DARK)
            cat_frame.pack(fill="x", pady=(10, 2))

            tk.Label(
                cat_frame, text=f"  {icon}  {cat_name}",
                font=self.heading_font, fg=ACCENT, bg=BG_DARK,
            ).pack(anchor="w")

            for tool in cat_tools:
                self._build_tool_row(container, tool)

        # ── Separator ──
        sep2 = tk.Frame(container, bg=BORDER, height=1)
        sep2.pack(fill="x", pady=15)

        # ── Select All / Deselect ──
        btn_row = tk.Frame(container, bg=BG_DARK)
        btn_row.pack(fill="x", pady=(0, 5))

        self._make_link_btn(btn_row, "Select All", self._select_all).pack(side="left")
        tk.Label(btn_row, text="  |  ", fg=FG_DIM, bg=BG_DARK, font=self.body_font).pack(side="left")
        self._make_link_btn(btn_row, "Deselect All", self._deselect_all).pack(side="left")

        # ── Progress Area ──
        prog_frame = tk.Frame(container, bg=BG_DARK)
        prog_frame.pack(fill="x", pady=(10, 5))

        self.progress_label = tk.Label(
            prog_frame, text="Ready to install",
            font=self.body_font, fg=FG_SECONDARY, bg=BG_DARK, anchor="w",
        )
        self.progress_label.pack(fill="x")

        style = ttk.Style()
        style.theme_use("default")
        style.configure(
            "Custom.Horizontal.TProgressbar",
            troughcolor=BG_INPUT,
            background=ACCENT,
            thickness=8,
            borderwidth=0,
        )

        self.progress_bar = ttk.Progressbar(
            prog_frame, style="Custom.Horizontal.TProgressbar",
            orient="horizontal", mode="determinate", maximum=100,
        )
        self.progress_bar.pack(fill="x", pady=(5, 0))

        # ── Log Area ──
        log_frame = tk.Frame(container, bg=BG_CARD, bd=0, relief="flat")
        log_frame.pack(fill="x", pady=(10, 5))

        self.log_text = tk.Text(
            log_frame, height=8, bg=BG_CARD, fg=FG_SECONDARY,
            font=self.mono_font, relief="flat", bd=10,
            insertbackground=FG_PRIMARY, selectbackground=ACCENT,
            wrap="word", state="disabled",
        )
        self.log_text.pack(fill="x")
        self.log_text.tag_configure("ok", foreground=GREEN)
        self.log_text.tag_configure("err", foreground=RED)
        self.log_text.tag_configure("warn", foreground=ORANGE)
        self.log_text.tag_configure("info", foreground=ACCENT)

        # ── Install Button ──
        btn_frame = tk.Frame(container, bg=BG_DARK)
        btn_frame.pack(fill="x", pady=(15, 25))

        self.install_btn = tk.Button(
            btn_frame, text="  Install Selected Tools  ",
            font=self.heading_font, fg=BG_DARK, bg=ACCENT,
            activebackground=ACCENT_HOVER, activeforeground=BG_DARK,
            relief="flat", bd=0, padx=30, pady=10,
            cursor="hand2", command=self._start_install,
        )
        self.install_btn.pack()

        # Hover effects
        self.install_btn.bind("<Enter>", lambda e: self.install_btn.configure(bg=ACCENT_HOVER))
        self.install_btn.bind("<Leave>", lambda e: self.install_btn.configure(bg=ACCENT))

    def _build_tool_row(self, parent, tool):
        """Build a single tool row with checkbox, name, description, and status."""
        row = tk.Frame(parent, bg=BG_CARD, bd=0, relief="flat")
        row.pack(fill="x", padx=10, pady=3, ipady=8)

        # Checkbox variable
        var = tk.BooleanVar(value=True)
        self.tool_vars[tool["name"]] = var

        cb = tk.Checkbutton(
            row, variable=var, bg=BG_CARD, fg=FG_PRIMARY,
            selectcolor=BG_INPUT, activebackground=BG_CARD,
            activeforeground=FG_PRIMARY, bd=0, highlightthickness=0,
            cursor="hand2",
        )
        cb.pack(side="left", padx=(12, 4))

        text_frame = tk.Frame(row, bg=BG_CARD)
        text_frame.pack(side="left", fill="x", expand=True)

        tk.Label(
            text_frame, text=tool["name"],
            font=self.body_font, fg=FG_PRIMARY, bg=BG_CARD, anchor="w",
        ).pack(anchor="w")

        tk.Label(
            text_frame, text=tool["desc"],
            font=self.small_font, fg=FG_SECONDARY, bg=BG_CARD, anchor="w",
        ).pack(anchor="w")

        # Status indicator
        status_lbl = tk.Label(
            row, text="\u2500", font=self.body_font,
            fg=FG_DIM, bg=BG_CARD, width=10,
        )
        status_lbl.pack(side="right", padx=(0, 12))
        self.tool_status_labels[tool["name"]] = status_lbl

        # Check if already installed
        self._check_existing(tool)

    def _check_existing(self, tool):
        """Check if a tool is already available and mark it."""
        name = tool["name"]
        label = self.tool_status_labels[name]
        found = False

        if tool["install"] == "pip":
            binary = tool["pip_pkg"].replace("-", "").lower()
            if shutil.which(binary) or shutil.which(tool["pip_pkg"]):
                found = True
        elif tool["install"] == "git+pip":
            subdir = tool.get("subdir", name.lower().replace(" ", ""))
            if (TOOLS_DIR / subdir).exists():
                found = True

        if found:
            label.configure(text="Installed", fg=GREEN)

    def _make_link_btn(self, parent, text, command):
        lbl = tk.Label(
            parent, text=text, font=self.body_font,
            fg=ACCENT, bg=BG_DARK, cursor="hand2",
        )
        lbl.bind("<Button-1>", lambda e: command())
        lbl.bind("<Enter>", lambda e: lbl.configure(fg=ACCENT_HOVER))
        lbl.bind("<Leave>", lambda e: lbl.configure(fg=ACCENT))
        return lbl

    def _select_all(self):
        for var in self.tool_vars.values():
            var.set(True)

    def _deselect_all(self):
        for var in self.tool_vars.values():
            var.set(False)

    # ----- Logging -----

    def log(self, message, tag=""):
        self.log_text.configure(state="normal")
        ts = datetime.now().strftime("%H:%M:%S")
        self.log_text.insert("end", f"[{ts}] {message}\n", tag)
        self.log_text.see("end")
        self.log_text.configure(state="disabled")

    # ----- Installation -----

    def _start_install(self):
        if self.installing:
            return

        selected = [t for t in TOOLS if self.tool_vars[t["name"]].get()]
        if not selected:
            messagebox.showwarning("No Tools Selected", "Please select at least one tool to install.")
            return

        self.installing = True
        self.install_btn.configure(state="disabled", bg=FG_DIM)
        thread = threading.Thread(target=self._install_thread, args=(selected,), daemon=True)
        thread.start()

    def _install_thread(self, selected):
        total = len(selected) + 2  # +2 for venv + configs
        done = 0

        def progress(msg):
            nonlocal done
            done += 1
            pct = int(done / total * 100)
            self.after(0, lambda: self.progress_bar.configure(value=pct))
            self.after(0, lambda: self.progress_label.configure(text=msg))

        # Step 1: Create directories
        self.after(0, lambda: self.log("Creating directory structure...", "info"))
        for d in [TOOLS_DIR, RESULTS_DIR, CONFIG_DIR,
                  RESULTS_DIR / "archives", RESULTS_DIR / "reports", RESULTS_DIR / "screenshots"]:
            d.mkdir(parents=True, exist_ok=True)

        # Step 2: Create virtual environment
        self.after(0, lambda: self.log("Setting up Python virtual environment...", "info"))
        ok, out = self.installer.create_venv()
        if ok:
            self.after(0, lambda: self.log("Virtual environment ready", "ok"))
        else:
            self.after(0, lambda: self.log(f"Venv error: {out}", "err"))
        progress("Virtual environment ready")

        # Step 3: Copy configs
        self.after(0, lambda: self.log("Setting up configuration files...", "info"))
        api_src = CONFIG_DIR / "api_keys.example.yaml"
        api_dst = CONFIG_DIR / "api_keys.yaml"
        if api_src.exists() and not api_dst.exists():
            shutil.copy2(api_src, api_dst)
            self.after(0, lambda: self.log("Created config/api_keys.yaml", "warn"))

        tgt_src = CONFIG_DIR / "targets.example.yaml"
        tgt_dst = CONFIG_DIR / "targets.yaml"
        if tgt_src.exists() and not tgt_dst.exists():
            shutil.copy2(tgt_src, tgt_dst)
            self.after(0, lambda: self.log("Created config/targets.yaml", "warn"))
        progress("Configuration ready")

        # Step 4: Install each selected tool
        for tool in selected:
            name = tool["name"]
            self.after(0, lambda n=name: self.log(f"Installing {n}...", "info"))
            self.after(
                0,
                lambda n=name: self.tool_status_labels[n].configure(
                    text="Installing...", fg=ORANGE
                ),
            )

            ok, out = self.installer.install_tool(tool)

            if ok:
                self.after(0, lambda n=name: self.log(f"{n} installed successfully", "ok"))
                self.after(
                    0,
                    lambda n=name: self.tool_status_labels[n].configure(
                        text="Installed", fg=GREEN
                    ),
                )
            else:
                err_short = out.strip().split("\n")[-1][:80] if out.strip() else "Unknown error"
                self.after(
                    0, lambda n=name, e=err_short: self.log(f"{n} failed: {e}", "err")
                )
                self.after(
                    0,
                    lambda n=name: self.tool_status_labels[n].configure(
                        text="Failed", fg=RED
                    ),
                )
            progress(f"Installed {name}")

        # Done
        self.after(0, lambda: self.progress_label.configure(text="Installation complete!"))
        self.after(0, lambda: self.progress_bar.configure(value=100))
        self.after(0, lambda: self.log("", ""))
        self.after(0, lambda: self.log("Setup complete! Run: python osint.py", "ok"))
        self.after(0, lambda: self.install_btn.configure(
            state="normal", bg=GREEN, text="  Installation Complete  "
        ))
        self.installing = False


# ---------------------------------------------------------------------------
# Entry Point
# ---------------------------------------------------------------------------
def main():
    app = InstallerApp()
    app.mainloop()


if __name__ == "__main__":
    main()
