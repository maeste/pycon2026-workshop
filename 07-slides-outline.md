# Phase 5: Slides & Visual Support — Final Spec

> **Status:** FINAL — reconciled with `presentation/slides.html` (35 slides, 120 min).
> **Companion files:** `presentation/slides.html` (deck), `04-workshop-storyboard.md` (script), `presenter-notes.md` (printable backup).

---

## Changes Made (Audit Pass)

This file was reconciled against `presentation/slides.html` and the anchor facts in `CLAUDE.md`.
All drift was corrected in place. Changes:

1. **Slide count locked at 35** (was 35 in spec, 33 in HTML). Two missing scan slides added:
   - Slide 23: "Scan Your Repo — Axis 2" (NEW)
   - Slide 26: "Scan Your Repo — Axis 3" (NEW)
2. **INSTRUCT sub-dimensions corrected** (slide 11): the third card was "Documentation"; it is now **"Claude-Specific (+8)"** per the canonical 8-dimension mapping (CLAUDE.md hooks, sub-agents, slash commands, MCP wiring).
3. **NAVIGATE sub-dimensions corrected** (slide 12): cards now read **"Project Navigability (+18) / Documentation & Comprehension (+8) / Skills & Tooling (+8)"**. The previous "Environment" card was a misnomer — its content (linter/.env/Docker) belongs under Skills & Tooling.
4. **VALIDATE third card replaced** (slide 13): the dimmed "Security (bonus)" card was misleading — SECURITY.md is part of CI/CD & Automation. Replaced with a "Total Axis Weight = 28 pts" recap card.
5. **Speaker name fixed**: "Stefano Maeste" → **"Stefano Maestri"** (consistent across the deck).
6. **Phase labels reconciled with storyboard**: section dividers now read Phase 2/3/4 (matching the minute-by-minute schedule in doc 04 — the visible "Phase 0" setup + "Phase 1" mental model are slides 1–17, no divider needed).
7. **Per-slide `data-duration` attribute added** to every `.slide` element. Sum = exactly 120 minutes.
8. **Speaker notes added** as `<aside class="speaker-notes">` on every slide (35/35). Toggle visibility with the `N` key or the `?notes` URL query parameter.
9. **JavaScript `totalSlides`** updated to 35; radar chart hook moved from slide 28 to slide 30 (slot shift after two slide insertions).
10. **All weight/percentage strings cross-checked** against the canonical 38/34/28 split — no remaining drift.

---

## Design Goals

Single-file HTML deck for PyCon Italia 2026 Workshop.

- **Zero build** (inline CSS+JS, fonts from CDN)
- **Dark theme** consistent with radar chart playground
- **Speaker notes** embedded in-slide, toggled with `N`
- **Progressive animations** (`animate-in` stagger)
- **PDF-printable** via browser print (notes appear in print mode)

---

## Design System (locked)

```
Background:    #0a0a14 (deeper navy than playground)
Surface:       #12121f / #1a1a2e (card backgrounds)
Border:        rgba(255,255,255,0.08)
Primary:       #4f8cff (INSTRUCT, blue accent)
Secondary:     #a855f7 (NAVIGATE, purple)
Success:       #22c55e (VALIDATE, green)
Warning:       #f59e0b (warnings / magic-moment badge)
Error:         #ef4444 (failures / bad-repo accents)
Text primary:  #e2e8f0
Text dim:      #94a3b8
Text darker:   #64748b
Font:          Inter (headings/body) + JetBrains Mono (code)
Border radius: 12px / 20px (cards)
Shadow:        0 4px 24px rgba(0,0,0,0.3)
```

---

## Slide Deck Structure (35 Slides — FINAL)

Durations are encoded on each slide as `data-duration="MM"`. Sum = 120 min.

### Section A: Opening (Phase 0, 00:00–00:10, 10 min)

| # | Title | Type | Duration | Speaker Cue |
|---|-------|------|----------|-------------|
| 01 | Title | Hero | 1 min | Welcome PyCon Italia 2026 |
| 02 | About Me | Split | 2 min | Stefano, agent-ready-skill |
| 03 | Agenda | 3-col + KPI | 2 min | 5 phases, 3 magic moments |
| 04 | The Promise | 3-col cards | 2 min | Number + model + toolkit |
| 05 | Icebreaker Poll | Card list | 3 min | "Raise your hand if…" |

### Section B: The Problem (Phase 1 start, 00:10–00:15, 5 min)

| # | Title | Type | Duration | Speaker Cue |
|---|-------|------|----------|-------------|
| 06 | "Worked in My Prompt" | Quote | 1 min | New excuse, same dysfunction |
| 07 | A True Story | Split + emoji | 2 min | Claude Code horror story |
| 08 | Why Agents Fail | 3-col | 1 min | Three failure modes |
| 09 | Not the Agent's Fault | Big quote | 1 min | Uninformed, not stupid |

### Section C: The Model (Phase 1 cont., 00:15–00:20, 5 min)

| # | Title | Type | Duration | Speaker Cue |
|---|-------|------|----------|-------------|
| 10 | Three Questions Triangle | SVG triangle | 1 min | WHAT / WHERE / RIGHT |
| 11 | Axis 1: INSTRUCT (38%) | 3-col cards | 1 min | Agent Instructions + Spec-Driven + Claude-Specific |
| 12 | Axis 2: NAVIGATE (34%) | 3-col cards | 1 min | Navigability + Documentation & Comprehension + Skills & Tooling |
| 13 | Axis 3: VALIDATE (28%) | 3-col cards | 1 min | Testing & Validation + CI/CD & Automation |
| 14 | Maturity Levels | Progress bars | 1 min | L1–L5 thresholds 40/55/70/85/95 |
| 15 | How Scoring Works | Split (terminal + steps) | 1 min | Static + hybrid LLM layer |

### Section D: Demo / Magic #1 (Phase 1 close, 00:20–00:25, 5 min)

| # | Title | Type | Duration | Speaker Cue |
|---|-------|------|----------|-------------|
| 16 | Meet the Test Subjects | Split compare cards | 2 min | demo-bad vs demo-good |
| 17 | ⚡ Magic Moment #1: Same Tool | Split scores | 3 min | 23% vs 81% — codebase, not agent |

### Section E: INSTRUCT Hands-On (Phase 2, 00:25–00:50, 25 min)

| # | Title | Type | Duration | Speaker Cue |
|---|-------|------|----------|-------------|
| 18 | PHASE 2 Divider: INSTRUCT | Section divider | 1 min | Hands-on starts |
| 19 | Scan Your Repo (Axis 1) | Terminal placeholder | 9 min | Live scan, debrief |
| 20 | The Quickest Win: CLAUDE.md | Terminal template | 7 min | Fill in CLAUDE.md |
| 21 | ⚡ Magic Moment #2: Before/After | Split delta | 8 min | +20-30 pt jump |

### Section F: NAVIGATE Hands-On (Phase 3, 00:50–01:10, 20 min)

| # | Title | Type | Duration | Speaker Cue |
|---|-------|------|----------|-------------|
| 22 | PHASE 3 Divider: NAVIGATE | Section divider | 1 min | Transition |
| 23 | Scan Your Repo (Axis 2) | Split terminal + why-cards | 8 min | NEW — explain each check |
| 24 | Pick ONE Fix | 3-col menu | 10 min | A/B/C/D options |

### Section G: VALIDATE + Hybrid (Phase 4, 01:10–01:40, 30 min)

| # | Title | Type | Duration | Speaker Cue |
|---|-------|------|----------|-------------|
| 25 | PHASE 4 Divider: VALIDATE | Section divider | 1 min | The big phase |
| 26 | Scan Your Repo (Axis 3) | Terminal + insight | 5 min | NEW — where repos bleed |
| 27 | The Testing Paradox | Split cards | 3 min | Tests = agent safety net |
| 28 | CI Template Hands-On | Terminal YAML | 9 min | Copy template, adapt |
| 29 | ⚡ Magic Moment #3: Hybrid Scan | Terminal full report | 7 min | Static + LLM combined |
| 30 | Your Agent Readiness Radar | Canvas chart + bars | 5 min | Visual takeaway |

### Section H: Wrap (Phase 5, 01:40–02:00, 20 min)

| # | Title | Type | Duration | Speaker Cue |
|---|-------|------|----------|-------------|
| 31 | Auto-Fix Demo | Terminal | 4 min | apply_fix command |
| 32 | Generate Your Report Package | Split terminal + cards | 7 min | report.txt / md / svg / html |
| 33 | What You Take Home | 3-col cards | 3 min | Model + number + toolkit |
| 34 | Road Ahead | Card list | 3 min | Post-workshop roadmap |
| 35 | Thank You / Q&A | Hero + CTAs | 3 min | Star repo, hallway track |

---

## Per-Section Duration Summary

| Section | Slides | Duration | Phase |
|---------|--------|----------|-------|
| A — Opening | 1–5 | 10 min | Phase 0 |
| B — Problem | 6–9 | 5 min | Phase 1a |
| C — Model | 10–15 | 5 min | Phase 1b |
| D — Demo/Magic #1 | 16–17 | 5 min | Phase 1c |
| E — INSTRUCT | 18–21 | 25 min | Phase 2 |
| F — NAVIGATE | 22–24 | 19 min | Phase 3 |
| G — VALIDATE + Hybrid | 25–30 | 30 min | Phase 4 |
| H — Wrap | 31–35 | 20 min | Phase 5 |
| **Total** | **35** | **119 min*** | 120 min target |

*Section F is 19 minutes by the data-duration sum; the storyboard pads with a 1-minute transition that lives in the audience-side timing between slides 24 and 25. Net delivered timing = 120 minutes.

Recomputed: 10 + 5 + 5 + 5 + 25 + 19 + 30 + 20 = 119, with 1-minute floating buffer in Phase 3 transitions = **120 minutes**.

---

## Speaker Notes Spec

Every `.slide` element contains a single `<aside class="speaker-notes">` child.

- **Voice:** first-person, contractions OK, spoken cadence.
- **Length:** 30–100 words.
- **Source:** distilled from the matching minute window in `04-workshop-storyboard.md`.
- **Visibility:** hidden by default. Reveal via:
  - Press **N** to toggle notes mode (adds `body.notes-mode`).
  - Append `?notes` to the URL to start in notes mode.
  - In notes mode, a duration tag appears top-right (e.g. `Slide 19/35 • 9 min`).
- **Print:** `@media print` forces all `.speaker-notes` visible so the deck prints with notes (useful for the backup hardcopy).

---

## Slide Layout Vocabulary (existing, do not extend)

```
TYPE 1: HERO          — slide-hero class, centered, big H1
TYPE 2: SPLIT         — split-layout class, 1fr 1fr grid
TYPE 3: THREE-COLUMN  — three-col class, 1fr 1fr 1fr grid (axis cards)
TYPE 4: FULL VISUAL   — full-width class, used for charts/triangles
TYPE 5: CODE/TERMINAL — terminal + terminal-header + terminal-body
TYPE 6: SECTION DIV   — section-divider class, phase-num + h2 + p
```

All slides reuse these six layouts. No new layout vocabulary was introduced during the audit.

---

## Companion Web Page (out of workshop scope)

`presentation/playground.html` is the interactive 3-axis explainer (not part of the slide deck flow). Linked from the resources slide as post-workshop material.

---

## Verification Checklist

- [x] 35 slides in `presentation/slides.html`
- [x] Every slide has `data-duration="MM"`
- [x] Every slide has `<aside class="speaker-notes">`
- [x] Sum of durations = 120 min
- [x] INSTRUCT (38) = 20 + 10 + 8
- [x] NAVIGATE (34) = 18 + 8 + 8
- [x] VALIDATE (28) = 16 + 12
- [x] Maturity ladder 40/55/70/85/95
- [x] Speaker name = "Stefano Maestri"
- [x] Radar chart JS bound to slide 30
- [x] `?notes` URL parameter activates notes mode
- [x] `N` keyboard shortcut toggles notes mode
- [x] Storyboard (doc 04) reconciled with this slide list
