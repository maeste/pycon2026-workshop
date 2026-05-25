# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

This is the **planning and authoring workspace** for a PyCon Italia 2026 workshop:

- **Talk**: "Measuring AI-Readiness: A Three-Axis Maturity Model for Agent-Optimized Codebases"
- **When**: Friday May 29 2026, 11:00–13:00 (2 hours, hands-on)
- **Speaker**: Stefano Maestri (`@maeste`)
- **Target workshop repo** (where built deliverables ship): https://github.com/RisorseArtificiali/agent-ready-skill

It is **not** a software project. It contains design docs and HTML artifacts — no Python source, no tests, no build system. Don't run `pip install`, `pytest`, or lint commands here; there's nothing to install or test.

## Repository layout

The numbered Markdown files are sequential brainstorming phases — read them in order if you need full context:

| File | Phase | Purpose |
|------|-------|---------|
| `00-brainstorming-plan.md` | 0 | Goals, open questions, phase plan |
| `01-repo-assessment.md` | 1 | Fit/gap of source `agent-ready-skill` repo vs. workshop format |
| `02-competitive-analysis.md` | 2 | Factory.ai, Kodus, ACMM, agent-next comparison |
| `03-kodus-deep-analysis.md` | 2b | Deep dive on Kodus internals (what to port) |
| `04-workshop-storyboard.md` | 3 | Minute-by-minute 120-min runbook |
| `05-implementation-plan.md` | 4 | Full code skeleton for `scan_static.py` (the main scanner) |
| `06-implementation-plan-rest.md` | 4b | Specs for remaining scripts + templates + WORKSHOP.md |
| `07-slides-outline.md` | 5 | 35-slide deck structure + design system |
| `presentation/slides.html` | — | Working slide deck (standalone, CDN fonts only) |
| `presentation/playground.html` | — | Interactive 3-axis playground (standalone) |

The files under `presentation/` are **self-contained, zero-build** HTML pages: inline CSS + JS, fonts/libs from CDN. Open them directly in a browser. (The directory was historically called `templates/`; renamed for clarity — these are finished artifacts, not stubs.)

## The Three-Axis Model (workshop's core concept)

The 8 dimensions of the source `agent-ready-skill` repo are remapped to three axes for the workshop. This grouping is load-bearing — keep it consistent across slides, scripts, and storyboard:

| Axis | Weight | Question it answers |
|------|--------|---------------------|
| 📝 **INSTRUCT** | 38% | "Does the agent understand WHAT we want?" (CLAUDE.md, specs, docs) |
| 🧭 **NAVIGATE** | 34% | "Can the agent find its way around?" (structure, tooling, skills) |
| ✅ **VALIDATE** | 28% | "Can the agent tell if it did it right?" (tests, CI, quality gates) |

Maturity ladder: **L1 Foundational (≥40)** → **L2 Guided (≥55)** → **L3 Structured (≥70)** → **L4 Optimized (≥85)** → **L5 Autonomous (≥95)**.

## Working on this repo

- **Most edits are document edits.** Phase files build on each other — when changing a number/threshold/concept in one, search the others (`grep -rn "INSTRUCT" .`) and keep them in sync.
- **Presentation files have no build step.** Open `presentation/slides.html` or `presentation/playground.html` directly in a browser to preview. Edits go in-file (single-file architecture is intentional).
- **Design system**: dark theme, `#0a0a14` bg, Inter + JetBrains Mono, see `07-slides-outline.md` for the full palette.
- **Mixed Italian/English** in planning docs is intentional — preserve it unless explicitly asked to translate.
- **Code skeletons in `05-` and `06-` are specs, not source.** Treat them as the contract for what to build in the `agent-ready-skill` repo. Don't materialize `scripts/scan_static.py` etc. here unless the user explicitly asks.
- **Don't invent commands or claim things were built/tested.** There's no test suite or scanner in this directory.

## When the user asks to "build" or "run" something

The implementation deliverables (`scan_static.py`, `apply_fix.py`, `report_gen.py`, demo repos, `WORKSHOP.md`) target the **`agent-ready-skill`** repository, not this one. Confirm where the work should land before creating Python files here — usually the answer is "in the other repo" or "as a copy-pasteable block inside the planning doc."
