# Presenter Notes — Printable Backup

**Workshop:** Measuring AI-Readiness: A Three-Axis Maturity Model for Agent-Optimized Codebases
**Event:** PyCon Italia 2026 — Friday, May 29, 2026, 11:00–13:00
**Speaker:** Stefano Maestri (`@maeste`)
**Repo:** https://github.com/RisorseArtificiali/agent-ready-skill
**Total duration:** 120 min | **Slide count:** 35 | **Language:** English

---

## The 3-Axis Model (memorize)

| Axis | Weight | Question | Sub-dimensions |
|------|--------|----------|----------------|
| INSTRUCT | 38% | "Does the agent understand WHAT we want?" | Agent Instructions (20) + Spec-Driven Workflow (10) + Claude-Specific (8) |
| NAVIGATE | 34% | "Can the agent find its way around?" | Project Navigability (18) + Documentation & Comprehension (8) + Skills & Tooling (8) |
| VALIDATE | 28% | "Can the agent tell if it did it right?" | Testing & Validation (16) + CI/CD & Automation (12) |

**Maturity ladder:** L1 Foundational ≥40 → L2 Guided ≥55 → L3 Structured ≥70 → L4 Optimized ≥85 → L5 Autonomous ≥95

**Demo flow:** scan chaos-monkey repo → fix gap → diff before/after.

**Deck shortcut:** press `N` to toggle speaker notes inline, or append `?notes` to the URL.

---

## Slide-by-Slide Script

### Slide 1 — Title (1 min)
- **Cue:** Welcome, big breath, scan the room.
- Hi, I'm Stefano. PyCon Italia 2026. Two hours hands-on.
- "Measuring AI-Readiness — Three-Axis Maturity Model."
- Promise: you leave with a number, a model, and a toolkit.

### Slide 2 — About Me (2 min)
- Software architect, working with agents since "before it was cool."
- Creator of `agent-ready-skill` — the toolkit we use today.
- One belief: agents are only as good as your codebase's readiness.

### Slide 3 — Agenda (2 min)
- 5 phases, 3 magic moments.
- Phase 1: model + demo. Phases 2–4: hands-on per axis. Phase 5: wrap.
- Mention the "magic moments" so they listen for the wow.

### Slide 4 — The Promise (2 min)
- Three deliverables: A Number, A Mental Model, A Toolkit.
- "Not theory. Not hype. Your repo. Your score. Your improvements."

### Slide 5 — Icebreaker Poll (3 min)
- Hands up: Python in production? AI agent used? Got burned by one?
- Confirm setup: clone guinea pig repo, verify Claude Code works.
- Fallback: `git checkout step-1-scan` if someone missed setup.

### Slide 6 — "Worked in My Prompt" (1 min)
- The new "works on my machine."
- We blame model temperature instead of dependency versions.

### Slide 7 — Horror Story (2 min)
- Tell the real story: Claude Code adding validation in the wrong dir, Flask patterns on FastAPI, lost Pydantic schemas.
- Land the punchline: the agent wasn't dumb, it was uninformed.

### Slide 8 — Why Agents Fail (1 min)
- Three failure modes → three axes. This is the foreshadowing slide.
- Doesn't understand → INSTRUCT. Can't navigate → NAVIGATE. Can't validate → VALIDATE.

### Slide 9 — Not the Agent's Fault (1 min)
- Reframe: agent = senior dev on day one.
- We'd never expect a human to be productive without a README, conventions, tests.

### Slide 10 — Three Questions Triangle (1 min)
- Show the triangle. WHAT, WHERE, RIGHT.
- Triangle is clickable — each vertex jumps to its axis deep-dive.

### Slide 11 — Axis 1: INSTRUCT 38% (1 min)
- Agent Instructions 20 (CLAUDE.md, .cursorrules).
- Spec-Driven Workflow 10 (ARCHITECTURE.md, ADRs).
- Claude-Specific 8 (hooks, sub-agents, slash commands, MCP).
- If you have nothing else, write CLAUDE.md — biggest lever.

### Slide 12 — Axis 2: NAVIGATE 34% (1 min)
- Project Navigability 18 (structure, naming, file size).
- Documentation & Comprehension 8 (README, CONTRIBUTING).
- Skills & Tooling 8 (linter, formatter, type checker, .env.example, Docker).
- This axis helps humans too — no AI-vs-human tradeoff.

### Slide 13 — Axis 3: VALIDATE 28% (1 min)
- Testing & Validation 16 (pytest, coverage).
- CI/CD & Automation 12 (workflow, gates, SECURITY.md, pre-commit).
- Smallest by weight, biggest by impact — most repos bleed points here.

### Slide 14 — Maturity Levels (1 min)
- Five levels at 40/55/70/85/95. Sequential — no skipping.
- Most wild repos are L1 or L2. Workshop goal: get to L2 or L3 by 13:00.

### Slide 15 — How Scoring Works (1 min)
- Step 1: agent scans 8 dimensions. Step 2: weighted rubric scoring. Step 3: overall + level gate.
- Key differentiator: the agent itself assesses — not a static script like Kodus or Factory.ai.

### Slide 16 — Meet the Test Subjects (2 min)
- Chaos Monkey: no CLAUDE.md, no linter, no tests, 400-line files.
- Agent Heaven: full CLAUDE.md, ruff+black+pyright, 12 tests, CI.
- Same language. Same complexity. Different readiness.

### Slide 17 — Magic Moment #1: Same Tool (3 min) ⚡
- 23% vs 81%. Level 1 vs Level 4.
- "The difference isn't the agent. It's the codebase."
- This is the thesis of the workshop. Pause, let it land.

### Slide 18 — PHASE 2 Divider: INSTRUCT (1 min)
- Mode shift: teacher → hands-on. Next 25 min is mostly you typing.
- 00:25–00:50 budget.

### Slide 19 — Scan Your Repo Axis 1 (9 min)
- `git checkout step-1-scan` then `/agent-ready scan .`
- Read the score. Surprise/disappointment is normal.
- Also try on THEIR repo: `/agent-ready scan ~/their-project`

### Slide 20 — The Quickest Win CLAUDE.md (7 min)
- Ask Claude: "Read this project and write me a CLAUDE.md"
- Claude generates it in 30 seconds. Review, tweak, save.
- 80% in thirty seconds beats 100% in two weeks.

### Slide 21 — Magic Moment #2: Before/After (8 min) ⚡
- Re-scan. Watch the number jump (+20 to +30).
- "That's it? One file?" Yes. That's the whole pitch.

### Slide 22 — PHASE 3 Divider: NAVIGATE (1 min)
- 20 min on NAVIGATE. Same loop: scan → fix → re-scan.

### Slide 23 — Scan Your Repo Axis 2 (8 min)
- `git checkout step-3-fix-ready` then `/agent-ready scan .` — focus on NAVIGATE.
- Explain: no .editorconfig → tabs/spaces chaos. No .env.example → guessed env vars.

### Slide 24 — /agent-ready fix (10 min)
- Run `/agent-ready fix`. The agent identifies gaps and generates files.
- THIS IS THE MAGIC MOMENT. The agent creates contextualized files, not boilerplate.
- Re-scan to confirm improvement.

### Slide 25 — PHASE 4 Divider: VALIDATE (1 min)
- Biggest phase (30 min). Where most repos bleed and where the magic moment lives.

### Slide 26 — Scan Your Repo Axis 3 (5 min)
- `/agent-ready scan .` — focus on VALIDATE dimensions in the output.
- Most repos test the code but the codebase doesn't test itself — no CI, no coverage.

### Slide 27 — The Testing Paradox (3 min)
- Controversial: tests aren't for finding bugs, they're for giving agents a safety net.
- Without tests = you bottleneck every PR. With tests = agent self-validates, you scale.

### Slide 28 — CI Template Hands-On (9 min)
- Ask Claude: "Create a GitHub Actions CI workflow for this project."
- Also: "Write pytest tests for the storage module."
- Minimal real CI > sophisticated nonexistent CI.

### Slide 29 — Magic Moment #3: Full Scan (7 min) ⚡⚡⚡
- `/agent-ready scan .` — the complete picture across all 8 dimensions.
- Why agent-powered beats static: checks BOTH file presence AND content quality.
- Example: CI file present but tests nothing meaningful. Agent catches it.

### Slide 30 — Your Agent Readiness Radar (5 min)
- Open playground.html in browser. Enter your scores, see the radar chart.
- Three axes, your shape tells your story. Take a screenshot.
- This is the artifact you came here for — engineering blog material.

### Slide 31 — The Agent Fixes What The Agent Needs (4 min)
- `/agent-ready fix` — the agent reads YOUR code and generates contextual files.
- Not boilerplate. Contextualized to your project's framework, structure, conventions.
- This is what static tools CAN'T do. Scan → Fix → Scan again.

### Slide 32 — Report + Diff (7 min)
- `/agent-ready report` generates comprehensive assessment document.
- `/agent-ready diff` compares current vs previous scan — shows the journey.
- `git checkout step-4-validate` for anyone who needs to catch up.

### Slide 33 — What You Take Home (3 min)
- Mental model + a number + a toolkit. Same as the promise on slide 4.
- Reinforces the contract.

### Slide 34 — Road Ahead (3 min)
- Public roadmap: 39-check engine, CI gate, history, dashboards, GitHub App.
- Call to action: star, file issues, send PRs.

### Slide 35 — Thank You / Q&A (3 min)
- Show of hands: who improved by ≥15 points? (Most hands go up.)
- "Star the repo. Try it on another project. Tell us what broke. This is v0."
- Hallway track for deep questions.

---

## Demo-Flow Checklist (do this once before the talk)

- [ ] Guinea pig repo cloned and all branches exist (`git branch -a` shows step-0 through step-5)
- [ ] `git checkout step-1-scan` → Claude Code sees skills in `.claude/skills/`
- [ ] `/agent-ready scan .` runs successfully from step-1-scan branch
- [ ] `/agent-ready fix` runs successfully from step-3-fix-ready branch
- [ ] `/agent-ready diff` runs successfully from step-4-validate branch
- [ ] `/agent-ready report` runs successfully from step-4-validate branch
- [ ] `git checkout step-5-complete` + `/agent-ready scan .` shows ~85/100
- [ ] `playground.html` opens in browser and shows interactive 3-axis model
- [ ] Slide deck opens in browser, `N` toggles notes, `←/→` navigates
- [ ] Tested on a SECOND real repo to verify skills work on external paths

---

## Backup Plans

### (a) If Claude Code / skills don't work
- Switch to the pre-recorded terminal output already mocked in slides 19, 23, 26, 29.
- Frame it as "here's what it looks like when it works" and continue narrative.
- Pair struggling participants with neighbors whose setup works.

### (b) If scans give unexpected results
- This is a feature. Discuss: "The agent interprets differently each time — like a new team member."
- Use `git checkout step-N` branches as the authoritative "known state."
- Fallback: walk through scoring on paper using the slide rubric and playground.html.

### (c) If network is unstable (no GitHub, no CDN)
- Slides use Google Fonts from CDN — fall back gracefully to system fonts (Inter → -apple-system → sans-serif). Deck still renders.
- Chart.js is loaded only on the radar slide; if it fails, the SVG triangle and progress bars still tell the story.
- Demo repos are in the workshop materials clone — no internet needed once cloned.
- Have the deck pre-loaded in a local browser tab.

### (d) If timing slips (running long)
- Phase 5 is compressible: cut Slide 31 (Auto-Fix Demo) and Slide 34 (Road Ahead) — saves 7 minutes.
- Phase 3 alternate cut: skip Pick-ONE-Fix typing time, walk through option A as a demo (saves 5 minutes).
- Phase 4: if Magic Moment #3 fails, jump straight to Slide 30 (Radar Reveal) with mocked data.

### (e) If the laptop dies completely
- This document. Print it. Hold it. Walk participants through the model verbally using the three-axis sketch on a whiteboard if available.
- Direct everyone to `github.com/RisorseArtificiali/agent-ready-skill` on their phones — the README contains the same essentials.
