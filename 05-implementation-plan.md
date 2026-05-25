# Phase 5 — Implementation Specification: `scan_static.py`

> **Document type**: Production-grade implementation specification
> **Target reader**: AI coding agent working inside `github.com/RisorseArtificiali/agent-ready-skill`
> **Output**: Two new files (`scripts/scan_static.py`, `tests/test_scan_static.py`) plus `requirements-workshop.txt`
> **Forbidden**: Modifying any file under `skills/`

---

## 1. Spec Header

### 1.1 Title

**`scan_static.py` — Deterministic Three-Axis Agent-Readiness Scanner**

### 1.2 Purpose

`scan_static.py` is a single-file Python 3.11+ CLI that scores any local
repository against the canonical 8-dimension agent-readiness rubric defined in
`skills/agent-ready/references/scoring.md`, then re-projects those eight
dimensions onto three derived **axes** — INSTRUCT, NAVIGATE, VALIDATE — and a
five-level **maturity model** (Foundational → Autonomous).

The scanner is **deterministic and static-only by default**: the same repository
at the same commit MUST produce the same JSON output. An optional `--hybrid`
mode augments two or three inherently subjective sub-criteria (e.g. README
quality, CLAUDE.md clarity) with an LLM judgement, but the canonical mode is
purely file-system inspection.

### 1.3 Target Audience

A senior Python engineer (human or AI agent) who:

1. Has cloned `github.com/RisorseArtificiali/agent-ready-skill` locally.
2. Has read this document, `skills/agent-ready/references/scoring.md`, and the
   five `SKILL.md` files inside `skills/`.
3. Will implement the scanner end-to-end in **two to three working days**.

The audience should **not** need to ask any clarifying questions about
behaviour, scoring, output format, or test expectations. Anything ambiguous
in this document is a spec defect; the canonical rubric in
`skills/agent-ready/references/scoring.md` is the tie-breaker.

### 1.4 Implementation Paths (Authoritative)

| Path                                    | Role                                  | New / Existing |
|-----------------------------------------|---------------------------------------|----------------|
| `scripts/scan_static.py`                | The scanner itself                    | NEW            |
| `tests/test_scan_static.py`             | Pytest behavioural suite              | NEW            |
| `requirements-workshop.txt`             | Pinned dependencies                   | NEW            |
| `.agent-ready/snapshots/`               | Runtime artefact directory            | NEW (runtime)  |
| `skills/**`                             | Canonical skills (READ-ONLY)          | EXISTING       |
| `skills/agent-ready/references/scoring.md` | Canonical 8-dim rubric             | EXISTING       |

### 1.5 Guardrails (Strict)

1. **Additive only.** The scanner MUST NOT write, delete, or rename any file
   under `skills/`. The scanner MUST NOT mutate the target repository it is
   scanning, except for opt-in artefacts under `.agent-ready/` when the user
   passes `--save-snapshot` or `--output`.
2. **Single file.** All scanner logic lives in `scripts/scan_static.py`. No
   helper modules, no `scripts/` package, no `__init__.py`.
3. **Python 3.11+ only.** Use `tomllib` from the standard library. Do not
   add `tomli` as a dependency.
4. **No network in static mode.** The default scan path MUST NOT make HTTP
   calls. Network is permitted only when `--hybrid` is set AND an LLM API key
   is in the environment.
5. **No bundling.** The HTML radar pulls Chart.js from the JSDelivr CDN at
   runtime; it MUST NOT ship a copy of Chart.js inside the repo.
6. **No emoji-only diagnostics.** Every emoji must be paired with text so that
   stdout is grep-able and screen-reader-friendly.

---

## 2. Hand-off Context

### 2.1 The Canonical 8-Dimension Rubric (Source of Truth)

The canonical rubric lives at
`skills/agent-ready/references/scoring.md` and defines eight weighted
dimensions summing to **100 points**. The agent MUST read that file before
writing any check logic — sub-criteria descriptions and partial-credit hints
live there, not in this document.

The dimensions, their canonical snake_case JSON keys, and their weights are
fixed and MUST NOT be changed:

| #  | Dimension                          | JSON key                      | Weight |
|----|------------------------------------|-------------------------------|--------|
| D1 | Agent Instructions                 | `agent_instructions`          | 20     |
| D2 | Project Navigability               | `project_navigability`        | 18     |
| D3 | Testing & Validation               | `testing_validation`          | 16     |
| D4 | CI/CD & Automation                 | `cicd_automation`             | 12     |
| D5 | Spec-Driven Workflow               | `spec_driven_workflow`        | 10     |
| D6 | Skills & Tooling                   | `skills_tooling`              |  8     |
| D7 | Documentation & Comprehension      | `documentation_comprehension` |  8     |
| D8 | Claude-Specific                    | `claude_specific`             |  8     |
|    | **Total**                          |                               | **100** |

> **Key-name fix.** The file `skills/agent-ready-scan/SKILL.md` uses
> `documentation` for D7. This is inconsistent with `scoring.md`, which uses
> `documentation_comprehension`. The scanner MUST emit
> `documentation_comprehension` in JSON output. Do not modify either skill
> file; just standardise on the rubric key.

### 2.2 Two-Layer View (From `scoring.md`)

The rubric is also partitioned into two layers:

- **Layer A — Agnostic** (D1-D5): maximum 76 points. Frameworks- and
  tool-agnostic signals applicable to any project.
- **Layer B — Claude-specific** (D6-D8): maximum 24 points. Signals tied to
  Claude Code, skills, and Claude-specific instructions.

The scanner emits both layer subtotals so callers can present an
"agnostic vs Claude-specific" breakdown.

### 2.3 Score Bands (From `scoring.md`)

| Band                | Range  | Visual icon |
|---------------------|--------|-------------|
| Not Ready           | 0-30   | red         |
| Partially Ready     | 31-60  | yellow      |
| Ready               | 61-80  | green       |
| Optimized           | 81-100 | trophy/gold |

The scanner MUST report this band alongside the maturity level.

### 2.4 Three-Axis Re-Projection (Workshop Lens)

The eight dimensions are deterministically remapped to three axes by sum of
weights:

```
INSTRUCT (38) = D1 (20) + D5 (10) + D8 ( 8)
NAVIGATE (34) = D2 (18) + D7 ( 8) + D6 ( 8)
VALIDATE (28) = D3 (16) + D4 (12)
                ─────────────────────
TOTAL    100
```

This is the **only** partition that splits the 8 dimensions cleanly into
38/34/28 weight buckets while preserving the canonical dimension weights.
The scanner MUST NOT introduce other groupings.

Each axis answers one workshop question:

- **INSTRUCT**: "Does the agent understand WHAT we want?"
- **NAVIGATE**: "Can the agent find its way around?"
- **VALIDATE**: "Can the agent verify its work is correct?"

### 2.5 Maturity Model (Five Levels, Gate-Based)

Computed from **overall percentage** and from **each axis percentage**
independently (so a repo can be L4 on NAVIGATE while L2 on VALIDATE).

| Level | Name          | Threshold (≥) | Meaning                                                  |
|-------|---------------|---------------|----------------------------------------------------------|
| 1     | Foundational  | 40            | Project exists; agents can find basic files.             |
| 2     | Guided        | 55            | Agents can follow instructions; basic guidance exists.   |
| 3     | Structured    | 70            | Agents navigate autonomously; tooling is consistent.     |
| 4     | Optimized     | 85            | Quality gates exist; agents validate their work.         |
| 5     | Autonomous    | 95            | Agents act as team members; minimal oversight needed.    |

If the overall percentage is **below 40**, level is **0 — "Pre-Foundational"**
(reported as level=0, level_name="Pre-Foundational") so output is always
populated.

### 2.6 Determinism Contract

- File traversal MUST use sorted output (`sorted(repo.glob(...))`,
  `sorted(repo.rglob(...))`) so two runs on the same commit produce
  identical JSON.
- Timestamps in the JSON output ARE allowed to differ between runs (only
  field `timestamp` and the `snapshots/<ts>.json` filename); all other fields
  MUST be byte-identical.
- `--hybrid` mode is explicitly excluded from this contract. The static-only
  mode (default) is the deterministic mode.

### 2.7 Output JSON: Strict Superset Rule

The scanner's JSON output MUST be a **strict superset** of the schema
documented in `skills/agent-ready/references/scoring.md`:

- Keep every key under `dimensions[*]` exactly as `scoring.md` specifies.
- Add three new top-level blocks: `axes`, `overall.layer_agnostic`,
  `overall.layer_claude`, and `hybrid_mode`.

Section 3.5 of this document defines the full schema.

---

## 3. `scripts/scan_static.py` — Full Specification

### 3.1 CLI Surface

Use `argparse` with `RawDescriptionHelpFormatter`. The CLI is exposed as a
single entry point: `python scripts/scan_static.py [args...]`.

#### 3.1.1 Positional argument

| Name        | Type | Default | Help                                              |
|-------------|------|---------|---------------------------------------------------|
| `repo_path` | path | `.`     | Path to the repository root to scan. If the path is not a directory, exit code 2 with a clear stderr message. |

#### 3.1.2 Axis selection (mutually exclusive group)

| Flag                                | Type    | Default       | Help                                                |
|-------------------------------------|---------|---------------|-----------------------------------------------------|
| `--axis {instruct,navigate,validate}` | choice  | None          | Score only one axis. Mutually exclusive with `--all`. |
| `--all`                             | flag    | implicit True | Score all three axes. Default if neither flag given. |

Implementation note: build an `add_mutually_exclusive_group()`; if neither
flag is set, default to `--all`.

#### 3.1.3 Hybrid mode

| Flag                  | Type | Default | Help                                                          |
|-----------------------|------|---------|---------------------------------------------------------------|
| `--hybrid`            | flag | False   | Enable LLM enrichment for subjective sub-criteria. Falls back to static-only if no API key is set. |
| `--llm-blend FLOAT`   | float| 0.5     | Static vs LLM blend weight when `--hybrid` is active. 0.0 = static-only, 1.0 = LLM-only. Range: 0.0..1.0. |

#### 3.1.4 Output format and destination

| Flag                                 | Type   | Default  | Help                                                          |
|--------------------------------------|--------|----------|---------------------------------------------------------------|
| `--format {pretty,json,markdown}`    | choice | `pretty` | Output renderer. `pretty` uses `rich`; `json` is machine-readable; `markdown` is human-readable plain text. |
| `--output PATH`                      | path   | stdout   | Write the chosen format to a file instead of stdout. Parent dirs are created if missing. |
| `--full-report DIR`                  | path   | None     | Write **all** formats (`report.txt`, `report.json`, `report.md`, `report.html`) into `DIR`. Mutually exclusive with `--format` and `--output`. |

#### 3.1.5 Visualisation

| Flag           | Type | Default | Help                                                       |
|----------------|------|---------|------------------------------------------------------------|
| `--visualize`  | flag | False   | Write a self-contained HTML radar to a temp file and open it in the default browser. |

#### 3.1.6 Snapshot and comparison

| Flag                  | Type | Default | Help                                                          |
|-----------------------|------|---------|---------------------------------------------------------------|
| `--save-snapshot`     | flag | False   | Persist the JSON output to `<repo>/.agent-ready/snapshots/YYYYMMDD-HHMMSS.json`. |
| `--compare PATH`      | path | None    | Load a previous snapshot JSON and print the per-dim / per-axis delta table. |

#### 3.1.7 Miscellaneous

| Flag        | Type | Default | Help                                |
|-------------|------|---------|-------------------------------------|
| `--quiet`   | flag | False   | Suppress non-essential stderr output. |
| `--version` | flag | -       | Print scanner version and exit 0.   |

#### 3.1.8 Examples block (placed under `epilog`)

```
Examples:
  scan_static.py .                                 # Scan cwd, pretty output
  scan_static.py /repo --axis instruct             # One axis only
  scan_static.py /repo --all --visualize           # Radar HTML + browser
  scan_static.py /repo --hybrid                    # Static + LLM blend
  scan_static.py /repo --full-report ./report/     # All formats at once
  scan_static.py /repo --save-snapshot             # Persist for diff later
  scan_static.py /repo --compare snap.json         # Diff vs snapshot
```

#### 3.1.9 Exit codes

| Code | Meaning                                                              |
|------|----------------------------------------------------------------------|
| 0    | Scan completed (independent of score).                               |
| 1    | Internal error (caught exception in scoring engine).                 |
| 2    | Bad CLI arguments (e.g. repo path not a directory; both `--axis` and `--all`). |
| 3    | I/O error while writing report or snapshot.                          |

### 3.2 Architecture

#### 3.2.1 Data flow

```
                ┌─────────────┐
   CLI args ──▶ │  parse_cli  │
                └──────┬──────┘
                       ▼
                ┌─────────────┐
                │  load_repo  │ ── resolves path, checks it is a dir,
                └──────┬──────┘    builds a RepoContext
                       ▼
                ┌─────────────┐
                │ run_checks  │ ── iterates 8 dimensions × N checks,
                └──────┬──────┘    returns DimensionResult[8]
                       ▼
                ┌─────────────┐
                │  aggregate  │ ── dims → axes → overall + maturity
                └──────┬──────┘
                       ▼
              (optional) ┌──────────────────────┐
                         │  maybe_enrich_llm    │
                         └──────────────────────┘
                       ▼
                ┌─────────────┐
                │  emit_*     │ ── pretty | json | markdown | html
                └──────┬──────┘
                       ▼
                stdout / file(s)
```

#### 3.2.2 Function inventory

The scanner has roughly 14 named functions (final number may vary ±2). Each
has exactly one responsibility:

| Function                    | Responsibility                                                |
|-----------------------------|---------------------------------------------------------------|
| `_file_exists`              | Return first matching file path (relative) or None.           |
| `_read_file_content`        | Safe UTF-8 read with `errors="ignore"`; returns None on miss. |
| `_content_contains`         | Case-insensitive substring match across patterns.             |
| `_glob_count`               | Count files matching a glob, skipping `.git`/`__pycache__`.   |
| `_parse_pyproject`          | `tomllib.loads` of pyproject.toml; returns `{}` on miss/error. |
| `run_check`                 | Execute a single check definition; catches and reports errors. |
| `score_dimension`           | Aggregate checks within one dimension → DimensionResult.      |
| `score_axis`                | Sum DimensionResults that belong to one axis → AxisResult.    |
| `score_overall`             | Sum axis raw scores → OverallResult; compute layer subtotals. |
| `compute_maturity`          | Map a percentage to (level, level_name).                      |
| `emit_pretty`               | Rich-based terminal renderer.                                 |
| `emit_json`                 | JSON serialiser (Section 3.5 schema).                         |
| `emit_markdown`             | Markdown renderer.                                            |
| `emit_html_radar`           | Self-contained HTML page builder.                             |
| `save_snapshot`             | Write JSON snapshot to `.agent-ready/snapshots/<ts>.json`.    |
| `compute_diff`              | Compute per-dim/per-axis delta vs a snapshot.                 |
| `maybe_enrich_with_llm`     | Conditional LLM enrichment, with hard 10s timeout.            |
| `main`                      | CLI entry point.                                              |

#### 3.2.3 Performance budget

The scanner MUST complete a scan of a representative 5 000-file Python
repository in **≤ 10 s** on a modern laptop (e.g. Apple M2, mid-range x86_64
laptop). Achieve this by:

- Caching the result of `_read_file_content` per `(repo, filepath)` tuple in
  a module-level dict so the same file is not opened twice.
- Using `Path.glob` / `Path.rglob` instead of shelling out.
- Reading at most 64 KB of any single file (use `read_text` then slice).
- Skipping `.git`, `node_modules`, `__pycache__`, `.venv`, `venv`, `.tox`,
  `dist`, `build` directories early.

### 3.3 Check Catalog

This section enumerates checks per dimension. The agent MUST cross-reference
`skills/agent-ready/references/scoring.md` for the authoritative sub-criteria
text. Where this document and `scoring.md` disagree on a sub-criterion
description, `scoring.md` wins.

Each check is described by:

- **id**: snake_case identifier, unique repo-wide.
- **name**: human-readable label.
- **internal_weight**: integer; sum of `internal_weight` across checks in
  a dimension equals 100.
- **inspection**: which files / globs / regex / config keys to inspect.
- **pass_condition**: boolean criterion for a full pass.
- **partial_credit_formula**: if applicable, how to compute 0 < credit < 1.
- **score_formula**: `score = internal_weight * partial_credit / 100`
  (so the dimension internal raw sum is in 0..100, then scaled by the
  dimension weight).

> Reading guide: "internal raw" stays in 0..100 within each dimension to make
> partial credit composable. The final dimension score is
> `dimension_score = internal_raw / 100 * dimension_weight`, so the eight
> dimension scores still sum to 0..100.

#### 3.3.1 D1 — Agent Instructions (weight 20)

| id                          | name                                | internal_weight | inspection                                                                                       | pass_condition                                                          | partial_credit_formula                                  |
|-----------------------------|-------------------------------------|-----------------|--------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------|---------------------------------------------------------|
| `d1_instruction_file_exists`| Agent instruction file present       | 30              | `CLAUDE.md`, `AGENTS.md`, `.cursorrules`, `.github/copilot-instructions.md`                       | At least one file exists.                                              | none (binary).                                          |
| `d1_instruction_length`     | Instruction file substantive         | 20              | Same files; measure character count.                                                             | ≥ 800 characters.                                                       | `min(chars, 800) / 800`.                                |
| `d1_has_conventions`        | Code conventions documented          | 15              | Same files; search for keywords `convention`, `style`, `naming`, `lint`, `format`.                | At least two keywords present.                                          | `min(hits, 2) / 2`.                                     |
| `d1_has_examples`           | Concrete examples in instructions    | 15              | Same files; count fenced code blocks (`` ``` ``).                                                | ≥ 2 code blocks.                                                        | `min(blocks, 2) / 2`.                                   |
| `d1_has_do_dont`            | Do / Don't or guardrails             | 10              | Same files; regex `(?im)^\s*#+\s*(do|don'?t|guardrails?|rules?)\b`.                              | ≥ 1 match.                                                              | none (binary).                                          |
| `d1_root_anchored`          | Instruction file at repo root        | 10              | File path of the matched instruction file.                                                       | At least one of the matches is at depth 0 (root).                       | none (binary).                                          |

#### 3.3.2 D2 — Project Navigability (weight 18)

| id                          | name                                | internal_weight | inspection                                                                                                                                                                | pass_condition                                                                | partial_credit_formula |
|-----------------------------|-------------------------------------|-----------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------|------------------------|
| `d2_readme_exists`          | README present                       | 15              | `README.md`, `README.rst`, `README` (root).                                                                                                                               | One exists.                                                                  | binary.                |
| `d2_readme_quality`         | README has setup + usage             | 20              | README content. Search for sections `install`, `setup`, `usage`, `getting started`, `quick start`.                                                                        | ≥ 3 of 5 sections present.                                                  | `min(hits, 3) / 3`.    |
| `d2_directory_structure`    | Logical directory layout             | 15              | Look for one of: `src/`, `lib/`, `<pkg>/__init__.py`, `app/`.                                                                                                            | At least one present.                                                       | binary.                |
| `d2_no_root_clutter`        | Root not cluttered                   | 10              | Count files (not dirs) directly under root.                                                                                                                               | ≤ 25 files.                                                                  | `clamp(1 - (count-25)/25, 0, 1)`. |
| `d2_consistent_naming`      | Consistent file naming               | 10              | Sample up to 50 `.py` files. Bucket names into snake_case vs camelCase vs kebab-case.                                                                                     | Dominant style holds ≥ 90 % of names.                                       | `(dominant / total)`.  |
| `d2_navigability_signals`   | Tree / index files                   | 10              | Files matching `STRUCTURE.md`, `TREE.md`, `docs/index.md`, `docs/README.md`.                                                                                              | One exists.                                                                  | binary.                |
| `d2_no_oversized_files`     | No file > 600 LOC                    | 10              | `rglob('*.py')`, count lines.                                                                                                                                             | No file > 600 lines.                                                        | `clamp(1 - (n_large/3), 0, 1)`. |
| `d2_python_version_pinned`  | Python version pinned                | 10              | `.python-version`, `.tool-versions`, or `requires-python` in pyproject.toml.                                                                                              | One exists.                                                                  | binary.                |

#### 3.3.3 D3 — Testing & Validation (weight 16)

| id                          | name                                | internal_weight | inspection                                                                                                                  | pass_condition                                                          | partial_credit_formula      |
|-----------------------------|-------------------------------------|-----------------|-----------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------|-----------------------------|
| `d3_test_framework`         | Test framework configured            | 25              | `pytest.ini`, `conftest.py`, `[tool.pytest.ini_options]` in pyproject, `[pytest]` in setup.cfg, `tox.ini`.                  | At least one configured.                                                | binary.                     |
| `d3_test_files_present`     | Test files exist                     | 25              | Globs `tests/**/*.py`, `**/test_*.py`, `**/*_test.py`. Exclude `.tox`, `.venv`, `node_modules`.                            | ≥ 3 test files.                                                         | `min(count, 10) / 10`.      |
| `d3_test_to_source_ratio`   | Test-to-source ratio                 | 15              | Compare count of test files vs `.py` source files (excluding tests).                                                       | ratio ≥ 0.3.                                                            | `min(ratio, 0.3) / 0.3`.    |
| `d3_coverage_configured`    | Coverage tool configured             | 15              | `.coveragerc`, `[tool.coverage.*]` in pyproject, `[coverage:run]` in setup.cfg.                                            | One present.                                                            | binary.                     |
| `d3_pre_commit`             | Pre-commit hooks                     | 10              | `.pre-commit-config.yaml` / `.yml`.                                                                                         | Exists.                                                                  | binary.                     |
| `d3_makefile_or_taskrunner` | Make/Task entry point for tests      | 10              | `Makefile` containing `test:` target, or `taskfile.yml`, `noxfile.py`, `tox.ini`.                                           | One present and references tests.                                       | binary.                     |

#### 3.3.4 D4 — CI/CD & Automation (weight 12)

| id                          | name                                | internal_weight | inspection                                                                                              | pass_condition                                                            | partial_credit_formula     |
|-----------------------------|-------------------------------------|-----------------|---------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------|----------------------------|
| `d4_ci_present`             | CI configuration present             | 30              | `.github/workflows/*.yml`/`*.yaml`, `.gitlab-ci.yml`, `.circleci/config.yml`, `azure-pipelines.yml`.    | At least one exists.                                                     | binary.                    |
| `d4_ci_runs_tests`          | CI runs tests                        | 25              | CI files contain `pytest`, `python -m pytest`, `tox`, `make test`, or `nox`.                            | Present.                                                                  | binary.                    |
| `d4_ci_runs_lint`           | CI runs lint/format                  | 20              | CI files contain `ruff`, `flake8`, `black`, `pylint`, `mypy`.                                           | At least one tool referenced.                                            | binary.                    |
| `d4_ci_runs_on_pr`          | CI runs on pull requests             | 10              | YAML contains `pull_request:` or equivalent in non-GitHub CI.                                          | Present.                                                                  | binary.                    |
| `d4_release_automation`     | Release automation                   | 10              | `release-please-config.json`, `semantic-release` config, `release.yml`, `dependabot.yml`, `renovate.json`. | One present.                                                              | binary.                    |
| `d4_secrets_handling`       | Secrets handled safely               | 5               | `.env.example` exists AND `.env` is in `.gitignore`.                                                    | Both conditions.                                                          | `0.5` per condition.       |

#### 3.3.5 D5 — Spec-Driven Workflow (weight 10)

| id                          | name                                | internal_weight | inspection                                                                                                | pass_condition                                  | partial_credit_formula |
|-----------------------------|-------------------------------------|-----------------|-----------------------------------------------------------------------------------------------------------|--------------------------------------------------|------------------------|
| `d5_spec_directory`         | `specs/` or `docs/specs/` directory  | 25              | `specs/`, `docs/specs/`, `spec/`, `rfcs/`.                                                                | One present and contains ≥ 1 file.              | binary.                |
| `d5_adr_directory`          | ADR directory                        | 25              | `docs/adr/`, `adr/`, `architecture/decisions/`.                                                          | One present and contains ≥ 1 file.              | binary.                |
| `d5_issue_templates`        | Issue / PR templates                 | 20              | `.github/ISSUE_TEMPLATE/`, `.github/pull_request_template.md`.                                            | At least one exists.                            | binary.                |
| `d5_contributing_guide`     | CONTRIBUTING file                    | 15              | `CONTRIBUTING.md`, `docs/contributing.md`.                                                               | Exists.                                          | binary.                |
| `d5_changelog`              | CHANGELOG file                       | 15              | `CHANGELOG.md`, `HISTORY.md`, `NEWS.md`.                                                                 | Exists.                                          | binary.                |

#### 3.3.6 D6 — Skills & Tooling (weight 8) — *Claude-specific*

| id                          | name                                | internal_weight | inspection                                                                          | pass_condition                                  | partial_credit_formula        |
|-----------------------------|-------------------------------------|-----------------|-------------------------------------------------------------------------------------|--------------------------------------------------|-------------------------------|
| `d6_skills_directory`       | `skills/` directory                  | 35              | `skills/`, `.claude/skills/`.                                                       | Exists with ≥ 1 subdir.                          | binary.                       |
| `d6_skill_md_present`       | At least one SKILL.md                | 25              | `**/SKILL.md` (depth ≤ 4).                                                          | ≥ 1 file.                                        | `min(count, 3) / 3`.          |
| `d6_skill_frontmatter`      | SKILL.md frontmatter valid           | 20              | First 2 KB of each SKILL.md; check leading `---` block parses as YAML with `name`. | All SKILL.md files have valid frontmatter.       | `valid / total`.              |
| `d6_skill_references`       | Skills reference each other / docs   | 10              | Search SKILL.md content for relative links `./` or `../`.                          | ≥ 1 link found across all SKILL.md.              | binary.                       |
| `d6_skills_indexed`         | Skills indexed in main README        | 10              | README content mentions `skill`, `skills/`, or `agent-ready`.                       | Present.                                          | binary.                       |

#### 3.3.7 D7 — Documentation & Comprehension (weight 8)

| id                          | name                                | internal_weight | inspection                                                                                                | pass_condition                          | partial_credit_formula            |
|-----------------------------|-------------------------------------|-----------------|-----------------------------------------------------------------------------------------------------------|------------------------------------------|-----------------------------------|
| `d7_docs_directory`         | `docs/` directory                    | 25              | `docs/`, `documentation/`.                                                                               | Exists with ≥ 1 file.                    | binary.                           |
| `d7_docstring_density`      | Docstrings on public symbols         | 25              | Sample up to 30 `.py` files; for each top-level `def`/`class`, check next non-empty line starts with `"""` or `'''`. | ≥ 50 % of public symbols have a docstring. | `density / 0.5` (capped at 1).    |
| `d7_architecture_doc`       | ARCHITECTURE doc                     | 20              | `ARCHITECTURE.md`, `docs/architecture.md`, `docs/ARCHITECTURE.md`.                                       | Exists.                                  | binary.                           |
| `d7_api_doc_generator`      | API doc generator configured         | 15              | `mkdocs.yml`, `sphinx`'s `conf.py`, `pdoc` config block in pyproject.                                    | One present.                             | binary.                           |
| `d7_readme_diagrams`        | Diagrams or mermaid in docs          | 15              | Any `.md` under root or `docs/` containing ```` ```mermaid ```` fence or `.svg`/`.png` reference.        | At least one.                            | binary.                           |

#### 3.3.8 D8 — Claude-Specific (weight 8)

| id                          | name                                | internal_weight | inspection                                                                                                          | pass_condition                                            | partial_credit_formula |
|-----------------------------|-------------------------------------|-----------------|---------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------|------------------------|
| `d8_claude_md_root`         | `CLAUDE.md` at repo root             | 30              | `CLAUDE.md` (root only).                                                                                            | Exists.                                                    | binary.                |
| `d8_claude_md_substance`    | CLAUDE.md substantive                | 25              | `CLAUDE.md` content length.                                                                                         | ≥ 1 500 characters.                                       | `min(chars, 1500) / 1500`. |
| `d8_claude_settings`        | `.claude/` settings directory        | 15              | `.claude/`, `.claude/settings.json`, `.claude/settings.local.json`.                                                | At least one exists.                                       | binary.                |
| `d8_skills_referenced_in_claude_md` | CLAUDE.md mentions skills    | 15              | CLAUDE.md content contains `skills/`, `SKILL.md`, or `/sc:` or `/agent-ready`.                                     | Present.                                                   | binary.                |
| `d8_global_overrides_documented` | Project overrides documented   | 15              | CLAUDE.md content references `~/.claude/CLAUDE.md`, "global", or "override".                                       | Present.                                                   | binary.                |

> **Confirm against `scoring.md`.** Sub-criterion *names* above are
> functional; the agent MUST confirm against `scoring.md`'s D1-D8
> sub-criteria descriptions and adjust the `name` field (not the `id`) so
> messages shown to users match the canonical wording.

### 3.4 Scoring & Aggregation

#### 3.4.1 Per-check scoring

```
check.score = check.internal_weight * partial_credit / 100
where 0 <= partial_credit <= 1
```

Result: each check returns a float in `[0, internal_weight]`. The sum across
checks within a dimension is `dimension_internal_raw ∈ [0, 100]`.

#### 3.4.2 Per-dimension scoring

```
dimension_max          = dimension_weight   (e.g. 20 for D1)
dimension_score        = dimension_internal_raw / 100 * dimension_weight
dimension_percentage   = round(dimension_internal_raw, 1)
```

Note: `dimension_percentage` reports 0..100 (internal raw), not the weighted
share. This matches `scoring.md`'s schema.

#### 3.4.3 Per-axis scoring

```
axis_score             = sum(dimension_score for dim in axis.dimensions)
axis_max               = sum(dimension_weight for dim in axis.dimensions)
                         # INSTRUCT=38, NAVIGATE=34, VALIDATE=28
axis_percentage        = round(axis_score / axis_max * 100, 1)
```

#### 3.4.4 Overall scoring

```
overall_score          = sum(dimension_score for dim in all_dimensions)
overall_max            = 100
overall_percentage     = round(overall_score, 1)
layer_agnostic         = sum(dimension_score for dim in D1..D5)   # max 76
layer_claude           = sum(dimension_score for dim in D6..D8)   # max 24
```

Sanity check: `layer_agnostic + layer_claude == overall_score`.
Implementation MUST assert this (allow `≤ 0.01` tolerance).

#### 3.4.5 Maturity level

```python
def compute_maturity(percentage: float) -> tuple[int, str]:
    if percentage >= 95: return (5, "Autonomous")
    if percentage >= 85: return (4, "Optimized")
    if percentage >= 70: return (3, "Structured")
    if percentage >= 55: return (2, "Guided")
    if percentage >= 40: return (1, "Foundational")
    return (0, "Pre-Foundational")
```

Apply the same function to `overall_percentage` AND to each
`axis_percentage`, so each axis carries its own `(level, level_name)` pair.

#### 3.4.6 Score band

```python
def compute_band(percentage: float) -> str:
    if percentage <= 30: return "not_ready"
    if percentage <= 60: return "partially_ready"
    if percentage <= 80: return "ready"
    return "optimized"
```

### 3.5 JSON Output Schema

The scanner emits a JSON document conforming to the schema below. The schema
itself is JSON Schema Draft 2020-12. Field names use `snake_case`. Numeric
fields are JSON numbers (not strings). `null` is allowed only where noted.

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "required": [
    "version", "tool_version", "repo_name", "repo_path", "timestamp",
    "dimensions", "axes", "overall", "hybrid_mode"
  ],
  "properties": {
    "version":      { "type": "string", "const": "1.0" },
    "tool_version": { "type": "string", "pattern": "^[0-9]+\\.[0-9]+\\.[0-9]+" },
    "repo_name":    { "type": "string" },
    "repo_path":    { "type": "string" },
    "timestamp":    { "type": "string", "format": "date-time" },
    "hybrid_mode":  { "type": "boolean" },

    "dimensions": {
      "type": "object",
      "required": [
        "agent_instructions", "project_navigability", "testing_validation",
        "cicd_automation", "spec_driven_workflow", "skills_tooling",
        "documentation_comprehension", "claude_specific"
      ],
      "additionalProperties": false,
      "patternProperties": {
        "^[a-z_]+$": {
          "type": "object",
          "required": ["score", "max", "percentage", "checks", "recommendations"],
          "properties": {
            "score":      { "type": "number", "minimum": 0, "maximum": 20 },
            "max":        { "type": "integer", "enum": [8, 10, 12, 16, 18, 20] },
            "percentage": { "type": "number", "minimum": 0, "maximum": 100 },
            "checks": {
              "type": "array",
              "items": {
                "type": "object",
                "required": ["id", "name", "internal_weight", "score", "passed", "message"],
                "properties": {
                  "id":              { "type": "string" },
                  "name":            { "type": "string" },
                  "internal_weight": { "type": "integer", "minimum": 0, "maximum": 100 },
                  "score":           { "type": "number" },
                  "passed":          { "type": "boolean" },
                  "message":         { "type": "string" },
                  "details":         { "type": "string" },
                  "llm_adjusted":    { "type": "boolean" }
                }
              }
            },
            "recommendations": {
              "type": "array",
              "items": {
                "type": "object",
                "required": ["title", "effort", "impact", "potential_gain"],
                "properties": {
                  "title":          { "type": "string" },
                  "effort":         { "type": "string", "enum": ["low", "medium", "high"] },
                  "impact":         { "type": "string", "enum": ["low", "medium", "high"] },
                  "potential_gain": { "type": "number" }
                }
              }
            }
          }
        }
      }
    },

    "axes": {
      "type": "object",
      "required": ["instruct", "navigate", "validate"],
      "additionalProperties": false,
      "patternProperties": {
        "^(instruct|navigate|validate)$": {
          "type": "object",
          "required": ["score", "max", "percentage", "level", "level_name", "dimensions"],
          "properties": {
            "score":       { "type": "number" },
            "max":         { "type": "integer", "enum": [38, 34, 28] },
            "percentage":  { "type": "number", "minimum": 0, "maximum": 100 },
            "level":       { "type": "integer", "minimum": 0, "maximum": 5 },
            "level_name":  { "type": "string" },
            "band":        { "type": "string", "enum": ["not_ready", "partially_ready", "ready", "optimized"] },
            "dimensions":  { "type": "array", "items": { "type": "string" } }
          }
        }
      }
    },

    "overall": {
      "type": "object",
      "required": [
        "score", "max", "percentage", "level", "level_name", "band",
        "layer_agnostic", "layer_claude"
      ],
      "properties": {
        "score":          { "type": "number", "minimum": 0, "maximum": 100 },
        "max":            { "type": "integer", "const": 100 },
        "percentage":     { "type": "number", "minimum": 0, "maximum": 100 },
        "level":          { "type": "integer", "minimum": 0, "maximum": 5 },
        "level_name":     { "type": "string" },
        "band":           { "type": "string", "enum": ["not_ready", "partially_ready", "ready", "optimized"] },
        "layer_agnostic": { "type": "number", "minimum": 0, "maximum": 76 },
        "layer_claude":   { "type": "number", "minimum": 0, "maximum": 24 }
      }
    }
  }
}
```

#### 3.5.1 Strict-superset guarantee

The `dimensions` block is a **strict superset** of the schema described in
`skills/agent-ready/references/scoring.md`. Any consumer written against
the rubric's schema will continue to function. New top-level blocks
(`axes`, `overall`, `hybrid_mode`) are additive.

### 3.6 Pretty Output (Rich)

The pretty renderer uses `rich.console.Console`, `rich.panel.Panel`,
`rich.table.Table`, and `rich.text.Text`. Layout:

1. **Header panel** (border style `bright_blue`):
   ```
   ╭── Agent Readiness Assessment ─────────────────────────╮
   │ Repo:    <repo_name>                                  │
   │ Path:    <repo_path>                                  │
   │ Overall: 67.4 %  •  Level 3 — Structured  •  ready    │
   │ Layers:  Agnostic 51.0 / 76    Claude 16.4 / 24       │
   ╰───────────────────────────────────────────────────────╯
   ```

2. **Axis bars** (one section per axis, sorted INSTRUCT → NAVIGATE → VALIDATE):
   ```
   INSTRUCT 71.0 %  ████████████░░░░  Level 3 Structured
   NAVIGATE 58.8 %  ██████████░░░░░░  Level 2 Guided
   VALIDATE 50.0 %  ████████░░░░░░░░  Level 1 Foundational
   ```
   Bar width: 16 characters, filled with `█` and `░`. Colour per axis:
   - INSTRUCT — `blue`
   - NAVIGATE — `cyan`
   - VALIDATE — `green`
   Bar colour shifts to `yellow` when percentage < 55 and `red` when < 40,
   overriding the axis colour.

3. **Per-dimension table** (one row per dimension):

   | Dim | Name                      | Score        | Pct    | Status |
   |-----|---------------------------|--------------|--------|--------|
   | D1  | Agent Instructions        | 14.0 / 20    | 70.0 % | green  |
   | D2  | Project Navigability      | 9.0 / 18     | 50.0 % | yellow |
   | …   | …                         | …            | …      | …      |

4. **Top-5 prioritised recommendations table**, sorted descending by
   `priority = dimension_weight * (100 - dimension_percentage) / 100`:

   | # | Recommendation                            | Axis     | Effort | Impact | +Pts |
   |---|-------------------------------------------|----------|--------|--------|------|
   | 1 | Add `CLAUDE.md` at repo root              | INSTRUCT | low    | high   | +6.0 |
   | 2 | Add `pytest.ini` and configure pytest     | VALIDATE | low    | high   | +4.0 |
   | … | …                                         | …        | …      | …      | …    |

   Effort heuristic:

   - **low**: single file addition (`.editorconfig`, `.env.example`,
     `SECURITY.md`, `CONTRIBUTING.md`, `dependabot.yml`).
   - **medium**: tool configuration with non-trivial choices
     (linter, formatter, type checker, coverage).
   - **high**: substantive content authoring (`README.md`, `CLAUDE.md`,
     test files, ARCHITECTURE).

   Impact heuristic:

   - **high**: dimension percentage < 40.
   - **medium**: dimension percentage 40-69.
   - **low**: dimension percentage ≥ 70.

5. **Footer line**: `Tool v<tool_version>  •  <timestamp>  •  static-only`
   (or `static + LLM (blend=0.5)` in hybrid mode).

### 3.7 HTML Radar Output (`--visualize` and `--full-report`)

#### 3.7.1 File location

- `--visualize`: write to `tempfile.NamedTemporaryFile(suffix=".html", delete=False)`.
- `--full-report DIR`: write to `<DIR>/report.html`.

After writing, `--visualize` opens the file with `webbrowser.open(f"file://{path}")`.

#### 3.7.2 HTML structure

```
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Agent Readiness — {repo_name}</title>
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4"></script>
  <style>/* dark theme, see 3.7.3 */</style>
</head>
<body>
  <header>…</header>
  <main>
    <canvas id="radar"></canvas>
    <section class="axis-cards">…</section>
  </main>
  <footer>…</footer>
  <script>/* dataset + Chart() call, see 3.7.4 */</script>
</body>
</html>
```

#### 3.7.3 Styling

- Background: `#0a0a14`
- Text: `#e2e8f0`
- Axis colours:
  - INSTRUCT: `#3b82f6`
  - NAVIGATE: `#06b6d4`
  - VALIDATE: `#22c55e`
- Cards (one per axis, three total): border `1px solid rgba(255,255,255,0.1)`,
  background `rgba(255,255,255,0.04)`, 16 px padding, 12 px radius.
- Card content: percentage in 2 rem bold (axis colour), axis name in
  uppercase 0.85 rem, then the workshop question in 0.75 rem opacity 0.6.

#### 3.7.4 Chart.js configuration (rendered inline)

The chart MUST be a radar with three points (one per axis).

> **Critical implementation rule.** Chart.js datasets are JSON-shaped. Do
> NOT write Python list comprehensions inside JavaScript `{...}` placeholders
> in the f-string. Build every dynamic JS value as a **plain Python string
> variable** first (via `json.dumps(...)` for arrays/objects), then
> interpolate that variable into the f-string. The bug in the original draft
> (lines ~1440-1495) came from writing `['rgba({c},1)' for c in colors]`
> inside an f-string placeholder; that is not legal Python.

Pattern to follow:

```python
import json

labels_js  = json.dumps(["INSTRUCT", "NAVIGATE", "VALIDATE"])
values_js  = json.dumps([axes["instruct"]["percentage"],
                         axes["navigate"]["percentage"],
                         axes["validate"]["percentage"]])
point_bg_js = json.dumps(["#3b82f6", "#06b6d4", "#22c55e"])

html = f"""
<script>
const data = {{
    labels: {labels_js},
    datasets: [{{
        label: "Readiness %",
        data: {values_js},
        backgroundColor: "rgba(59,130,246,0.15)",
        borderColor: "#3b82f6",
        pointBackgroundColor: {point_bg_js},
        pointBorderColor: "#fff",
        borderWidth: 2,
    }}]
}};
new Chart(document.getElementById("radar").getContext("2d"), {{
    type: "radar",
    data: data,
    options: {{
        responsive: true,
        maintainAspectRatio: false,
        scales: {{
            r: {{
                beginAtZero: true,
                max: 100,
                ticks: {{ stepSize: 20, color: "rgba(226,232,240,0.7)",
                          backdropColor: "transparent" }},
                grid: {{ color: "rgba(255,255,255,0.08)" }},
                angleLines: {{ color: "rgba(255,255,255,0.08)" }},
                pointLabels: {{ color: "#e2e8f0",
                                font: {{ size: 13, weight: "bold" }} }}
            }}
        }},
        plugins: {{
            legend: {{ display: false }},
            tooltip: {{ callbacks: {{
                label: function(ctx) {{ return ctx.label + ": " + ctx.raw + "%"; }}
            }} }}
        }}
    }}
}});
</script>
"""
```

Note: every `{` and `}` that belongs to JavaScript object literals is
escaped as `{{` / `}}` because we are inside an f-string. **Every** f-string
placeholder is a single Python expression — never a comprehension.

#### 3.7.5 Per-axis cards

Below the canvas, render three `<article>` elements, one per axis. Each
card contains:

- The axis name in uppercase (e.g. `INSTRUCT`).
- The percentage, large, coloured with the axis colour.
- The maturity level (`Level 3 — Structured`).
- The workshop question.

#### 3.7.6 Footer

`Generated by scan_static.py v{tool_version} at {timestamp}`.

### 3.8 Snapshot & Diff

#### 3.8.1 `--save-snapshot`

- Create directory `<repo>/.agent-ready/snapshots/` if missing.
- Filename: `YYYYMMDD-HHMMSS.json` (UTC, ISO-style without separators in
  filename), e.g. `20260525-141233.json`.
- Content: the full JSON output (section 3.5).
- Print one stderr line: `Snapshot saved: <abs path>`.

#### 3.8.2 `--compare PATH`

- Load JSON from `PATH`.
- Validate it has `dimensions` and `axes` blocks (or just `dimensions`, for
  scoring.md schema compatibility — in which case compute axes on the fly).
- Compute deltas:
  - `dim_delta[d] = current.dimensions[d].percentage - previous.dimensions[d].percentage`
  - `axis_delta[a] = current.axes[a].percentage - previous.axes[a].percentage`
  - `overall_delta = current.overall.percentage - previous.overall.percentage`
- Print a table:
  ```
  Comparison: <snapshot file>
  ───────────────────────────────────────────────────────────
   Marker  Bucket            Before    After     Delta
  ───────────────────────────────────────────────────────────
   up      Overall           41.0 %    67.4 %    +26.4
   up      INSTRUCT          50.0 %    71.0 %    +21.0
   right   NAVIGATE          58.8 %    58.8 %     +0.0
   down    VALIDATE          55.0 %    50.0 %     -5.0
   …
  ```
  Markers: `up` (green) when delta > 0.5, `down` (red) when delta < -0.5,
  `right` (grey) when |delta| ≤ 0.5. The agent MAY pair the marker with
  the emoji 📈/📉/➡️ in the pretty renderer, but text-only markers MUST
  remain for grep-ability.

### 3.9 Hybrid Mode

#### 3.9.1 Activation

`--hybrid` requires one of `OPENAI_API_KEY` or `ANTHROPIC_API_KEY` in
the environment. If neither is set, the scanner logs to stderr:

```
WARNING: --hybrid requested but no LLM API key found
         (OPENAI_API_KEY / ANTHROPIC_API_KEY). Falling back to static-only.
```

and continues in static-only mode. The JSON output's `hybrid_mode` field
remains `false`. **Identical output to static-only mode otherwise.**

#### 3.9.2 What gets LLM-adjusted

Only these inherently subjective sub-criteria, all from D1 and D7:

- `d1_instruction_length` (length is a proxy for substance)
- `d1_has_conventions`     (keyword match is imprecise)
- `d7_docstring_density`   (density is a proxy for quality)

For each, the static score `s_static` is blended with an LLM score
`s_llm ∈ [0, 1]` per:

```
s_final = (1 - blend) * s_static + blend * s_llm
```

Default blend = 0.5. Configurable via `--llm-blend`.

#### 3.9.3 LLM call contract

- Choose provider by which env var is present (Anthropic preferred when
  both are set).
- Timeout: **10 s per call**, hard.
- On any exception (timeout, HTTP non-2xx, JSON parse error), fall back to
  the static score for that check; record `llm_adjusted = false` for that
  check. Do not retry.
- Model selection: `claude-haiku-*` (latest 4.x) for Anthropic,
  `gpt-4o-mini` for OpenAI. Both kept small for speed and cost.
- Prompt template (Anthropic; mirror for OpenAI):

  ```
  System:
    You score one specific quality signal of a software repository. Reply with
    JSON of shape {"score": <0..1 float>, "reason": <short string>}. No prose.

  User:
    Signal: {check.name}
    What "1.0" means: {one-line definition}
    Repository file: {filename}
    Content (truncated to 4 KB):
    """{content}"""
  ```

- Total LLM cost ceiling: at most 3 calls per scan. Sequentially, so the
  total scan time grows by at most 30 s in the worst case.

#### 3.9.4 JSON marking

In the per-check JSON record, set `"llm_adjusted": true` when the LLM
contributed to the final score, `false` otherwise.

### 3.10 Reference Python Skeleton

The skeleton is the agent's starting point. It is intentionally incomplete
(some check bodies are stubs) but every f-string and every imported name is
verified syntactically. The skeleton should be **600-700 lines** when fully
fleshed out by the agent.

> **Style.** Type hints everywhere. No bare `except:`. No `print(...)` in
> library functions (only in `main` and adapters via Rich console). One
> module-level constant block at the top. Helper functions are
> prefixed with `_`.

```python
#!/usr/bin/env python3
"""scan_static.py — Deterministic agent-readiness scanner.

Scans a repository against an 8-dimension rubric and projects results onto
three axes: INSTRUCT, NAVIGATE, VALIDATE. Emits pretty / JSON / markdown /
HTML radar output. Static-only by default; optional --hybrid mode blends
in LLM judgement for subjective sub-criteria.

Single-file. Python 3.11+. See PyCon 2026 spec doc 05-implementation-plan.md.
"""
from __future__ import annotations

import argparse
import datetime as _dt
import json
import os
import re
import sys
import tempfile
import tomllib
import webbrowser
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Callable, Iterable

try:
    from rich.console import Console
    from rich.panel import Panel
    from rich.table import Table
    from rich.text import Text
except ImportError:  # pragma: no cover - import-time hint only
    sys.stderr.write("ERROR: install dependencies: pip install -r requirements-workshop.txt\n")
    sys.exit(1)

try:
    import yaml  # used to validate SKILL.md frontmatter
except ImportError:  # pragma: no cover
    yaml = None  # type: ignore[assignment]


# ─────────────────────────────────────────────────────────────────────────
# Constants
# ─────────────────────────────────────────────────────────────────────────

TOOL_VERSION = "1.0.0"
SCHEMA_VERSION = "1.0"

# Skip these directories everywhere
SKIP_DIRS = frozenset({
    ".git", "node_modules", "__pycache__", ".venv", "venv", ".tox",
    "dist", "build", ".mypy_cache", ".pytest_cache", ".ruff_cache",
})

# Canonical dimension keys and weights (from scoring.md)
DIMENSIONS: dict[str, dict[str, Any]] = {
    "agent_instructions":         {"id": "D1", "name": "Agent Instructions",         "weight": 20, "axis": "instruct"},
    "project_navigability":       {"id": "D2", "name": "Project Navigability",       "weight": 18, "axis": "navigate"},
    "testing_validation":         {"id": "D3", "name": "Testing & Validation",       "weight": 16, "axis": "validate"},
    "cicd_automation":            {"id": "D4", "name": "CI/CD & Automation",         "weight": 12, "axis": "validate"},
    "spec_driven_workflow":       {"id": "D5", "name": "Spec-Driven Workflow",       "weight": 10, "axis": "instruct"},
    "skills_tooling":             {"id": "D6", "name": "Skills & Tooling",           "weight":  8, "axis": "navigate"},
    "documentation_comprehension":{"id": "D7", "name": "Documentation & Comprehension","weight":  8, "axis": "navigate"},
    "claude_specific":            {"id": "D8", "name": "Claude-Specific",            "weight":  8, "axis": "instruct"},
}

# Axis metadata
AXES: dict[str, dict[str, Any]] = {
    "instruct": {
        "label": "INSTRUCT",
        "question": "Does the agent understand WHAT we want?",
        "color": "#3b82f6",
        "rich_color": "blue",
        "max": 38,
    },
    "navigate": {
        "label": "NAVIGATE",
        "question": "Can the agent find its way around?",
        "color": "#06b6d4",
        "rich_color": "cyan",
        "max": 34,
    },
    "validate": {
        "label": "VALIDATE",
        "question": "Can the agent verify its work is correct?",
        "color": "#22c55e",
        "rich_color": "green",
        "max": 28,
    },
}

# Maturity gate thresholds (descending)
MATURITY_LEVELS: list[tuple[int, str, float]] = [
    (5, "Autonomous",      95.0),
    (4, "Optimized",       85.0),
    (3, "Structured",      70.0),
    (2, "Guided",          55.0),
    (1, "Foundational",    40.0),
    (0, "Pre-Foundational", 0.0),
]

# Maximum bytes read per file
MAX_READ_BYTES = 64 * 1024


# ─────────────────────────────────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────────────────────────────────

_READ_CACHE: dict[tuple[str, str], str | None] = {}


def _safe_relative(p: Path, root: Path) -> str:
    """Return p relative to root as a forward-slash string."""
    try:
        return p.relative_to(root).as_posix()
    except ValueError:
        return p.as_posix()


def _is_skipped(p: Path) -> bool:
    """Return True if any part of p's path is in SKIP_DIRS."""
    return any(part in SKIP_DIRS for part in p.parts)


def _file_exists(repo: Path, *patterns: str) -> str | None:
    """Return the relative path of the first matching file, or None.

    Patterns may be literal paths ('CLAUDE.md', 'docs/architecture.md')
    or globs ('.github/workflows/*.yml').
    """
    for pattern in patterns:
        if "*" in pattern or "?" in pattern:
            matches = [
                m for m in sorted(repo.glob(pattern))
                if m.is_file() and not _is_skipped(m)
            ]
            if matches:
                return _safe_relative(matches[0], repo)
        else:
            target = repo / pattern
            if target.is_file():
                return pattern
            if target.is_dir():
                # If pattern names a directory and it contains anything, treat as present
                # (caller decides whether to use it).
                try:
                    if any(True for _ in target.iterdir()):
                        return pattern
                except OSError:
                    pass
    return None


def _read_file_content(repo: Path, filepath: str) -> str | None:
    """Read up to MAX_READ_BYTES of a file relative to repo root.

    Cached per (repo, filepath) for the lifetime of the process.
    """
    key = (str(repo), filepath)
    if key in _READ_CACHE:
        return _READ_CACHE[key]
    target = repo / filepath
    content: str | None = None
    if target.is_file():
        try:
            with target.open("rb") as f:
                blob = f.read(MAX_READ_BYTES)
            content = blob.decode("utf-8", errors="ignore")
        except OSError:
            content = None
    _READ_CACHE[key] = content
    return content


def _content_contains(content: str | None, *patterns: str) -> bool:
    """Case-insensitive substring match across patterns."""
    if not content:
        return False
    low = content.lower()
    return any(p.lower() in low for p in patterns)


def _glob_count(repo: Path, pattern: str) -> int:
    """Count files matching glob pattern, skipping noise dirs."""
    return sum(
        1 for p in repo.glob(pattern)
        if p.is_file() and not _is_skipped(p)
    )


def _rglob_count(repo: Path, pattern: str) -> int:
    """Count files matching rglob pattern, skipping noise dirs."""
    return sum(
        1 for p in repo.rglob(pattern)
        if p.is_file() and not _is_skipped(p)
    )


def _parse_pyproject(repo: Path) -> dict[str, Any]:
    """Parse pyproject.toml; return {} on miss or error."""
    p = repo / "pyproject.toml"
    if not p.is_file():
        return {}
    try:
        with p.open("rb") as f:
            return tomllib.load(f)
    except (OSError, tomllib.TOMLDecodeError):
        return {}


def _clamp(x: float, lo: float = 0.0, hi: float = 1.0) -> float:
    return max(lo, min(hi, x))


# ─────────────────────────────────────────────────────────────────────────
# Check types
# ─────────────────────────────────────────────────────────────────────────

@dataclass
class CheckResult:
    id: str
    name: str
    internal_weight: int
    score: float          # 0..internal_weight
    passed: bool
    message: str
    details: str = ""
    llm_adjusted: bool = False


@dataclass
class CheckDef:
    id: str
    name: str
    internal_weight: int
    fn: Callable[[Path], tuple[float, bool, str, str]]
    #   returns (partial_credit_in_0_1, passed_bool, message, details)


# ─────────────────────────────────────────────────────────────────────────
# D1 — Agent Instructions
# ─────────────────────────────────────────────────────────────────────────

INSTRUCTION_FILES = (
    "CLAUDE.md", "AGENTS.md", ".cursorrules",
    ".github/copilot-instructions.md",
)


def _check_d1_instruction_file_exists(repo: Path) -> tuple[float, bool, str, str]:
    found = _file_exists(repo, *INSTRUCTION_FILES)
    if found:
        return (1.0, True, f"Found: {found}", "")
    return (0.0, False,
            "No agent instruction file found",
            "Add CLAUDE.md, AGENTS.md, or .cursorrules at repo root.")


def _check_d1_instruction_length(repo: Path) -> tuple[float, bool, str, str]:
    found = _file_exists(repo, *INSTRUCTION_FILES)
    if not found:
        return (0.0, False, "No instruction file", "")
    content = _read_file_content(repo, found) or ""
    n = len(content)
    credit = _clamp(n / 800.0)
    passed = n >= 800
    return (credit, passed,
            f"{n} characters in {found}",
            "" if passed else "Expand instruction file to ≥ 800 chars.")


def _check_d1_has_conventions(repo: Path) -> tuple[float, bool, str, str]:
    found = _file_exists(repo, *INSTRUCTION_FILES)
    content = _read_file_content(repo, found) if found else None
    if not content:
        return (0.0, False, "No content to analyse", "")
    keywords = ("convention", "style", "naming", "lint", "format")
    hits = sum(1 for kw in keywords if kw in content.lower())
    credit = _clamp(hits / 2.0)
    return (credit, hits >= 2,
            f"{hits}/5 convention keywords",
            "Document code conventions: style, naming, lint, format.")


def _check_d1_has_examples(repo: Path) -> tuple[float, bool, str, str]:
    found = _file_exists(repo, *INSTRUCTION_FILES)
    content = _read_file_content(repo, found) if found else None
    if not content:
        return (0.0, False, "No content to analyse", "")
    # Count opening fences only
    fences = len(re.findall(r"(?m)^```", content)) // 2
    credit = _clamp(fences / 2.0)
    return (credit, fences >= 2,
            f"{fences} code blocks in instructions",
            "Add ≥ 2 concrete code examples to instruction file.")


def _check_d1_has_do_dont(repo: Path) -> tuple[float, bool, str, str]:
    found = _file_exists(repo, *INSTRUCTION_FILES)
    content = _read_file_content(repo, found) if found else None
    if not content:
        return (0.0, False, "No content", "")
    pat = re.compile(r"(?im)^\s*#+\s*(do|don'?t|guardrails?|rules?)\b")
    has = bool(pat.search(content))
    return (1.0 if has else 0.0, has,
            "Do/Don't section found" if has else "No Do/Don't section",
            "" if has else "Add a 'Do / Don't' or 'Guardrails' section.")


def _check_d1_root_anchored(repo: Path) -> tuple[float, bool, str, str]:
    for f in INSTRUCTION_FILES:
        if "/" not in f and (repo / f).is_file():
            return (1.0, True, f"{f} at repo root", "")
    return (0.0, False,
            "Instruction file not at repo root",
            "Move/duplicate the instruction file to the repository root.")


D1_CHECKS: list[CheckDef] = [
    CheckDef("d1_instruction_file_exists", "Agent instruction file present", 30, _check_d1_instruction_file_exists),
    CheckDef("d1_instruction_length",      "Instruction file substantive",    20, _check_d1_instruction_length),
    CheckDef("d1_has_conventions",         "Code conventions documented",     15, _check_d1_has_conventions),
    CheckDef("d1_has_examples",            "Concrete examples in instructions",15,_check_d1_has_examples),
    CheckDef("d1_has_do_dont",             "Do/Don't or guardrails",          10, _check_d1_has_do_dont),
    CheckDef("d1_root_anchored",           "Instruction file at repo root",   10, _check_d1_root_anchored),
]


# ─────────────────────────────────────────────────────────────────────────
# D2-D8 — STUBS for the agent to complete
# (mirror the same pattern: one CheckDef list per dimension, six checks each)
# ─────────────────────────────────────────────────────────────────────────

# The agent MUST implement, following Section 3.3 of the spec:
#   D2_CHECKS = [...]  # 8 checks; sum of internal_weight == 100
#   D3_CHECKS = [...]  # 6 checks; sum == 100
#   D4_CHECKS = [...]  # 6 checks; sum == 100
#   D5_CHECKS = [...]  # 5 checks; sum == 100
#   D6_CHECKS = [...]  # 5 checks; sum == 100
#   D7_CHECKS = [...]  # 5 checks; sum == 100
#   D8_CHECKS = [...]  # 5 checks; sum == 100

D2_CHECKS: list[CheckDef] = []   # TODO: implement per spec 3.3.2
D3_CHECKS: list[CheckDef] = []   # TODO: implement per spec 3.3.3
D4_CHECKS: list[CheckDef] = []   # TODO: implement per spec 3.3.4
D5_CHECKS: list[CheckDef] = []   # TODO: implement per spec 3.3.5
D6_CHECKS: list[CheckDef] = []   # TODO: implement per spec 3.3.6
D7_CHECKS: list[CheckDef] = []   # TODO: implement per spec 3.3.7
D8_CHECKS: list[CheckDef] = []   # TODO: implement per spec 3.3.8

DIMENSION_CHECKS: dict[str, list[CheckDef]] = {
    "agent_instructions":          D1_CHECKS,
    "project_navigability":        D2_CHECKS,
    "testing_validation":          D3_CHECKS,
    "cicd_automation":             D4_CHECKS,
    "spec_driven_workflow":        D5_CHECKS,
    "skills_tooling":              D6_CHECKS,
    "documentation_comprehension": D7_CHECKS,
    "claude_specific":             D8_CHECKS,
}


# ─────────────────────────────────────────────────────────────────────────
# Scoring engine
# ─────────────────────────────────────────────────────────────────────────

def run_check(repo: Path, c: CheckDef) -> CheckResult:
    """Execute a single check definition, capturing exceptions."""
    try:
        credit, passed, message, details = c.fn(repo)
    except Exception as exc:  # noqa: BLE001 - we want to keep going
        return CheckResult(
            id=c.id, name=c.name, internal_weight=c.internal_weight,
            score=0.0, passed=False,
            message=f"Check raised {type(exc).__name__}",
            details=str(exc)[:200],
        )
    credit = _clamp(credit)
    score = c.internal_weight * credit
    return CheckResult(
        id=c.id, name=c.name, internal_weight=c.internal_weight,
        score=score, passed=passed, message=message, details=details,
    )


def score_dimension(repo: Path, dim_key: str) -> dict[str, Any]:
    """Score one dimension; return the JSON-shaped dict."""
    meta = DIMENSIONS[dim_key]
    checks_def = DIMENSION_CHECKS[dim_key]
    results = [run_check(repo, c) for c in checks_def]
    internal_raw = sum(r.score for r in results)
    dim_score = round(internal_raw / 100.0 * meta["weight"], 2)
    recs = _recommendations_for(results, dim_key)
    return {
        "score": dim_score,
        "max": meta["weight"],
        "percentage": round(internal_raw, 1),
        "checks": [
            {
                "id": r.id, "name": r.name, "internal_weight": r.internal_weight,
                "score": round(r.score, 2), "passed": r.passed,
                "message": r.message, "details": r.details,
                "llm_adjusted": r.llm_adjusted,
            } for r in results
        ],
        "recommendations": recs,
    }


def _recommendations_for(results: list[CheckResult], dim_key: str) -> list[dict[str, Any]]:
    """Build dimension-local recommendations from failed/partial checks."""
    out: list[dict[str, Any]] = []
    for r in results:
        if r.score >= r.internal_weight:
            continue
        effort = _effort_for(r.id)
        impact = _impact_for(dim_key)
        out.append({
            "title": r.details or r.message,
            "effort": effort,
            "impact": impact,
            "potential_gain": round(r.internal_weight - r.score, 2),
        })
    out.sort(key=lambda x: -x["potential_gain"])
    return out


def _effort_for(check_id: str) -> str:
    low = {
        "d2_python_version_pinned", "d4_secrets_handling",
        "d5_changelog", "d5_contributing_guide", "d5_issue_templates",
        "d8_claude_settings",
    }
    high = {
        "d1_instruction_length", "d3_test_files_present",
        "d7_docstring_density",
    }
    if check_id in low:
        return "low"
    if check_id in high:
        return "high"
    return "medium"


def _impact_for(dim_key: str) -> str:
    # impact ~ inverse of current dimension score; calling code can override.
    return "medium"


def score_axis(axis_key: str, dims: dict[str, dict[str, Any]]) -> dict[str, Any]:
    """Sum dimension scores belonging to axis_key into an axis record."""
    dim_keys = [k for k, m in DIMENSIONS.items() if m["axis"] == axis_key]
    score = round(sum(dims[k]["score"] for k in dim_keys), 2)
    ax_max = AXES[axis_key]["max"]
    pct = round(score / ax_max * 100.0, 1) if ax_max else 0.0
    level, level_name = compute_maturity(pct)
    return {
        "score": score,
        "max": ax_max,
        "percentage": pct,
        "level": level,
        "level_name": level_name,
        "band": compute_band(pct),
        "dimensions": dim_keys,
    }


def score_overall(dims: dict[str, dict[str, Any]]) -> dict[str, Any]:
    """Build the overall block, including layer subtotals."""
    total = round(sum(d["score"] for d in dims.values()), 2)
    layer_agnostic = round(sum(
        dims[k]["score"] for k, m in DIMENSIONS.items() if m["weight"] >= 10
        and m["axis"] != "claude_only_marker"  # all D1..D5
        and k in ("agent_instructions", "project_navigability",
                  "testing_validation", "cicd_automation", "spec_driven_workflow")
    ), 2)
    layer_claude = round(total - layer_agnostic, 2)
    level, level_name = compute_maturity(total)
    return {
        "score": total,
        "max": 100,
        "percentage": round(total, 1),
        "level": level,
        "level_name": level_name,
        "band": compute_band(total),
        "layer_agnostic": layer_agnostic,
        "layer_claude": layer_claude,
    }


def compute_maturity(percentage: float) -> tuple[int, str]:
    for level, name, threshold in MATURITY_LEVELS:
        if percentage >= threshold:
            return level, name
    return 0, "Pre-Foundational"


def compute_band(percentage: float) -> str:
    if percentage <= 30:
        return "not_ready"
    if percentage <= 60:
        return "partially_ready"
    if percentage <= 80:
        return "ready"
    return "optimized"


# ─────────────────────────────────────────────────────────────────────────
# Top-level orchestration
# ─────────────────────────────────────────────────────────────────────────

def scan(repo: Path, axes: Iterable[str] | None = None) -> dict[str, Any]:
    """Run all (or selected) checks and assemble the full JSON record."""
    selected_axes = list(axes) if axes else list(AXES.keys())
    dim_keys = [k for k, m in DIMENSIONS.items() if m["axis"] in selected_axes]

    dims: dict[str, dict[str, Any]] = {}
    for k in dim_keys:
        dims[k] = score_dimension(repo, k)

    axes_block: dict[str, dict[str, Any]] = {}
    for ax in selected_axes:
        axes_block[ax] = score_axis(ax, dims)

    overall = score_overall(dims) if len(selected_axes) == 3 else {
        "score": 0.0, "max": 100, "percentage": 0.0,
        "level": 0, "level_name": "Pre-Foundational",
        "band": "not_ready",
        "layer_agnostic": 0.0, "layer_claude": 0.0,
    }

    return {
        "version": SCHEMA_VERSION,
        "tool_version": TOOL_VERSION,
        "repo_name": repo.name,
        "repo_path": str(repo),
        "timestamp": _dt.datetime.now(_dt.timezone.utc).isoformat(),
        "dimensions": dims,
        "axes": axes_block,
        "overall": overall,
        "hybrid_mode": False,
    }


# ─────────────────────────────────────────────────────────────────────────
# Hybrid mode (LLM enrichment) — see spec 3.9
# ─────────────────────────────────────────────────────────────────────────

LLM_TARGETS = ("d1_instruction_length", "d1_has_conventions", "d7_docstring_density")


def maybe_enrich_with_llm(
    result: dict[str, Any], repo: Path, blend: float, console: Console,
) -> dict[str, Any]:
    """Optionally blend in LLM judgement for subjective checks.

    Returns the (possibly modified) result. Sets result['hybrid_mode'].
    Hard 10 s timeout per call. Any failure → static score retained.
    """
    api_key = os.environ.get("ANTHROPIC_API_KEY") or os.environ.get("OPENAI_API_KEY")
    if not api_key:
        sys.stderr.write(
            "WARNING: --hybrid requested but no LLM API key found\n"
            "         (OPENAI_API_KEY / ANTHROPIC_API_KEY). "
            "Falling back to static-only.\n"
        )
        return result

    # Walk the result, find target check ids, call LLM for each, blend.
    # Implementation detail: see spec 3.9.3.
    for dim_key, dim in result["dimensions"].items():
        for check in dim["checks"]:
            if check["id"] not in LLM_TARGETS:
                continue
            s_llm = _query_llm_score(check["id"], repo, api_key)
            if s_llm is None:
                continue
            s_static = check["score"] / max(check["internal_weight"], 1)
            blended = (1.0 - blend) * s_static + blend * s_llm
            check["score"] = round(blended * check["internal_weight"], 2)
            check["llm_adjusted"] = True

    # Recompute dimension/axis/overall after LLM adjustments.
    # Re-aggregate from scratch using the modified per-check scores.
    for dim_key, dim in result["dimensions"].items():
        internal_raw = sum(c["score"] for c in dim["checks"])
        dim["percentage"] = round(internal_raw, 1)
        dim["score"] = round(internal_raw / 100.0 * DIMENSIONS[dim_key]["weight"], 2)
    for ax_key in result["axes"]:
        result["axes"][ax_key] = score_axis(ax_key, result["dimensions"])
    result["overall"] = score_overall(result["dimensions"])
    result["hybrid_mode"] = True
    return result


def _query_llm_score(check_id: str, repo: Path, api_key: str) -> float | None:
    """Query the LLM provider for a 0..1 score. Returns None on any error.

    Hard 10 s timeout. Uses urllib so we add no extra dependency.
    """
    # Implementation detail: see spec 3.9.3.
    # The agent MUST implement this with urllib.request + a 10s timeout.
    # On any exception, return None (caller will fall back to static).
    return None  # TODO: implement per spec 3.9.3


# ─────────────────────────────────────────────────────────────────────────
# Output adapters
# ─────────────────────────────────────────────────────────────────────────

def emit_json(result: dict[str, Any]) -> str:
    return json.dumps(result, indent=2, sort_keys=False, ensure_ascii=False)


def emit_markdown(result: dict[str, Any]) -> str:
    # Implementation outline (the agent fills in details):
    # 1. Title with repo name + overall %.
    # 2. Section per axis with table of dimensions, score, percentage.
    # 3. Top-5 recommendations.
    # 4. Footer with tool version + timestamp.
    raise NotImplementedError("TODO: see spec 3.6 / 3.10")


def emit_pretty(result: dict[str, Any], console: Console) -> None:
    # Implementation outline (the agent fills in details):
    # 1. Header panel with overall percentage / level / band.
    # 2. Per-axis bar (16 chars filled/empty).
    # 3. Dimension table.
    # 4. Recommendation table.
    # 5. Footer line.
    raise NotImplementedError("TODO: see spec 3.6")


def emit_html_radar(result: dict[str, Any]) -> str:
    """Build a self-contained HTML page with a Chart.js radar.

    IMPORTANT: every dynamic JS literal is constructed via json.dumps BEFORE
    the f-string. Do NOT put Python comprehensions inside JS placeholders.
    """
    labels = [AXES[a]["label"] for a in ("instruct", "navigate", "validate")]
    values = [result["axes"][a]["percentage"] for a in ("instruct", "navigate", "validate")]
    point_bg = [AXES[a]["color"] for a in ("instruct", "navigate", "validate")]

    labels_js   = json.dumps(labels)
    values_js   = json.dumps(values)
    point_bg_js = json.dumps(point_bg)

    repo_name      = result["repo_name"]
    overall_pct    = result["overall"]["percentage"]
    overall_level  = result["overall"]["level"]
    overall_name   = result["overall"]["level_name"]
    timestamp      = result["timestamp"]
    tool_version   = result["tool_version"]

    # Build per-axis cards as a single HTML chunk OUTSIDE the f-string.
    cards_chunks: list[str] = []
    for ax_key in ("instruct", "navigate", "validate"):
        ax = result["axes"][ax_key]
        meta = AXES[ax_key]
        cards_chunks.append(
            f'<article class="card" style="border-color:{meta["color"]};">'
            f'  <div class="ax-pct" style="color:{meta["color"]};">{ax["percentage"]:.1f}%</div>'
            f'  <div class="ax-label">{meta["label"]}</div>'
            f'  <div class="ax-level">Level {ax["level"]} &mdash; {ax["level_name"]}</div>'
            f'  <div class="ax-question">{meta["question"]}</div>'
            f'</article>'
        )
    cards_html = "\n".join(cards_chunks)

    return f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>Agent Readiness &mdash; {repo_name}</title>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4"></script>
<style>
  body {{
    margin: 0; padding: 24px;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    background: #0a0a14; color: #e2e8f0;
  }}
  main {{ max-width: 880px; margin: 0 auto; }}
  header {{ text-align: center; margin-bottom: 24px; }}
  header h1 {{ font-size: 1.5rem; margin: 0 0 4px 0; }}
  header .sub {{ font-size: 0.9rem; opacity: 0.6; }}
  .overall-badge {{
    display: inline-block; margin-top: 8px;
    padding: 4px 16px; border-radius: 20px;
    background: rgba(255,255,255,0.06); font-weight: 600;
  }}
  .chart-wrap {{ height: 420px; }}
  .cards {{
    display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; margin-top: 24px;
  }}
  .card {{
    background: rgba(255,255,255,0.04);
    border: 1px solid rgba(255,255,255,0.1);
    border-radius: 12px;
    padding: 16px; text-align: center;
  }}
  .ax-pct {{ font-size: 2rem; font-weight: 700; }}
  .ax-label {{ font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.1em; opacity: 0.8; }}
  .ax-level {{ font-size: 0.85rem; opacity: 0.7; margin-top: 4px; }}
  .ax-question {{ font-size: 0.75rem; opacity: 0.55; margin-top: 8px; }}
  footer {{
    text-align: center; margin-top: 24px;
    font-size: 0.8rem; opacity: 0.4;
  }}
</style>
</head>
<body>
<main>
  <header>
    <h1>Agent Readiness Assessment</h1>
    <div class="sub">{repo_name}</div>
    <div class="overall-badge">
      Level {overall_level} &mdash; {overall_name} &mdash; {overall_pct:.1f}%
    </div>
  </header>

  <div class="chart-wrap"><canvas id="radar"></canvas></div>

  <section class="cards">
    {cards_html}
  </section>

  <footer>
    Generated by scan_static.py v{tool_version} &middot; {timestamp}
  </footer>
</main>

<script>
const data = {{
  labels: {labels_js},
  datasets: [{{
    label: "Readiness %",
    data: {values_js},
    backgroundColor: "rgba(59,130,246,0.15)",
    borderColor: "#3b82f6",
    pointBackgroundColor: {point_bg_js},
    pointBorderColor: "#fff",
    borderWidth: 2,
  }}]
}};
new Chart(document.getElementById("radar").getContext("2d"), {{
  type: "radar",
  data: data,
  options: {{
    responsive: true,
    maintainAspectRatio: false,
    scales: {{
      r: {{
        beginAtZero: true, max: 100,
        ticks: {{ stepSize: 20, color: "rgba(226,232,240,0.7)", backdropColor: "transparent" }},
        grid: {{ color: "rgba(255,255,255,0.08)" }},
        angleLines: {{ color: "rgba(255,255,255,0.08)" }},
        pointLabels: {{ color: "#e2e8f0", font: {{ size: 13, weight: "bold" }} }}
      }}
    }},
    plugins: {{
      legend: {{ display: false }},
      tooltip: {{ callbacks: {{
        label: function(ctx) {{ return ctx.label + ": " + ctx.raw + "%"; }}
      }} }}
    }}
  }}
}});
</script>
</body>
</html>
"""


# ─────────────────────────────────────────────────────────────────────────
# Snapshot / diff
# ─────────────────────────────────────────────────────────────────────────

def save_snapshot(result: dict[str, Any], repo: Path) -> Path:
    snap_dir = repo / ".agent-ready" / "snapshots"
    snap_dir.mkdir(parents=True, exist_ok=True)
    ts = _dt.datetime.now(_dt.timezone.utc).strftime("%Y%m%d-%H%M%S")
    out = snap_dir / f"{ts}.json"
    out.write_text(emit_json(result), encoding="utf-8")
    return out


def load_snapshot(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def compute_diff(current: dict[str, Any], previous: dict[str, Any]) -> dict[str, Any]:
    diff: dict[str, Any] = {"dimensions": {}, "axes": {}, "overall": {}}
    for k, v in current["dimensions"].items():
        prev = previous.get("dimensions", {}).get(k, {})
        diff["dimensions"][k] = {
            "before": prev.get("percentage", 0.0),
            "after":  v["percentage"],
            "delta":  round(v["percentage"] - prev.get("percentage", 0.0), 1),
        }
    for k, v in current["axes"].items():
        prev = previous.get("axes", {}).get(k, {})
        diff["axes"][k] = {
            "before": prev.get("percentage", 0.0),
            "after":  v["percentage"],
            "delta":  round(v["percentage"] - prev.get("percentage", 0.0), 1),
        }
    diff["overall"] = {
        "before": previous.get("overall", {}).get("percentage", 0.0),
        "after":  current["overall"]["percentage"],
        "delta":  round(current["overall"]["percentage"]
                       - previous.get("overall", {}).get("percentage", 0.0), 1),
    }
    return diff


# ─────────────────────────────────────────────────────────────────────────
# CLI
# ─────────────────────────────────────────────────────────────────────────

def _build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        prog="scan_static.py",
        description="Deterministic three-axis agent-readiness scanner.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "Examples:\n"
            "  scan_static.py .\n"
            "  scan_static.py /repo --axis instruct\n"
            "  scan_static.py /repo --all --visualize\n"
            "  scan_static.py /repo --hybrid --llm-blend 0.4\n"
            "  scan_static.py /repo --full-report ./report\n"
            "  scan_static.py /repo --save-snapshot\n"
            "  scan_static.py /repo --compare ./prev.json\n"
        ),
    )
    p.add_argument("repo_path", nargs="?", default=".", help="Path to the repository to scan.")

    grp = p.add_mutually_exclusive_group()
    grp.add_argument("--axis", choices=["instruct", "navigate", "validate"])
    grp.add_argument("--all", action="store_true")

    p.add_argument("--hybrid", action="store_true")
    p.add_argument("--llm-blend", type=float, default=0.5)

    p.add_argument("--format", choices=["pretty", "json", "markdown"], default="pretty")
    p.add_argument("--output", type=Path, default=None)
    p.add_argument("--full-report", type=Path, default=None,
                   help="Write all formats (pretty/json/md/html) into DIR.")

    p.add_argument("--visualize", action="store_true")
    p.add_argument("--save-snapshot", action="store_true")
    p.add_argument("--compare", type=Path, default=None)

    p.add_argument("--quiet", action="store_true")
    p.add_argument("--version", action="version",
                   version=f"scan_static.py {TOOL_VERSION}")
    return p


def main(argv: list[str] | None = None) -> int:
    parser = _build_parser()
    args = parser.parse_args(argv)

    repo = Path(args.repo_path).resolve()
    if not repo.is_dir():
        sys.stderr.write(f"ERROR: not a directory: {repo}\n")
        return 2
    if args.full_report and (args.output or args.format != "pretty"):
        sys.stderr.write("ERROR: --full-report is mutually exclusive with --format/--output\n")
        return 2
    if not 0.0 <= args.llm_blend <= 1.0:
        sys.stderr.write("ERROR: --llm-blend must be in [0.0, 1.0]\n")
        return 2

    console = Console(stderr=False, quiet=args.quiet)

    axes = (args.axis,) if args.axis else ("instruct", "navigate", "validate")
    try:
        result = scan(repo, axes=axes)
    except Exception as exc:  # noqa: BLE001
        sys.stderr.write(f"ERROR: scan failed: {exc}\n")
        return 1

    if args.hybrid:
        result = maybe_enrich_with_llm(result, repo, args.llm_blend, console)

    # Snapshot/compare side channels
    if args.save_snapshot:
        try:
            out = save_snapshot(result, repo)
            sys.stderr.write(f"Snapshot saved: {out}\n")
        except OSError as exc:
            sys.stderr.write(f"ERROR: cannot write snapshot: {exc}\n")
            return 3

    if args.compare:
        try:
            previous = load_snapshot(args.compare)
            diff = compute_diff(result, previous)
            # Pretty-print the diff (implementation: see spec 3.8.2).
            console.print_json(json.dumps(diff))
        except (OSError, json.JSONDecodeError) as exc:
            sys.stderr.write(f"ERROR: cannot load snapshot: {exc}\n")
            return 3

    # Output dispatch
    if args.full_report:
        out_dir = args.full_report
        try:
            out_dir.mkdir(parents=True, exist_ok=True)
            (out_dir / "report.json").write_text(emit_json(result), encoding="utf-8")
            (out_dir / "report.md").write_text(emit_markdown(result), encoding="utf-8")
            (out_dir / "report.html").write_text(emit_html_radar(result), encoding="utf-8")
            # Pretty output goes to report.txt as plain ANSI-stripped text;
            # easiest path: write the markdown again here, or capture rich Console.
            (out_dir / "report.txt").write_text(emit_markdown(result), encoding="utf-8")
        except OSError as exc:
            sys.stderr.write(f"ERROR: cannot write full-report: {exc}\n")
            return 3
    else:
        if args.format == "json":
            text = emit_json(result)
            (args.output.write_text(text, encoding="utf-8")
             if args.output else sys.stdout.write(text + "\n"))
        elif args.format == "markdown":
            text = emit_markdown(result)
            (args.output.write_text(text, encoding="utf-8")
             if args.output else sys.stdout.write(text + "\n"))
        else:
            emit_pretty(result, console)
            if args.output:
                # Re-emit markdown for file output when --format pretty + --output:
                args.output.write_text(emit_markdown(result), encoding="utf-8")

    if args.visualize:
        html = emit_html_radar(result)
        tmp = tempfile.NamedTemporaryFile(
            mode="w", suffix=".html", delete=False, prefix="agent-ready-radar-",
            encoding="utf-8",
        )
        tmp.write(html)
        tmp.close()
        sys.stderr.write(f"Radar chart: {tmp.name}\n")
        webbrowser.open(f"file://{tmp.name}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
```

> **Note to the implementing agent.** The skeleton above intentionally
> leaves D2-D8 check arrays and the `emit_pretty` / `emit_markdown` bodies
> empty. These are not optional — they are required by Section 3.3 / 3.6.
> They are stubbed so the file imports cleanly during early development.
> The final delivered file MUST have all stubs replaced.

---

## 4. Acceptance Criteria

### 4.1 Behavioural Criteria

The scanner is accepted if and only if the following eight behaviours hold.

**B1 — Deterministic Scoring.**
Two consecutive runs of `scan_static.py` against the same repository at the
same commit produce JSON outputs that differ only in the `timestamp` field.
Every other field, including all per-check scores, must be byte-identical.
Diffing two runs of `scan_static.py /repo --all --format json` with `jq -S`
applied (sort keys) and `timestamp` stripped MUST be empty.

**B2 — JSON Schema Compliance and Strict-Superset.**
Output validates against the JSON Schema in Section 3.5. In particular,
the `dimensions` object contains exactly eight keys with the canonical
snake_case names listed in Section 2.1, with `documentation_comprehension`
(not `documentation`). When the `axes`, `overall`, and `hybrid_mode`
top-level keys are removed, the remainder is a valid instance of the
schema in `skills/agent-ready/references/scoring.md`.

**B3 — Axis Aggregation Consistency.**
The sum of `result.axes[a].score` over `a ∈ {instruct, navigate, validate}`
equals `result.overall.score` within a rounding tolerance of 0.05.
Equivalently, `layer_agnostic + layer_claude` equals `overall.score` within
the same tolerance. The scanner asserts this internally and exits with code 1
if it ever fails.

**B4 — Hybrid Degradation.**
Running with `--hybrid` but without either of `OPENAI_API_KEY` or
`ANTHROPIC_API_KEY` in the environment produces output that is identical to
running without `--hybrid` (modulo the warning written to stderr and the
`hybrid_mode: false` field). No exception is raised; exit code is 0.

**B5 — Performance Budget.**
Scanning a representative Python repository with ~5 000 files
(e.g. `smolagents`, `cpython/Lib`, or a synthesised fixture of that size)
completes in ≤ 10 seconds wall-clock on a modern laptop. The scanner must
never read more than `MAX_READ_BYTES` (64 KB) from any single file.

**B6 — Radar HTML Validity.**
The HTML produced by `emit_html_radar` parses with `html.parser`,
contains exactly one `<canvas id="radar">`, includes the JSDelivr Chart.js
script tag, and renders without JavaScript errors in modern Chrome and
Firefox. The page is self-contained: no local file references; only the
single Chart.js CDN URL.

**B7 — Snapshot Idempotency.**
Calling `save_snapshot` twice in the same second produces two files with
identical content (after stripping the `timestamp` field) but different
filenames (because the filename includes seconds). Calling it twice with
a clock-stop between yields byte-identical content too.

**B8 — Error Handling.**
Passing a path that does not exist or is not a directory exits with code 2
and a message on stderr starting with `ERROR:`. Files that cannot be
opened during scanning are skipped silently (or counted) but never crash
the whole scan. An invalid `--llm-blend` value (outside `[0,1]`) exits
with code 2 and a clear message.

### 4.2 Executable Test Suite

The test suite is split between bash one-liners (for smoke validation) and a
pytest module (`tests/test_scan_static.py`) for the main behavioural coverage.

Tests assume two fixture repositories exist:

- `tests/fixtures/demo-bad/` — minimal: only `README.md` (10 lines).
- `tests/fixtures/demo-good/` — well-equipped: CLAUDE.md ≥ 1 500 chars,
  pyproject.toml with `[tool.ruff]` and `[tool.pytest.ini_options]`,
  `tests/test_smoke.py`, `.github/workflows/ci.yml` with pytest + ruff,
  `docs/architecture.md`, `.pre-commit-config.yaml`, etc.

The agent MAY check these fixtures in or generate them in a `conftest.py`.
Spec doc 06 describes the fixtures formally; this doc only requires they
exist when tests run.

#### 4.2.1 Bash smoke tests

```bash
# Test S1: scanner version flag works (covers B8)
python scripts/scan_static.py --version | grep -E "^scan_static.py [0-9]+\.[0-9]+\.[0-9]+$"
test $? -eq 0

# Test S2: invalid repo path → exit 2 (covers B8)
python scripts/scan_static.py /nonexistent/path 2>/dev/null
test $? -eq 2

# Test S3: demo-bad scores low (covers B2)
python scripts/scan_static.py tests/fixtures/demo-bad --all --format json \
  | jq -e '.overall.percentage < 40'

# Test S4: demo-good scores high (covers B2)
python scripts/scan_static.py tests/fixtures/demo-good --all --format json \
  | jq -e '.overall.percentage >= 65'

# Test S5: single axis only emits that axis (covers B2)
python scripts/scan_static.py tests/fixtures/demo-bad --axis instruct --format json \
  | jq -e 'has("axes") and (.axes | keys | length == 1) and (.axes | has("instruct"))'

# Test S6: JSON is well-formed (covers B2)
python scripts/scan_static.py tests/fixtures/demo-bad --all --format json \
  | python -m json.tool > /dev/null

# Test S7: snapshot file is created (covers B7)
rm -rf tests/fixtures/demo-bad/.agent-ready
python scripts/scan_static.py tests/fixtures/demo-bad --all --save-snapshot
ls tests/fixtures/demo-bad/.agent-ready/snapshots/*.json | head -1

# Test S8: HTML radar contains required tokens (covers B6)
python scripts/scan_static.py tests/fixtures/demo-good --full-report /tmp/agr-report
grep -q '<canvas id="radar"' /tmp/agr-report/report.html
grep -q 'cdn.jsdelivr.net/npm/chart.js@4' /tmp/agr-report/report.html

# Test S9: hybrid without API key warns and exits 0 (covers B4)
unset OPENAI_API_KEY ANTHROPIC_API_KEY
python scripts/scan_static.py tests/fixtures/demo-bad --all --hybrid 2>&1 \
  | grep -E "no LLM API key|Falling back"
test ${PIPESTATUS[0]} -eq 0

# Test S10: documentation_comprehension key present, not 'documentation' (covers B2)
python scripts/scan_static.py tests/fixtures/demo-good --all --format json \
  | jq -e '.dimensions | has("documentation_comprehension") and (has("documentation") | not)'
```

#### 4.2.2 Pytest skeleton (`tests/test_scan_static.py`)

```python
"""Behavioural tests for scripts/scan_static.py.

These tests invoke the scanner as a subprocess to mirror real CLI use.
Fixtures demo-bad/ and demo-good/ must exist under tests/fixtures/.
"""
from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parents[1]
SCRIPT = REPO_ROOT / "scripts" / "scan_static.py"
FIXTURES = REPO_ROOT / "tests" / "fixtures"


def _run(*args: str, env: dict[str, str] | None = None) -> subprocess.CompletedProcess[str]:
    cmd = [sys.executable, str(SCRIPT), *args]
    return subprocess.run(
        cmd, capture_output=True, text=True, env=env or os.environ.copy(),
    )


@pytest.fixture(scope="session")
def demo_bad() -> Path:
    p = FIXTURES / "demo-bad"
    if not p.is_dir():
        pytest.skip(f"missing fixture: {p}")
    return p


@pytest.fixture(scope="session")
def demo_good() -> Path:
    p = FIXTURES / "demo-good"
    if not p.is_dir():
        pytest.skip(f"missing fixture: {p}")
    return p


def test_b1_deterministic_scoring(demo_good: Path) -> None:
    """B1: same repo → same scores across runs."""
    r1 = _run(str(demo_good), "--all", "--format", "json")
    r2 = _run(str(demo_good), "--all", "--format", "json")
    assert r1.returncode == 0 and r2.returncode == 0
    d1 = json.loads(r1.stdout)
    d2 = json.loads(r2.stdout)
    d1.pop("timestamp"); d2.pop("timestamp")
    assert d1 == d2


def test_b2_schema_compliance(demo_good: Path) -> None:
    """B2: JSON has canonical keys and strict-superset shape."""
    r = _run(str(demo_good), "--all", "--format", "json")
    assert r.returncode == 0
    d = json.loads(r.stdout)
    assert set(d["dimensions"].keys()) == {
        "agent_instructions", "project_navigability", "testing_validation",
        "cicd_automation", "spec_driven_workflow", "skills_tooling",
        "documentation_comprehension", "claude_specific",
    }
    assert set(d["axes"].keys()) == {"instruct", "navigate", "validate"}
    assert d["overall"]["max"] == 100
    assert "hybrid_mode" in d


def test_b2_documentation_key_canonical(demo_good: Path) -> None:
    """B2: emit documentation_comprehension, never 'documentation'."""
    r = _run(str(demo_good), "--all", "--format", "json")
    d = json.loads(r.stdout)
    assert "documentation_comprehension" in d["dimensions"]
    assert "documentation" not in d["dimensions"]


def test_b3_axis_aggregation_consistency(demo_good: Path) -> None:
    """B3: sum of axis scores ≈ overall score (tolerance 0.05)."""
    r = _run(str(demo_good), "--all", "--format", "json")
    d = json.loads(r.stdout)
    axes_sum = sum(d["axes"][a]["score"] for a in ("instruct", "navigate", "validate"))
    assert abs(axes_sum - d["overall"]["score"]) <= 0.05
    layers = d["overall"]["layer_agnostic"] + d["overall"]["layer_claude"]
    assert abs(layers - d["overall"]["score"]) <= 0.05


def test_b4_hybrid_degrades_silently(demo_bad: Path) -> None:
    """B4: --hybrid with no API key behaves like static-only."""
    env = {k: v for k, v in os.environ.items()
           if k not in ("OPENAI_API_KEY", "ANTHROPIC_API_KEY")}
    r_static = _run(str(demo_bad), "--all", "--format", "json", env=env)
    r_hybrid = _run(str(demo_bad), "--all", "--hybrid", "--format", "json", env=env)
    assert r_static.returncode == 0 and r_hybrid.returncode == 0
    a = json.loads(r_static.stdout); b = json.loads(r_hybrid.stdout)
    a.pop("timestamp"); b.pop("timestamp")
    # hybrid_mode must be false in both
    assert a["hybrid_mode"] is False and b["hybrid_mode"] is False
    assert a == b


def test_b5_performance_budget(demo_good: Path) -> None:
    """B5: scan finishes well under 10s on the demo-good fixture."""
    import time
    t0 = time.monotonic()
    r = _run(str(demo_good), "--all", "--format", "json")
    elapsed = time.monotonic() - t0
    assert r.returncode == 0
    # demo-good is small; allow ample slack but enforce the cap.
    assert elapsed < 10.0, f"scan took {elapsed:.2f}s"


def test_b6_radar_html_validity(demo_good: Path, tmp_path: Path) -> None:
    """B6: HTML radar contains required tokens."""
    out = tmp_path / "report"
    r = _run(str(demo_good), "--full-report", str(out))
    assert r.returncode == 0
    html = (out / "report.html").read_text(encoding="utf-8")
    assert '<canvas id="radar"' in html
    assert "cdn.jsdelivr.net/npm/chart.js@4" in html
    assert "new Chart(" in html


def test_b7_snapshot_persisted(demo_bad: Path, tmp_path: Path) -> None:
    """B7: --save-snapshot creates a JSON snapshot file."""
    work = tmp_path / "demo-bad"
    shutil.copytree(demo_bad, work)
    r = _run(str(work), "--all", "--save-snapshot")
    assert r.returncode == 0
    snaps = list((work / ".agent-ready" / "snapshots").glob("*.json"))
    assert len(snaps) == 1
    data = json.loads(snaps[0].read_text(encoding="utf-8"))
    assert "overall" in data and "dimensions" in data


def test_b8_invalid_path_exits_2(tmp_path: Path) -> None:
    """B8: non-directory path → exit code 2."""
    r = _run(str(tmp_path / "nope"))
    assert r.returncode == 2
    assert r.stderr.startswith("ERROR:")


def test_b8_invalid_blend_exits_2(demo_bad: Path) -> None:
    """B8: --llm-blend outside [0,1] → exit code 2."""
    r = _run(str(demo_bad), "--all", "--llm-blend", "1.5")
    assert r.returncode == 2


def test_b8_axis_and_all_mutually_exclusive(demo_bad: Path) -> None:
    """B8: --axis and --all cannot be combined."""
    r = _run(str(demo_bad), "--axis", "instruct", "--all")
    assert r.returncode == 2


def test_compare_diff_table(demo_good: Path, tmp_path: Path) -> None:
    """compute_diff is correctly wired through --compare."""
    snap = tmp_path / "snap.json"
    r1 = _run(str(demo_good), "--all", "--format", "json")
    snap.write_text(r1.stdout, encoding="utf-8")
    r2 = _run(str(demo_good), "--all", "--compare", str(snap), "--format", "json")
    assert r2.returncode == 0
```

Mapping of pytest cases to behaviours:

| Test                                             | Covers |
|--------------------------------------------------|--------|
| `test_b1_deterministic_scoring`                  | B1     |
| `test_b2_schema_compliance`                      | B2     |
| `test_b2_documentation_key_canonical`            | B2     |
| `test_b3_axis_aggregation_consistency`           | B3     |
| `test_b4_hybrid_degrades_silently`               | B4     |
| `test_b5_performance_budget`                     | B5     |
| `test_b6_radar_html_validity`                    | B6     |
| `test_b7_snapshot_persisted`                     | B7     |
| `test_b8_invalid_path_exits_2`                   | B8     |
| `test_b8_invalid_blend_exits_2`                  | B8     |
| `test_b8_axis_and_all_mutually_exclusive`        | B8     |
| `test_compare_diff_table`                        | (extra)|

The test module is intentionally written with `subprocess` so it can run
against a future packaged build without modification.

---

## 5. Implementation Order

This is a guidance, not a contract; the test suite is the final arbiter.

### Day 1 — INSTRUCT axis end-to-end

1. Scaffold `scripts/scan_static.py` with constants, helpers, dataclasses,
   and `_build_parser()` exactly as in Section 3.10.
2. Implement D1 checks completely (already shown in the skeleton).
3. Implement D5 and D8 checks per Section 3.3.5 and 3.3.8.
4. Implement `score_dimension`, `score_axis`, `score_overall`,
   `compute_maturity`, `compute_band`.
5. Implement `emit_json` and a minimal `emit_pretty` (header panel + per-axis
   bar; no recommendation table yet).
6. Land tests `test_b1_*`, `test_b2_*`, `test_b3_*`, `test_b8_*`.
7. End-of-day check: `python scripts/scan_static.py . --axis instruct
   --format json | jq .` returns a valid JSON record.

### Day 2 — NAVIGATE + VALIDATE axes, full JSON, markdown

1. Implement D2, D7, D6 (the NAVIGATE-axis dimensions).
2. Implement D3, D4 (the VALIDATE-axis dimensions).
3. Flesh out `emit_pretty`: dimension table and top-5 recommendation table
   per Section 3.6.
4. Implement `emit_markdown` per Section 3.6 (mirror the pretty layout in
   plain text).
5. Land remaining behavioural tests: `test_b5_*`, `test_compare_diff_table`.
6. End-of-day check: `scan_static.py . --all` produces a complete, readable
   pretty report; demo-bad < 40 %, demo-good ≥ 65 %.

### Day 3 — HTML radar, snapshot/diff, hybrid mode, polish

1. Implement `emit_html_radar` per Section 3.7. Verify against the rule in
   3.7.4 that every JS literal is built via `json.dumps`. Open the file in a
   real browser and confirm the radar renders.
2. Wire `--visualize` and `--full-report`.
3. Implement `save_snapshot`, `load_snapshot`, `compute_diff`, and the
   `--compare` rendering.
4. Implement `maybe_enrich_with_llm` and `_query_llm_score` per Section 3.9.
5. Land tests `test_b4_*`, `test_b6_*`, `test_b7_*`.
6. Run the full pytest suite green; the bash smoke tests S1-S10 pass.
7. Add `requirements-workshop.txt` (Section 7).

---

## 6. Out of Scope (Strict)

The scanner deliberately does NOT do, and MUST NOT attempt:

1. **Mutating skills.** No write/create/rename/delete under `skills/`.
2. **New dimensions / new weights.** The 8-dimension rubric and the 38/34/28
   axis weights are immutable.
3. **Dashboard server / SaaS.** No HTTP server, no `Flask`/`FastAPI`,
   no background daemons.
4. **GitHub App / Action publication.** This spec covers only the local CLI.
   A future Action wrapper is out of scope.
5. **JavaScript / TypeScript / Node / Bun.** Python only. The only JS in this
   repo is the inline Chart.js setup in the radar HTML.
6. **ML / AI frameworks.** No `transformers`, no `langchain`, no
   `llama-index`. Optional hybrid mode uses the `anthropic` or `openai`
   SDK at most, called via stdlib `urllib.request` to keep the dependency
   surface flat.
7. **Bundling Chart.js.** Always loaded from the JSDelivr CDN at runtime.
8. **Auto-fixing.** The scanner only diagnoses. The companion skill
   `agent-ready-fix` is responsible for remediation.
9. **Cross-repo or multi-repo scans.** One scan = one repository.
10. **Sub-second precision in timestamps or snapshots.** Snapshot filenames
    are second-resolution; no microseconds.

---

## 7. Dependencies

`requirements-workshop.txt` (NEW file at repo root):

```
# Required at runtime
rich>=13.0,<14
pyyaml>=6.0,<7

# Optional: only needed for --hybrid mode.
# Either of these is sufficient. Install whichever provider you use.
# anthropic>=0.39,<1
# openai>=1.30,<2
```

Notes for the implementing agent:

- The scanner imports `yaml` conditionally; if `pyyaml` is missing, the
  `d6_skill_frontmatter` check degrades to a regex-based heuristic
  (`'^name:\s*\S+'` in the first 2 KB after the leading `---`).
- The hybrid path uses `urllib.request` only; the `anthropic` / `openai`
  SDKs are *not* imported. The lines are commented in
  `requirements-workshop.txt` so they remain documented but not installed
  by default.
- Python 3.11+ is non-negotiable because `tomllib` is used for
  `pyproject.toml` parsing.

---

## 8. File Layout in Target Repo

After the agent's work, the repository looks like:

```
agent-ready-skill/
├── README.md                              (UNCHANGED)
├── LICENSE                                (UNCHANGED)
├── CONTRIBUTING.md                        (UNCHANGED)
│
├── scripts/
│   └── scan_static.py                     (NEW — this spec)
│
├── tests/
│   ├── test_scan_static.py                (NEW — pytest suite)
│   └── fixtures/
│       ├── demo-bad/                      (NEW — see spec doc 06)
│       └── demo-good/                     (NEW — see spec doc 06)
│
├── requirements-workshop.txt              (NEW)
│
├── skills/                                (READ-ONLY)
│   ├── agent-ready/
│   │   ├── SKILL.md
│   │   └── references/
│   │       └── scoring.md                 (CANONICAL RUBRIC)
│   ├── agent-ready-scan/SKILL.md
│   ├── agent-ready-fix/SKILL.md
│   ├── agent-ready-report/SKILL.md
│   └── agent-ready-diff/SKILL.md
│
└── .agent-ready/                          (RUNTIME — created by --save-snapshot)
    └── snapshots/
        └── YYYYMMDD-HHMMSS.json
```

The agent MUST NOT add or modify any file outside the boxes marked NEW.

---

## 9. Self-check Before Hand-off

Before declaring the work done, the agent runs (in order):

1. `python -c "import scripts.scan_static"` — module imports clean.
   (If running as a script, this check is `python -m py_compile scripts/scan_static.py`.)
2. `python scripts/scan_static.py --version` — prints `scan_static.py 1.0.0`.
3. `python scripts/scan_static.py . --all` — scans the agent-ready-skill repo
   itself; produces a pretty report.
4. `python scripts/scan_static.py . --all --format json | python -m json.tool > /dev/null`
   — JSON is well-formed.
5. `pytest tests/test_scan_static.py -v` — all pytest cases pass.
6. The bash smoke tests S1-S10 of Section 4.2.1 all pass.
7. `ruff check scripts/scan_static.py tests/test_scan_static.py` — zero
   lint findings (if Ruff is configured; otherwise skip).
8. `mypy --strict scripts/scan_static.py` — clean (if mypy configured).
9. Open the generated HTML radar in a real browser; confirm the chart
   renders and the per-axis cards are populated.
10. Diff the JSON output's `dimensions` block against the schema in
    `skills/agent-ready/references/scoring.md`; confirm strict-superset.

If any step fails, fix the root cause — do not work around it.

---

## 10. Glossary

| Term                | Definition                                                                                            |
|---------------------|-------------------------------------------------------------------------------------------------------|
| Dimension (D1-D8)   | One of the eight canonical rubric categories defined in `scoring.md`.                                 |
| Axis (3)            | A derived grouping of dimensions for the workshop lens: INSTRUCT, NAVIGATE, VALIDATE.                 |
| Layer A / Agnostic  | The subtotal D1+D2+D3+D4+D5; max 76 of 100.                                                           |
| Layer B / Claude    | The subtotal D6+D7+D8; max 24 of 100.                                                                 |
| Maturity Level (0-5)| Foundational/Guided/Structured/Optimized/Autonomous gate, applied to overall and to each axis.        |
| Band                | One of `not_ready` / `partially_ready` / `ready` / `optimized` (0-30 / 31-60 / 61-80 / 81-100).        |
| Static mode         | The default deterministic scoring path; no network calls.                                             |
| Hybrid mode         | Optional path that blends LLM judgement into three subjective sub-criteria.                           |
| Snapshot            | A JSON file written under `.agent-ready/snapshots/` by `--save-snapshot`.                             |
| Check               | An atomic boolean-or-partial-credit observation against a single inspection target.                   |
| Internal weight     | A check's weight within its dimension (sum to 100 per dimension).                                     |
| Strict-superset     | The scanner's JSON contains every field required by `scoring.md`, plus additive fields (`axes`, etc.) |

---

## 11. Open Questions for the Implementing Agent

The agent should resolve these by reading `scoring.md` directly. They are
listed so the agent does not need to guess.

1. **Exact sub-criterion wording per dimension.** This document gives
   functional descriptions; `scoring.md` gives the canonical wording.
   When the canonical wording is longer, prefer it in the `name` field
   shown to users.
2. **Whether D6 expects skills under `skills/` or `.claude/skills/`.**
   Both are acceptable in `scoring.md`; the scanner accepts either.
3. **Whether `AGENTS.md` counts equivalently to `CLAUDE.md` for D8.**
   This spec scores `CLAUDE.md` strictly for D8 (Claude-specific) but
   accepts both for D1 (generic agent instructions). The `d8_claude_md_root`
   check is `CLAUDE.md`-specific by design.
4. **Whether `pyproject.toml`-embedded configuration counts as a separate
   file for checks like the linter or coverage check.** Yes — both forms
   count equally.

If any further question arises during implementation, the agent escalates
by leaving a `# QUESTION:` comment in the source and continues with the
most conservative interpretation (lower score when in doubt).

---

*End of specification.*
