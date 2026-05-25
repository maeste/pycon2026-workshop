# Phase 4b — Implementation Plan: Remaining Deliverables

> **Companion document to `05-implementation-plan.md`** (which specifies
> `scripts/scan_static.py`). This document specifies **every other artifact**
> required to ship the PyCon Italia 2026 *Agent Readiness* workshop inside the
> repository [`github.com/RisorseArtificiali/agent-ready-skill`](https://github.com/RisorseArtificiali/agent-ready-skill).
>
> The intended reader is an AI coding agent (Claude Code, Cursor, Codex, etc.)
> working **inside** that repository. No clarifying questions should be needed:
> every section is self-contained.

---

## 1. Header & Purpose

### 1.1 What this document covers

`05-implementation-plan.md` describes the **core scanner** (`scripts/scan_static.py`).
This document describes the **fourteen remaining deliverables** that together
turn the prompt-only `agent-ready-skill` repository into a working, two-hour
workshop kit:

| #  | Deliverable                              | Type      |
|----|------------------------------------------|-----------|
| 1  | `scripts/apply_fix.py`                   | Python script |
| 2  | `scripts/report_gen.py`                  | Python script |
| 3  | `scripts/check_setup.py`                 | Python script |
| 4  | `templates/claude-md-template.md`        | Jinja2 template |
| 5  | `templates/ci-template.yml`              | GitHub Actions workflow |
| 6  | `templates/editorconfig`                 | Static template |
| 7  | `templates/env-example`                  | Static template |
| 8  | `templates/security-md-template.md`      | Markdown template |
| 9  | `templates/contributing-md-template.md`  | Jinja2 template |
| 10 | `templates/pyproject-snippet.toml`       | Static template |
| 11 | `templates/badge.svg.j2`                 | Jinja2 SVG template |
| 12 | `repos/demo-bad/`                        | Reference demo repo |
| 13 | `repos/demo-good/`                       | Reference demo repo |
| 14 | `WORKSHOP.md`                            | Participant guide |
| 15 | `requirements-workshop.txt`              | Pip dependency list |

### 1.2 Target audience

A senior Python engineer (human or AI) who has read **this document plus
spec 05 plus `skills/agent-ready/references/scoring.md`** and is then asked
to implement all fifteen deliverables in three to five working days.

### 1.3 Hand-off context

The agent-ready-skill repository is currently **prompt-only**:

```
agent-ready-skill/
├── CONTRIBUTING.md
├── LICENSE
├── README.md
└── skills/
    ├── agent-ready/
    │   ├── SKILL.md
    │   └── references/scoring.md       ← CANONICAL RUBRIC
    ├── agent-ready-fix/SKILL.md
    ├── agent-ready-scaffold/SKILL.md
    ├── agent-ready-evidence/SKILL.md
    └── agent-readiness-mini-audit/SKILL.md
```

There is no Python code, no templates as standalone files, no demo repos.
All workshop tooling described below is **new**. Existing `skills/*` files
are **read-only** for the duration of this work (see Section 11).

The `skills/agent-ready-fix/SKILL.md` file already contains, embedded inside
its prose, full reference text for: `CLAUDE.md`, `.env.example`, `Makefile`,
`mypy.ini`, `.pre-commit-config.yaml`, `.github/workflows/ci.yml`,
`CODEOWNERS`, `dependabot.yml`, `specs/TEMPLATE.md`,
`.github/ISSUE_TEMPLATE/*`, `docs/adr/0001-*.md`, `ARCHITECTURE.md`, and
`.claude/settings.local.json`. The agent **should mine that file** as the
primary source of truth for template content, while being free to modernize
syntax (e.g., use `actions/setup-python@v5`, Python 3.12).

### 1.4 Canonical scoring weights (restated once)

The scanner uses an **8-dimension canonical rubric** that sums to 100 points,
remapped to **3 visualization axes** that sum to 100%.

**8 dimensions** (from `skills/agent-ready/references/scoring.md`):

| ID | Dimension                       | Weight |
|----|---------------------------------|-------:|
| D1 | Agent Instructions              |    20 |
| D2 | Project Navigability            |    18 |
| D3 | Testing & Validation            |    16 |
| D4 | CI/CD & Automation              |    12 |
| D5 | Spec-Driven Workflow            |    10 |
| D6 | Skills & Tooling                |     8 |
| D7 | Documentation & Comprehension   |     8 |
| D8 | Claude-Specific                 |     8 |
|    | **Total**                       | **100** |

**3-axis remap** (used in the radar chart and badge):

| Axis      | Dimensions   | Weight |
|-----------|--------------|-------:|
| INSTRUCT  | D1 + D5 + D8 |    38 |
| NAVIGATE  | D2 + D7 + D6 |    34 |
| VALIDATE  | D3 + D4      |    28 |
|           | **Total**    | **100** |

**Maturity levels** (overall percentage):

| Level | Name          | Threshold |
|-------|---------------|-----------|
| L1    | Foundational  | ≥ 40 %    |
| L2    | Guided        | ≥ 55 %    |
| L3    | Structured    | ≥ 70 %    |
| L4    | Optimized     | ≥ 85 %    |
| L5    | Autonomous    | ≥ 95 %    |

These thresholds and weights are **frozen** for the workshop. Do not change
them in any deliverable below.

### 1.5 Conventions used in this spec

- Code blocks marked `# REFERENCE` are templates the agent is expected to
  copy, adapt, and improve as needed.
- `acceptance criteria (AC)` are testable behaviors the implementation must
  exhibit; numbered for traceability.
- Paths starting with `agent-ready-skill/` are absolute paths inside the
  target repository.
- All shell commands assume `bash` or `zsh` on macOS/Linux.

---

## 2. `scripts/apply_fix.py` — Automated Fix Generator

### 2.1 Purpose

`apply_fix.py` reads the latest scan results from
`<repo>/.agent-ready/scores.json`, identifies missing artifacts that lowered
the score, and **renders Jinja2 templates** from
`agent-ready-skill/templates/` into the target repository. It is the second
beat of the workshop "scan → fix → re-scan" loop.

### 2.2 Path and dependencies

| Property      | Value                                          |
|---------------|------------------------------------------------|
| Path          | `agent-ready-skill/scripts/apply_fix.py`       |
| Python        | ≥ 3.11                                         |
| Dependencies  | `jinja2 >= 3.1`, `rich >= 13.0` (stdlib otherwise) |
| Approx. lines | 150                                            |

### 2.3 Command-line interface

```text
Usage:
  apply_fix.py [-h] [--list] [--all-fixes] [--dry-run] [--force]
               [--scores PATH] [FIX_NAME] REPO_PATH

Positional:
  FIX_NAME      One of the keys below. Omit when using --list or --all-fixes.
  REPO_PATH     Target repository (where files will be written).

Options:
  --list        Print every available fix and whether the target repo
                already has the destination file. Exit 0.
  --all-fixes   Apply every fix whose destination file does not exist.
  --dry-run     Render templates and print a unified diff to stdout, but
                write nothing.
  --force       Overwrite an existing destination file (default: skip with
                a warning).
  --scores PATH Override the default location of scores.json.
                Default: REPO_PATH/.agent-ready/scores.json

Available fix names:
  agent-instructions    →  CLAUDE.md
  ci-workflow           →  .github/workflows/ci.yml
  editorconfig          →  .editorconfig
  env-example           →  .env.example
  security-md           →  SECURITY.md
  contributing-md       →  CONTRIBUTING.md
  pyproject-snippet     →  appends to pyproject.toml
```

The fix names map **1-to-1** to template filenames in
`agent-ready-skill/templates/` (see Section 5).

### 2.4 Behavioral flow

For a single fix invocation `apply_fix.py FIX_NAME REPO_PATH`:

1. **Load scan output** (if it exists). Read
   `REPO_PATH/.agent-ready/scores.json` to extract the project's detected
   metadata: project name, framework, Python version, has_async,
   has_tests, package layout. If the file is missing, fall back to
   live filesystem detection (read `pyproject.toml`, glob for files);
   if both fail, prompt the user interactively for the project name and
   continue with sensible defaults.
2. **Build template context.** Construct a dict suitable for Jinja2
   rendering. Keys (all strings unless noted):
   - `project_name`
   - `project_slug` (kebab-case)
   - `python_version` (e.g., `"3.12"`)
   - `python_versions_matrix` (list, e.g., `["3.11", "3.12"]`)
   - `framework` (`"fastapi" | "django" | "flask" | "cli" | "library" | "unknown"`)
   - `has_async` (bool)
   - `has_tests` (bool)
   - `package_dir` (e.g., `"src/project_name"` or `"project_name"`)
   - `year` (current year as int)
   - `author_name` (best-effort from `git config user.name`)
   - `security_contact` (best-effort from `git config user.email`,
     else `"security@example.com"`)
3. **Render the template** using a Jinja2 `Environment` rooted at the
   `templates/` directory. Templates without `.j2` suffix are treated as
   plain Jinja2 templates (per the existing project convention).
4. **Resolve destination path.** Each fix knows its target relative path.
   Create parent directories with `Path.mkdir(parents=True, exist_ok=True)`.
5. **Pre-write check.**
   - If destination exists and `--force` is not set, print
     `[skip] {dest} already exists (use --force to overwrite)` and continue.
   - If destination exists and `--force` is set, print a unified diff of
     the proposed change before proceeding.
6. **Confirmation prompt.** Unless `--dry-run`, prompt the user:
   ```
   Write {dest}? [y/N]
   ```
   `y` or `yes` (case-insensitive) writes the file. Anything else skips
   it. Honor `--force` only for overwrite permission, **not** for skipping
   the prompt; the prompt is always shown for safety.
7. **Idempotent write.** Use `Path.write_text(content, encoding="utf-8")`.
   For `pyproject-snippet`, **append** to an existing `pyproject.toml`
   rather than overwriting (idempotency rule: detect existing
   `[tool.ruff]`, `[tool.pytest.ini_options]`, `[tool.mypy]` sections
   and skip those that already exist; only append the missing ones).
8. **Post-write report.** Print a one-line summary per fix:
   ```
   [ok]    CLAUDE.md                  +18 points potential
   [skip]  .editorconfig              already exists
   [diff]  .github/workflows/ci.yml   (dry-run, see stdout)
   ```

For `--all-fixes`, iterate over the fix table in dependency-sensible
order: `editorconfig → env-example → pyproject-snippet → agent-instructions
→ ci-workflow → security-md → contributing-md`.

For `--list`, print a Rich table:

```
┏━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━┳━━━━━━━━━━┓
┃ Fix Name              ┃ Destination                ┃ Exists ┃ Axis     ┃
┡━━━━━━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━━━━━━━━━━╇━━━━━━━━╇━━━━━━━━━━┩
│ agent-instructions    │ CLAUDE.md                  │   ✗    │ INSTRUCT │
│ ci-workflow           │ .github/workflows/ci.yml   │   ✗    │ VALIDATE │
│ editorconfig          │ .editorconfig              │   ✓    │ NAVIGATE │
│ env-example           │ .env.example               │   ✗    │ NAVIGATE │
│ security-md           │ SECURITY.md                │   ✗    │ VALIDATE │
│ contributing-md       │ CONTRIBUTING.md            │   ✗    │ INSTRUCT │
│ pyproject-snippet     │ pyproject.toml (append)    │   ~    │ NAVIGATE │
└───────────────────────┴────────────────────────────┴────────┴──────────┘
```

`~` means the file exists but does not contain the snippet sections.

### 2.5 Reference Python skeleton

```python
# REFERENCE — apply_fix.py
#!/usr/bin/env python3
"""Render agent-readiness templates into a target repository."""
from __future__ import annotations

import argparse
import difflib
import json
import os
import re
import subprocess
import sys
from dataclasses import dataclass
from datetime import date
from pathlib import Path
from typing import Any

from jinja2 import Environment, FileSystemLoader, StrictUndefined
from rich.console import Console
from rich.table import Table

TEMPLATE_DIR = Path(__file__).resolve().parent.parent / "templates"
console = Console()


@dataclass(frozen=True)
class Fix:
    name: str
    template: str           # file in templates/
    destination: str        # relative path inside target repo
    axis: str               # INSTRUCT | NAVIGATE | VALIDATE
    mode: str = "write"     # "write" or "append"


FIXES: list[Fix] = [
    Fix("editorconfig",        "editorconfig",                ".editorconfig",                "NAVIGATE"),
    Fix("env-example",         "env-example",                 ".env.example",                 "NAVIGATE"),
    Fix("pyproject-snippet",   "pyproject-snippet.toml",      "pyproject.toml",               "NAVIGATE", "append"),
    Fix("agent-instructions",  "claude-md-template.md",       "CLAUDE.md",                    "INSTRUCT"),
    Fix("ci-workflow",         "ci-template.yml",             ".github/workflows/ci.yml",     "VALIDATE"),
    Fix("security-md",         "security-md-template.md",     "SECURITY.md",                  "VALIDATE"),
    Fix("contributing-md",     "contributing-md-template.md", "CONTRIBUTING.md",              "INSTRUCT"),
]
FIX_BY_NAME = {f.name: f for f in FIXES}


def detect_context(repo: Path, scores: dict[str, Any] | None) -> dict[str, Any]:
    """Build the Jinja2 rendering context."""
    if scores and "context" in scores:
        ctx = dict(scores["context"])
    else:
        ctx = {}

    ctx.setdefault("project_name", repo.name)
    ctx.setdefault("project_slug", re.sub(r"[^a-z0-9-]+", "-", repo.name.lower()).strip("-"))
    ctx.setdefault("python_version", "3.12")
    ctx.setdefault("python_versions_matrix", ["3.11", "3.12"])
    ctx.setdefault("framework", _detect_framework(repo))
    ctx.setdefault("has_async", _detect_async(repo))
    ctx.setdefault("has_tests", any(repo.glob("tests/**/*.py")))
    ctx.setdefault("package_dir", _detect_package_dir(repo))
    ctx.setdefault("year", date.today().year)
    ctx.setdefault("author_name", _git_config("user.name") or "the team")
    ctx.setdefault("security_contact", _git_config("user.email") or "security@example.com")
    return ctx


def _detect_framework(repo: Path) -> str:
    pyproject = repo / "pyproject.toml"
    if pyproject.exists():
        text = pyproject.read_text(encoding="utf-8", errors="ignore").lower()
        for needle in ("fastapi", "django", "flask"):
            if needle in text:
                return needle
        if "[project.scripts]" in text:
            return "cli"
    return "unknown"


def _detect_async(repo: Path) -> bool:
    for py in repo.rglob("*.py"):
        if any(part.startswith(".") for part in py.parts):
            continue
        try:
            if "async def" in py.read_text(encoding="utf-8", errors="ignore"):
                return True
        except OSError:
            continue
    return False


def _detect_package_dir(repo: Path) -> str:
    for candidate in ("src", repo.name.replace("-", "_")):
        if (repo / candidate).is_dir():
            return candidate
    return "src"


def _git_config(key: str) -> str | None:
    try:
        return subprocess.check_output(
            ["git", "config", "--get", key], text=True, stderr=subprocess.DEVNULL
        ).strip() or None
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None


def load_scores(repo: Path, override: Path | None) -> dict[str, Any] | None:
    path = override or (repo / ".agent-ready" / "scores.json")
    if not path.exists():
        console.print(f"[yellow]No scores.json at {path}; using live detection.[/]")
        return None
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        console.print(f"[red]Could not parse {path}: {exc}[/]")
        return None


def render(fix: Fix, ctx: dict[str, Any]) -> str:
    env = Environment(
        loader=FileSystemLoader(str(TEMPLATE_DIR)),
        undefined=StrictUndefined,
        keep_trailing_newline=True,
    )
    return env.get_template(fix.template).render(**ctx)


def write_with_confirmation(
    dest: Path, content: str, *, mode: str, force: bool, dry_run: bool
) -> str:
    """Return one of: 'ok', 'skip', 'diff', 'append'."""
    if dest.exists() and not force and mode == "write":
        console.print(f"[yellow][skip][/] {dest} already exists (use --force)")
        return "skip"

    existing = dest.read_text(encoding="utf-8") if dest.exists() else ""
    if dry_run:
        diff = "".join(
            difflib.unified_diff(
                existing.splitlines(keepends=True),
                content.splitlines(keepends=True),
                fromfile=str(dest) + " (current)",
                tofile=str(dest) + " (proposed)",
            )
        )
        console.print(diff or f"(no changes for {dest})")
        return "diff"

    answer = input(f"Write {dest}? [y/N] ").strip().lower()
    if answer not in {"y", "yes"}:
        console.print(f"[dim][skip] {dest} (declined)[/]")
        return "skip"

    dest.parent.mkdir(parents=True, exist_ok=True)
    if mode == "append" and dest.exists():
        merged = _merge_pyproject(existing, content)
        dest.write_text(merged, encoding="utf-8")
        return "append"

    dest.write_text(content, encoding="utf-8")
    return "ok"


def _merge_pyproject(existing: str, snippet: str) -> str:
    """Append only sections that are not already present."""
    section_re = re.compile(r"^\[(?P<name>[^]]+)\]\s*$", re.MULTILINE)
    have = {m.group("name") for m in section_re.finditer(existing)}
    blocks: list[str] = []
    current_name: str | None = None
    buffer: list[str] = []

    def flush() -> None:
        if current_name and current_name not in have:
            blocks.append("".join(buffer))

    for line in snippet.splitlines(keepends=True):
        m = section_re.match(line)
        if m:
            flush()
            current_name = m.group("name")
            buffer = [line]
        else:
            buffer.append(line)
    flush()

    if not blocks:
        return existing
    addition = "\n" + "".join(blocks).rstrip() + "\n"
    return existing.rstrip() + "\n" + addition


def cmd_list(repo: Path) -> int:
    table = Table(title=f"Available fixes for {repo}")
    table.add_column("Fix Name")
    table.add_column("Destination")
    table.add_column("Exists", justify="center")
    table.add_column("Axis")
    for f in FIXES:
        dest = repo / f.destination
        exists = "✓" if dest.exists() else "✗"
        if f.mode == "append" and dest.exists():
            exists = "~"
        table.add_row(f.name, f.destination, exists, f.axis)
    console.print(table)
    return 0


def cmd_apply(
    repo: Path, fix_names: list[str], *, dry_run: bool, force: bool, scores_path: Path | None
) -> int:
    scores = load_scores(repo, scores_path)
    ctx = detect_context(repo, scores)
    rc = 0
    for name in fix_names:
        fix = FIX_BY_NAME[name]
        try:
            content = render(fix, ctx)
        except Exception as exc:
            console.print(f"[red][err]  {name}: {exc}[/]")
            rc = 1
            continue
        dest = repo / fix.destination
        status = write_with_confirmation(
            dest, content, mode=fix.mode, force=force, dry_run=dry_run
        )
        if status == "ok":
            console.print(f"[green][ok][/]    {fix.destination}")
        elif status == "append":
            console.print(f"[green][append][/] {fix.destination} (merged new sections)")
    return rc


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("fix", nargs="?", choices=sorted(FIX_BY_NAME))
    parser.add_argument("repo", type=Path)
    parser.add_argument("--list", dest="list_only", action="store_true")
    parser.add_argument("--all-fixes", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--force", action="store_true")
    parser.add_argument("--scores", type=Path)
    args = parser.parse_args(argv)

    repo = args.repo.resolve()
    if not repo.is_dir():
        parser.error(f"{repo} is not a directory")

    if args.list_only:
        return cmd_list(repo)
    if args.all_fixes:
        return cmd_apply(
            repo, [f.name for f in FIXES],
            dry_run=args.dry_run, force=args.force, scores_path=args.scores,
        )
    if not args.fix:
        parser.error("Specify a fix name, --list, or --all-fixes.")
    return cmd_apply(
        repo, [args.fix],
        dry_run=args.dry_run, force=args.force, scores_path=args.scores,
    )


if __name__ == "__main__":
    raise SystemExit(main())
```

### 2.6 Behavioral acceptance criteria

| ID    | Criterion                                                                                                                                                                  |
|-------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| AC-AF-1 | **Never overwrite without an explicit prompt.** With `--force` omitted, an existing destination file results in `[skip]` and exit code 0; the file on disk is byte-identical. |
| AC-AF-2 | **Idempotent.** Running `apply_fix.py agent-instructions REPO` twice in a row (declining the second prompt) leaves `CLAUDE.md` unchanged after the second invocation.       |
| AC-AF-3 | **Prompt-aware project name.** Given a `pyproject.toml` declaring `name = "url-shortener"`, the rendered `CLAUDE.md` contains the string `url-shortener` and not `unknown`. |
| AC-AF-4 | **Dry-run mode.** `--dry-run` emits a unified diff to stdout and writes nothing; subsequent `git status` shows no modified files inside `REPO`.                            |
| AC-AF-5 | **Graceful absence of scan output.** With no `.agent-ready/scores.json` present, the tool prints a yellow warning, falls back to filesystem detection, and still completes successfully (exit 0). |

### 2.7 Executable tests

`tests/test_apply_fix.py` (pytest, six tests):

```python
# REFERENCE — tests/test_apply_fix.py
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
DEMO_BAD = REPO_ROOT / "repos" / "demo-bad"
APPLY_FIX = REPO_ROOT / "scripts" / "apply_fix.py"


def _run(args, **kwargs):
    return subprocess.run(
        [sys.executable, str(APPLY_FIX), *args],
        cwd=REPO_ROOT, capture_output=True, text=True, **kwargs,
    )


def test_list_exits_zero(tmp_path):
    # Copy demo-bad to a temp dir so list reflects pristine state
    target = _copy_demo(tmp_path)
    proc = _run(["--list", str(target)])
    assert proc.returncode == 0
    assert "agent-instructions" in proc.stdout
    assert "CLAUDE.md" in proc.stdout


def test_dry_run_writes_nothing(tmp_path):
    target = _copy_demo(tmp_path)
    snapshot = _hash_dir(target)
    proc = _run(["--dry-run", "agent-instructions", str(target)])
    assert proc.returncode == 0
    assert "+++ " in proc.stdout  # unified diff marker
    assert _hash_dir(target) == snapshot


def test_apply_creates_claude_md(tmp_path):
    target = _copy_demo(tmp_path)
    proc = _run(["agent-instructions", str(target)], input="y\n")
    assert proc.returncode == 0
    assert (target / "CLAUDE.md").is_file()
    body = (target / "CLAUDE.md").read_text()
    assert target.name in body


def test_existing_file_skipped_without_force(tmp_path):
    target = _copy_demo(tmp_path)
    (target / "CLAUDE.md").write_text("# preexisting\n")
    proc = _run(["agent-instructions", str(target)], input="y\n")
    assert proc.returncode == 0
    assert (target / "CLAUDE.md").read_text() == "# preexisting\n"


def test_force_overwrites_after_confirmation(tmp_path):
    target = _copy_demo(tmp_path)
    (target / "CLAUDE.md").write_text("# old\n")
    proc = _run(["--force", "agent-instructions", str(target)], input="y\n")
    assert proc.returncode == 0
    assert (target / "CLAUDE.md").read_text() != "# old\n"


def test_pyproject_snippet_is_idempotent(tmp_path):
    target = _copy_demo(tmp_path)
    (target / "pyproject.toml").write_text('[project]\nname = "x"\n')
    _run(["pyproject-snippet", str(target)], input="y\n")
    first = (target / "pyproject.toml").read_text()
    _run(["pyproject-snippet", str(target)], input="y\n")
    second = (target / "pyproject.toml").read_text()
    assert first == second
```

Helpers `_copy_demo` and `_hash_dir` are simple `shutil.copytree` and
`hashlib`-based utilities defined in `tests/conftest.py`.

---

## 3. `scripts/report_gen.py` — Multi-Format Report Generator

### 3.1 Purpose

Consume a single `scores.json` produced by `scan_static.py` and emit three
artifacts the participant can take home:

1. `report.txt`   — terminal-friendly plain-text summary.
2. `recommendations.md` — prioritized improvement plan in Markdown.
3. `badge.svg`    — Shields.io-style maturity badge for the project README.

### 3.2 Path and dependencies

| Property      | Value                                          |
|---------------|------------------------------------------------|
| Path          | `agent-ready-skill/scripts/report_gen.py`      |
| Python        | ≥ 3.11                                         |
| Dependencies  | `jinja2 >= 3.1`, `rich >= 13.0` (stdlib otherwise) |
| Approx. lines | 120                                            |

### 3.3 Command-line interface

```text
Usage:
  report_gen.py SCORES_JSON --output DIR

Positional:
  SCORES_JSON   Path to scores.json produced by scan_static.py.

Options:
  --output DIR  Output directory. Created if missing. Required.
  --quiet       Suppress progress output (errors still printed).
```

### 3.4 Recommendation prioritization

Each failed or partially-passed check contributes a recommendation. The
priority score is:

```
priority = check.weight * (100 - check.score_pct) / 100
```

where `score_pct = (check.score / check.max_score) * 100`.

Recommendations are sorted by priority **descending**, so the most impactful
gaps come first. Ties are broken by axis order (INSTRUCT before NAVIGATE
before VALIDATE) and then alphabetical check ID.

The Markdown report renders the top N (default: all) as a checklist:

```markdown
- [ ] **CLAUDE.md is missing** *(INSTRUCT, +20 pts)*
      Create `CLAUDE.md` describing your project's purpose, conventions,
      and commands. Run `python scripts/apply_fix.py agent-instructions .`.
```

### 3.5 Badge rendering

The badge is rendered from `templates/badge.svg.j2`. The template receives:

| Variable          | Type   | Example value         |
|-------------------|--------|-----------------------|
| `level`           | int    | `3`                   |
| `level_name`      | str    | `"Structured"`        |
| `percentage`      | float  | `72.4`                |
| `color`           | str    | `"#1976d2"` (blue)    |

Color is chosen by level using the table in Section 5.8.

### 3.6 Reference Python skeleton

```python
# REFERENCE — report_gen.py
#!/usr/bin/env python3
"""Render text/Markdown/SVG reports from a scan_static.py scores.json."""
from __future__ import annotations

import argparse
import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from jinja2 import Environment, FileSystemLoader
from rich.console import Console

TEMPLATE_DIR = Path(__file__).resolve().parent.parent / "templates"
console = Console()

LEVEL_COLOR = {
    1: "#d32f2f",  # red    — Foundational
    2: "#f57c00",  # orange — Guided
    3: "#1976d2",  # blue   — Structured
    4: "#388e3c",  # green  — Optimized
    5: "#7b1fa2",  # purple — Autonomous
}

AXIS_ORDER = ["INSTRUCT", "NAVIGATE", "VALIDATE"]


@dataclass(frozen=True)
class Recommendation:
    check_id: str
    title: str
    axis: str
    weight: int
    score: int
    max_score: int
    advice: str

    @property
    def priority(self) -> float:
        score_pct = (self.score / self.max_score * 100.0) if self.max_score else 0.0
        return self.weight * (100.0 - score_pct) / 100.0

    @property
    def gain(self) -> int:
        return self.max_score - self.score


def collect_recommendations(scores: dict[str, Any]) -> list[Recommendation]:
    recs: list[Recommendation] = []
    for axis_name, axis_data in scores["axes"].items():
        for check in axis_data["checks"]:
            if check["score"] >= check["max_score"]:
                continue
            recs.append(Recommendation(
                check_id=check["id"],
                title=check["name"],
                axis=axis_name.upper(),
                weight=check.get("weight", check["max_score"]),
                score=check["score"],
                max_score=check["max_score"],
                advice=check.get("details", ""),
            ))
    recs.sort(
        key=lambda r: (-r.priority, AXIS_ORDER.index(r.axis), r.check_id)
    )
    return recs


def render_txt(scores: dict[str, Any], recs: list[Recommendation]) -> str:
    overall = scores["overall"]
    lines = [
        "=" * 60,
        f"  AGENT READINESS — {scores['repo_name']}",
        "=" * 60,
        f"  Scanned at : {scores['timestamp']}",
        f"  Maturity   : L{overall['level']} {overall['level_name']}",
        f"  Overall    : {overall['percentage']:.1f}%",
        "",
    ]
    for axis_name in AXIS_ORDER:
        a = scores["axes"][axis_name.lower()]
        bar_len = int(a["percentage"] / 100 * 40)
        bar = "█" * bar_len + "░" * (40 - bar_len)
        lines.append(f"  {axis_name:<9} {bar} {a['percentage']:>5.1f}%")
    lines += ["", "  Top recommendations:", ""]
    for r in recs[:5]:
        lines.append(f"   • [{r.axis}] {r.title} (+{r.gain} pts possible)")
    lines.append("")
    return "\n".join(lines)


def render_markdown(scores: dict[str, Any], recs: list[Recommendation]) -> str:
    overall = scores["overall"]
    md = [
        f"# Agent Readiness Report — `{scores['repo_name']}`",
        "",
        f"- **Scanned:** {scores['timestamp']}",
        f"- **Overall:** {overall['percentage']:.1f}%",
        f"- **Maturity:** L{overall['level']} — {overall['level_name']}",
        "",
        "## Axis breakdown",
        "",
        "| Axis | Score |",
        "|------|-------|",
    ]
    for axis_name in AXIS_ORDER:
        a = scores["axes"][axis_name.lower()]
        md.append(f"| {axis_name} | {a['percentage']:.1f}% |")
    md += ["", "## Prioritized recommendations", ""]
    if not recs:
        md.append("Nothing to do — full score! 🎉")
    for r in recs:
        md.append(
            f"- [ ] **{r.title}** *({r.axis}, +{r.gain} pts)*"
        )
        if r.advice:
            md.append(f"      {r.advice}")
    md.append("")
    return "\n".join(md)


def render_badge(scores: dict[str, Any]) -> str:
    env = Environment(
        loader=FileSystemLoader(str(TEMPLATE_DIR)),
        keep_trailing_newline=True,
    )
    tpl = env.get_template("badge.svg.j2")
    overall = scores["overall"]
    return tpl.render(
        level=overall["level"],
        level_name=overall["level_name"],
        percentage=round(overall["percentage"], 1),
        color=LEVEL_COLOR.get(overall["level"], "#555555"),
    )


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("scores_json", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--quiet", action="store_true")
    args = parser.parse_args(argv)

    scores = json.loads(args.scores_json.read_text(encoding="utf-8"))
    recs = collect_recommendations(scores)

    args.output.mkdir(parents=True, exist_ok=True)
    (args.output / "report.txt").write_text(render_txt(scores, recs), encoding="utf-8")
    (args.output / "recommendations.md").write_text(render_markdown(scores, recs), encoding="utf-8")
    (args.output / "badge.svg").write_text(render_badge(scores), encoding="utf-8")

    if not args.quiet:
        console.print(f"[green]Wrote 3 artifacts to {args.output}[/]")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
```

### 3.7 Behavioral acceptance criteria

| ID      | Criterion                                                                                              |
|---------|--------------------------------------------------------------------------------------------------------|
| AC-RG-1 | Given a valid `scores.json`, all three files appear in `--output` directory after a successful run.    |
| AC-RG-2 | `recommendations.md` lists items sorted by `weight × (100 − score_pct) / 100` descending.              |
| AC-RG-3 | `badge.svg` validates as well-formed XML (`xml.etree.ElementTree.fromstring` parses without error).    |
| AC-RG-4 | A perfect score (100%) produces a `recommendations.md` containing the literal `Nothing to do` phrase.  |

### 3.8 Executable tests

`tests/test_report_gen.py`:

```python
# REFERENCE — tests/test_report_gen.py
import json
import subprocess
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
REPORT_GEN = REPO_ROOT / "scripts" / "report_gen.py"


def _scores(tmp_path: Path, *, overall_pct: float, level: int) -> Path:
    payload = {
        "repo_name": "fixture",
        "timestamp": "2026-01-01T00:00:00",
        "axes": {
            "instruct": {"percentage": overall_pct, "checks": []},
            "navigate": {"percentage": overall_pct, "checks": []},
            "validate": {"percentage": overall_pct, "checks": []},
        },
        "overall": {
            "percentage": overall_pct,
            "level": level,
            "level_name": "Structured",
        },
    }
    out = tmp_path / "scores.json"
    out.write_text(json.dumps(payload))
    return out


def test_all_three_files_written(tmp_path):
    scores = _scores(tmp_path, overall_pct=70.0, level=3)
    out = tmp_path / "out"
    subprocess.run(
        [sys.executable, str(REPORT_GEN), str(scores), "--output", str(out)],
        check=True,
    )
    assert (out / "report.txt").is_file()
    assert (out / "recommendations.md").is_file()
    assert (out / "badge.svg").is_file()


def test_badge_is_valid_xml(tmp_path):
    scores = _scores(tmp_path, overall_pct=72.4, level=3)
    out = tmp_path / "out"
    subprocess.run(
        [sys.executable, str(REPORT_GEN), str(scores), "--output", str(out)],
        check=True,
    )
    ET.fromstring((out / "badge.svg").read_text())


def test_perfect_score_says_nothing_to_do(tmp_path):
    scores = _scores(tmp_path, overall_pct=100.0, level=5)
    out = tmp_path / "out"
    subprocess.run(
        [sys.executable, str(REPORT_GEN), str(scores), "--output", str(out)],
        check=True,
    )
    assert "Nothing to do" in (out / "recommendations.md").read_text()


def test_recommendations_sorted_by_priority(tmp_path):
    # Build a scores.json with two failing checks: one heavy, one light.
    payload = {
        "repo_name": "fixture",
        "timestamp": "2026-01-01T00:00:00",
        "axes": {
            "instruct": {"percentage": 0, "checks": [
                {"id": "low", "name": "Low weight", "axis": "INSTRUCT",
                 "weight": 2, "score": 0, "max_score": 2, "details": ""},
                {"id": "high", "name": "High weight", "axis": "INSTRUCT",
                 "weight": 20, "score": 0, "max_score": 20, "details": ""},
            ]},
            "navigate": {"percentage": 100, "checks": []},
            "validate": {"percentage": 100, "checks": []},
        },
        "overall": {"percentage": 50, "level": 2, "level_name": "Guided"},
    }
    scores = tmp_path / "scores.json"
    scores.write_text(json.dumps(payload))
    out = tmp_path / "out"
    subprocess.run(
        [sys.executable, str(REPORT_GEN), str(scores), "--output", str(out)],
        check=True,
    )
    text = (out / "recommendations.md").read_text()
    assert text.index("High weight") < text.index("Low weight")
```

---

## 4. `scripts/check_setup.py` — Pre-Workshop Environment Check

### 4.1 Purpose

Run by participants **before** the workshop starts. Verifies the laptop is
ready, prints a green checklist if so, or a red checklist with remediation
hints if not. Mirrors a familiar "doctor" command UX (compare with
`brew doctor`, `flutter doctor`).

### 4.2 Path and dependencies

| Property      | Value                                       |
|---------------|---------------------------------------------|
| Path          | `agent-ready-skill/scripts/check_setup.py`  |
| Python        | ≥ 3.11                                      |
| Dependencies  | stdlib only (must run even before `pip install -r requirements-workshop.txt`) |
| Approx. lines | 40 (excluding constants)                    |

### 4.3 What it verifies

| Check                                                     | Required          |
|-----------------------------------------------------------|-------------------|
| Python interpreter version ≥ 3.11                         | yes               |
| `rich` importable                                         | yes               |
| `pyyaml` importable                                       | yes               |
| `jinja2` importable                                       | yes               |
| `git` available on `PATH`                                 | yes               |
| Sibling file `scripts/scan_static.py` exists              | yes               |
| Sibling file `scripts/apply_fix.py` exists                | yes               |

Exit code `0` if **all** required checks pass; `1` otherwise.

### 4.4 Reference Python skeleton

```python
# REFERENCE — check_setup.py
#!/usr/bin/env python3
"""Pre-workshop environment check for agent-ready-skill."""
from __future__ import annotations

import importlib
import shutil
import sys
from pathlib import Path

CHECKS = [
    ("python>=3.11", lambda: sys.version_info >= (3, 11), "Install Python 3.11 or later."),
    ("import rich",   lambda: importlib.import_module("rich"),   "pip install rich"),
    ("import yaml",   lambda: importlib.import_module("yaml"),   "pip install pyyaml"),
    ("import jinja2", lambda: importlib.import_module("jinja2"), "pip install jinja2"),
    ("git on PATH",   lambda: bool(shutil.which("git")),         "Install git: https://git-scm.com"),
]
SIBLINGS = ["scan_static.py", "apply_fix.py"]


def main() -> int:
    here = Path(__file__).resolve().parent
    print("Agent Readiness — environment check\n")
    ok = True
    for label, check, hint in CHECKS:
        try:
            result = check()
        except Exception:
            result = False
        symbol = "✓" if result else "✗"
        print(f"  [{symbol}] {label}")
        if not result:
            print(f"        → {hint}")
            ok = False
    for sibling in SIBLINGS:
        present = (here / sibling).is_file()
        symbol = "✓" if present else "✗"
        print(f"  [{symbol}] scripts/{sibling}")
        if not present:
            print(f"        → Make sure you cloned the full repo (missing: {sibling})")
            ok = False
    print()
    if ok:
        print("All checks passed. You are ready for the workshop.")
        return 0
    print("Some checks failed. Fix the issues above and rerun.")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
```

### 4.5 Behavioral acceptance criteria

| ID      | Criterion                                                                                                |
|---------|----------------------------------------------------------------------------------------------------------|
| AC-CS-1 | Exit code 0 in a clean virtualenv where `pip install -r requirements-workshop.txt` has just succeeded.    |
| AC-CS-2 | Exit code 1 and a non-empty stderr/stdout listing of failed checks when any dependency is missing.       |
| AC-CS-3 | Runs successfully with stdlib only (so participants whose deps install fails still get useful output).   |

### 4.6 Executable test

```python
# REFERENCE — tests/test_check_setup.py
import subprocess
import sys
from pathlib import Path

CHECK = Path(__file__).resolve().parents[1] / "scripts" / "check_setup.py"


def test_check_setup_exits_zero_in_workshop_env():
    proc = subprocess.run(
        [sys.executable, str(CHECK)], capture_output=True, text=True
    )
    assert proc.returncode == 0, proc.stdout + proc.stderr
    assert "All checks passed" in proc.stdout
```

---

## 5. Template Files Specification

All eight templates live in `agent-ready-skill/templates/`. Templates use
Jinja2 syntax `{{ variable }}` where dynamic substitution is needed; static
templates contain no Jinja markers. Filenames are listed without leading
dots to keep them visible in tooling — `apply_fix.py` is responsible for
renaming on write.

### 5.1 `templates/claude-md-template.md`

- **Path**: `agent-ready-skill/templates/claude-md-template.md`
- **Used by**: `apply_fix.py agent-instructions` → writes `CLAUDE.md` at
  the target repo root.
- **Variables**:

  | Name                       | Type         | Example                |
  |----------------------------|--------------|------------------------|
  | `project_name`             | str          | `url-shortener`        |
  | `framework`                | str          | `fastapi`              |
  | `python_version`           | str          | `3.12`                 |
  | `has_async`                | bool         | `true`                 |
  | `has_tests`                | bool         | `true`                 |
  | `package_dir`              | str          | `src/url_shortener`    |

- **Full content**:

```markdown
# CLAUDE.md — Agent Instructions for `{{ project_name }}`

> This file orients AI coding agents (Claude Code, Cursor, Codex, etc.)
> to this codebase. Keep it short. Update it when conventions change.

## 1. What this project is

<!-- 1–3 sentences. What problem does this codebase solve? Who uses it? -->

- **Framework**: {{ framework }}
- **Python**: {{ python_version }}
{% if has_async %}- **Concurrency**: async (asyncio){% endif %}

## 2. Where things live

```
{{ package_dir }}/        application source
tests/                    pytest test suite
docs/                     human-facing documentation
scripts/                  one-off operational scripts
```

If you cannot find something, run `rg` from the repo root. Do not add new
top-level directories without updating this section.

## 3. How to run, test, and lint

```bash
# Install
pip install -e ".[dev]"

# Run the test suite
pytest

# Lint and auto-fix
ruff check . --fix
ruff format .

# Type-check
mypy {{ package_dir }}
```

## 4. Conventions

- **Imports**: absolute, ordered by `isort` defaults (stdlib → third-party → local).
- **Strings**: double quotes (`"like this"`).
- **Type hints**: required on all public functions and methods.
- **Docstrings**: Google style. One-liner for trivial helpers.
- **Naming**: `snake_case` for functions/variables, `PascalCase` for classes,
  `SCREAMING_SNAKE` for module-level constants.
{% if has_async %}- **Async**: never call blocking I/O inside `async def`. Use `asyncio.to_thread`.{% endif %}

## 5. Pitfalls — things to avoid

- ❌ Do not commit secrets. Use `.env` (gitignored); update `.env.example`
  when you add a new variable.
- ❌ Do not introduce new dependencies without updating `pyproject.toml`.
- ❌ Do not use `print()` for logs. Use `logging.getLogger(__name__)`.
- ❌ Do not skip tests with `xfail` to make CI green; fix the underlying bug.

## 6. Spec-driven workflow

Larger changes start with a written spec in `docs/specs/` and an ADR in
`docs/adr/`. When asked to implement a feature, first look for the
corresponding spec; if none exists, propose one before writing code.

## 7. When the agent is stuck

If you have read this file and still cannot proceed:

1. Run `git log --oneline -- {{ package_dir }} | head -20` for recent context.
2. Read the closest `README.md` in the directory you are working in.
3. Ask the human a clarifying question; do **not** guess.

<!-- Last updated: keep this date current when editing this file. -->
```

- **Successful application looks like**: `CLAUDE.md` exists at the repo
  root, every `{{ … }}` placeholder is resolved (no `{{` characters
  remain), and rescanning gives full credit on the `agent_instructions`
  check (+20 points in the INSTRUCT axis).

### 5.2 `templates/ci-template.yml`

- **Path**: `agent-ready-skill/templates/ci-template.yml`
- **Used by**: `apply_fix.py ci-workflow` → writes
  `.github/workflows/ci.yml`.
- **Variables**:

  | Name                       | Type         | Example          |
  |----------------------------|--------------|------------------|
  | `project_name`             | str          | `url-shortener`  |
  | `python_versions_matrix`   | list[str]    | `["3.11", "3.12"]` |
  | `package_dir`              | str          | `src`            |

- **Full content**:

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

permissions:
  contents: read

concurrency:
  group: ${{ '{{' }} github.workflow {{ '}}' }}-${{ '{{' }} github.ref {{ '}}' }}
  cancel-in-progress: true

jobs:
  test:
    name: test (py${{ '{{' }} matrix.python-version {{ '}}' }})
    runs-on: ubuntu-latest
    timeout-minutes: 15
    strategy:
      fail-fast: false
      matrix:
        python-version: {{ python_versions_matrix | tojson }}

    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ '{{' }} matrix.python-version {{ '}}' }}
          cache: pip
          cache-dependency-path: pyproject.toml

      - name: Install
        run: |
          python -m pip install --upgrade pip
          pip install -e ".[dev]"

      - name: Lint
        run: ruff check .

      - name: Format check
        run: ruff format --check .

      - name: Type check
        run: mypy {{ package_dir }}

      - name: Tests
        run: pytest --cov={{ package_dir }} --cov-report=xml --cov-report=term

      - name: Upload coverage
        if: matrix.python-version == '{{ python_versions_matrix[-1] }}'
        uses: actions/upload-artifact@v4
        with:
          name: coverage-xml
          path: coverage.xml
          if-no-files-found: ignore
```

Note: the `${{ '{{' }} … {{ '}}' }}` escaping renders to literal
`${{ … }}` for GitHub Actions while keeping the file valid Jinja2.

- **Successful application looks like**: rescanning gives full credit on
  the `ci_configured` check (CI runs lint, format, mypy, and pytest).

### 5.3 `templates/editorconfig`

- **Path**: `agent-ready-skill/templates/editorconfig`
- **Used by**: `apply_fix.py editorconfig` → writes `.editorconfig`.
- **Variables**: none (static template).
- **Full content**:

```ini
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

[*.{yml,yaml,json,toml}]
indent_size = 2

[Makefile]
indent_style = tab

[*.{md,rst}]
trim_trailing_whitespace = false
```

- **Successful application looks like**: rescanning gives full credit on
  the `editorconfig` check (+2 points).

### 5.4 `templates/env-example`

- **Path**: `agent-ready-skill/templates/env-example`
- **Used by**: `apply_fix.py env-example` → writes `.env.example`.
- **Variables**: `project_name`.
- **Full content**:

```bash
# .env.example — committed to git. Copy to `.env` and fill in real values.
# Never commit your real .env file.

# --- Application ---
APP_NAME={{ project_name }}
APP_ENV=development
LOG_LEVEL=INFO
DEBUG=false

# --- Database ---
# Postgres example:
# DATABASE_URL=postgresql+psycopg://user:password@localhost:5432/{{ project_name }}
# SQLite (dev):
DATABASE_URL=sqlite:///./{{ project_name }}.db

# --- Secrets ---
# SECRET_KEY=replace-with-a-long-random-string

# --- External services (uncomment as needed) ---
# OPENAI_API_KEY=
# ANTHROPIC_API_KEY=
# SENTRY_DSN=
```

- **Successful application looks like**: rescanning gives full credit on
  the `env_documentation` check (+4 points).

### 5.5 `templates/security-md-template.md`

- **Path**: `agent-ready-skill/templates/security-md-template.md`
- **Used by**: `apply_fix.py security-md` → writes `SECURITY.md`.
- **Variables**:

  | Name                | Type | Example                 |
  |---------------------|------|-------------------------|
  | `project_name`      | str  | `url-shortener`         |
  | `security_contact`  | str  | `security@example.com`  |

- **Full content**:

```markdown
# Security Policy for {{ project_name }}

## Supported versions

| Version | Supported          |
|---------|--------------------|
| latest  | :white_check_mark: |
| older   | :x:                |

## Reporting a vulnerability

If you believe you have found a security vulnerability in {{ project_name }},
please **do not open a public issue**. Instead:

1. Email <{{ security_contact }}> with the subject line
   `SECURITY: {{ project_name }} — <short description>`.
2. Include:
   - A description of the issue and its impact.
   - Steps to reproduce (proof of concept if possible).
   - Affected versions or commit hashes.
   - Suggested remediation, if you have one.
3. You will receive an acknowledgement within **2 business days** and a
   resolution timeline within **7 business days**.

## Disclosure policy

We follow coordinated disclosure. We will work with you on a fix and
publication date, credit you in the changelog (unless you prefer to remain
anonymous), and request a CVE when appropriate.

## Dependency monitoring

This project uses automated dependency updates via Dependabot. Critical
advisories are triaged the same day; non-critical advisories on the next
maintenance window.
```

- **Successful application looks like**: rescanning gives full credit on
  the `security_policy` check (+2 points).

### 5.6 `templates/contributing-md-template.md`

- **Path**: `agent-ready-skill/templates/contributing-md-template.md`
- **Used by**: `apply_fix.py contributing-md` → writes `CONTRIBUTING.md`.
- **Variables**:

  | Name                | Type | Example                 |
  |---------------------|------|-------------------------|
  | `project_name`      | str  | `url-shortener`         |
  | `package_dir`       | str  | `src/url_shortener`     |
  | `python_version`    | str  | `3.12`                  |

- **Full content**:

```markdown
# Contributing to {{ project_name }}

Thanks for taking the time to contribute! This document explains the
day-to-day workflow.

## 1. Local setup

You need Python {{ python_version }} or newer.

```bash
git clone <your-fork-url>
cd {{ project_name }}
python -m venv .venv
source .venv/bin/activate
pip install -e ".[dev]"
pre-commit install
```

## 2. Running checks

| Task          | Command                                  |
|---------------|------------------------------------------|
| Tests         | `pytest`                                 |
| Coverage      | `pytest --cov={{ package_dir }}`         |
| Lint          | `ruff check .`                           |
| Format        | `ruff format .`                          |
| Type-check    | `mypy {{ package_dir }}`                 |
| All of above  | `pre-commit run --all-files && pytest`   |

## 3. Branching and commits

- Branch from `main` using a topic name: `feat/short-summary`,
  `fix/short-summary`, `docs/short-summary`.
- Write commit messages in the imperative mood
  (`add caching to resolver`, not `added caching`).
- Reference issues in the body (`Refs #42`, `Closes #42`).

## 4. Pull requests

Open a PR against `main`. CI must be green before review. Please:

- Keep PRs small. Aim for less than 400 lines of diff.
- Include or update tests.
- Update `CHANGELOG.md` (if present).
- If the change affects user-visible behavior, update the README.

## 5. Code review

Reviewers will look for:

- Tests that cover the new behavior (happy path **and** at least one edge).
- No public API changes without an entry in `docs/adr/` or `docs/specs/`.
- Conventions documented in `CLAUDE.md` are respected.

## 6. Releasing

Maintainers tag releases with `vX.Y.Z` following semver. CI builds and
publishes artifacts.
```

- **Successful application looks like**: rescanning gives full credit on
  the `contributing_guide` check (+5 points).

### 5.7 `templates/pyproject-snippet.toml`

- **Path**: `agent-ready-skill/templates/pyproject-snippet.toml`
- **Used by**: `apply_fix.py pyproject-snippet` → **appends** missing
  sections to the target `pyproject.toml`.
- **Variables**: `package_dir`, `python_version`.
- **Full content**:

```toml
# === Begin agent-ready snippet ===
# Add these sections to your pyproject.toml. apply_fix.py will only
# append sections that are not already present.

[tool.ruff]
target-version = "py{{ python_version | replace('.', '') }}"
line-length = 120
src = ["{{ package_dir }}"]

[tool.ruff.lint]
select = [
    "E", "W",   # pycodestyle
    "F",        # pyflakes
    "I",        # isort
    "N",        # pep8-naming
    "UP",       # pyupgrade
    "B",        # bugbear
    "SIM",      # simplify
    "TCH",      # type-checking imports
]
ignore = ["E501"]

[tool.ruff.format]
quote-style = "double"
indent-style = "space"

[tool.pytest.ini_options]
minversion = "7.0"
testpaths = ["tests"]
python_files = ["test_*.py", "*_test.py"]
addopts = [
    "-ra",
    "--strict-markers",
    "--strict-config",
    "--tb=short",
]
filterwarnings = ["error::DeprecationWarning"]

[tool.mypy]
python_version = "{{ python_version }}"
strict = true
warn_unused_ignores = true
warn_return_any = true
disallow_untyped_defs = true
show_error_codes = true
files = ["{{ package_dir }}"]

[tool.coverage.run]
branch = true
source = ["{{ package_dir }}"]

[tool.coverage.report]
fail_under = 70
show_missing = true
skip_covered = true
exclude_lines = ["pragma: no cover", "if TYPE_CHECKING:", "raise NotImplementedError"]
# === End agent-ready snippet ===
```

- **Successful application looks like**: rescanning gives full credit on
  `linter_configured`, `formatter_configured`, `type_checker`,
  `test_framework`, and `coverage_configured` checks (cumulative +28
  points across NAVIGATE and VALIDATE).

### 5.8 `templates/badge.svg.j2`

- **Path**: `agent-ready-skill/templates/badge.svg.j2`
- **Used by**: `report_gen.py` → writes `badge.svg`.
- **Variables**:

  | Name          | Type   | Example       |
  |---------------|--------|---------------|
  | `level`       | int    | `3`           |
  | `level_name`  | str    | `Structured`  |
  | `percentage`  | float  | `72.4`        |
  | `color`       | str    | `#1976d2`     |

- **Full content**:

```svg
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="200" height="20" role="img"
     aria-label="agent-ready: L{{ level }} {{ level_name }} {{ percentage }}%">
  <title>agent-ready: L{{ level }} {{ level_name }} {{ percentage }}%</title>
  <linearGradient id="g" x2="0" y2="100%">
    <stop offset="0" stop-color="#bbb" stop-opacity=".1"/>
    <stop offset="1" stop-opacity=".1"/>
  </linearGradient>
  <clipPath id="r"><rect width="200" height="20" rx="3" fill="#fff"/></clipPath>
  <g clip-path="url(#r)">
    <rect width="80" height="20" fill="#555"/>
    <rect x="80" width="120" height="20" fill="{{ color }}"/>
    <rect width="200" height="20" fill="url(#g)"/>
  </g>
  <g fill="#fff" text-anchor="middle"
     font-family="Verdana,Geneva,DejaVu Sans,sans-serif" font-size="11">
    <text x="40" y="14">agent-ready</text>
    <text x="140" y="14">L{{ level }} · {{ percentage }}%</text>
  </g>
</svg>
```

- **Successful application looks like**: the SVG renders in GitHub's
  markdown viewer and in `<img>` tags, with the configured color and
  level/percentage visible.

---

## 6. Demo Repositories

The workshop ships two reference repositories that participants can scan
when they prefer not to use their own code, and that the test suite uses
as fixtures.

> **Construction principle (per user direction): skeleton + key files
> only.** Specify the few files that *drive the score* in full detail,
> and describe the rest by name + one-line purpose. Do not invent every
> filler file; the demo repos are pedagogical artifacts, not production
> applications.

### 6.1 `repos/demo-bad/`

- **Target overall score**: 20 – 30 % (Level 1: Foundational).
- **Theme**: a single-file script that "works" but signals nothing to
  agents. The repo intentionally lacks structure.

**Directory layout**:

```
repos/demo-bad/
├── README.md
├── main.py
└── requirements.txt
```

**`repos/demo-bad/README.md`** (full content):

```markdown
# notes app

run main.py to start.
```

**`repos/demo-bad/main.py`** (full content):

```python
import json, os, sys
from datetime import datetime

NOTES = "notes.json"

def load():
    if not os.path.exists(NOTES):
        return []
    with open(NOTES) as f:
        return json.load(f)

def save(data):
    with open(NOTES, "w") as f:
        json.dump(data, f)

def add(text):
    items = load()
    items.append({"t": text, "at": str(datetime.now())})
    save(items)
    print("ok")

def list_all():
    for i, n in enumerate(load()):
        print(i, n["at"], n["t"])

def delete(i):
    items = load()
    del items[int(i)]
    save(items)

if __name__ == "__main__":
    cmd = sys.argv[1]
    if cmd == "add":
        add(" ".join(sys.argv[2:]))
    elif cmd == "list":
        list_all()
    elif cmd == "del":
        delete(sys.argv[2])
    else:
        print("?")
```

**`repos/demo-bad/requirements.txt`** (full content):

```text
requests
click
```

(No version pins on purpose — this is what triggers the lock-file check
to fail and the version-pinning check to fail.)

**Explicitly missing files**, and which check they fail:

| Missing file/dir                  | Check that fails       | Lost points |
|-----------------------------------|------------------------|------------:|
| `CLAUDE.md` / `.cursorrules`      | `agent_instructions`   | -20         |
| `tests/`                          | `test_files_exist`     | -5          |
| `pytest.ini` / `[tool.pytest]`    | `test_framework`       | -6          |
| `.github/workflows/*.yml`         | `ci_configured`        | -6          |
| `ARCHITECTURE.md` / `docs/adr/`   | `architecture_docs`    | -10         |
| `.editorconfig`                   | `editorconfig`         | -2          |
| `pyproject.toml`                  | `linter_configured`, `formatter_configured`, `type_checker` | -18 |
| `.env.example`                    | `env_documentation`    | -4          |
| `CONTRIBUTING.md`                 | `contributing_guide`   | -5          |
| `SECURITY.md`                     | `security_policy`      | -2          |
| `.pre-commit-config.yaml`         | `pre_commit`           | -3          |
| `.github/dependabot.yml`          | `dependency_update_automation` | -2  |

`README.md` exists but is too short to earn full credit on
`readme_quality` (length < 200 chars, no sections, no code blocks);
expected score 0–2 out of 8.

### 6.2 `repos/demo-good/`

- **Target overall score**: 80 – 90 % (Level 4: Optimized).
- **Theme**: a tiny URL shortener CLI/library, fully agent-ready.

**Directory layout**:

```
repos/demo-good/
├── .editorconfig
├── .env.example
├── .github/
│   ├── dependabot.yml
│   └── workflows/
│       └── ci.yml
├── .gitignore
├── .pre-commit-config.yaml
├── .python-version
├── ARCHITECTURE.md
├── CLAUDE.md
├── CONTRIBUTING.md
├── README.md
├── SECURITY.md
├── pyproject.toml
├── src/
│   └── url_shortener/
│       ├── __init__.py
│       ├── cli.py
│       ├── models.py
│       └── service.py
└── tests/
    ├── __init__.py
    ├── test_models.py
    └── test_service.py
```

**Source files in `src/url_shortener/`** (one-line purpose each):

| File             | Purpose                                                                  |
|------------------|--------------------------------------------------------------------------|
| `__init__.py`    | Package marker. Exposes `__version__ = "0.1.0"` and re-exports `Shortener`. |
| `models.py`      | `@dataclass(frozen=True) class ShortLink` with `id`, `url`, `created_at`. |
| `service.py`     | `class Shortener` with `shorten(url) -> ShortLink` and `resolve(id) -> str | None`. Uses an in-memory dict; deterministic IDs via base62 hash. |
| `cli.py`         | `typer.Typer` app with `shorten` and `resolve` commands; `main()` entry point referenced from `pyproject.toml [project.scripts]`. |

These files should be written cleanly — type hints everywhere, docstrings
on public functions — but their exact text is not specified here; the
implementer should produce idiomatic code. They exist so that the
scanner's "no large files", "test_files_exist", and "test_framework"
checks all pass.

**Key files specified in full**:

**`repos/demo-good/README.md`**:

```markdown
# url-shortener

A tiny, type-checked URL shortener used as a "good repo" demo for the
PyCon Italia 2026 *Agent Readiness* workshop.

## Quick Start

```bash
python -m venv .venv && source .venv/bin/activate
pip install -e ".[dev]"
url-shortener shorten "https://example.com/very/long/url"
url-shortener resolve <id>
```

## Architecture

`src/url_shortener/` is split into three layers:

- `models.py` — frozen dataclasses (no I/O).
- `service.py` — `Shortener` class with deterministic short IDs.
- `cli.py` — Typer CLI built on top of the service.

See [ARCHITECTURE.md](./ARCHITECTURE.md) for details and ADRs.

## Commands

```bash
pytest                          # tests
ruff check . && ruff format .   # lint + format
mypy src/url_shortener          # type check
pre-commit run --all-files      # everything pre-commit knows about
```

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md). Bug reports and PRs welcome.

## License

MIT.
```

**`repos/demo-good/CLAUDE.md`** (filled-in version of the template from §5.1):

```markdown
# CLAUDE.md — Agent Instructions for `url-shortener`

> This file orients AI coding agents (Claude Code, Cursor, Codex, etc.)
> to this codebase. Keep it short. Update it when conventions change.

## 1. What this project is

`url-shortener` is a minimal in-process URL shortener used as a
"good repo" demonstration for the PyCon Italia 2026 workshop on agent
readiness. It is not production-ready; it stores data in memory.

- **Framework**: cli (Typer)
- **Python**: 3.12

## 2. Where things live

```
src/url_shortener/        application source
tests/                    pytest test suite
docs/                     human-facing documentation (ADRs)
```

## 3. How to run, test, and lint

```bash
pip install -e ".[dev]"
pytest
ruff check . --fix
ruff format .
mypy src/url_shortener
```

## 4. Conventions

- Absolute imports.
- Double-quoted strings.
- Type hints required on all public functions.
- Google-style docstrings.
- `snake_case`/`PascalCase`/`SCREAMING_SNAKE` per PEP 8.

## 5. Pitfalls

- Do not introduce a database without an ADR first.
- Do not change short-ID generation; existing IDs must remain stable
  (see `docs/adr/0001-short-id-algorithm.md`).
- Do not use `print()` for logs; use `logging`.

## 6. Spec-driven workflow

Large changes start in `docs/specs/` and are accepted via an ADR in
`docs/adr/`.

## 7. When the agent is stuck

1. Read this file.
2. Read the closest `README.md`.
3. Ask the human a clarifying question; do not guess.
```

**`repos/demo-good/pyproject.toml`**:

```toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "url-shortener"
version = "0.1.0"
description = "A tiny URL shortener — agent-readiness demo."
readme = "README.md"
requires-python = ">=3.11"
license = { text = "MIT" }
authors = [{ name = "Workshop" }]
dependencies = [
    "typer>=0.12",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.0",
    "pytest-cov>=5.0",
    "ruff>=0.4",
    "mypy>=1.10",
    "pre-commit>=3.7",
]

[project.scripts]
url-shortener = "url_shortener.cli:main"

[tool.hatch.build.targets.wheel]
packages = ["src/url_shortener"]

[tool.ruff]
target-version = "py312"
line-length = 120
src = ["src"]

[tool.ruff.lint]
select = ["E", "W", "F", "I", "N", "UP", "B", "SIM", "TCH"]
ignore = ["E501"]

[tool.ruff.format]
quote-style = "double"
indent-style = "space"

[tool.pytest.ini_options]
minversion = "7.0"
testpaths = ["tests"]
addopts = ["-ra", "--strict-markers", "--strict-config", "--tb=short"]

[tool.mypy]
python_version = "3.12"
strict = true
files = ["src/url_shortener"]

[tool.coverage.run]
branch = true
source = ["src/url_shortener"]

[tool.coverage.report]
fail_under = 80
show_missing = true
```

**`repos/demo-good/.github/workflows/ci.yml`**:

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

permissions:
  contents: read

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  test:
    name: test (py${{ matrix.python-version }})
    runs-on: ubuntu-latest
    timeout-minutes: 15
    strategy:
      fail-fast: false
      matrix:
        python-version: ["3.11", "3.12"]

    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
          cache: pip
          cache-dependency-path: pyproject.toml

      - name: Install
        run: |
          python -m pip install --upgrade pip
          pip install -e ".[dev]"

      - name: Lint
        run: ruff check .

      - name: Format check
        run: ruff format --check .

      - name: Type check
        run: mypy src/url_shortener

      - name: Tests
        run: pytest --cov=src/url_shortener --cov-report=term
```

**`repos/demo-good/.editorconfig`**: identical content to §5.3.

**`repos/demo-good/.env.example`**:

```bash
APP_NAME=url-shortener
APP_ENV=development
LOG_LEVEL=INFO
DEBUG=false

# In-memory storage uses no DATABASE_URL by default.
# To switch to a SQLite backend in the future:
# DATABASE_URL=sqlite:///./url-shortener.db
```

**`repos/demo-good/tests/test_main.py`**:

```python
"""Smoke tests for the url-shortener demo."""
from __future__ import annotations

import pytest

from url_shortener.models import ShortLink
from url_shortener.service import Shortener


def test_shorten_returns_stable_id() -> None:
    s = Shortener()
    a = s.shorten("https://example.com/foo")
    b = s.shorten("https://example.com/foo")
    assert isinstance(a, ShortLink)
    assert a.id == b.id, "Short IDs must be deterministic per URL."


def test_resolve_returns_original_url() -> None:
    s = Shortener()
    link = s.shorten("https://example.com/bar")
    assert s.resolve(link.id) == "https://example.com/bar"


def test_resolve_unknown_id_returns_none() -> None:
    s = Shortener()
    assert s.resolve("not-an-id") is None


def test_short_id_is_url_safe() -> None:
    s = Shortener()
    link = s.shorten("https://example.com/x?y=1&z=2")
    assert link.id.isalnum(), "Short IDs must be URL-safe."


@pytest.mark.parametrize("url", ["", "   ", "not a url"])
def test_shorten_rejects_obviously_invalid(url: str) -> None:
    s = Shortener()
    with pytest.raises(ValueError):
        s.shorten(url)
```

**`repos/demo-good/ARCHITECTURE.md`**:

```markdown
# Architecture

## Overview

`url-shortener` is a single-process, in-memory URL shortener. It is
deliberately tiny — its purpose is to act as a "good repo" reference for
the agent-readiness workshop.

```
┌──────────┐      ┌────────────┐      ┌────────────┐
│  cli.py  │ ───▶ │ service.py │ ───▶ │ models.py  │
└──────────┘      └────────────┘      └────────────┘
   (Typer)         (Shortener)        (ShortLink)
```

## Decisions

### ADR 0001 — Deterministic short IDs

We compute the short ID as base62 of the first 5 bytes of `sha256(url)`.
This makes the same URL always map to the same short ID across runs, which
keeps tests stable and makes the in-memory store predictable. The trade-off
is that we cannot enumerate or revoke IDs without a backing store; this is
acceptable for a demo.

### ADR 0002 — No database

The demo intentionally has no database. Adding one would obscure the
agent-readiness signals we want to demonstrate (CI, lint, types, tests).
A future revision could plug a `Repository` protocol behind `Shortener`.
```

**`repos/demo-good/.pre-commit-config.yaml`**:

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.6.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-toml
      - id: check-merge-conflict

  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.4.10
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.10.0
    hooks:
      - id: mypy
        files: ^src/
        additional_dependencies: [typer>=0.12]
```

**`repos/demo-good/.python-version`** (one line):

```text
3.12
```

**`repos/demo-good/.github/dependabot.yml`**:

```yaml
version: 2
updates:
  - package-ecosystem: pip
    directory: "/"
    schedule:
      interval: weekly
    open-pull-requests-limit: 5

  - package-ecosystem: github-actions
    directory: "/"
    schedule:
      interval: monthly
```

**`repos/demo-good/SECURITY.md`** and **`repos/demo-good/CONTRIBUTING.md`**:
filled-in versions of templates §5.5 and §5.6 with `project_name = "url-shortener"`.

**`repos/demo-good/.gitignore`** (standard Python `.gitignore`; see
github.com/github/gitignore/blob/main/Python.gitignore as the reference).

---

## 7. `WORKSHOP.md` — Participant Guide

- **Path**: `agent-ready-skill/WORKSHOP.md`
- **Length target**: about 250 lines.
- **Audience**: workshop participants who have arrived with a laptop and
  want a single document to follow.

The file's full content:

```markdown
# Workshop — Measure & Improve Agent Readiness

Welcome! This guide walks you through the two-hour, hands-on workshop on
making your Python codebase ready for AI coding agents. You will:

1. **Scan** your repository and see a 3-axis readiness score.
2. **Fix** the most impactful gaps using templates.
3. **Re-scan** and watch the score climb.
4. **Take home** a maturity badge for your README.

## 1. Prerequisites

- Python **3.11 or newer** (`python --version`).
- `git` installed and configured.
- A terminal you are comfortable in.
- (Optional) Your own Python project, ideally with a `pyproject.toml`.
  No project? Use the bundled `repos/demo-bad/` repo.

## 2. Pre-workshop setup (10 minutes)

```bash
git clone https://github.com/RisorseArtificiali/agent-ready-skill.git
cd agent-ready-skill

python -m venv .venv
source .venv/bin/activate

pip install -r requirements-workshop.txt

python scripts/check_setup.py
```

`check_setup.py` should print `All checks passed`. If anything is red,
follow its hints before the workshop starts.

## 3. Repository structure (what's where)

```
agent-ready-skill/
├── scripts/
│   ├── scan_static.py        ← scanner (analyses any Python repo)
│   ├── apply_fix.py          ← writes templates into a target repo
│   ├── report_gen.py         ← turns scores into txt/markdown/SVG
│   └── check_setup.py        ← pre-flight environment check
├── templates/                ← Jinja2 templates used by apply_fix.py
├── repos/
│   ├── demo-bad/             ← low-score reference repo (use this if you didn't bring one)
│   └── demo-good/            ← high-score reference repo
├── skills/                   ← (read-only) canonical scoring rubric
├── requirements-workshop.txt
└── WORKSHOP.md               ← you are here
```

## 4. Quick start (5 steps, 10 minutes)

### Step 1 — Scan

```bash
python scripts/scan_static.py /path/to/your/repo --all
```

Reads your repo, prints a colored summary, and writes
`/path/to/your/repo/.agent-ready/scores.json`.

### Step 2 — Visualize

```bash
python scripts/scan_static.py /path/to/your/repo --all --visualize
```

Opens a 3-axis radar chart in your browser. Screenshot it now; you will
want a "before" picture.

### Step 3 — Fix

```bash
python scripts/apply_fix.py --list /path/to/your/repo
python scripts/apply_fix.py agent-instructions /path/to/your/repo
python scripts/apply_fix.py --all-fixes /path/to/your/repo   # or this
```

`--all-fixes` proposes every missing artifact one by one and waits for
your confirmation. You can always say *no* and apply fixes selectively.

### Step 4 — Snapshot and diff

```bash
python scripts/scan_static.py /path/to/your/repo --all \
  --compare /path/to/your/repo/.agent-ready/scores.json
```

This re-scans and prints a table showing the delta versus the previous
scan. Look for the green arrows.

### Step 5 — Generate the take-home report

```bash
python scripts/report_gen.py \
  /path/to/your/repo/.agent-ready/scores.json \
  --output /path/to/your/repo/.agent-ready/report/
```

Produces three files in `report/`:

- `report.txt`           — paste it into Slack, mail it to your team.
- `recommendations.md`   — a prioritized to-do list.
- `badge.svg`            — drop it at the top of your README.

## 5. The 3-axis model in one minute

```
                INSTRUCT (38%)
                /        \
               /          \
      NAVIGATE (34%) — VALIDATE (28%)
```

- **INSTRUCT** — does the agent *understand what to do*?
  Driven by `CLAUDE.md`, `ARCHITECTURE.md`, `CONTRIBUTING.md`, and Claude-
  specific signals.
- **NAVIGATE** — can the agent *find what it needs*?
  Driven by linter/formatter/type-checker configs, `.editorconfig`,
  pinned Python version, `.env.example`.
- **VALIDATE** — can the agent *tell whether it succeeded*?
  Driven by tests, CI workflow, coverage, pre-commit, security policy.

The 38/34/28 split comes from a remap of an underlying 8-dimension rubric
in `skills/agent-ready/references/scoring.md`. You don't need to memorize
the dimensions — the axes are the working interface.

## 6. Maturity levels

| Level | Name          | Overall % | What it means in practice                                |
|-------|---------------|-----------|----------------------------------------------------------|
| L1    | Foundational  | ≥ 40      | The repo exists. Agents do basic things, supervised.     |
| L2    | Guided        | ≥ 55      | An agent can follow your conventions with hand-holding.  |
| L3    | Structured    | ≥ 70      | An agent can self-navigate small features end-to-end.    |
| L4    | Optimized     | ≥ 85      | An agent can validate its own work via CI/tests.         |
| L5    | Autonomous    | ≥ 95      | An agent can ship low-risk PRs with minimal review.      |

## 7. Troubleshooting

| Symptom                                          | Fix                                               |
|--------------------------------------------------|---------------------------------------------------|
| `ModuleNotFoundError: rich`                      | `pip install -r requirements-workshop.txt`        |
| `--visualize` fails to open browser              | The HTML file path is printed; open it manually.  |
| `apply_fix.py` says "no scores.json found"       | Run `scan_static.py` first, then re-run `apply_fix`. |
| `apply_fix.py` overwrote my file                 | It doesn't — without `--force`, it skips existing files. |
| Score didn't improve after a fix                 | Run `scan_static.py` again *after* the fix. The previous output is cached only in `scores.json`. |

## 8. After the workshop

- Re-scan your codebase weekly. Commit `.agent-ready/snapshots/*.json`
  to track progress.
- Add the badge to your README:

  ```markdown
  ![agent-ready](.agent-ready/report/badge.svg)
  ```

- Open a PR on https://github.com/RisorseArtificiali/agent-ready-skill
  if you spot a check that should exist but doesn't.

Happy shipping.
```

---

## 8. `requirements-workshop.txt`

- **Path**: `agent-ready-skill/requirements-workshop.txt`
- **Purpose**: pin the minimum dependency set installed by participants
  during pre-workshop setup. Kept intentionally tiny.
- **Exact content**:

```text
rich>=13.0.0
pyyaml>=6.0
jinja2>=3.1
# Optional: hybrid mode
# anthropic>=0.18
# openai>=1.12
```

The commented-out lines hint at the hybrid LLM mode described in spec 05
without forcing participants to install large SDKs.

---

## 9. Acceptance Criteria — Overall

The deliverables in this document are accepted when **all** of the
following are simultaneously true:

| ID        | Cross-deliverable acceptance criterion                                                                                                                       |
|-----------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|
| AC-ALL-1  | `python scripts/scan_static.py repos/demo-bad --all` exits 0 and reports an overall percentage **strictly less than 30 %**.                                  |
| AC-ALL-2  | `python scripts/scan_static.py repos/demo-good --all` exits 0 and reports an overall percentage **strictly greater than 80 %**.                              |
| AC-ALL-3  | Running `apply_fix.py --all-fixes` (auto-confirming `y`) against a fresh copy of `repos/demo-bad` raises its subsequent scan score by **at least 20 points**. |
| AC-ALL-4  | `report_gen.py` produces three files (`report.txt`, `recommendations.md`, `badge.svg`); the SVG parses as well-formed XML; the markdown contains a checklist. |
| AC-ALL-5  | `check_setup.py` exits 0 in a clean virtualenv immediately after `pip install -r requirements-workshop.txt` and `pip install -e .[dev]` (no other steps).      |
| AC-ALL-6  | `pytest` runs the entire test suite end-to-end in **under 60 seconds** on a typical laptop.                                                                  |
| AC-ALL-7  | No file in this work modifies `skills/**` or `skills/agent-ready/references/scoring.md`.                                                                     |

### 9.1 End-to-end executable test

`tests/test_end_to_end.py` orchestrates the full participant flow:

```python
# REFERENCE — tests/test_end_to_end.py
"""End-to-end: scan → apply fixes → re-scan → assert improvement."""
from __future__ import annotations

import json
import shutil
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
SCAN = REPO_ROOT / "scripts" / "scan_static.py"
FIX = REPO_ROOT / "scripts" / "apply_fix.py"
REPORT = REPO_ROOT / "scripts" / "report_gen.py"
DEMO_BAD = REPO_ROOT / "repos" / "demo-bad"


def _run(args: list[str], **kw) -> subprocess.CompletedProcess:
    return subprocess.run(args, capture_output=True, text=True, check=True, **kw)


def test_full_workshop_loop(tmp_path: Path) -> None:
    # 1. Copy demo-bad to a scratch directory.
    target = tmp_path / "demo-bad-scratch"
    shutil.copytree(DEMO_BAD, target)

    # 2. Initial scan — score should be low.
    _run([sys.executable, str(SCAN), str(target), "--all"])
    before = json.loads((target / ".agent-ready" / "scores.json").read_text())
    assert before["overall"]["percentage"] < 30

    # 3. Apply every fix, auto-confirming.
    n_fixes = 7  # one prompt per fix
    _run(
        [sys.executable, str(FIX), "--all-fixes", str(target)],
        input="y\n" * n_fixes,
    )

    # 4. Re-scan.
    _run([sys.executable, str(SCAN), str(target), "--all"])
    after = json.loads((target / ".agent-ready" / "scores.json").read_text())

    # 5. Assert at least +20 points improvement.
    delta = after["overall"]["percentage"] - before["overall"]["percentage"]
    assert delta >= 20, f"expected +20 points, got +{delta:.1f}"

    # 6. Generate reports and assert the three files exist.
    out = tmp_path / "report"
    _run([
        sys.executable, str(REPORT),
        str(target / ".agent-ready" / "scores.json"),
        "--output", str(out),
    ])
    assert (out / "report.txt").is_file()
    assert (out / "recommendations.md").is_file()
    assert (out / "badge.svg").is_file()
```

This test is the single most important regression guard for the workshop.

---

## 10. Implementation Order

The 15 deliverables should be implemented in three working days.

### Day 1 — Static content and one harness

1. `requirements-workshop.txt` (5 minutes).
2. All 8 templates (§5.1 through §5.8). They are static or near-static
   and unblock everything downstream.
3. `repos/demo-bad/` complete contents (§6.1).
4. `repos/demo-good/` complete contents (§6.2), with `src/url_shortener/`
   source files written by hand (clean, idiomatic, < 60 lines each).
5. `scripts/check_setup.py` (§4).

By end of day 1, a manual `python scripts/scan_static.py repos/demo-bad`
should show < 30 % and `repos/demo-good` should show > 80 %.

### Day 2 — Tooling

6. `scripts/apply_fix.py` (§2), including the per-fix Jinja2 rendering,
   the `--list` command, and the pyproject merge logic.
7. `scripts/report_gen.py` (§3), including badge SVG generation.
8. Per-script pytest suites (`tests/test_apply_fix.py`,
   `tests/test_report_gen.py`, `tests/test_check_setup.py`).

By end of day 2, `pytest -q` runs cleanly.

### Day 3 — Participant-facing polish

9. `WORKSHOP.md` (§7), proofread.
10. `tests/test_end_to_end.py` (§9.1).
11. README updates linking to `WORKSHOP.md`.
12. Manual walkthrough on a real, non-demo repo to flush out edge cases.

---

## 11. Out of Scope

For the avoidance of doubt, the following are **not** part of this work:

- **Editing the canonical skills.** Files under `skills/**`, including
  `skills/agent-ready/references/scoring.md`, are read-only. They are
  the source of truth for the rubric and must remain unchanged.
- **Server, SaaS, or GitHub App.** All tooling is local-first CLI.
- **JavaScript bundler / framework.** The radar visualization loads
  Chart.js from a CDN inside a single self-contained HTML file
  (see spec 05). No `package.json`, no Node toolchain.
- **Docker / dev containers.** Out of scope for v0. Participants run
  Python locally.
- **Translations.** Every artifact in this spec is English-only.
- **Hybrid LLM scoring implementation details.** Specified in spec 05
  only; this document only mentions the commented-out optional
  dependencies in `requirements-workshop.txt`.
- **Workshop slides.** Authored separately (see `07-slides-outline.md`).

---

## 12. File Layout Summary in Target Repo

After all 15 deliverables are merged, the repository layout is:

```
agent-ready-skill/
├── CONTRIBUTING.md                       (pre-existing)
├── LICENSE                               (pre-existing)
├── README.md                             (pre-existing, may be touched)
├── WORKSHOP.md                           ← NEW (§7)
├── requirements-workshop.txt             ← NEW (§8)
├── scripts/
│   ├── scan_static.py                    ← see spec 05
│   ├── apply_fix.py                      ← NEW (§2)
│   ├── report_gen.py                     ← NEW (§3)
│   └── check_setup.py                    ← NEW (§4)
├── tests/
│   ├── conftest.py
│   ├── test_apply_fix.py                 ← NEW
│   ├── test_check_setup.py               ← NEW
│   ├── test_end_to_end.py                ← NEW
│   ├── test_report_gen.py                ← NEW
│   └── test_scan_static.py               ← see spec 05
├── templates/                            ← NEW (§5)
│   ├── badge.svg.j2
│   ├── ci-template.yml
│   ├── claude-md-template.md
│   ├── contributing-md-template.md
│   ├── editorconfig
│   ├── env-example
│   ├── pyproject-snippet.toml
│   └── security-md-template.md
├── repos/                                ← NEW (§6)
│   ├── demo-bad/
│   │   ├── README.md
│   │   ├── main.py
│   │   └── requirements.txt
│   └── demo-good/
│       ├── .editorconfig
│       ├── .env.example
│       ├── .github/
│       │   ├── dependabot.yml
│       │   └── workflows/ci.yml
│       ├── .gitignore
│       ├── .pre-commit-config.yaml
│       ├── .python-version
│       ├── ARCHITECTURE.md
│       ├── CLAUDE.md
│       ├── CONTRIBUTING.md
│       ├── README.md
│       ├── SECURITY.md
│       ├── pyproject.toml
│       ├── src/url_shortener/{__init__,cli,models,service}.py
│       └── tests/{__init__,test_models,test_service}.py
└── skills/                               (READ-ONLY, untouched)
    ├── agent-ready/{SKILL.md,references/scoring.md}
    ├── agent-ready-fix/SKILL.md
    ├── agent-ready-scaffold/SKILL.md
    ├── agent-ready-evidence/SKILL.md
    └── agent-readiness-mini-audit/SKILL.md
```

---

*End of specification. Together with `05-implementation-plan.md` and
`skills/agent-ready/references/scoring.md`, this document is sufficient
to implement the workshop deliverables end-to-end in three to five
working days.*
