# Fase 4b: Implementation Plan — Resto dei Deliverables

---

## 2. Template Files

### 2.1 `templates/claude-md-template.md`

**Path**: `agent-ready-skill/templates/claude-md-template.md`
**Uso**: Workshop Phase 2 (Axis 1) — participants lo copiano e adattano

```markdown
# Project Context — Agent Instructions

## Overview
<!-- One paragraph: what does this project do? Who is it for? -->

## Architecture
- **Framework**: <!-- FastAPI / Django / Flask / Script / Library -->
- **Main entry point**: <!-- e.g. src/main.py, app.py -->
- **Key directories:
  - `src/` or `app/` → <!-- application code -->
  - `tests/` → <!-- test suite -->
  - `config/` → <!-- configuration files -->
  - `scripts/` → <!-- utility/CLI scripts -->

## Conventions
- **Style**: <!-- ruff (with black compat), black+isort, pylint... -->
- **Type hints**: <!-- strict (pyright strict) / loose / none -->
- **String quotes**: <!-- double / single -->
- **Import order**: <!-- stdlib → third-party → local -->
- **Naming**: <!-- snake_case functions/vars, PascalCase classes, UPPER constants -->
- **Docstrings**: <!-- Google style / NumPy / None -->

## Commands
```bash
# Install dependencies
pip install -e ".[dev]"    # or: poetry install, uv sync

# Run tests
pytest                      # or: pytest tests/ -v

# Run linter
ruff check .                # or: flake8, pylint

# Format code
ruff format .               # or: black .

# Type check
pyright                     # or: mypy src/

# Run the application
python -m app               # or: uvicorn app.main:app
```

## Pitfalls — Common Mistakes to Avoid
- ❌ Don't use `import *` — be explicit about imports
- ❌ Don't add new dependencies without updating requirements/pyproject.toml
- ❌ Don't put business logic in `__init__.py` files
- ❌ Don't use `print()` for logging — use the `logging` module
- ⚠️ Database migrations must go through `alembic upgrade head`
- ⚠️ Environment variables are defined in `.env.example` — never hardcode secrets

## Testing Strategy
- Framework: <!-- pytest -->
- Coverage target: <!-- e.g. 80% for new code -->
- Key fixtures: <!-- e.g. db_session, client, sample_data -->
- Where to put tests: <!-- co-located _test.py next to source, or tests/ directory -->

## AI-Specific Notes
<!-- Anything an AI agent should know that isn't obvious from code:
     - Preferred patterns (e.g. "always use dependency injection")
     - Anti-patterns in this codebase
     - Areas under active development
     - Technical debt to avoid compounding
-->
```

---

### 2.2 `templates/ci-template.yml`

**Path**: `agent-ready-skill/templates/ci-template.yml`
**Uso**: Workshop Phase 4 (Axis 3) — participants copiano in `.github/workflows/ci.yml`

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  quality:
    name: Quality Checks
    runs-on: ubuntu-latest
    timeout-minutes: 10

    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"
          cache: pip
          cache-dependency-path: |
            pyproject.toml
            requirements-dev.txt

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -e ".[dev]"   # adjust to your project's install command

      # ── Lint ──
      - name: Lint (ruff)
        run: ruff check . --output-format=github

      # ── Format Check ──
      - name: Format check (ruff)
        run: ruff format --check --diff

      # ── Type Check ──
      - name: Type check (pyright)
        run: pyright                    # or: mypy src/
        continue-on-error: true         # optional: don't block on type errors

  test:
    name: Tests
    runs-on: ubuntu-latest
    timeout-minutes: 15

    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -e ".[dev]"

      - name: Run tests
        run: pytest tests/ -v --tb=short --cov=src/ --cov-report=term-missing
        env:
          PYTHONPATH: ${{ github.workspace }}

      # ── Optional: Upload coverage ──
      - name: Upload coverage
        if: success()
        uses: codecov/codecov-action@v4
        with:
          fail_ci_if_error: false
```

---

### 2.3 `templates/security-md-template.md`

**Path**: `agent-ready-skill/templates/security-md-template.md`

```markdown
# Security Policy

## Supported Versions
| Version | Supported          |
| ------- | ------------------ |
| x.x.x   | :white_check_mark: |
| < x.x.x | :x:                |

## Reporting a Vulnerability

We take security seriously. If you discover a security issue:

1. **DO NOT** open a public issue or PR
2. Email us at: <!-- your-security-email@example.com -->
3. Include:
   - Description of the vulnerability
   - Steps to reproduce (if applicable)
   - Potential impact
4. We will acknowledge within **48 hours** and provide a timeline for a fix

## Security Best Practices for This Project

<!-- Add project-specific security notes:
     - How secrets/env vars should be managed
     - Known dependencies with CVEs (if any)
     - Security-related configuration
-->

## Dependencies

This project uses automated dependency monitoring via:
- [ ] Dependabot (`.github/dependabot.yml`)
- [ ] Renovate (`renovate.json`)

See [SECURITY.md](https://github.com/RisorseArtificiali/agent-ready-skill/blob/main/SECURITY.md) for more.
```

---

### 2.4 `templates/.env.example`

```
# Copy this file to .env and fill in your values
# NEVER commit .env to version control

# Application
APP_NAME=MyProject
APP_ENV=development
DEBUG=true
LOG_LEVEL=INFO

# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/mydb
# For SQLite (dev): DATABASE_URL=sqlite:///./dev.db

# External APIs
# API_KEY=your-key-here
# WEBHOOK_SECRET=your-secret-here

# AI/LLM (optional)
# OPENAI_API_KEY=sk-...
# ANTHROPIC_API_KEY=sk-ant-...
```

---

### 2.5 `templates/.editorconfig`

```ini
# EditorConfig — consistent coding styles across editors
# https://editorconfig.org

root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 4

[*.py]
indent_size = 4
max_line_length = 120

[*.{yml,yaml}]
indent_size = 2

[Makefile]
indent_style = tab

[*.{md,rst}]
trim_trailing_whitespace = false
```

---

### 2.6 `templates/pyproject-agent-ready-snippet.toml`

```toml
# === AGENT READINESS: Add these sections to your pyproject.toml ===

# --- Linting ---
[tool.ruff]
target-version = "py311"
line-length = 120

[tool.ruff.lint]
select = [
    "E",    # pycodestyle errors
    "W",    # pycodestyle warnings
    "F",    # Pyflakes
    "I",    # isort
    "N",    # pep8-naming
    "UP",   # pyupgrade
    "B",    # flake8-bugbear
    "SIM",  # flake8-simplify
]
ignore = ["E501"]  # line too long (formatter handles this)

# --- Formatting ---
[tool.ruff.format]
quote-style = "double"
indent-style = "space"

# --- Testing ---
[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py", "*_test.py"]
addopts = "-v --tb=short"
filterwarnings = ["ignore::DeprecationWarning"]

# --- Type Checking ---
[tool.pyright]
typeCheckingMode = "basic"       # or "strict" for maximum safety
pythonVersion = "3.11"
reportMissingImports = "warning"
reportMissingModuleSource = "none"
reportOptionalMemberAccess = "warning"
reportUnknownVariableType = "warning"
include = ["src/", "app/"]

# --- Coverage ---
[tool.coverage.run]
source = ["src"]
branch = true
omit = ["*/tests/*", "*/__pycache__/*"]

[tool.coverage.report]
fail_under = 60
show_missing = true
skip_covered = true
```

---

## 3. `scripts/apply_fix.py` — Auto-Fix Tool

**Path**: `agent-ready-skill/scripts/apply_fix.py`
**Dipendenze**: `jinja2`, stdlib
**Righe**: ~120

```python
#!/usr/bin/env python3
"""
Agent Ready Auto-Fix — Apply targeted improvements to a codebase.

Generates missing files from templates, adapted to the project context.

Usage:
    python apply_fix.py <target> /path/to/repo [--dry-run]

Targets:
    agent-instructions  Generate CLAUDE.md from template
    editorconfig       Generate .editorconfig
    env-example        Generate .env.example
    ci-config          Generate .github/workflows/ci.yml
    security-policy    Generate SECURITY.md
    contributing       Generate CONTRIBUTING.md
    pyproject-ruff     Add [tool.ruff] section to pyproject.toml
    pre-commit         Generate .pre-commit-config.yaml
    all                Apply all recommended fixes
"""

from __future__ import annotations

import argparse
import shutil
import sys
from pathlib import Path
from datetime import date

try:
    from jinja2 import Environment, FileSystemLoader
except ImportError:
    print("ERROR: pip install jinja2", file=sys.stderr)
    sys.exit(1)

TEMPLATE_DIR = Path(__file__).parent.parent / "templates"

# Target definitions: what each fix generates
FIXES = {
    "agent-instructions": {
        "dest": "CLAUDE.md",
        "template": "claude-md-template.md",
        "description": "Agent instructions file (CLAUDE.md)",
        "axis": "instruct",
        "effort": "medium",
        "potential_gain": 20,
    },
    "editorconfig": {
        "dest": ".editorconfig",
        "template": None,  # static content
        "static_content": """\
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 4

[*.py]
indent_size = 4
max_line_length = 120

[*.{yml,yaml}]
indent_size = 2
""",
        "description": "EditorConfig for consistent editing",
        "axis": "navigate",
        "effort": "low",
        "potential_gain": 2,
    },
    "env-example": {
        "dest": ".env.example",
        "template": ".env.example",
        "description": "Environment variables documentation",
        "axis": "navigate",
        "effort": "low",
        "potential_gain": 4,
    },
    "ci-config": {
        "dest": ".github/workflows/ci.yml",
        "template": "ci-template.yml",
        "description": "GitHub Actions CI pipeline",
        "axis": "validate",
        "effort": "medium",
        "potential_gain": 6,
    },
    "security-policy": {
        "dest": "SECURITY.md",
        "template": "security-md-template.md",
        "description": "Security policy document",
        "axis": "validate",
        "effort": "low",
        "potential_gain": 2,
    },
    "contributing": {
        "dest": "CONTRIBUTING.md",
        "template": "contributing-template.md",
        "description": "Contributing guide",
        "axis": "instruct",
        "effort": "low",
        "potential_gain": 5,
    },
}


def detect_project_info(repo: Path) -> dict[str, str]:
    """Auto-detect project info from existing files."""
    info = {
        "project_name": repo.name,
        "year": str(date.today().year),
        "has_tests": False,
        "has_ruff": False,
        "has_black": False,
        "has_pytest": False,
        "framework": "unknown",
        "main_entry": "",
    }

    # Detect framework
    pyproject = repo / "pyproject.toml"
    if pyproject.exists():
        content = pyproject.read_text(encoding="utf-8", errors="ignore")
        if "fastapi" in content.lower():
            info["framework"] = "FastAPI"
        elif "django" in content.lower():
            info["framework"] = "Django"
        elif "flask" in content.lower():
            info["framework"] = "Flask"
        elif "[project.scripts]" in content:
            info["framework"] = "CLI/Library"
        else:
            info["framework"] = "Python Package"

        info["has_ruff"] = "[tool.ruff]" in content
        info["has_black"] = ("[tool.black]" in content or 
                             'black' in content.lower())
        info["has_pytest"] = ("[tool.pytest]" in content or 
                              "[pytest]" in content)

    # Detect test directory
    if (repo / "tests").is_dir() or (repo / "test").is_dir():
        info["has_tests"] = True
    else:
        # Look for any test file
        for p in repo.rglob("test_*.py"):
            info["has_tests"] = True
            break
        else:
            for p in repo.rglob("*_test.py"):
                info["has_tests"] = True
                break

    # Find main entry point
    for candidate in ["app.py", "main.py", "src/main.py", "src/app.py"]:
        if (repo / candidate).exists():
            info["main_entry"] = candidate
            break

    return info


def apply_fix(target: str, repo: Path, dry_run: bool = False) -> dict[str, str]:
    """Apply a single fix target."""
    if target not in FIXES:
        print(f"ERROR: Unknown target '{target}'", file=sys.stderr)
        print(f"Available targets: {', '.join(FIXES.keys())}", file=sys.stderr)
        sys.exit(1)

    fix = FIXES[target]
    dest_path = repo / fix["dest"]

    if dest_path.exists() and not dry_run:
        print(f"⚠ {fix['dest']} already exists. Skipping (use --force to overwrite)")
        return {"status": "exists", "file": fix["dest"]}

    # Get content
    if fix.get("static_content"):
        content = fix["static_content"]
    elif fix.get("template"):
        template_path = TEMPLATE_DIR / fix["template"]
        if not template_path.exists():
            print(f"⚠ Template not found: {template_path}", file=sys.stderr)
            return {"status": "missing_template", "file": fix["dest"]}
        
        env = Environment(loader=FileSystemLoader(str(TEMPLATE_DIR)))
        tmpl = env.get_template(fix["template"])
        context = detect_project_info(repo)
        content = tmpl.render(**context)
    else:
        print(f"ERROR: No template or static content for '{target}'")
        return {"status": "error", "file": fix["dest"]}

    if dry_run:
        print(f"\n[DRY RUN] Would create: {fix['dest']}")
        print("---")
        print(content[:500])
        if len(content) > 500:
            print(f"... ({len(content)} chars total)")
        print("---")
        return {"status": "dry_run", "file": fix["dest"], "size": len(content)}

    # Write file
    dest_path.parent.mkdir(parents=True, exist_ok=True)
    dest_path.write_text(content, encoding="utf-8")

    print(f"✅ Created: {fix['dest']} ({len(content)} chars)")
    print(f"   Axis: {fix['axis']} | Effort: {fix['effort']} | "
          f"Potential score gain: +{fix['potential_gain']}")
    
    return {"status": "created", "file": fix["dest"], "size": len(content)}


def list_recommended_fixes(repo: Path) -> list[dict]:
    """Scan repo and recommend which fixes to apply."""
    recommended = []
    for target_id, fix in FIXES.items():
        dest = repo / fix["dest"]
        if not dest.exists():
            recommended.append({**fix, "id": target_id})
    return recommended


def main(argv: list[str] | None = None) -> None:
    parser = argparse.ArgumentParser(
        description="Agent Ready Auto-Fix — Generate missing agent-readiness files",
    )
    parser.add_argument("target", help="Fix target (see available below)")
    parser.add_argument(
        "path", nargs="?", default=".",
        help="Path to repository (default: cwd)"
    )
    parser.add_argument(
        "--dry-run", action="store_true",
        help="Show what would be created without writing files"
    )
    parser.add_argument(
        "--list", action="store_true",
        "dest": "list_fixes",
        help="List recommended fixes for this repo"
    )
    parser.add_argument(
        "--all-fixes", action="store_true",
        help="Apply ALL recommended fixes"
    )

    args = parser.parse_args(argv)

    repo = Path(args.path).resolve()
    if not repo.is_dir():
        print(f"ERROR: Not a directory: {repo}", file=sys.stderr)
        sys.exit(1)

    if args.list_fixes:
        fixes = list_recommended_fixes(repo)
        if not fixes:
            print("✅ All agent-readiness files present!")
            return
        print(f"\n📋 Recommended fixes ({len(fixes)}):\n")
        for f in fixes:
            print(f"  {f['id']:25s} → {f['dest']:30s} "
                  f"[{f['axis']}] +{f['potential_gain']}pt ({f['effort']})")
        return

    if args.all_fixes:
        fixes = list_recommended_fixes(repo)
        results = []
        for f in fixes:
            r = apply_fix(f["id"], repo, dry_run=args.dry_run)
            results.append(r)
        created = sum(1 for r in results if r["status"] == "created")
        print(f"\n🎉 Done! {created}/{len(results)} files created.")
        return

    apply_fix(args.target, repo, dry_run=args.dry_run)


if __name__ == "__main__":
    main()
```

---

## 4. Demo Repos

### 4.1 `repos/demo-bad/` — Intentionally Low Score

Struttura minima deliberatamente carente:

```
repos/demo-bbad/
├── app.py              # 400 lines, no structure, no docstrings
├── utils.py            # 200 lines, mixed concerns
├── helpers.py          # 150 lines, copy-pasted code
├── models.py           # 100 lines, no type hints
├── main.py             # entry point, no __name__ guard
└── requirements.txt    # no lock file, no versions pinned
```

Caratteristiche (tutte negative per lo scan):
- ❌ Nessun CLAUDE.md, .cursorrules, README decente
- ❌ Nessun .editorconfig, ruff, black, pyright
- ❌ Nessun test file, nessun pytest.ini
- ❌ Nessun CI, nessun .github/
- ❌ File lunghi (>300 righe), naming inconsistente
- ❌ Nessun .env.example, nessun SECURITY.md
- **Expected score**: ~15-25% (Level 1: Foundational)

### 4.2 `repos/demo-good/` — High Score Reference

```
repos/demo-good/
├── README.md                  # Complete, sections, code examples
├── CLAUDE.md                  # Full agent instructions
├── CONTRIBUTING.md            # Setup + dev workflow
├── ARCHITECTURE.md            # Design decisions
├── SECURITY.md                # Security policy
├── .editorconfig              # Consistent settings
├── .env.example               # All env vars documented
├── .pre-commit-config.yaml    # Ruff + hooks
├── pyproject.toml             # [tool.ruff], [tool.pytest], [tool.pyright], coverage
├── .python-version            # Pinned Python 3.12
├── poetry.lock                # Reproducible deps
├── src/
│   ├── __init__.py
│   ├── main.py                # Clean entry point, typed
│   ├── models/                # Domain models, well-documented
│   │   ├── __init__.py
│   │   └── user.py            # Typed dataclass, docstrings
│   ├── services/              # Business logic
│   │   ├── __init__.py
│   │   └── auth_service.py    # Single responsibility, <150 lines
│   └── api/                   # Route handlers
│       ├── __init__.py
│       └── routes.py          # Clean FastAPI router
├── tests/
│   ├── __init__.py
│   ├── conftest.py            # Fixtures
│   ├── test_models.py         # Model tests
│   ├── test_services.py       # Service tests
│   └── test_api.py            # Integration tests
└── .github/
    ├── workflows/
    │   └── ci.yml             # lint + type-check + test + coverage
    └── dependabot.yml         # Auto-updates
```

**Expected score**: ~75-85% (Level 3-4: Structured/Optimized)

---

## 5. `scripts/report_gen.py` — Multi-Format Report Generator

**Path**: `agent-ready-skill/scripts/report_gen.py`
**Dipendenze**: stdlib + `json` (dal report JSON di scan_static.py)
**Righe**: ~80

```python
#!/usr/bin/env python3
"""
Generate multi-format reports from scan results.

Usage:
    python report_gen.py report.json --output ./report-dir/

Outputs:
    report.txt     Terminal-friendly summary
    radar.html     Interactive visualization (same as --visualize)
    recommendations.md  Prioritized todo list
    badge.svg      Maturity level badge for README
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from datetime import datetime


BADGE_SVG_TEMPLATE = '''<svg xmlns="http://www.w3.org/2000/svg" width="220" height="30">
<rect width="220" height="30" rx="4" fill="{bg_color}"/>
<rect x="90" width="130" height="30" rx="0" ry="0" fill="{score_bg}"/>
<rect x="90" width="130" height="30" rx="4" fill="{score_bg}" 
      clip-path="inset(0 0 0 round-right)"/>
<text x="66" y="19" font-family="Arial,sans-serif" font-size="11" 
      fill="#fff" text-anchor="middle" font-weight="bold">agent-ready</text>
<text x="155" y="19" font-family="Arial,sans-serif" font-size="11" 
      fill="#fff" text-anchor="middle" font-weight="bold">{level_name}</text>
</svg>'''


LEVEL_COLORS = {
    1: ("#555555", "#d32f2f"),   # gray bg, red score
    2: ("#f57c00", "#f57c00"),   # orange
    3: ("#1976d2", "#1976d2"),   # blue
    4: ("#388e3c", "#388e3c"),   # green
    5: ("#7b1fa2", "#7b1fa2"),   # purple
}


def generate_badge_svg(level: int, level_name: str, percentage: float) -> str:
    """Generate SVG badge for maturity level."""
    bg_color, score_bg = LEVEL_COLORS.get(level, LEVEL_COLORS[1])
    short_name = f"L{level} {percentage:.0f}%"
    return BADGE_SVG_TEMPLATE.format(
        bg_color=bg_color,
        score_bg=score_bg,
        level_name=short_name,
    )


def generate_txt_report(result: dict) -> str:
    """Generate plain-text report."""
    lines = []
    lines.append("=" * 56)
    lines.append("  AGENT READINESS ASSESSMENT REPORT")
    lines.append("=" * 56)
    lines.append("")
    lines.append(f"  Repo:     {result['repo_name']}")
    lines.append(f"  Date:     {result['timestamp']}")
    lines.append(f"  Level:    {result['overall']['level']} — {result['overall']['level_name']}")
    lines.append(f"  Overall:  {result['overall']['percentage']}%")
    lines.append("")
    lines.append("-" * 56)

    for ax_id, ax_data in result["axes"].items():
        bar_len = int(ax_data["percentage"] / 100 * 40)
        bar = "█" * bar_len + "░" * (40 - bar_len)
        lines.append(f"  {ax_id.upper():12s}  {bar} {ax_data['percentage']:>5.1f}%")

        for check in ax_data["checks"]:
            status = "✓" if check["pass"] else "✗"
            lines.append(f"    [{status}] {check['name']:30s} "
                        f"{check['score']}/{check['max_score']}")

    lines.append("-" * 56)
    lines.append(f"  Generated: {datetime.now().isoformat()}")
    lines.append("")
    return "\n".join(lines)


def generate_recommendations_md(result: dict) -> str:
    """Generate prioritized recommendations as markdown."""
    # Import recommendation logic from scan_static logic
    recs = []
    for ax_id, ax_data in result["axes"].items():
        for check in ax_data["checks"]:
            if not check["pass"]:
                recs.append({
                    "axis": ax_id,
                    "title": check["name"],
                    "details": check.get("details", ""),
                    "gain": check["max_score"] - check["score"],
                })

    recs.sort(key=lambda r: -r["gain"])

    lines = ["# 🏆 Agent Readiness — Improvement Plan\n"]
    lines.append(f"**Repo:** {result['repo_name']}  ")
    lines.append(f"**Score:** {result['overall']['percentage']}% "
                 f"(Level {result['overall']['level']}: {result['overall']['level_name']})\n")
    lines.append("---\n")

    for i, r in enumerate(recs, 1):
        axis_icon = {"instruct": "📝", "navigate": "🧭", "validate": "✅"}
        icon = axis_icon.get(r["axis"], "•")
        lines.append(f"## {i}. {icon} {r['title']}")
        lines.append(f"- **Axis:** {r['axis'].capitalize()}")
        lines.append(f"- **Potential improvement:** +{r['gain']} points")
        if r["details"]:
            lines.append(f"- **How:** {r['details']}")
        lines.append("")

    lines.append("---\n")
    lines.append("*Re-scan after applying fixes to track progress:*")
    lines.append("`python scripts/scan_static.py /path/to/repo --all --compare snapshot.json`\n")

    return "\n".join(lines)


def main(argv: list[str] | None = None) -> None:
    parser = argparse.ArgumentParser(description="Generate reports from scan results")
    parser.add_argument("report_json", help="Path to report JSON from scan_static.py")
    parser.add_argument("--output", "-o", default="./report/", help="Output directory")

    args = parser.parse_args(argv)

    report_path = Path(args.report_json)
    if not report_path.exists():
        print(f"ERROR: File not found: {report_path}", file=sys.stderr)
        sys.exit(1)

    with open(report_path) as f:
        result = json.load(f)

    out_dir = Path(args.output)
    out_dir.mkdir(parents=True, exist_ok=True)

    # Text report
    txt = generate_txt_report(result)
    (out_dir / "report.txt").write_text(txt, encoding="utf-8")
    print(f"✅ report.txt ({len(txt)} chars)")

    # Recommendations MD
    md = generate_recommendations_md(result)
    (out_dir / "recommendations.md").write_text(md, encoding="utf-8")
    print(f"✅ recommendations.md ({len(md)} chars)")

    # Badge SVG
    svg = generate_badge_svg(
        result["overall"]["level"],
        result["overall"]["level_name"],
        result["overall"]["percentage"],
    )
    (out_dir / "badge.svg").write_text(svg, encoding="utf-8")
    print(f"✅ badge.svg")

    print(f"\n📁 All outputs saved to: {out_dir.resolve()}")


if __name__ == "__main__":
    main()
```

---

## 6. `WORKSHOP.md` — Istruzioni Partecipanti

**Path**: `agent-ready-skill/WORKSHOP.md`
**Uso**: Pre-event instructions + reference durante workshop

```markdown
# 🤖 PyCon Italia 2026 — Measuring AI-Readiness Workshop

## Before You Arrive (10 min prep)

### ✅ Checklist

- [ ] **Python 3.11+ installed**
  ```bash
  python --version  # Must show 3.11 or higher
  ```

- [ ] **Git installed**
  ```bash
  git --version
  ```

- [ ] **Choose a repository** to analyze during the workshop
  - Your own project (best experience!)
  - An open-source project you contribute to
  - A work project you're familiar with
  - **Fallback**: We'll provide demo repos if needed

- [ ] **Clone the workshop materials**
  ```bash
  git clone https://github.com/RisorseArtificiali/agent-ready-skill.git
  cd agent-ready-skill
  ```

- [ ] **Install dependencies**
  ```bash
  pip install rich pyyaml jinja2
  ```
  Only 3 lightweight packages. No heavy ML/AI frameworks needed.

- [ ] **(Optional) LLM API key** for hybrid scoring mode
  - Export before the workshop:
    ```bash
    export OPENAI_API_KEY="sk-..."
    # OR
    export ANTHROPIC_API_KEY="sk-ant-..."
    ```
  - Without a key, the tool works in **static-only mode** (still fully functional!)

### 🔧 What We'll Build Together

You'll leave with:
1. **A numerical assessment** of your codebase's agent-readiness (3 axes, 0-100%)
2. **A maturity level badge** for your README
3. **Concrete improvements** you made during the workshop
4. **A reusable toolkit** to re-scan anytime

### 📁 Repository Structure

```
agent-ready-skill/
├── scripts/
│   ├── scan_static.py      ← Main scanner (you'll use this!)
│   ├── apply_fix.py        ← Auto-fix tool
│   └── report_gen.py       ← Report generator
├── templates/              ← Templates we'll adapt together
│   ├── claude-md-template.md
│   ├── ci-template.yml
│   └── ...
├── repos/                  ← Demo repositories
│   ├── demo-bad/           ← Example of low readiness
│   └── demo-good/          ← Example of high readiness
├── skills/                 ← Original agent-ready skills (reference)
└── WORKSHOP.md             ← This file
```

## Quick Start (During Workshop)

### Step 1: Scan Your Repository

```bash
# Scan all three axes
python scripts/scan_static.py /path/to/your/repo --all

# Or scan one axis at a time
python scripts/scan_static.py /path/to/your/repo --axis instruct
python scripts/scan_static.py /path/to/your/repo --axis navigate
python scripts/scan_static.py /path/to/your/repo --axis validate
```

### Step 2: Visualize Results

```bash
# Opens interactive radar chart in browser
python scripts/scan_static.py /path/to/your/repo --all --visualize
```

### Step 3: Apply Fixes

```bash
# See what's missing
python scripts/apply_fix.py --list /path/to/your/repo

# Apply a specific fix
python scripts/apply_fix.py agent-instructions /path/to/your/repo

# Apply ALL recommended fixes (review each one!)
python scripts/apply_fix.py --all-fixes /path/to/your/repo
```

### Step 4: Compare Before & After

```bash
# Save current state as snapshot
python scripts/scan_static.py /path/to/your/repo --all --save-snapshot

# ... make improvements ...

# Compare with previous state
python scripts/scan_static.py /path/to/your/repo --all \
  --compare .agent-ready/snapshots/<TIMESTAMP>.json
```

### Step 5: Generate Final Report

```bash
# First, save scan as JSON
python scripts/scan_static.py /path/to/your/repo --all \
  --format json --output ./my-report/report.json

# Then generate all formats
python scripts/report_gen.py ./my-report/report.json --output ./my-report/
```

Output:
```
my-report/
├── report.txt          ← Terminal-friendly summary
├── recommendations.md  ← Your prioritized todo list
└── badge.svg           ← Level badge for your README
```

## The Three-Axis Model

```
              📝 INSTRUCT (38%)
             /    "Does the agent understand
            /      WHAT we want?"
           /
🧭 NAVIGATE (34%) ───── ✅ VALIDATE (28%)
  "Can the agent find     "Does the agent know
   its way around?"        if it did it right?"
```

| Axis | Weight | Questions It Answers |
|------|--------|---------------------|
| 📝 Instruct | 38% | CLAUDE.md? Architecture docs? README? |
| 🧭 Navigate | 34% | Linter? Formatter? Type checker? Env docs? |
| ✅ Validate | 28% | Tests? CI pipeline? Security policy? |

## Maturity Levels

| Level | Name | Threshold | Meaning |
|-------|------|-----------|---------|
| 1 | Foundational | ≥40% | The project exists |
| 2 | Guided | ≥55% | Agents can follow instructions |
| 3 | Structured | ≥70% | Agents navigate autonomously |
| 4 | Optimized | ≥85% | Agents validate their work |
| 5 | Autonomous | ≥95% | Agents are team members |

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `ModuleNotFoundError: rich` | Run `pip install rich pyyaml jinja2` |
| PermissionError on write | Check file permissions; don't scan system dirs |
| Score seems wrong | Open an issue with `--format json` output attached |
| Radar chart doesn't open | Manually open the HTML file path shown in output |
| LLM scoring fails | Works fine without it — static-only mode |

## After the Workshop

- ⭐ Star the repo: https://github.com/RisorseArtificiali/agent-ready-skill
- 🐛 Found a bug? Open an issue!
- 💡 Have an idea? PRs welcome!
- 📢 Blog/tweet about your score using the badge!

---

*Workshop by Stefano Maeste — PyCon Italia 2026, May 29*
```

---

## 7. `requirements-workshop.txt`

```
# Agent Readiness Scanner — Workshop Dependencies
# Only 3 packages. No ML frameworks needed.

rich>=13.0.0          # Terminal UI (tables, panels, progress bars)
pyyaml>=6.0           # Config file support (optional, future use)
jinja2>=3.1           # Template rendering for apply_fix.py
```

---

## 8. `scripts/check_setup.py` — Environment Checker

**Path**: `agent-ready-skill/scripts/check_setup.py`
**Righe**: ~35

```python
#!/usr/bin/env python3
"""Verify workshop environment is ready."""

import sys
from pathlib import Path


CHECKS = [
    ("Python 3.11+", lambda: sys.version_info >= (3, 11)),
    ("rich package", lambda: __import__("rich")),
    ("jinja2 package", lambda: __import__("jinja2")),
    ("Git available", lambda: __import__("subprocess").run(
        ["git", "--version"], capture_output=True).returncode == 0),
]


def main():
    print("🔍 Agent Ready Workshop — Environment Check\n")
    all_ok = True

    for name, check_fn in CHECKS:
        try:
            ok = check_fn()
            status = "✅" if ok else "❌"
            print(f"  {status} {name}")
            if not ok:
                all_ok = False
        except Exception:
            print(f"  ❌ {name} (import error)")
            all_ok = False

    # Check that script siblings exist
    here = Path(__file__).parent
    for sibling in ["scan_static.py", "apply_fix.py"]:
        exists = (here / sibling).exists()
        status = "✅" if exists else "❌"
        print(f"  {status} {sibling}")
        if not exists:
            all_ok = False

    print()
    if all_ok:
        print("🎉 All checks passed! You're ready for the workshop.")
        return 0
    else:
        print("⚠️  Some checks failed. See above for details.")
        print("   Fix with: pip install rich pyyaml jinja2")
        return 1


if __name__ == "__main__":
    sys.exit(main())
```

---

## 📊 Riepilogo Totale Deliverables

| File | Righe | Dipendenze | Tempo Stima |
|------|-------|-----------|-------------|
| `scripts/scan_static.py` | ~650 | rich, pyyaml | 3-4h |
| `scripts/apply_fix.py` | ~170 | jinja2 | 1-2h |
| `scripts/report_gen.py` | ~110 | stdlib | 1h |
| `scripts/check_setup.py` | ~35 | stdlib | 0.5h |
| `templates/claude-md-template.md` | ~65 | — | 0.5h |
| `templates/ci-template.yml` | ~50 | — | 0.5h |
| `templates/security-md-template.md` | ~25 | — | 0.25h |
| `templates/.env.example` | ~18 | — | 0.1h |
| `templates/.editorconfig` | ~16 | — | 0.1h |
| `templates/pyproject-agent-ready-snippet.toml` | ~45 | — | 0.25h |
| `WORKSHOP.md` | ~230 | — | 0.5h |
| `requirements-workshop.txt` | ~5 | — | 0.05h |
| `repos/demo-bad/` | ~5 files, ~850 loc | — | 1h |
| `repos/demo-good/` | ~20 files, ~1200 loc | — | 2h |
| **TOTALE** | **~1420 righe + 2 repo completi** | **3 pkg pip** | **~13-15 ore** |

---

## 🔄 Ordine di Implementazione Consigliato

```
Giorno 1 (6h):
  ① scan_static.py core (checks + scoring engine)
  ② check_setup.py
  ③ requirements-workshop.txt

Giorno 2 (5h):
  ④ Demo repos (demo-bad + demo-good)
  ⑤ Template files (tutti)
  ⑥ Test: scan su entrambi i demo repos

Giorno 3 (4h):
  ⑦ apply_fix.py
  ⑧ report_gen.py + badge SVG
  ⑨ Hybrid scoring (LLM integration)
  ⑩ Radar chart HTML (embedded in scan_static.py)

Giorno 4-5 (buffer + polish):
  ⑪ WORKSHOP.md finale
  ⑫ Test end-to-end completo
  ⑬ Slides outline / speaker notes
  ⑭ Edge cases + error handling
```
