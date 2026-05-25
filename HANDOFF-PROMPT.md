# Hand-off Prompt — Agent-Ready-Skill Workshop Implementation

This file contains the prompt to give an AI coding agent (Claude Code, Cursor, etc.) working inside the [`agent-ready-skill`](https://github.com/RisorseArtificiali/agent-ready-skill) repository so it can implement the PyCon Italia 2026 workshop deliverables.

---

## How to use this prompt

**Prerequisites** (do these once before running the agent):

1. Clone `agent-ready-skill` and create a workshop branch:
   ```bash
   git clone git@github.com:RisorseArtificiali/agent-ready-skill.git
   cd agent-ready-skill
   git checkout -b workshop/pycon-2026
   ```

2. Copy the three spec docs into the repo so the agent can read them locally:
   ```bash
   mkdir -p docs/workshop
   cp /path/to/pycon2026-workshop/02-competitive-analysis.md      docs/workshop/
   cp /path/to/pycon2026-workshop/05-implementation-plan.md       docs/workshop/
   cp /path/to/pycon2026-workshop/06-implementation-plan-rest.md  docs/workshop/
   git add docs/workshop && git commit -m "docs: add workshop implementation specs"
   ```

3. Start the agent in the repo root. Paste the prompt below into the first message.

4. Review every commit before pushing. The Day-by-Day plan keeps PRs small and reviewable.

---

## The prompt (copy everything below into the agent)

```
You are implementing the PyCon Italia 2026 workshop deliverables for this repository (agent-ready-skill). Your goal is to add a deterministic Python tooling layer on top of the existing prompt-only skills, without modifying any of the existing skills.

## What this repo is right now

This repo is prompt-only. It contains 5 Agent Skills under skills/ that ask an LLM to score a codebase against 8 dimensions:

1. Agent Instructions (20)
2. Project Navigability (18)
3. Testing & Validation (16)
4. CI/CD & Automation (12)
5. Spec-Driven Workflow (10)
6. Skills & Tooling (8)
7. Documentation & Comprehension (8)
8. Claude-Specific (8)

The canonical rubric lives at skills/agent-ready/references/scoring.md. This file is READ-ONLY for you. Do not edit it. Do not edit any file under skills/.

## What you are adding

A deterministic Python layer that complements the LLM skills. The full spec lives in two documents under docs/workshop/. Read them in this order:

1. docs/workshop/02-competitive-analysis.md — context only. Understand what the workshop is trying to differentiate from. Skim, do not memorize.
2. docs/workshop/05-implementation-plan.md — the spec for scripts/scan_static.py. This is your primary deliverable.
3. docs/workshop/06-implementation-plan-rest.md — specs for everything else: apply_fix.py, report_gen.py, check_setup.py, templates/, repos/demo-bad and repos/demo-good, WORKSHOP.md, requirements-workshop.txt.

You must follow the specs as written. If you find an ambiguity, write your interpretation as a comment in the relevant file and proceed; flag it in the PR description.

## Canonical facts (do not deviate)

- 8 dimensions sum to 100. Weights above are authoritative; do not change them.
- The workshop projects these 8 dimensions onto 3 axes using exactly this partition (this is the ONLY partition that hits the target weights):
  - INSTRUCT (38) = Agent Instructions (20) + Spec-Driven Workflow (10) + Claude-Specific (8)
  - NAVIGATE (34) = Project Navigability (18) + Documentation & Comprehension (8) + Skills & Tooling (8)
  - VALIDATE (28) = Testing & Validation (16) + CI/CD & Automation (12)
- Maturity levels (gate-based, applied to overall score): L1 Foundational ≥40, L2 Guided ≥55, L3 Structured ≥70, L4 Optimized ≥85, L5 Autonomous ≥95.
- JSON output schema must be a STRICT SUPERSET of scoring.md's schema. Use canonical snake_case keys: agent_instructions, project_navigability, testing_validation, cicd_automation, spec_driven_workflow, skills_tooling, documentation_comprehension, claude_specific. Do not use the inconsistent "documentation" key from skills/agent-ready-scan/SKILL.md.

## Target file layout

```
agent-ready-skill/
├── scripts/
│   ├── scan_static.py        # NEW — spec in docs/workshop/05
│   ├── apply_fix.py          # NEW — spec in docs/workshop/06
│   ├── report_gen.py         # NEW — spec in docs/workshop/06
│   └── check_setup.py        # NEW — spec in docs/workshop/06
├── tests/
│   ├── test_scan_static.py
│   ├── test_apply_fix.py
│   ├── test_report_gen.py
│   └── test_end_to_end.py
├── templates/
│   ├── claude-md-template.md
│   ├── ci-template.yml
│   ├── editorconfig
│   ├── env-example
│   ├── security-md-template.md
│   ├── contributing-md-template.md
│   ├── pyproject-snippet.toml
│   └── badge.svg.j2
├── repos/
│   ├── demo-bad/             # NEW — targets ~25% overall
│   └── demo-good/            # NEW — targets ~85% overall
├── WORKSHOP.md               # NEW — participant guide
├── requirements-workshop.txt # NEW — rich, pyyaml, jinja2
├── docs/workshop/            # specs (already copied for you)
└── skills/                   # UNCHANGED — read-only canonical rubric
```

## Hard guardrails

1. Do not modify, rename, or delete anything under skills/.
2. Do not modify README.md, LICENSE, CONTRIBUTING.md at the repo root unless the spec explicitly asks (it does not).
3. Python 3.11+ only. Use tomllib from stdlib (no third-party toml). Stdlib + rich + pyyaml + jinja2 only. Optional: anthropic OR openai SDK for hybrid mode (gracefully degrade if absent).
4. No JS bundler. Any HTML output loads Chart.js from cdn.jsdelivr.net.
5. No Docker, devcontainer, GitHub App, or SaaS components. CLI scripts only.
6. Every f-string and every dynamic JS injection must be syntactically valid. Build complex strings as Python variables BEFORE the f-string; never put list comprehensions inside f-string placeholders.
7. Never overwrite an existing user file without an interactive confirmation prompt (this applies to apply_fix.py especially).

## Definition of done

The work is complete when ALL of the following are true:

1. Every file in the target layout exists at the specified path.
2. `pytest tests/` exits 0. Every behavioral acceptance criterion in the specs has a passing test.
3. End-to-end check passes:
   ```bash
   python scripts/check_setup.py                                                   # exit 0
   python scripts/scan_static.py repos/demo-bad/  --all --format json --output /tmp/bad.json
   python scripts/scan_static.py repos/demo-good/ --all --format json --output /tmp/good.json
   jq '.overall.percentage' /tmp/bad.json   # < 30
   jq '.overall.percentage' /tmp/good.json  # > 80
   python scripts/scan_static.py repos/demo-bad/ --all --save-snapshot
   python scripts/apply_fix.py --all-fixes repos/demo-bad/  # interactive; auto-confirm in test
   python scripts/scan_static.py repos/demo-bad/ --all \
     --compare repos/demo-bad/.agent-ready/snapshots/*.json
   # delta must show overall improvement ≥ 20 points
   python scripts/report_gen.py /tmp/bad.json --output /tmp/report-bad/
   # produces report.txt, recommendations.md, badge.svg
   ```
4. `python scripts/scan_static.py repos/demo-good/ --all --visualize` opens a Chart.js radar HTML with no JS console errors.
5. README of agent-ready-skill is unchanged (we'll add a workshop section in a separate PR).
6. `git diff --stat skills/` is empty.

## Day-by-day plan (recommended)

**Day 1 — Foundation + INSTRUCT axis**
- requirements-workshop.txt
- scripts/check_setup.py (and one test)
- scripts/scan_static.py CLI scaffold + helper functions
- INSTRUCT axis checks (D1 + D5 + D8) end-to-end with pretty + json output
- tests/test_scan_static.py covering INSTRUCT
- Open PR: "workshop: scan_static.py INSTRUCT axis"

**Day 2 — NAVIGATE + VALIDATE axes**
- NAVIGATE checks (D2 + D7 + D6)
- VALIDATE checks (D3 + D4)
- Markdown output adapter
- repos/demo-bad/ and repos/demo-good/ skeletons + key files (per spec §6 in doc 06)
- Tests for all 8 dimensions
- Open PR: "workshop: complete static scanner + demo repos"

**Day 3 — HTML radar, snapshot/diff, hybrid, fixes**
- HTML radar output (`--visualize`)
- `--save-snapshot` and `--compare`
- `--hybrid` mode with graceful degradation
- templates/* (all 8 template files)
- scripts/apply_fix.py + tests
- scripts/report_gen.py + tests + templates/badge.svg.j2
- tests/test_end_to_end.py covering the full DoD flow
- WORKSHOP.md
- Open PR: "workshop: visualization, snapshots, fixes, reports"

## How to ask for help

Do NOT ask the human clarifying questions about the spec mid-implementation. The specs are detailed enough. If you hit a genuine ambiguity:
- Write your chosen interpretation as a comment in the code.
- List it in the PR description under "Spec ambiguities resolved".
- Continue.

If you discover a real spec bug (a contradiction between docs/workshop/05 and 06, or between either doc and skills/agent-ready/references/scoring.md): stop, document the contradiction, and open a draft PR with the question.

## First action

Read these files in order, then propose a Day 1 implementation plan (file list with line estimates) before writing any code:
1. skills/agent-ready/references/scoring.md
2. docs/workshop/05-implementation-plan.md (sections 1, 2, 3.1–3.4, 4)
3. docs/workshop/06-implementation-plan-rest.md (sections 1, 4, 9)

After I approve the plan, proceed to implementation.
```

---

## Notes for the human running this

- The agent will probably take 2-4 hours total in agent-time across Days 1-3. In wall-clock time with you reviewing each PR, expect 1-2 days.
- The Day 1 PR is the most important — if the scanner foundation is wrong, everything else compounds the error. Read it carefully.
- The "do not modify skills/" guardrail is load-bearing. The workshop's whole pitch is that the new Python layer is additive. If the agent edits scoring.md, the existing skill behavior changes and the talk's narrative breaks.
- If the agent gets confused about the 3-axis partition, point it at this verbatim:
  > INSTRUCT (38) = 20 + 10 + 8 ; NAVIGATE (34) = 18 + 8 + 8 ; VALIDATE (28) = 16 + 12. There is no other valid partition.
- If the agent wants to add SECURITY.md as a dimension or scope item, decline — that's intentionally out of scope for v0 (the workshop's 8 dimensions don't include security).
- After the agent finishes, run `presenter-notes.md` Day-of checks before the workshop: a fresh clone + `pip install -r requirements-workshop.txt` + `python scripts/check_setup.py` should pass in <60 seconds.
