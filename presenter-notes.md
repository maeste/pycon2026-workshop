# Presenter Notes — Printable Backup (v2)

**Workshop:** Measuring AI-Readiness: A Three-Axis Maturity Model for Agent-Optimized Codebases
**Event:** PyCon Italia 2026 — Friday, May 29, 2026, 11:00–13:00
**Speaker:** Stefano Maestri (`@maeste`)
**Skills repo:** https://github.com/RisorseArtificiali/agent-ready-skill
**Guinea pig:** https://github.com/maeste/quicknote-demo
**Deck:** 36 slides · press `N` for inline per-slide speaker notes · `←/→` navigate

> The per-slide script lives in the deck (`N`). This file is the model + phase
> cue cards + the day-of checklist + backup plans. The minute-by-minute runbook
> is `08-storyboard-v2.md`.

---

## The model (memorize) — agent-ready v2

| Axis | Wt | Question | Dimensions |
|------|----|----------|------------|
| 📝 INSTRUCT | 28 | Understand WHAT? | D1 Agent Instructions & Context (18) + D7 Spec-Driven Workflow & Docs (10) |
| 🧭 NAVIGATE | 30 | Find WHERE + tools? | D2 Navigability & Code Intelligence (18) + D5 Agent Tooling & Capabilities (12) |
| ✅ VALIDATE | 30 | Did it RIGHT? | D3 Testing & Feedback (16) + D4 CI/CD, Automation & Governance (14) |
| 🛡️ SECURE | 12 | Run SAFELY? | D6 Security & Sandbox (12) |

**Maturity:** L1 ≥40 · L2 ≥55 · L3 ≥70 · L4 ≥85 · L5 ≥95.
**Layers:** portable (any agent) vs target (only with `--agents claude,codex,opencode,pi`).

### Three things to land that are new in v2
1. **AGENTS.md is the primary file** (cross-vendor standard). CLAUDE.md = `ln -s AGENTS.md CLAUDE.md`. v2 **penalizes instruction bloat**.
2. **SECURE is the fourth axis** — the reveal. Pitched three; security forced a fourth.
3. **The agent assesses *and fixes* itself** — and v2 reports **explained findings** (why/consequence/fix/effort). That's the line against Kodus/Factory.ai.

### The reveal (slide 14)
"When I submitted this talk it was three axes — that's the title. Then I built v2,
and one question kept surfacing that INSTRUCT, NAVIGATE and VALIDATE didn't answer:
*can the agent run safely?* An agent can understand, navigate and validate perfectly
and still leak a secret or follow a prompt injection. So the model grew a fourth axis."

---

## Scan-posture rule (read once, repeat to yourself)

All hands-on scans are **portable (bare `/agent-ready scan .`)** so the Phase-6
`diff` is apples-to-apples — `diff` always re-scans portable and takes no `--agents`.
`--agents claude` appears in exactly three places: the **P1 reveal**, the **P5 fix**
(to surface the target permission policy), and the **P6 finale** scan of `step-5-complete`.
**Save the baseline in P1.** Catch-up needs `git stash -u` / `git checkout -f` (untracked files).

## Phase cue cards

**P0 · Setup & Install (10m, slides 1–5)**
Poll (Python in prod / used an agent / been burned). Install 6 skills → `~/.claude/skills/`
(Method A copy is the safe fallback). `git clone quicknote-demo && git checkout step-0-bare`.
Verify `/agent-ready scan .`. Catch-up later: **`git stash -u`** or **`git checkout -f step-N`**
(plain `stash`/`checkout -- .` won't move the untracked files people create).

**P1 · Model + First Scan + Layers (15m, slides 6–17)**
Failure stories → three axes (footnote teases the 4th). Deep-dives 11/12/13.
⚡ **Slide 14 SECURE reveal** — slow down, let it land. Maturity (15). Scoring + **Portable vs Target** (16).
Two test subjects (17). Live scan guinea pig (~10) → **save baseline**:
`cp .agent-ready/agent-ready-scores.json .agent-ready/baseline.json`. Then once
`--agents claude` to light the target layer (then back to portable). Then "scan your own repo."

**P2 · INSTRUCT (20m, slides 18–21)**
Ask Claude to draft a concise AGENTS.md (<200 lines) → review → save → `ln -s AGENTS.md CLAUDE.md`.
Re-scan **bare**, watch INSTRUCT jump. Hammer **concise beats bloated**. Do it on their repo.
Catch-up: `git checkout step-1-instruct`.
→ *Branch adds AGENTS.md + CLAUDE.md symlink (D1), README/CONTRIBUTING (D2 readme), specs/ + ADR + issue&PR templates + CHANGELOG (D7). Live = D1 headline only; branch = full INSTRUCT. **Mindset:** the agent now knows WHAT & HOW before touching code.*

**P3 · NAVIGATE (18m, slides 22–24)**
`/agent-ready fix navigability_code_intelligence` (+ `agent_tooling_capabilities`) → agent writes
ARCHITECTURE/repo map, `.mcp.json` (Serena), `scripts/`. **Scope it** — bare `fix` closes every axis at once.
Disambiguation: code *supports* nav (D2) vs tooling *wired up* (D5). Re-scan **bare**.
Catch-up: `git checkout step-2-navigate`.
→ *Branch adds ARCHITECTURE.md + type hints + .editorconfig (D2), .mcp.json/Serena + scripts/ (D5). **Mindset:** the agent can now FIND its way — map + typed code + MCP wired, no more grepping.*

**P4 · VALIDATE (18m, slides 25–28)**
Ask Claude for CI (ruff+mypy+pytest) and tests with descriptive assertions.
"Feedback quality is the lever — tests are the agent's only signal." Re-scan **bare**.
Governance not covered by the two prompts → mention `/agent-ready fix cicd_automation_governance`.
Catch-up: `git checkout step-3-validate`.
→ *Branch adds tests/ + pyproject tooling (D3), ci.yml + pre-commit + Dependabot + CODEOWNERS (D4). **Mindset:** the agent can now VERIFY — tests are its feedback loop, CI gates regressions.*

**P5 · SECURE (18m, slides 29–30)**
`/agent-ready fix security_sandbox --agents claude` → `docs/agent-execution.md` (LINCE among options),
`.env.example`, `.gitignore` secrets, lockfile (+ `--agents` *surfaces* the target permission policy, manual).
Re-scan **bare** (5/6 SECURE sub-criteria are portable). ⚡⚡⚡ **Slide 30** narrates the full 4-axis +
Portable/Target view. Catch-up: `git checkout step-4-secure`.
→ *Branch adds docs/agent-execution.md + devcontainer (isolation), .env.example + .gitignore secrets, requirements.txt lockfile, SECURITY.md (D6). **Mindset:** the agent can now run SAFELY — sandbox contains it, no secrets to leak, deps pinned. Credit is earned by DOCUMENTING posture (runtime sandbox is invisible to a scan).*

**P6 · Wrap (20m, slides 31–36)**
Radar/playground (4 axes). 🎯 **Journey diff vs baseline**: `/agent-ready diff .agent-ready/baseline.json`
(bare `diff` compares only against the last scan → ~0, so pass the path!). `report --format html` → `.agent-ready/`.
`git checkout step-5-complete` → `/agent-ready scan . --agents claude` → ~85, "Optimized" (finale uses `--agents`).
Take-home: skills global, `/agent-ready init` (empty dir) for greenfield, AGENTS.md is cross-vendor.
Greenfield slide (35). Closing poll: "≥15 points gained?"
→ *step-5-complete adds .claude/skills/changelog-entry (D5 standard_skills) + .claude/settings.json deny rules (D6 permission policy, target) + AGENTS.md fast-feedback note (D3). **Mindset:** last mile — the project ships agent tooling AND constrains the agent. L4 Optimized.*

---

## Day-of checklist (run once before the talk)

- [ ] Guinea pig cloned; `git branch -r` shows step-0-bare … step-5-complete
- [ ] 6 skills resolve: type `/agent-ready` in Claude Code and see it listed
- [ ] `git checkout step-0-bare` → `/agent-ready scan .` runs clean; `cp …/agent-ready-scores.json …/baseline.json` works
- [ ] `git checkout step-1-instruct` then bare `/agent-ready scan .` runs clean
- [ ] `/agent-ready fix navigability_code_intelligence` on `step-2-navigate` offers to generate files (scoped)
- [ ] `/agent-ready fix security_sandbox --agents claude` works (surfaces the permission policy)
- [ ] `/agent-ready diff .agent-ready/baseline.json` shows the baseline→current delta (not ~0)
- [ ] `git checkout step-5-complete` + `/agent-ready scan . --agents claude` shows ~85
- [ ] Catch-up tested: with untracked files present, `git stash -u` / `git checkout -f step-N` unblocks checkout
- [ ] `playground.html` opens, shows 4 axes + radar
- [ ] Deck opens, `N` toggles notes, `←/→` works; slide 14 is the SECURE reveal
- [ ] Tested a scan on a SECOND real repo (skills work on external paths)
- [ ] Windows attendees know the symlink copy-fallback: `copy AGENTS.md CLAUDE.md`

---

## Backup plans

**(a) Claude Code / skills don't work** — use the mocked terminal output already in the
deck (slides 16, 19, 21, 30). Frame as "here's what it looks like" and pair people up.

**(b) Scan variance** — feature, not bug: "the agent reads like a new teammate — slightly
different each time, which is why strong signals matter." Branches are the known-good states.

**(c) No network / CDN blocked** — deck fonts fall back to system; the slide radar is a hand-drawn
canvas (no Chart.js). Guinea pig is already cloned. Playground radar needs Chart.js CDN; the
fallback bars render without it.

**(d) Running long** — Phase 5 compresses to 10 min (just `fix security_sandbox` + one re-scan);
Phase 6 can drop the report/diff demo and jump to step-5-complete + take-home.

**(e) Laptop dies** — this file + a whiteboard: draw the 4 axes, tell the SECURE reveal, walk the
maturity ladder. The story stands without the screen.
