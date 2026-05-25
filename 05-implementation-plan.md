# Fase 4: Implementation Plan — Codice Skeleton & Spec

## 🎯 Obiettivo
Spec completa con **codice reale** (non pseudocodice) per ogni file da buildare.
Ogni file ha: path, dipendenze, codice skeleton completo, test cases.

---

## 1. `scripts/scan_static.py` — Core Scanner

**Path**: `agent-ready-skill/scripts/scan_static.py`
**Dipendenze**: `rich`, `pyyaml`, stdlib (`pathlib`, `json`, `sys`, `tomllib`)
**Righe**: ~250

```python
#!/usr/bin/env python3
"""
Agent Readiness Static Scanner — Three-Axis Model

Scans a Python codebase for agent-readiness signals across 3 axes:
  📝 INSTRUCT  — Does the agent understand WHAT we want?
  🧭 NAVIGATE  — Can the agent find its way around?
  ✅ VALIDATE  — Can the agent tell if it did it right?

Usage:
    python scan_static.py /path/to/repo --axis instruct
    python scan_static.py /path/to/repo --axis navigate
    python scan_static.py /path/to/repo --axis validate
    python scan_static.py /path/to/repo --all --hybrid
    python scan_static.py /path/to/repo --all --visualize
    python scan_static.py /path/to/repo --full-report --output ./report/
"""

from __future__ import annotations

import argparse
import json
import sys
import tomllib
from pathlib import Path
from typing import Any, Optional

try:
    from rich.console import Console
    from rich.panel import Panel
    from rich.table import Table
    from rich.progress import Progress, SpinnerColumn, TextColumn
except ImportError:
    print("ERROR: pip install rich", file=sys.stderr)
    sys.exit(1)

try:
    import yaml
except ImportError:
    yaml = None  # YAML optional (only for config files)

# ─── Constants ───────────────────────────────────────────────

VERSION = "0.1.0-workshop"

# Axis definitions with weights (total = 100 per axis)
AXES = {
    "instruct": {
        "icon": "📝",
        "name": "INSTRUCT",
        "question": "Does the agent understand WHAT we want?",
        "weight": 38,
        "color": "blue",
    },
    "navigate": {
        "icon": "🧭",
        "name": "NAVIGATE",
        "question": "Can the agent find its way around?",
        "weight": 34,
        "color": "cyan",
    },
    "validate": {
        "icon": "✅",
        "name": "VALIDATE",
        "question": "Can the agent tell if it did it right?",
        "weight": 28,
        "color": "green",
    },
}

# Maturity level thresholds
MATURITY_LEVELS = {
    1: ("FOUNDATIONAL", 40, "The project exists. Agents can find basic files."),
    2: ("GUIDED", 55, "Agents can follow instructions. Basic guidance exists."),
    3: ("STRUCTURED", 70, "Agents navigate autonomously. Tooling is consistent."),
    4: ("OPTIMIZED", 85, "Agents validate their work. Quality gates exist."),
    5: ("AUTONOMOUS", 95, "Agents are effective team members. Minimal oversight needed."),
}

# ─── Check Definitions ──────────────────────────────────────
# Each check returns a result dict:
#   { "id": str, "name": str, "pass": bool, "score": int,
#     "max_score": int, "message": str, "details": Optional[str] }

def _file_exists(repo: Path, *patterns: str) -> Optional[str]:
    """Check if any pattern matches. Returns first match or None."""
    for pattern in patterns:
        # Support glob patterns
        if "*" in pattern or "?" in pattern:
            matches = list(repo.glob(pattern))
            # Filter out directories and hidden dirs like .git
            matches = [m for m in matches if m.is_file() and ".git" not in m.parts]
            if matches:
                return str(matches[0].relative_to repo)
        else:
            target = repo / pattern
            if target.is_file():
                return pattern
    return None


def _read_file_content(repo: Path, filepath: str) -> Optional[str]:
    """Read file content relative to repo root."""
    target = repo / filepath
    if target.is_file():
        try:
            return target.read_text(encoding="utf-8", errors="ignore")
        except OSError:
            return None
    return None


def _content_contains(filepath_content: Optional[str], *patterns: str) -> bool:
    """Check if file content contains any of the patterns."""
    if not filepath_content:
        return False
    content_lower = filepath_content.lower()
    return any(p.lower() in content_lower for p in patterns)


def _glob_count(repo: Path, pattern: str) -> int:
    """Count files matching glob pattern."""
    return len([
        f for f in repo.glob(pattern)
        if f.is_file() and ".git" not in f.parts
        and "__pycache__" not in f.parts
    ])


# ════════════════════════════════════════════════════════════
# AXIS 1: INSTRUCT CHECKS
# ════════════════════════════════════════════════════════════

INSTRUCT_CHECKS: list[dict[str, Any]] = [
    {
        "id": "agent_instructions",
        "name": "Agent Instructions File",
        "weight": 20,
        "max_score": 20,
        "check": lambda repo: (
            {
                "pass": bool(_file_exists(repo, "CLAUDE.md", ".cursorrules",
                                          ".github/copilot-instructions.md")),
                "score": 20 if _file_exists(repo, "CLAUDE.md", ".cursorrules",
                                              ".github/copilot-instructions.md") else 0,
                "message": f"Found: {_file_exists(repo, 'CLAUDE.md', '.cursorrules', '.github/copilot-instructions.md')}"
                          if _file_exists(repo, "CLAUDE.md", ".cursorrules",
                                         ".github/copilot-instructions.md")
                else "No agent instruction file found (CLAUDE.md, .cursorrules)",
                "details": "Add CLAUDE.md or .cursorrules to guide AI agents on your project conventions.",
            }
        ),
    },
    {
        "id": "readme_quality",
        "name": "README Quality",
        "weight": 8,
        "max_score": 8,
        "check": lambda repo: (
            _check_readme(repo)
        ),
    },
    {
        "id": "contributing_guide",
        "name": "Contributing Guide",
        "weight": 5,
        "max_score": 5,
        "check": lambda repo: (
            {
                "pass": bool(_file_exists(repo, "CONTRIBUTING.md",
                                          "docs/contributing.md")),
                "score": 5 if _file_exists(repo, "CONTRIBUTING.md",
                                           "docs/contributing.md") else 0,
                "message": f"Found: {_file_exists(repo, 'CONTRIBUTING.md', 'docs/contributing.md')}"
                          if _file_exists(repo, "CONTRIBUTING.md",
                                         "docs/contributing.md")
                else "No contributing guide found",
                "details": "Add CONTRIBUTING.md to document how to contribute.",
            }
        ),
    },
    {
        "id": "architecture_docs",
        "name": "Architecture Documentation",
        "weight": 10,
        "max_score": 10,
        "check": lambda repo: (
            {
                "pass": bool(_file_exists(repo, "ARCHITECTURE.md",
                                          "docs/architecture.md",
                                          "docs/adr/")),
                "score": 10 if _file_exists(repo, "ARCHITECTURE.md",
                                             "docs/architecture.md",
                                             "docs/adr/") else 0,
                "message": f"Found: {_file_exists(repo, 'ARCHITECTURE.md', 'docs/architecture.md', 'docs/adr/')}"
                          if _file_exists(repo, "ARCHITECTURE.md",
                                         "docs/architecture.md", "docs/adr/")
                else "No architecture documentation found",
                "details": "Add ARCHITECTURE.md or docs/adr/ for design decisions.",
            }
        ),
    },
]


def _check_readme(repo: Path) -> dict[str, Any]:
    """Check README existence and quality (length + sections)."""
    found = _file_exists(repo, "README.md", "readme.md", "Readme.md")
    if not found:
        return {
            "pass": False, "score": 0, "max_score": 8,
            "message": "No README.md found",
            "details": "Add a README.md with project overview and setup instructions.",
        }

    content = _read_file_content(repo, found)
    if not content:
        return {"pass": False, "score": 0, "max_score": 8,
                "message": "README.md is empty", "details": ""}

    score = 0
    details_parts = []

    # Length check (>300 chars = decent)
    if len(content) > 500:
        score += 3
    elif len(content) > 200:
        score += 1
    details_parts.append(f"{len(content)} chars")

    # Section checks
    required_sections = ["installation", "usage", "setup", "getting started"]
    found_sections = [s for s in required_sections if s in content.lower()]
    score += min(len(found_sections), 3)
    details_parts.append(f"sections: {len(found_sections)}/4")

    has_code_example = "```" in content or "`" in content
    if has_code_example:
        score += 2
        details_parts.append("has code examples")

    return {
        "pass": score >= 5,
        "score": min(score, 8),
        "max_score": 8,
        "message": f"README.md ({', '.join(details_parts)})",
        "details": f"Score: {min(score, 8)}/8. Add installation, usage, code examples.",
    }


# ════════════════════════════════════════════════════════════
# AXIS 2: NAVIGATE CHECKS
# ════════════════════════════════════════════════════════════

NAVIGATE_CHECKS: list[dict[str, Any]] = [
    {
        "id": "editorconfig",
        "name": "EditorConfig",
        "weight": 2,
        "max_score": 2,
        "check": lambda repo: (
            {
                "pass": bool(_file_exists(repo, ".editorconfig")),
                "score": 2 if _file_exists(repo, ".editorconfig") else 0,
                "message": f"Found: {_file_exists(repo, '.editorconfig')}" if _file_exists(repo, ".editorconfig")
                else "No .editorconfig found",
                "details": "Add .editorconfig for consistent editor settings.",
            }
        ),
    },
    {
        "id": "linter_configured",
        "name": "Linter Configured",
        "weight": 6,
        "max_score": 6,
        "check": lambda repo: (_check_linter(repo)),
    },
    {
        "id": "formatter_configured",
        "name": "Formatter Configured",
        "weight": 6,
        "max_score": 6,
        "check": lambda repo: (_check_formatter(repo)),
    },
    {
        "id": "type_checker",
        "name": "Type Checker",
        "weight": 6,
        "max_score": 6,
        "check": lambda repo: (
            {
                "pass": bool(_file_exists(repo, "pyrightconfig.json",
                                          "mypy.ini", ".mypy.ini",
                                          "setup.cfg")),  # setup.cfg might have [mypy]
                "score": 6 if _file_exists(repo, "pyrightconfig.json",
                                            "mypy.ini", ".mypy.ini") else
                         (3 if _type_check_in_setup_cfg(repo) else 0),
                "message": f"Found: {_file_exists(repo, 'pyrightconfig.json', 'mypy.ini', '.mypy.ini')}"
                          if _file_exists(repo, "pyrightconfig.json",
                                         "mypy.ini", ".mypy.ini")
                else ("Type hints in setup.cfg" if _type_check_in_setup_cfg(repo)
                       else "No type checker configured"),
                "details": "Add pyrightconfig.json or mypy.ini for static typing.",
            }
        ),
    },
    {
        "id": "env_documentation",
        "name": "Environment Variables Documented",
        "weight": 4,
        "max_score": 4,
        "check": lambda repo: (
            {
                "pass": bool(_file_exists(repo, ".env.example",
                                          ".env.template", ".env.sample")),
                "score": 4 if _file_exists(repo, ".env.example",
                                           ".env.template", ".env.sample") else 0,
                "message": f"Found: {_file_exists(repo, '.env.example', '.env.template', '.env.sample')}"
                          if _file_exists(repo, ".env.example",
                                         ".env.template", ".env.sample")
                else "No .env.example found",
                "details": "Add .env.example listing all required environment variables.",
            }
        ),
    },
    {
        "id": "large_files",
        "name": "Large Files Check",
        "weight": 4,
        "max_score": 4,
        "check": lambda repo: (_check_large_files(repo)),
    },
    {
        "id": "version_pinned",
        "name": "Python Version Pinned",
        "weight": 3,
        "max_score": 3,
        "check": lambda repo: (
            {
                "pass": bool(_file_exists(repo, ".python-version",
                                          ".tool-versions", "pyproject.toml")),
                "score": 3 if _file_exists(repo, ".python-version",
                                           ".tool-versions") else
                         (2 if _requires_python_in_pyproject(repo) else 0),
                "message": f"Found: {_file_exists(repo, '.python-version', '.tool-versions')}"
                          if _file_exists(repo, ".python-version",
                                         ".tool-versions")
                else ("Python version in pyproject.toml"
                       if _requires_python_in_pyproject(repo)
                       else "No Python version pinned"),
                "details": "Add .python-version or .tool-versions.",
            }
        ),
    },
    {
        "id": "lock_file",
        "name": "Dependency Lock File",
        "weight": 3,
        "max_score": 3,
        "check": lambda repo: (
            {
                "pass": bool(_file_exists(repo, "poetry.lock",
                                          "Pipfile.lock", "uv.lock",
                                          "requirements-lock.txt")),
                "score": 3 if _file_exists(repo, "poetry.lock",
                                           "Pipfile.lock", "uv.lock") else 0,
                "message": f"Found: {_file_exists(repo, 'poetry.lock', 'Pipfile.lock', 'uv.lock')}"
                          if _file_exists(repo, "poetry.lock",
                                         "Pipfile.lock", "uv.lock")
                else "No dependency lock file found",
                "details": "Commit your lock file for reproducible builds.",
            }
        ),
    },
]


def _check_linter(repo: Path) -> dict[str, Any]:
    """Check for Python linter configuration."""
    ruff_configs = ["ruff.toml", ".ruff.toml"]
    pyproject_content = _read_file_content(repo, "pyproject.toml")

    # Check dedicated ruff config files
    for cfg in ruff_configs:
        if _file_exists(repo, cfg):
            return {"pass": True, "score": 6, "max_score": 6,
                    "message": f"Ruff configured: {cfg}", "details": ""}

    # Check pyproject.toml for [tool.ruff]
    if pyproject_content and "[tool.ruff]" in pyproject_content:
        return {"pass": True, "score": 6, "max_score": 6,
                "message": "Ruff configured in pyproject.toml [tool.ruff]",
                "details": ""}

    # Check for flake8, pylint configs
    other_linters = [".flake8", "pylintrc", ".pylintrc", "setup.cfg"]
    for cfg in other_linters:
        if _file_exists(repo, cfg):
            content = _read_file_content(repo, cfg)
            if cfg == "setup.cfg":
                if content and ("[flake8]" in content or "[pylint]" in content):
                    return {"pass": True, "score": 4, "max_score": 6,
                            "message": f"Linter configured: {cfg}",
                            "details": "Consider migrating to Ruff."}
            elif _file_exists(repo, cfg):
                return {"pass": True, "score": 4, "max_score": 6,
                        "message": f"Linter configured: {cfg}",
                        "details": "Consider migrating to Ruff."}

    return {"pass": False, "score": 0, "max_score": 6,
            "message": "No linter configured",
            "details": "Add Ruff (ruff.toml or [tool.ruff] in pyproject.toml)."}


def _check_formatter(repo: Path) -> dict[str, Any]:
    """Check for code formatter configuration."""
    pyproject_content = _read_file_content(repo, "pyproject.toml")

    # Check common formatters
    formatter_patterns = [
        ("[tool.black]", "Black"),
        ("[tool.ruff.format]", "Ruff format"),
    ]

    if pyproject_content:
        for pattern, name in formatter_patterns:
            if pattern in pyproject_content:
                return {"pass": True, "score": 6, "max_score": 6,
                        "message": f"{name} configured in pyproject.toml",
                        "details": ""}

    # Dedicated config files
    if _file_exists(repo, ".black"):
        return {"pass": True, "score": 6, "max_score": 6,
                "message": "Black configured (.black)", "details": ""}

    return {"pass": False, "score": 0, "max_score": 6,
            "message": "No formatter configured",
            "details": "Add Black ([tool.black]) or Ruff format ([tool.ruff.format])."}


def _check_large_files(repo: Path) -> dict[str, Any]:
    """Check for excessively large Python files (hard for agents to parse)."""
    threshold_lines = 300
    large_files = []

    for py_file in repo.rglob("*.py"):
        if ".git" in py_file.parts or "__pycache__" in py_file.parts:
            continue
        try:
            line_count = sum(1 for _ in open(py_file, encoding="utf-8", errors="ignore"))
            if line_count > threshold_lines:
                large_files.append((str(py_file.relative_to(repo)), line_count))
        except OSError:
            continue

    if not large_files:
        return {"pass": True, "score": 4, "max_score": 4,
                "message": "No oversized Python files",
                "details": ""}

    large_files.sort(key=lambda x: x[1], reverse=True)
    top_3 = large_files[:3]
    details = ", ".join(f"{f} ({n}ln)" for f, n in top_3)
    if len(large_files) > 3:
        details += f" (+{len(large_files) - 3} more)"

    score = max(0, 4 - len(large_files))
    return {"pass": score >= 2, "score": score, "max_score": 4,
            "message": f"{len(large_files)} file(s) > {threshold_lines} lines",
            "details": details}


def _type_check_in_setup_cfg(repo: Path) -> bool:
    """Check if setup.cfg contains [mypy] section."""
    content = _read_file_content(repo, "setup.cfg")
    return bool(content and "[mypy]" in content)


def _requires_python_in_pyproject(repo: Path) -> bool:
    """Check if pyproject.toml requires-python is set."""
    content = _read_file_content(repo, "pyproject.toml")
    return bool(content and "requires-python" in content)


# ════════════════════════════════════════════════════════════
# AXIS 3: VALIDATE CHECKS
# ════════════════════════════════════════════════════════════

VALIDATE_CHECKS: list[dict[str, Any]] = [
    {
        "id": "test_framework",
        "name": "Test Framework Configured",
        "weight": 6,
        "max_score": 6,
        "check": lambda repo: (_check_test_framework(repo)),
    },
    {
        "id": "test_files_exist",
        "name": "Test Files Exist",
        "weight": 5,
        "max_score": 5,
        "check": lambda repo: (_check_test_files(repo)),
    },
    {
        "id": "ci_configured",
        "name": "CI Pipeline Configured",
        "weight": 6,
        "max_score": 6,
        "check": lambda repo: (_check_ci(repo)),
    },
    {
        "id": "coverage_configured",
        "name": "Coverage Configured",
        "weight": 4,
        "max_score": 4,
        "check": lambda repo: (_check_coverage(repo)),
    },
    {
        "id": "pre_commit",
        "name": "Pre-commit Hooks",
        "weight": 3,
        "max_score": 3,
        "check": lambda repo: (
            {
                "pass": bool(_file_exists(repo, ".pre-commit-config.yaml",
                                          ".pre-commit-config.yml")),
                "score": 3 if _file_exists(repo, ".pre-commit-config.yaml",
                                           ".pre-commit-config.yml") else 0,
                "message": f"Found: {_file_exists(repo, '.pre-commit-config.yaml', '.pre-commit-config.yml')}"
                          if _file_exists(repo, ".pre-commit-config.yaml",
                                         ".pre-commit-config.yml")
                else "No pre-commit hooks configured",
                "details": "Add .pre-commit-config.yaml for automated checks before commit.",
            }
        ),
    },
    {
        "id": "security_policy",
        "name": "Security Policy (SECURITY.md)",
        "weight": 2,
        "max_score": 2,
        "check": lambda repo: (
            {
                "pass": bool(_file_exists(repo, "SECURITY.md",
                                          ".github/SECURITY.md")),
                "score": 2 if _file_exists(repo, "SECURITY.md",
                                           ".github/SECURITY.md") else 0,
                "message": f"Found: {_file_exists(repo, 'SECURITY.md', '.github/SECURITY.md')}"
                          if _file_exists(repo, "SECURITY.md",
                                         ".github/SECURITY.md")
                else "No SECURITY.md found",
                "details": "Add SECURITY.md for vulnerability reporting instructions.",
            }
        ),
    },
    {
        "id": "dependency_update_automation",
        "name": "Dependency Update Automation",
        "weight": 2,
        "max_score": 2,
        "check": lambda repo: (
            {
                "pass": bool(_file_exists(repo, ".github/dependabot.yml",
                                          ".github/dependabot.yaml",
                                          "renovate.json")),
                "score": 2 if _file_exists(repo, ".github/dependabot.yml",
                                           ".github/dependabot.yaml",
                                           "renovate.json") else 0,
                "message": f"Found: {_file_exists(repo, '.github/dependabot.yml', '.renovate.json')}"
                          if _file_exists(repo, ".github/dependabot.yml",
                                         ".github/dependabot.yaml",
                                         "renovate.json")
                else "No dependency update automation found",
                "details": "Add Dependabot or Renovate for automatic updates.",
            }
        ),
    },
]


def _check_test_framework(repo: Path) -> dict[str, Any]:
    """Check for test framework configuration."""
    # Config files
    test_configs = [
        ("pytest.ini", "pytest"),
        ("conftest.py", "pytest"),
        ("pyproject.toml", "pytest"),  # will check content
        ("setup.cfg", "pytest"),       # will check content
    ]

    for cfg, name in test_configs:
        if _file_exists(repo, cfg):
            if cfg in ("pyproject.toml", "setup.cfg"):
                content = _read_file_content(repo, cfg)
                if content and ("[tool.pytest]" in content or
                                 "[pytest]" in content or
                                 "test" in content.lower()):
                    return {"pass": True, "score": 6, "max_score": 6,
                            "message": f"{name} configured in {cfg}",
                            "details": ""}
            else:
                return {"pass": True, "score": 6, "max_score": 6,
                        "message": f"{name} configured ({cfg})",
                        "details": ""}

    # Check for test files as implicit framework detection
    test_count = _glob_count(repo, "**/test_*.py") + _glob_count(repo, "**/*_test.py")
    if test_count > 0:
        return {"pass": True, "score": 4, "max_score": 6,
                "message": f"Test files found ({test_count}) but no explicit config",
                "details": "Add pytest.ini or [tool.pytest] to pyproject.toml."}

    return {"pass": False, "score": 0, "max_score": 6,
            "message": "No test framework configured",
            "details": "Add pytest.ini or configure [tool.pytest] in pyproject.toml."}


def _check_test_files(repo: Path) -> dict[str, Any]:
    """Check for existence of test files."""
    patterns = ["**/test_*.py", "**/*_test.py", "tests/**/*.py"]
    total = sum(_glob_count(repo, p) for p in patterns)

    if total >= 5:
        return {"pass": True, "score": 5, "max_score": 5,
                "message": f"Found {total} test files", "details": ""}
    elif total >= 2:
        return {"pass": True, "score": 3, "max_score": 5,
                "message": f"Found {total} test files (need ≥5 for full score)",
                "details": f"Add more tests. Current: {total}"}
    elif total >= 1:
        return {"pass": False, "score": 1, "max_score": 5,
                "message": f"Only {total} test file found",
                "details": "Add more test files covering core functionality."}
    else:
        return {"pass": False, "score": 0, "max_score": 5,
                "message": "No test files found",
                "details": "Add test_*.py or *_test.py files."}


def _check_ci(repo: Path) -> dict[str, Any]:
    """Check for CI pipeline configuration."""
    ci_patterns = [
        ".github/workflows/*.yml",
        ".github/workflows/*.yaml",
        ".gitlab-ci.yml",
        ".circleci/config.yml",
    ]

    for pattern in ci_patterns:
        matches = list(repo.glob(pattern))
        valid = [m for m in matches if m.is_file()]
        if valid:
            # Check if CI actually does something useful
            has_tests = False
            has_lint = False
            for m in valid[:3]:  # Check up to 3 workflow files
                content = _read_file_content(repo, str(m.relative_to(repo)))
                if content:
                    content_lower = content.lower()
                    if any(kw in content_lower for kw in
                           ["pytest", "test", "ruff check", "lint", "black"]):
                        has_tests = True
                    if any(kw in content_lower for kw in
                           ["ruff", "lint", "flake8", "black", "mypy"]):
                        has_lint = True

            score = 6 if (has_tests and has_lint) else (4 if has_tests or has_lint else 2)
            filenames = ", ".join(m.name for m in valid[:3])
            return {"pass": score >= 4, "score": score, "max_score": 6,
                    "message": f"CI configured: {filenames}",
                    "details": "Add test + lint steps to CI for full score."}

    return {"pass": False, "score": 0, "max_score": 6,
            "message": "No CI pipeline configured",
            "details": "Add .github/workflows/ci.yml with test and lint steps."}


def _check_coverage(repo: Path) -> dict[str, Any]:
    """Check for test coverage configuration."""
    coverage_indicators = [
        ".coveragerc", ".coveragerc.ini",
        "pytest.ini", "pyproject.toml", "setup.cfg",
    ]

    for cfg in coverage_indicators:
        if _file_exists(repo, cfg):
            content = _read_file_content(repo, cfg)
            if content and ("coverage" in content.lower()):
                return {"pass": True, "score": 4, "max_score": 4,
                        "message": f"Coverage configured in {cfg}",
                        "details": ""}

    return {"pass": False, "score": 0, "max_score": 4,
            "message": "No coverage configuration found",
            "details": "Add coverage config to pytest.ini or pyproject.toml."}


# ─── Scoring Engine ──────────────────────────────────────────

ALL_CHECKS = {
    "instruct": INSTRUCT_CHECKS,
    "navigate": NAVIGATE_CHECKS,
    "validate": VALIDATE_CHECKS,
}


def run_checks(repo: Path, axis: str | None = None) -> dict[str, Any]:
    """
    Run all checks for given axis (or all axes if None).
    
    Returns:
    {
        "repo_name": str,
        "repo_path": str,
        "timestamp": str,
        "axes": {
            "instruct": {
                "score": int,
                "max_score": int,
                "percentage": float,
                "checks": [...]
            },
            ...
        },
        "overall": {
            "score": int,
            "max_score": int,
            "percentage": float,
            "level": int,
            "level_name": str,
        }
    }
    """
    axes_to_run = [axis] if axis else list(ALL_CHECKS.keys())
    result: dict[str, Any] = {
        "repo_name": repo.name,
        "repo_path": str(repo),
        "timestamp": __import__("datetime").datetime.now().isoformat(),
        "axes": {},
        "overall": {},
    }

    total_score = 0
    total_max = 0

    for ax in axes_to_run:
        checks = ALL_CHECKS.get(ax, [])
        axis_results = []
        ax_score = 0
        ax_max = 0

        for check_def in checks:
            check_fn = check_def["check"]
            try:
                cr = check_fn(repo)
            except Exception as e:
                cr = {
                    "pass": False, "score": 0,
                    "max_score": check_def.get("max_score", 0),
                    "message": f"Error: {e}",
                    "details": "",
                    "id": check_def["id"],
                    "name": check_def["name"],
                }
            # Ensure id and name are present
            cr["id"] = check_def["id"]
            cr["name"] = check_def["name"]
            axis_results.append(cr)
            ax_score += cr.get("score", 0)
            ax_max += cr.get("max_score", 0)

        pct = round((ax_score / ax_max * 100), 1) if ax_max > 0 else 0
        result["axes"][ax] = {
            "score": ax_score,
            "max_score": ax_max,
            "percentage": pct,
            "checks": axis_results,
        }
        total_score += ax_score
        total_max += ax_max

    # Calculate overall
    overall_pct = round((total_score / total_max * 100), 1) if total_max > 0 else 0
    level, level_name = _calculate_maturity_level(overall_pct)

    result["overall"] = {
        "score": total_score,
        "max_score": total_max,
        "percentage": overall_pct,
        "level": level,
        "level_name": level_name,
    }

    return result


def _calculate_maturity_level(percentage: float) -> tuple[int, str]:
    """Determine maturity level from overall percentage."""
    for lvl in sorted(MATURITY_LEVELS.keys(), reverse=True):
        name, threshold, _ = MATURITY_LEVELS[lvl]
        if percentage >= threshold:
            return lvl, name
    return 1, MATURITY_LEVELS[1][0]


# ─── Output Formatters ───────────────────────────────────────

def _color_for_percentage(pct: float) -> str:
    """Return Rich color name for percentage."""
    if pct >= 80:
        return "green"
    elif pct >= 50:
        return "yellow"
    else:
        return "red"


def print_terminal_report(result: dict[str, Any], console: Console) -> None:
    """Format and print the terminal report using Rich."""
    overall = result["overall"]

    # Header panel
    header_text = (
        f"[bold white]AGENT READINESS ASSESSMENT[/bold white]\n\n"
        f"Repo: [cyan]{result['repo_name']}[/cyan]\n"
        f"Level: [bold]{overall['level']}: {overall['level_name']}[/bold]\n"
        f"Overall: [bold]{overall['percentage']}%[/bold]"
    )
    console.print(Panel(header_text, border_style="bright_blue"))

    # Per-axis tables
    for ax_id, ax_data in result["axes"].items():
        ax_info = AXES[ax_id]
        color = _color_for_percentage(ax_data["percentage"])

        table = Table(
            title=f"{ax_info['icon']} Axis: {ax_info['name']} "
                   f"[{ax_data['percentage']}%]",
            show_header=True,
            header_style="bold dim",
        )
        table.add_column("Status", justify="center", width=4)
        table.add_column("Check", style="dim", min_width=22)
        table.add_column("Score", justify="right", width=6)
        table.add_column("Detail", max_width=50)

        for check in ax_data["checks"]:
            status = "[green]✓[/green]" if check["pass"] else "[red]✗[/red]"
            score_str = f"{check['score']}/{check['max_score']}"
            table.add_row(
                status,
                check["name"],
                f"[{color}]{score_str}[/{color}]",
                check.get("message", "")[:50],
            )

        console.print(table)
        console.print()

    # Overall summary bar
    _print_overall_bar(overall, console)


def _print_overall_bar(overall: dict[str, Any], console: Console) -> None:
    """Print a visual progress bar for overall score."""
    pct = overall["percentage"]
    filled = int(pct / 100 * 30)
    bar = "█" * filled + "░" * (30 - filled)
    color = _color_for_percentage(pct)

    console.print()
    console.print(f"[{color}]  {bar}[/{color}] {pct}%")
    console.print(f"  Level {overall['level']}: {overall['level_name']}")
    console.print()


def generate_recommendations(result: dict[str, Any]) -> list[dict[str, Any]]:
    """Generate prioritized recommendations based on failed checks."""
    recommendations = []

    for ax_id, ax_data in result["axes"].items():
        for check in ax_data["checks"]:
            if not check["pass"]:
                # Determine effort based on what needs to be done
                effort = _estimate_effort(check["id"])
                impact = _estimate_impact(check, ax_data["percentage"])
                recommendations.append({
                    "axis": ax_id,
                    "check_id": check["id"],
                    "title": check["name"],
                    "description": check.get("details", ""),
                    "potential_gain": check["max_score"] - check["score"],
                    "effort": effort,
                    "impact": impact,
                })

    # Sort: high impact first, then low effort
    impact_order = {"high": 0, "medium": 1, "low": 2}
    effort_order = {"low": 0, "medium": 1, "high": 2}
    recommendations.sort(key=lambda r: (
        impact_order.get(r["impact"], 1),
        effort_order.get(r["effort"], 1),
        -r["potential_gain"],
    ))

    return recommendations[:10]


def _estimate_effort(check_id: str) -> str:
    """Estimate implementation effort for a check."""
    low_effort = {
        "editorconfig", "env_documentation", "security_policy",
        "lock_file", "version_pinned", "pre_commit",
        "dependency_update_automation",
    }
    medium_effort = {
        "linter_configured", "formatter_configured", "type_checker",
        "test_framework", "ci_configured", "coverage_configured",
        "contributing_guide", "architecture_docs",
    }
    high_effort = {
        "agent_instructions", "readme_quality", "test_files_exist",
        "large_files",
    }

    if check_id in low_effort:
        return "low"
    elif check_id in medium_effort:
        return "medium"
    else:
        return "high"


def _estimate_impact(check: dict, axis_pct: float) -> str:
    """Estimate impact based on axis current state."""
    if axis_pct < 40:
        return "high"
    elif axis_pct < 70:
        return "medium"
    else:
        return "low"


# ─── JSON / Report Output ───────────────────────────────────

def save_json_report(result: dict[str, Any], output_path: Path) -> Path:
    """Save results as JSON file."""
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(result, f, indent=2, ensure_ascii=False)
    return output_path


def generate_radar_data(result: dict[str, Any]) -> dict[str, Any]:
    """Extract data suitable for radar chart visualization."""
    radar_data = []
    for ax_id, ax_data in result["axes"].items():
        ax_info = AXES[ax_id]
        radar_data.append({
            "axis": ax_info["name"],
            "value": round(ax_data["percentage"], 1),
            "icon": ax_info["icon"],
            "question": ax_info["question"],
        })
    return radar_data


# ─── CLI Entry Point ─────────────────────────────────────────

def main(argv: list[str] | None = None) -> None:
    parser = argparse.ArgumentParser(
        description="Agent Readiness Static Scanner — Three-Axis Maturity Model",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s /path/to/repo --axis instruct
  %(prog)s /path/to/repo --all --hybrid
  %(prog)s /path/to/repo --all --visualize
  %(prog)s /path/to/repo --full-report --output ./report/
        """,
    )
    parser.add_argument(
        "path", nargs="?", default=".",
        help="Path to the repository to scan (default: cwd)"
    )
    parser.add_argument(
        "--axis", choices=["instruct", "navigate", "validate"],
        help="Scan only this axis"
    )
    parser.add_argument(
        "--all", action="store_true",
        help="Scan all three axes (default if --axis omitted)"
    )
    parser.add_argument(
        "--hybrid", action="store_true",
        help="Enable hybrid mode (static + LLM semantic scoring)"
    )
    parser.add_argument(
        "--visualize", "--web", action="store_true",
        help="Generate and open HTML radar chart"
    )
    parser.add_argument(
        "--format", choices=["text", "json"], default="text",
        help="Output format (default: text)"
    )
    parser.add_argument(
        "--output", "-o", metavar="DIR",
        help="Output directory for reports"
    )
    parser.add_argument(
        "--compare", metavar="JSON_FILE",
        help="Compare with previous snapshot JSON file"
    )
    parser.add_argument(
        "--save-snapshot", action="store_true",
        help="Save results as snapshot for future comparison"
    )
    parser.add_argument(
        "--version", action="version", version=f"%(prog)s {VERSION}"
    )

    args = parser.parse_args(argv)

    # Resolve repo path
    repo = Path(args.path).resolve()
    if not repo.is_dir():
        print(f"ERROR: Not a directory: {repo}", file=sys.stderr)
        sys.exit(1)

    # Default to --all if no axis specified
    axis = args.axis if args.axis else (None if args.all else None)
    if axis is None and not args.all:
        axis = None  # Run all

    # Initialize Rich console
    console = Console()

    # Run scanner
    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        console=console,
    ) as progress:
        task = progress.add_task(f"Scanning {repo.name}...", total=None)
        result = run_checks(repo, axis=axis)
        progress.update(task, completed=True)

    # Handle hybrid mode
    if args.hybrid:
        result = _apply_hybrid_scoring(result, repo, console)

    # Output
    if args.format == "json":
        print(json.dumps(result, indent=2))
    else:
        print_terminal_report(result, console)

        # Print recommendations
        recs = generate_recommendations(result)
        if recs:
            rec_table = Table(title="\n🏆 Top Recommendations")
            rec_table.add_column("#", justify="right", width=3)
            rec_table.add_column("Recommendation", min_width=25)
            rec_table.add_column("Axis", width=10)
            rec_table.add_column("Effort", width=8)
            rec_table.add_column("Impact", width=8)
            rec_table.add_column("+Score", justify="right", width=7)

            for i, r in enumerate(recs, 1):
                ax_icon = AXES[r["axis"]]["icon"]
                rec_table.add_row(
                    str(i),
                    r["title"],
                    f"{ax_icon} {r['axis'].capitalize()}",
                    r["effort"],
                    r["impact"],
                    f"+{r['potential_gain']}",
                )
            console.print(rec_table)

    # Save outputs
    if args.output:
        out_dir = Path(args.output)
        json_path = save_json_report(result, out_dir / "report.json")
        console.print(f"\n[dim]Report saved: {json_path}[/dim]")

    # Save snapshot
    if args.save_snapshot:
        snap_dir = repo / ".agent-ready" / "snapshots"
        ts = result["timestamp"].replace(":", "-").split(".")[0]
        save_json_report(result, snap_dir / f"{ts}.json")
        console.print(f"[dim]Snapshot saved: {snap_dir / f'{ts}.json'}[/dim]")

    # Comparison mode
    if args.compare:
        _print_comparison(result, args.compare, console)

    # Visualize
    if args.visualize:
        _generate_and_open_radar(result, console)


def _apply_hybrid_scoring(
    result: dict[str, Any],
    repo: Path,
    console: Console,
) -> dict[str, Any]:
    """
    Apply hybrid scoring: combine static (60%) with LLM semantic (40%).
    
    If no LLM API key available, falls back to static-only with a note.
    """
    api_key = __import__("os").environ.get("OPENAI_API_KEY") or \
              __import__("os").environ.get("ANTHROPIC_API_KEY")

    if not api_key:
        console.print("[yellow]⚠ No LLM API key found. Hybrid mode: static-only.[/yellow]")
        console.print("[dim]Set OPENAI_API_KEY or ANTHROPIC_API_KEY for full hybrid scoring.[/dim]")
        result["_hybrid_mode"] = "static_only"
        return result

    # Import here to avoid hard dependency
    try:
        import urllib.request
        import json as _json

        console.print("[dim]Running LLM semantic analysis...[/dim]")

        for ax_id, ax_data in result["axes"].items():
            llm_score = _query_llm_axis(repo, ax_id, api_key)
            if llm_score is not None:
                # Combine: 60% static + 40% LLM
                static_pct = ax_data["percentage"]
                combined = round(static_pct * 0.6 + llm_score * 0.4, 1)
                ax_data["llm_percentage"] = llm_score
                ax_data["percentage"] = combined

        # Recalculate overall
        total_combined = sum(ax["percentage"] for ax in result["axes"].values())
        avg_combined = round(total_combined / len(result["axes"]), 1)
        level, level_name = _calculate_maturity_level(avg_combined)
        result["overall"]["percentage"] = avg_combined
        result["overall"]["level"] = level
        result["overall"]["level_name"] = level_name
        result["_hybrid_mode"] = "full"

        console.print("[green]✓ Hybrid scoring applied (60% static + 40% LLM)[/green]")

    except ImportError:
        console.print("[yellow]⚠ Hybrid scoring requires urllib (should be available).[/yellow]")
        result["_hybrid_mode"] = "error"
    except Exception as e:
        console.print(f"[yellow]⚠ LLM scoring failed: {e}[/yellow]")
        result["_hybrid_mode"] = "error"

    return result


def _query_llm_axis(repo: Path, axis: str, api_key: str) -> float | None:
    """Query LLM for semantic quality assessment of an axis."""
    import urllib.request
    import json as _json

    axis_prompts = {
        "instruct": (
            "Evaluate this codebase's INSTRUCTION quality for AI agents. "
            "Consider: Is there clear guidance for agents? Are conventions documented? "
            "Is the project's purpose clear? Rate 0-100."
        ),
        "navigate": (
            "Evaluate this codebase's NAVIGABILITY for AI agents. "
            "Consider: Is the code structure logical? Are naming conventions consistent? "
            "Can an agent find what it needs? Rate 0-100."
        ),
        "validate": (
            "Evaluate this codebase's VALIDATION infrastructure for AI agents. "
            "Consider: Can changes be automatically verified? Are tests meaningful? "
            "Is there CI/CD? Rate 0-100."
        ),
    }

    # Gather context files per axis
    context_files = {
        "instruct": ["README.md", "CLAUDE.md", "CONTRIBUTING.md", "ARCHITECTURE.md"],
        "navigate": ["pyproject.toml", ".editorconfig", "src/", "lib/"],
        "validate": ["pytest.ini", "conftest.py", ".github/workflows/"],
    }

    context_parts = []
    for cf in context_files.get(axis, []):
        content = _read_file_content(repo, cf)
        if content:
            # Truncate long files
            context_parts.append(f"=== {cf} ===\n{content[:2000]}")

    # Also add file tree
    try:
        file_tree = []
        for p in sorted(repo.iterdir()):
            if p.name.startswith(".") or p.name == "__pycache__":
                continue
            if p.is_file():
                file_tree.append(f"  {p.name}")
            elif p.is_dir():
                file_tree.append(f"  {p.name}/")
        context_parts.append("=== FILE TREE ===\n" + "\n".join(file_tree[:30]))
    except Exception:
        pass

    prompt = axis_prompts.get(axis, "")
    context = "\n\n".join(context_parts)[:6000]

    payload = _json.dumps({
        "model": "gpt-4o-mini",
        "messages": [
            {"role": "system", "content": "You are a codebase evaluator. Respond ONLY with a JSON object: {\"score\": 0-100, \"reason\": \"string\"}"},
            {"role": "user", "content": f"{prompt}\n\n## Repository Context\n{context}"},
        ],
        "response_format": {"type": "json_object"},
        "temperature": 0.1,
        "max_tokens": 150,
    }).encode()

    req = urllib.request.Request(
        "https://api.openai.com/v1/chat/completions",
        data=payload,
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {api_key}",
        },
    )

    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            data = _json.loads(resp.read().decode())
            content = data["choices"][0]["message"]["content"]
            result = _json.loads(content)
            return float(result.get("score", 50))
    except Exception as e:
        return None


def _print_comparison(
    result: dict[str, Any],
    compare_path: str,
    console: Console,
) -> None:
    """Print before/after comparison table."""
    compare_file = Path(compare_path)
    if not compare_file.exists():
        console.print(f"[red]Snapshot file not found: {compare_path}[/red]")
        return

    with open(compare_file) as f:
        previous = json.load(f)

    table = Table(title="📊 Before → After Comparison")
    table.add_column("Axis", style="bold")
    table.add_column("Before", justify="right")
    table.add_column("After", justify="right")
    table.add_column("Delta", justify="right")

    for ax_id in result["axes"]:
        before_pct = previous.get("axes", {}).get(ax_id, {}).get("percentage", 0)
        after_pct = result["axes"][ax_id]["percentage"]
        delta = after_pct - before_pct
        delta_str = f"[green]+{delta:.1f}%[/green]" if delta >= 0 else f"[red]{delta:.1f}%[/red]"
        icon = AXES[ax_id]["icon"]
        table.add_row(
            f"{icon} {ax_id.capitalize()}",
            f"{before_pct:.1f}%",
            f"{after_pct:.1f}%",
            delta_str,
        )

    console.print(table)


def _generate_and_open_radar(result: dict[str, Any], console: Console) -> None:
    """Generate HTML radar chart and open in browser."""
    import webbrowser
    import tempfile

    radar_data = generate_radar_data(result)
    html = _build_radar_html(radar_data, result)

    # Write to temp file and open
    tmp = tempfile.NamedTemporaryFile(
        mode="w", suffix=".html", delete=False, prefix="agent-ready-radar-"
    )
    tmp.write(html)
    tmp.close()

    console.print(f"\n[dim]Radar chart: {tmp.name}[/dim]")
    webbrowser.open(f"file://{tmp.name}")


def _build_radar_html(radar_data: list[dict], result: dict) -> str:
    """Build standalone HTML page with Chart.js radar chart."""
    labels = [d["axis"] for d in radar_data]
    values = [d["value"] for d in radar_data]
    colors_map = {
        "INSTRUCT": "54, 162, 235",   # blue
        "NAVIGATE": "75, 192, 192",   # cyan
        "VALIDATE": "40, 167, 69",    # green
    }
    colors = [colors_map.get(d["axis"], "201, 203, 207") for d in radar_data]

    # Determine overall color
    overall_pct = result["overall"]["percentage"]
    if overall_pct >= 70:
        bg_color = "17, 24, 39"  # dark (good)
        text_color = "229, 231, 235"
    elif overall_pct >= 45:
        bg_color = "30, 27, 75"  # medium-dark purple
        text_color = "236, 239, 244"
    else:
        bg_color = "64, 32, 32"  # dark red tint
        text_color = "252, 211, 77"

    level_name = result["overall"]["level_name"]
    level = result["overall"]["level"]

    return f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Agent Readiness — {result['repo_name']}</title>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4"></script>
<style>
* {{ margin: 0; padding: 0; box-sizing: border-box; }}
body {{
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    background: rgb({bg_color});
    color: rgb({text_color});
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 100vh;
    padding: 20px;
}}
.container {{
    max-width: 800px;
    width: 100%;
}}
.header {{
    text-align: center;
    margin-bottom: 24px;
}}
.header h1 {{ font-size: 1.5rem; margin-bottom: 4px; }}
.header .subtitle {{ font-size: 0.9rem; opacity: 0.7; }}
.badge {{
    display: inline-block;
    padding: 4px 16px;
    border-radius: 20px;
    font-size: 0.85rem;
    font-weight: bold;
    margin-top: 8px;
}}
.level-1 {{ background: rgba(239,68,68,0.3); color: #fca5a5; }}
.level-2 {{ background: rgba(245,158,11,0.3); color: #fde68a; }}
.level-3 {{ background: rgba(59,130,246,0.3); color: #93c5fd; }}
.level-4 {{ background: rgba(16,185,129,0.3); color: #6ee7b7; }}
.level-5 {{ background: rgba(139,92,246,0.3); color: #d8b4fe; }}
.chart-container {{
    position: relative;
    height: 400px;
    width: 100%;
}}
.details {{
    margin-top: 24px;
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 12px;
}}
.detail-card {{
    background: rgba(255,255,255,0.05);
    border: 1px solid rgba(255,255,255,0.1);
    border-radius: 12px;
    padding: 16px;
    text-align: center;
}}
.detail-card .score {{ font-size: 2rem; font-weight: bold; }}
.detail-card .label {{ font-size: 0.85rem; opacity: 0.7; margin-top: 4px; }}
.footer {{
    text-align: center;
    margin-top: 24px;
    font-size: 0.8rem;
    opacity: 0.4;
}}
</style>
</head>
<body>
<div class="container">
    <div class="header">
        <h1>🤖 Agent Readiness Assessment</h1>
        <div class="subtitle">{result['repo_name']} • {result['timestamp']}</div>
        <div class="badge level-{level}">
            Level {level}: {level_name} — {overall_pct}%
        </div>
    </div>

    <div class="chart-container">
        <canvas id="radarChart"></canvas>
    </div>

    <div class="details">
        {''.join(f'''
        <div class="detail-card">
            <div class="score" style="color: rgb({c});">{v:.0f}%</div>
            <div class="label">{d['icon']} {d['axis']}</div>
            <div style="font-size:0.75rem;opacity:0.5;margin-top:4px;">{d['question']}</div>
        </div>''' for d, c, v in zip(radar_data, colors, values))}
    </div>

    <div class="footer">
        Generated by Agent Ready Scanner v{VERSION}
    </div>
</div>

<script>
const ctx = document.getElementById('radarChart').getContext('2d');
new Chart(ctx, {{
    type: 'radar',
    data: {{
        labels: {labels},
        datasets: [{{
            label: 'Readiness Score',
            data: {values},
            fill: true,
            backgroundColor: 'rgba(54, 162, 235, 0.15)',
            borderColor: 'rgba(54, 162, 235, 1)',
            pointBackgroundColor: ['rgba({c},1)' for c in colors],
            pointBorderColor: '#fff',
            pointHoverBackgroundColor: '#fff',
            pointHoverBorderColor: ['rgba({c},1)' for c in colors],
            borderWidth: 2,
        }}]
    }},
    options: {{
        responsive: true,
        maintainAspectRatio: false,
        scales: {{
            r: {{
                beginAtZero: true,
                max: 100,
                ticks: {{
                    stepSize: 20,
                    color: 'rgba({text_color}, 0.7)',
                    backdropColor: 'transparent',
                }},
                grid: {{
                    color: 'rgba(255,255,255,0.08)',
                }},
                angleLines: {{
                    color: 'rgba(255,255,255,0.08)',
                }},
                pointLabels: {{
                    color: 'rgba({text_color}, 0.9)',
                    font: {{ size: 13, weight: 'bold' }},
                }},
            }}
        }},
        plugins: {{
            legend: {{ display: false }},
            tooltip: {{
                callbacks: {{
                    label: function(context) {{
                        return context.label + ': ' + context.raw + '%';
                    }}
                }}
            }}
        }}
    }}
}});
</script>
</body>
</html>"""


if __name__ == "__main__":
    main()
```

---

### Test Plan per `scan_static.py`

```bash
# Test 1: Scan demo-bad repo (expect low scores)
python scripts/scan_static.py repos/demo-bad/ --all --format json | python -c "
import json, sys
d = json.load(sys.stdin)
assert d['overall']['percentage'] < 40, f'Expected <40%, got {d}'
print('✓ Test 1 PASS: demo-bad scores low'
"

# Test 2: Scan demo-good repo (expect high scores)
python scripts/scan_static.py repos/demo-good/ --all --format json | python -c "
import json, sys
d = json.load(sys.stdin)
assert d['overall']['percentage'] > 65, f'Expected >65%, got {d}'
print('✓ Test 2 PASS: demo-good scores high'
"

# Test 3: Single axis mode
python scripts/scan_static.py repos/demo-bad/ --axis instruct --format json | python -c "
import json, sys
d = json.load(sys.stdin)
assert 'instruct' in d['axes']
assert 'navigate' not in d['axes']
print('✓ Test 3 PASS: single axis works'
"

# Test 4: JSON output validity
python scripts/scan_static.py repos/demo-bad/ --all --format json | python -m json.tool > /dev/null && echo '✓ Test 4 PASS: valid JSON'

# Test 5: Snapshot save
python scripts/scan_static.py repos/demo-bad/ --all --save-snapshot
test -f repos/demo-bad/.agent-ready/snapshots/*.json && echo '✓ Test 5 PASS: snapshot saved' || echo '✗ Test 5 FAIL'

# Test 6: Radar HTML generation
python scripts/scan_static.py repos/demo-bad/ --all --visualize 2>&1 | grep -q "Radar chart" && echo '✓ Test 6 PASS: radar generated'
```
