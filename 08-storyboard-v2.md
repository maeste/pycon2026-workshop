# Workshop Storyboard v2 — Skills-First, Four-Axis (agent-ready v2)

> **Replaces** the v1 storyboard. Aligned to **agent-ready-skill v2**:
> 7 dimensions, 4 axes, AGENTS.md-first, Portable/Target layers, Security & Sandbox.
> **Workshop**: PyCon Italia 2026, Fri May 29, 11:00-13:00 (120 min).

## The model (v2)

| Axis | Wt | Question | Dimensions |
|------|----|----------|------------|
| 📝 INSTRUCT | 28 | Understand WHAT? | D1 Agent Instructions & Context (18) + D7 Spec-Driven Workflow & Docs (10) |
| 🧭 NAVIGATE | 30 | Find WHERE + tools? | D2 Navigability & Code Intelligence (18) + D5 Agent Tooling & Capabilities (12) |
| ✅ VALIDATE | 30 | Did it RIGHT? | D3 Testing & Feedback (16) + D4 CI/CD, Automation & Governance (14) |
| 🛡️ SECURE | 12 | Run SAFELY? | D6 Security & Sandbox (12) |

**Layers**: every sub-criterion is **portable** (any agent) or **target** (only with `--agents`).
**Levels**: L1 ≥40 · L2 ≥55 · L3 ≥70 · L4 ≥85 · L5 ≥95.

## The narrative spine

The talk was pitched as **three axes**. Building v2, security kept surfacing a
question none of the three answered — *can the agent run safely?* — so the model
grew a **fourth axis: SECURE**. The reveal (slide 14) turns the title/content
tension into the most memorable moment of the talk.

Other v2 shifts to land:
- **AGENTS.md**, not CLAUDE.md, is the primary file (cross-vendor). CLAUDE.md = a symlink bridge.
- **Evidence over folklore**: directory-depth/naming heuristics retired; instruction *bloat* penalized.
- **The agent assesses & fixes itself** — the differentiator vs static tools (Kodus/Factory.ai).

## Guinea pig: quicknote-demo (branches = pure project states; skills are global)

```
step-0-bare        bare CLI                                  ~10/100
step-1-instruct    AGENTS.md (+CLAUDE.md symlink), README, specs/, ADR, templates
step-2-navigate    ARCHITECTURE, .mcp.json (serena), scripts/, type hints
step-3-validate    tests, CI (lint+type+test), pre-commit, dependabot, CODEOWNERS
step-4-secure      docs/agent-execution.md, .env.example, .gitignore secrets, devcontainer, lockfile
step-5-complete    project skill, restrictive .claude/settings.json            ~85/100
```

---

## TIMELINE (120 min)

### PHASE 0 — Setup & Install (10 min) · slides 1–5
- Poll: used an AI agent? been burned by one?
- Install the 6 skills into `~/.claude/skills/` (Method A copy or B symlink).
- `git clone quicknote-demo && git checkout step-0-bare`.
- Verify: `/agent-ready scan .` returns a 4-axis score.

### PHASE 1 — The Model + First Scan + Layers (15 min) · slides 6–17
- Why agents fail → three failure modes → three axes (slide 10), with a footnote teasing a 4th.
- Deep-dives: INSTRUCT (11), NAVIGATE (12), VALIDATE (13).
- **⚡ Slide 14 — the SECURE reveal**: "I pitched three; security forced a fourth."
- Maturity ladder (15), scoring + **Portable vs Target** (16), two test subjects (17).
- 💻 First scan on the guinea pig (~10). Then `--agents claude` to show the target layer light up.
- 🔍 "Now your repo": `/agent-ready scan ~/your-project`.

### PHASE 2 — INSTRUCT (20 min) · slides 18–21
- 💻 Ask Claude: *"write a concise AGENTS.md (<200 lines)…"* → review → save.
- `ln -s AGENTS.md CLAUDE.md` (bridge, no drift).
- ⚡ Re-scan: INSTRUCT jumps. **Concise beats bloated** (v2 penalty).
- 🔍 Do it on your repo. Catch-up: `git checkout step-1-instruct`.

### PHASE 3 — NAVIGATE (18 min) · slides 22–24
- 💻 `/agent-ready fix navigability_code_intelligence` (then `agent_tooling_capabilities`) → agent generates ARCHITECTURE / repo map, `.mcp.json` (Serena), `scripts/`. **Scoped on purpose** — bare `fix` would close VALIDATE+SECURE too.
- Disambiguation: code *supports* semantic nav (D2) vs tooling *wired up* (D5).
- ⚡ Re-scan. Catch-up: `git checkout step-2-navigate`.

### PHASE 4 — VALIDATE (18 min) · slides 25–28
- 💻 Ask Claude for CI (ruff + mypy + pytest) and tests with descriptive assertions.
- Feedback *quality* is the lever — tests are the agent's only signal.
- ⚡ Re-scan. Catch-up: `git checkout step-3-validate`.

### PHASE 5 — SECURE, the 4th axis (18 min) · slides 29–30
- 🛡️ `/agent-ready fix security_sandbox` → `docs/agent-execution.md` (LINCE among options),
  `.env.example`, `.gitignore` secrets, lockfile flagged.
- ⚡⚡⚡ Slide 30 — **full 4-axis scan** with `--agents claude`: all four bars + Portable/Target maxes
  + explained findings (why/consequence/fix/effort).
- Catch-up: `git checkout step-4-secure`.

### PHASE 6 — Wrap (20 min) · slides 31–36
- 📊 Radar (31, now 4 axes) or the playground.
- 🔧 Fix recap (32), `/agent-ready report --format html` + `diff` → `.agent-ready/` (33).
- `git checkout step-5-complete` → ~85/100, "Optimized".
- 🎁 Take-home (34): skills are global; `/agent-ready init` for greenfield; AGENTS.md is cross-vendor.
- Roadmap (35), thanks + poll (36): "who gained ≥15 points?"

---

## Risk register

| Risk | Mitigation |
|------|-----------|
| Skill install fails | Method A copy fallback; pair up; pre-event email |
| `--agents` confusion | Default portable is fine; show target only once as the reveal of layers |
| Scan variance between people | Focus on direction, not exact number; branches are the known-good states |
| SECURE feels abstract | Anchor on concrete files: `.env.example`, `docs/agent-execution.md`, devcontainer |
| Time slips | Phase 5 compressible to 10 min; Phase 6 can drop the report/diff demo |
| AGENTS.md symlink on Windows | Note copy-fallback (`copy AGENTS.md CLAUDE.md`) |
