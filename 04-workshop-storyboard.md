# Phase 3: Workshop Structure & Storyboard

> **FINAL — reconciled with slide deck.** Final slide count: **35 / Total duration: 120 min**
> **Companion files:** `07-slides-outline.md` (slide spec), `presentation/slides.html` (deck), `presenter-notes.md` (printable backup).

## Goal
Minute-by-minute storyboard of the 2-hour workshop with incremental deliverables.
Participants **discover** the 3 axes one at a time, not all together.

## Slide ↔ Minute Mapping (FINAL)

| Time (mm:ss) | Phase | Slides | Duration |
|--------------|-------|--------|----------|
| 00:00–00:10 | Phase 0: Setup & Icebreaker | 1–5 | 10 min |
| 00:10–00:15 | Phase 1a: The Problem | 6–9 | 5 min |
| 00:15–00:20 | Phase 1b: The Model | 10–15 | 5 min |
| 00:20–00:25 | Phase 1c: Demo + Magic Moment #1 | 16–17 | 5 min |
| 00:25–00:50 | Phase 2: INSTRUCT hands-on | 18–21 | 25 min |
| 00:50–01:10 | Phase 3: NAVIGATE hands-on | 22–24 | 20 min |
| 01:10–01:40 | Phase 4: VALIDATE + Hybrid Moment | 25–30 | 30 min |
| 01:40–02:00 | Phase 5: Fix Sprint & Wrap | 31–35 | 20 min |
| **Total** | — | **35** | **120 min** |

---

## Conventions

```
🎤  = Teacher speaks / demo
💻  = Participants code / type
🔍  = Participants analyze their OWN repo
📊  = Visualization reveal
⚡  = "Magic moment" (wow factor)
🎁  = Deliverable takeaway
[Sn] = Slide reference in presentation/slides.html
```

---

## FULL TIMELINE (120 min)

### PHASE 0: Setup & Icebreaker [00:00–00:10] (10 min) — Slides 1–5

```
00:00  🎤  Welcome + "raise hand if..." poll (2 min)
       - Written Python in production? 
       - Used an AI coding agent? (Cursor, Claude Code, Copilot, etc.)
       - Ever had an agent mess up your codebase?

00:02  🎤  The Promise (3 min)
       "In 2 hours you'll measure how ready YOUR codebase is for AI agents,
        fix the most impactful gaps, and walk out with a reusable toolkit"
       
       Show the END STATE first (teaser del radar chart finale)
       ← Single screenshot o GIF del radar chart completato

00:05  💻  Setup Check (5 min)
       - Everyone: pip install rich pyyaml (2 deps total)
       - Clone/fetch workshop materials
       - Verify: python scan_static.py --version works
       - Fallback: chi non ha repo pronto usa il DEMO REPO
```

**Deliverable**: `scripts/check_setup.py` — environment check, prints ok/fail

---

### PHASE 1: The Mental Model [00:10–00:25] (15 min) — Slides 6–17

```
00:10  🎤  The Problem — "Why agents fail" (5 min)
       
       Storytime: "Last month I asked Claude Code to add validation
        to our API endpoint. It added tests... in the wrong directory.
        It followed our linting rules... from 2 years ago.
        It couldn't find where we keep request schemas."
       
       → Agents are NOT stupid. They are **uninformed**.
       
       Write on board (or slide):
       ┌─────────────────────────────────────────────┐
       │  An agent is only as good as your           │
       │  ability to tell it WHAT to do, WHERE       │
       │  things are, and HOW to know if it worked   │
       └─────────────────────────────────────────────┘

00:15  🎤  Introduce Three-Axis Model (5 min)
       
       Draw the triangle live:
              📝 INSTRUCT
             /            \
            /              \
      🧭 NAVIGATE —— ✅ VALIDATE
       
       Axis 1: INSTRUCT    "Does the agent understand WHAT we want?"
       Axis 2: NAVIGATE    "Can the agent find its way around?"
       Axis 3: VALIDATE    "Can the agent tell if it did it right?"
       
       KEY MESSAGE: These aren't random best practices.
       Each maps to a REAL failure mode of AI agents.

00:20  🎤  Live Demo: Two Repos, Two Scores (5 min)
       
       Repo A: "chaos-monkey" (intentionally bad)
         → Scan it live → show terrible scores
         → "This agent will break things"
       
       Repo B: "agent-heaven" (well-structured)  
         → Scan it live → show great scores
         → "This agent will be productive"
       
       ⚡ MAGIC MOMENT #1: Same tool, different scores
        The difference isn't the agent — it's the CODEBASE.
```

**Deliverable**: `repos/demo-bad/` and `repos/demo-good/` — two example repos ready to scan

---

### PHASE 2: AXIS 1 — INSTRUCT [00:25–00:50] (25 min) — Slides 18–21

```
00:25  🎤  Introduce Axis 1: INSTRUCT (3 min)
       
       "Your agent just landed in your codebase. It doesn't know
        anything. What's the FIRST thing it needs?"
       
       → Instructions. Context. Not code — MEANING.
       
       Show the 3 sub-dimensions of INSTRUCT:
       ├─ Agent Instructions (CLAUDE.md, .cursorrules)  [weight: 20]
       ├─ Spec-Driven Dev (ARCHITECTURE.md, ADRs)      [weight: 10]
       └─ Documentation Quality (README, CONTRIBUTING)   [weight: 8]

00:28  💻🔍  HANDS-ON: First Scan — Axis 1 ONLY (7 min)
       
       Command:
       python scripts/scan_static.py /path/to/your/repo --axis instruct
       
       Output example:
       ╭──────────────────────────────────────────╮
       │  📝 AXIS 1: INSTRUCT                     │
       │  ═══════════════════════════════════     │
       │                                          │
       │  Score: 35/100  ████████░░░░░░░░░ 35%   │
       │                                          │
       │  ✅ README.md          found (847 chars)  │
       │  ❌ CLAUDE.md          NOT FOUND    -20   │
       │  ❌ .cursorrules       NOT FOUND     -0   │
       │  ❌ CONTRIBUTING.md     NOT FOUND     -0   │
       │  ❌ ARCHITECTURE.md     NOT FOUND    -10   │
       │  ⚠️  ai-context         partial       -5   │
       │                                          │
       │  Level: 1 — FOUNDATIONAL                │
       ╰──────────────────────────────────────────╯
       
       Participants see THEIR score. Surprise/disappointment factor 😅

00:35  🎤  Debrief: What does this mean? (3 min)
       
       "A score of 35 means: if you ask an agent to make a change,
        it has a ~35% chance of understanding your project's
        conventions, goals, and architecture BEFORE writing code."
       
       Show real failure examples:
       - Agent writes Flask routes when you use FastAPI
       - Agent puts utils in src/utils/ when you use lib/
       - Agent follows PEP8 when you use Black+isort

00:38  💻  HANDS-ON: The Quickest Win (7 min)
       
       Task: Create a minimal CLAUDE.md (or AGENTS.md for agnostic)
       
       Template provided:
       ---
       # Project Context
       ## Overview
       <one paragraph about what this project does>
       
       ## Architecture
       - Framework: <FastAPI / Django / Flask / ...>
       - Main entry point: <file>
       - Key directories: <list>
       
       ## Conventions
       - Style: <ruff / black / ...>  
       - Test framework: <pytest / ...>
       - Type hints: <strict / loose>
       
       ## Commands
       - Run tests: <command>
       - Run linter: <command>
       - Run format: <command>
       
       ## Pitfalls
       - <don't do X because Y>
       ---
       
       Participants fill in the template for THEIR repo.
       Save it to repo root.

00:45  🔍  Re-scan — See the Improvement (3 min)
       
       python scripts/scan_static.py /path/to/your/repo --axis instruct
       
       ⚡ MAGIC MOMENT #2: Score jumps!
       Before: 35%  →  After: 55-75% (+20 to +40 points!)
       
       Room reaction: "That's it? One file?"
       
       🎤  "Yes. ONE file. That's the whole point.
        Agent readiness isn't about rewriting your codebase.
        It's about giving agents the RIGHT information."
       
00:48  🎤  Transition to Axis 2 (2 min)
       
       "Great — your agent now knows WHAT to do.
        But does it know WHERE things are?
        That's Axis 2."
```

**Deliverables**:
- `scripts/scan_static.py` with `--axis instruct` mode
- `templates/claude-md-template.md` — fill-in template for participants
- Before/after score for every participant

---

### PHASE 3: AXIS 2 — NAVIGATE [00:50–01:10] (20 min) — Slides 22–24

```
00:50  🎤  Introduce Axis 2: NAVIGATE (3 min)
       
       "Your agent knows WHAT to do. Now it opens a file...
        and sees 5000 lines of spaghetti. Or it can't find
        where tests live. Or it formats code wrong and CI fails."
       
       Sub-dimensions of NAVIGATE:
       ├─ Navigability (structure, conventions, naming)     [weight: 18]
       ├─ Tooling (linter, formatter, type checker)        [weight: 8]
       └─ Agent-Specific Config (.env.example, containers)  [weight: 8]

00:53  💻🔍  HANDS-ON: Scan Axis 2 (5 min)
       
       python scripts/scan_static.py /path/to/your/repo --axis navigate
       
       Output:
       ╭──────────────────────────────────────────╮
       │  🧭 AXIS 2: NAVIGATE                    │
       │  ═══════════════════════════════════     │
       │                                          │
       │  Score: 52/100  ████████████████░░ 52%   │
       │                                          │
       │  ✅ .editorconfig       found          +2   │
       │  ✅ pyproject.toml      found           +2   │
       │  ✅ ruff configured     [tool.ruff]     +4   │
       │  ✅ black configured    [tool.black]    +4   │
       │  ❌ pyrightconfig.json  NOT FOUND      -4   │
       │  ❌ .env.example        NOT FOUND      -2   │
       │  ❌ Dockerfile          NOT FOUND      -2   │
       │  ⚠️  Large files (>300ln) 3 found      -2   │
       ╰──────────────────────────────────────────╯

00:58  🎤  The "Why" Behind Each Check (2 min)
       
       Quick-fire explanations:
       - No .editorconfig → agent mixes tabs/spaces → CI fails
       - No type checker → agent can't verify its changes compile
       - No .env.example → agent guesses env vars → broken config
       - Large files → agent's context window fills up → hallucinates

01:00  💻  HANDS-ON: Pick ONE Fix (5 min)
       
       Choose from menu (based on their scan):
       A) Add .env.example (30 sec — list your env vars)
       B) Enable pyright (2 min — create pyrightconfig.json)
       C) Add .editorconfig (1 min — copy template)
       D) Configure ruff properly (3 min — add [tool.ruff] section)
       
       Most pick A or C (quickest wins)

01:05  🔍  Re-scan Axis 2 (2 min)
       
       Score improvement visible immediately.
       
       Discuss: "Notice how NAVIGATE improvements help HUMANS too,
        not just agents. This isn't 'AI stuff' — this is
        'good software engineering'."

01:07  🎤  Transition to Axis 3 (3 min)
       
       "Your agent knows WHAT to do and WHERE things are.
        But here's the scary part: it makes a change, says 'done!',
        and you deploy... and production breaks."
       
       "How do you know the agent did it RIGHT?"
       → Axis 3: VALIDATE
```

**Deliverables**:
- `scan_static.py` with `--axis navigate` mode
- Templates: `.env.example`, `.editorconfig`, `pyrightconfig.json`

---

### PHASE 4: AXIS 3 — VALIDATE + HYBRID MOMENT [01:10–01:40] (30 min) — Slides 25–30

```
01:10  🎤  Introduce Axis 3: VALIDATE (3 min)
       
       "This is the axis that separates 'fun toy' from
        'production tool'. Validation is how you trust
        an agent with your codebase."
       
       Sub-dimensions:
       ├─ Testing (framework, files, coverage)           [weight: 16]
       └─ CI/CD (pipeline, quality gates, security)       [weight: 12]

01:13  💻🔍  HANDS-ON: Scan Axis 3 (5 min)
       
       python scripts/scan_static.py /path/to/your/repo --axis validate
       
       Output:
       ╭──────────────────────────────────────────╮
       │  ✅ AXIS 3: VALIDATE                    │
       │  ═══════════════════════════════════     │
       │                                          │
       │  Score: 28/100  ████████░░░░░░░░░ 28%   │
       │                                          │
       │  ✅ pytest configured   [tool.pytest]    +6   │
       │  ✅ test files found    12 files         +5   │
       │  ✅ poetry.lock          present          +2   │
       │  ❌ CI workflow          NOT FOUND       -4   │
       │  ❌ coverage configured  NO              -4   │
       │  ❌ SECURITY.md          NOT FOUND        -2   │
       │  ❌ pre-commit           NOT FOUND        -2   │
       ╰──────────────────────────────────────────╯

01:18  🎤  The Testing Paradox (3 min)
       
       "Here's the controversial take: tests are NOT for finding bugs.
        Tests are for giving AGENTS a safety net."
       
       Show: When an agent adds a feature:
       1. Writes code → 2. Runs existing tests → 3. If pass → confident PR
       
       Without tests: agent writes code → you manually verify → bottleneck
       With tests: agent writes code → tests verify → you review → scale
       
       "Tests multiply your effectiveness WITH agents."

01:21  💻  HANDS-ON: The CI File (7 min)
       
       Provide template: `.github/workflows/agent-ready-ci.yml`
       
       Minimal but real:
       ```yaml
       name: Agent Ready CI
       on: [push, pull_request]
       jobs:
         validate:
           runs-on: ubuntu-latest
           steps:
             - uses: actions/checkout@v4
             - uses: actions/setup-python@v5
               with:
                 python-version: "3.12"
             - run: pip install ruff pytest
             - run: ruff check .
             - run: pytest --tb=short
       ```
       
       Participants adapt to their project (change linter/test runner)
       Save to `.github/workflows/ci.yml`

01:28  🔍  Re-scan Axis 3 (2 min)
       
       Scores jump for everyone who added CI.

01:30  ⚡⚡⚡  THE HYBRID MOMENT — Full Scan (5 min)
       
       THIS IS THE PEAK OF THE WORKSHOP.
       
       Command:
       python scripts/scan_static.py /path/to/your/repo --all --hybrid
       
       Output — THE FULL THREE-AXIS REPORT:
       
       ╭─────────────────────────────────────────────────────╮
       │    ╭───────────────────────────────────────────╮   │
       │    │   AGENT READINESS ASSESSMENT              │   │
       │    │   Repo: <their-repo-name>                 │   │
       │    ╰───────────────────────────────────────────╯   │
       │                                                 │
       │    Overall: 54%  │  Level 2: GUIDED  ▲▸▸ Level 3│
       │                                                 │
       │    ┌────────────┬────────┬────────┬────────┐     │
       │    │ Axis       │ Static │  LLM   │ Final  │     │
       │    ├────────────┼────────┼────────┼────────┤     │
       │    │ 📝INSTRUCT │   65%  │   50%  │  59%   │     │
       │    │ 🧭NAVIGATE │   72%  │   60%  │  67%   │     │
       │    │ ✅VALIDATE │   38%  │   45%  │  41%   │     │
       │    ├────────────┼────────┼────────┼────────┤     │
       │    │ COMBINED   │   58%  │   52%  │  56%   │     │
       │    └────────────┴────────┴────────┴────────┘     │
       │                                                 │
       │    🏆 Top 3 Quick Wins:                          │
       │    1. +12% → Add SECURITY.md (low effort)        │
       │    2. +10% → Enable coverage reporting (med)      │
       │    3. +8%  → Add pre-commit hooks (med)          │
       │                                                 │
       ╰─────────────────────────────────────────────────────╯
       
       Explanation of Hybrid Scoring:
       "Static checks asked: Does the FILE exist? (60% weight)
        LLM checks asked: Is the CONTENT good? (40% weight)
        Together they tell the full story."
       
       🎤  "You might have a CI file (static ✓) but it doesn't
        actually test anything meaningful (LLM ✗). Or you have
        beautiful docs (LLM ✓) but no CLAUDE.md (static ✗).
        You need BOTH."

01:35  📊  RADAR CHART REVEAL (3 min)
       
       Command:
       python scripts/scan_static.py /path/to/your/repo --all --visualize
       
       Opens browser (or generates HTML):
       
       → Interactive radar chart with 3 axes
       → Hover shows details per axis
       → Color-coded: red (<50), yellow (50-80), green (>80)
       → Can download as PNG for sharing
       
       ⚡ MAGIC MOMENT #3: Visual proof of progress
       "This is something you can put in your engineering blog,
        show your manager, or share with your team."
       
01:38  📊  Comparison Mode (2 min)
       
       "Want to see how far you came? Compare with the start:"
       
       python scripts/scan_static.py /path/to/repo \
         --compare .agent-ready/snapshot-initial.json
       
       Shows delta table:
       │ Axis       │ Before │ After  │ Delta  │
       │------------|--------|--------|--------│
       │ 📝INSTRUCT │   35%  │   59%  │  +24%  │
       │ 🧭NAVIGATE │   52%  │   67%  │  +15%  │
       │ ✅VALIDATE │   28%  │   41%  │  +13%  │
```

**Deliverables**:
- `scan_static.py` with `--all`, `--hybrid`, `--visualize`, `--compare` flags
- `templates/radar.html` — Chart.js radar chart
- `.github/workflows/agent-ready-ci.yml` template
- Snapshot system for comparison

---

### PHASE 5: Fix Sprint & Wrap [01:40–02:00] (20 min) — Slides 31–35

```
01:40  🎤  The Fix Concept — Auto-Fix Skills (3 min)
       
       "So far we've been fixing things MANUALLY.
        But here's where it gets interesting..."
       
       Introduce the agent-ready-fix concept:
       "An AI agent that can not only ASSESS your codebase
        but also FIX the gaps it finds — guided by
        the same scoring system."
       
       Demo (pre-recorded or live if brave):
       agent-ready-fix --target security-policy
       → Generates SECURITY.md tailored to project
       
       agent-ready-fix --target ci-config
       → Generates .github/workflows/ci.yml
       
       KEY POINT: The fix skill uses the SAME criteria as the scan.
       Scan measures → Fix improves → Scan again validates.

01:43  💻  HANDS-ON: One Automated Fix (7 min)
       
       Participants pick ONE auto-fix target:
       A) Generate SECURITY.md from template
       B) Generate CONTRIBUTING.md from analysis
       C) Suggest test coverage gaps
       
       Run the fix skill (or manual script version for workshop):
       python scripts/apply_fix.py security-policy /path/to/repo
       
       Review the generated file → accept/edit/discuss

01:50  🎁  Final Report Generation (5 min)
       
       Command:
       python scripts/scan_static.py /path/to/repo --full-report \
         --output ./agent-ready-report/
       
       Generates:
       ├── report.txt          (terminal-friendly summary)
       ├── report.json         (machine-readable, CI-compatible)
       ├── radar.html          (interactive visualization)
       ├── recommendations.md  (prioritized todo list)
       └── badge.svg           (maturity level badge for README)
       
       Badge example:
       ┌─────────────────────────────┐
       │  Agent Ready: Level 2 🟡   │
       │  Instruct 59% | Navigate 67% │
       │  Validate 41%              │
       └─────────────────────────────┘
       
       "Put this badge in your README. Signal to the world
        — and to future AI agents — that you care about
        agent readiness."

01:55  🎤  Closing — The Road Ahead (3 min)
       
       Recap the journey:
       "Two hours ago you didn't know how agent-ready your codebase was.
        Now you have:
        ✅ A numerical assessment (3 axes, 0-100)
        ✅ A maturity level (Foundational → Autonomous)
        ✅ Concrete improvements you made TODAY
        ✅ A visual report to share
        ✅ A toolkit to re-scan anytime"
       
       What's next (post-workshop / Set B):
       - Full 39-check engine (porting Kodus)
       - CI gate integration (--ci --min-level 3)
       - History tracking and trend charts
       - Team comparison dashboards
       - GitHub App for automatic scanning
       
       Call to action:
       "Star the repo. Try it on another project.
        Tell us what broke. This is v0 — we need you."

01:58  ⚡  Final Magic Moment (1 min)
       
       Room poll: "Show of hands — who improved their score
        by at least 15 points today?"
       
       (Most hands go up 🙌)
       
       "That's 15 points closer to having agents that
        HELP you instead of HURTING you."
       
02:00  🎉  END
```

**Deliverables**:
- `scripts/apply_fix.py` — workshop version of the auto-fix
- Multi-format report generator
- Badge SVG generator
- `templates/badge.svg` template

---

## Complete Workshop Deliverables

### To Build (Code)

| File | Lines | Priority | Dependencies |
|------|-------|----------|------------|
| `scripts/scan_static.py` | ~250 | **Must** | `rich`, `pyyaml`, stdlib |
| `scripts/apply_fix.py` | ~120 | High | Jinja2 (template rendering) |
| `scripts/report_gen.py` | ~80 | Medium | stdlib |
| `scripts/badge_gen.py` | ~40 | Low | svgwrite or string template |
| `templates/radar.html` | ~180 | **Must** | Chart.js CDN |
| `templates/radar-dark.html` | ~180 | Nice | Chart.js CDN |
| `templates/claude-md-template.md` | ~40 | **Must** | none |
| `templates/ci-template.yml` | ~30 | **Must** | none |
| `templates/security-md-template.md` | ~25 | Medium | none |
| `templates/contributing-md-template.md` | ~30 | Medium | none |
| `repos/demo-bad/` | ~15 files | **Must** | none |
| `repos/demo-good/` | ~15 files | **Must** | none |

### Estimated Totals
- **~990 lines of code/templates**
- **~12-16 hours** of effective work
- **4 dependencies**: `rich`, `pyyaml`, `jinja2`, `tomllib` (stdlib from 3.11)

---

## Incremental Flow (Branch Strategy)

For the `RisorseArtificiali/agent-ready-skill` repo:

```
main                          (stato attuale — skills complete)
  │
  ├─ workshop/phase0-setup    (check_setup.py + requirements.txt)
  │
  ├─ workshop/phase1-instruct (scan_static.py --axis instruct)
  │                            + templates/claude-md-template.md
  │
  ├─ workshop/phase2-navigate (scan_static.py --axis navigate)
  │                            + templates/.editorconfig, .env.example
  │
  ├─ workshop/phase3-validate (scan_static.py --axis validate)
  │                            + templates/ci-template.yml
  │                            + hybrid scoring logic
  │
  ├─ workshop/phase4-visual   (radar.html + report_gen.py)
  │
  └─ workshop/phase5-final   (apply_fix.py + badge_gen.py)
                               + demo-bad/ + demo-good/
                               + WORKSHOP.md (istruzioni complete)
```

Participants either clone and checkout each branch step by step,
or work on `main` with everything available and unlock phase by phase
via the `--axis` flag.

**Recommendation**: Second approach (single `main` + flags) —
fewer git mistakes during a live workshop.

---

## Risk Register

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Participant has no repo | High | Medium | Demo repo as fallback |
| Slow `pip install` | Medium | Low | Pre-event instructions |
| LLM API key fails | Medium | High | Hybrid mode: static-only fallback (show static score only) |
| Time runs out, Phase 5 cut short | Medium | Medium | Phase 5 compressible to 10 min |
| Someone already at 95% | Low | Low | Challenge: "reach Level 5 Autonomous" |
| Too many questions | Medium | Low | "Parking lot" — answer at end |
| Radar chart fails to render in browser | Medium | Medium | Fallback: ASCII radar in terminal |

---

## Success Metrics (post-workshop)

| Metric | Target |
|--------|--------|
| % participants improving score by ≥15pt | >80% |
| % participants cloning the repo | >60% |
| GitHub stars within 24h post-workshop | >50 |
| Issues/PRs received in following week | >10 |
| PyCon feedback rating (1–5) | >4.2 |
