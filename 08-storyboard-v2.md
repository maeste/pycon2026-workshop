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

> **Scan-posture rule (read once).** All hands-on scans are **portable (bare)**
> so the Phase-6 `diff` is apples-to-apples — `diff` always re-scans portable and
> can't take `--agents`. `--agents claude` appears only as a teaching reveal in
> Phase 1, on the Phase-5 *fix* (to surface the target permission policy), and on
> the Phase-6 finale scan of `step-5-complete`. Save the baseline in Phase 1.

### PHASE 0 — Setup & Install (10 min) · slides 1–5
- Poll: used an AI agent? been burned by one?
- Install the 6 skills into `~/.claude/skills/` (Method A copy or B symlink).
- `git clone quicknote-demo && git checkout step-0-bare`.
- Verify: `/agent-ready scan .` returns a 4-axis score.
- **Catch-up uses untracked files** → tell people: `git stash -u` or `git checkout -f step-N` (plain `stash` / `checkout -- .` won't move untracked files).

### PHASE 1 — The Model + First Scan + Layers (15 min) · slides 6–17
- Why agents fail → three failure modes → three axes (slide 10), with a footnote teasing a 4th.
- Deep-dives: INSTRUCT (11), NAVIGATE (12), VALIDATE (13).
- **⚡ Slide 14 — the SECURE reveal**: "I pitched three; security forced a fourth."
- Maturity ladder (15), scoring + **Portable vs Target** (16), two test subjects (17).
- 💻 First scan on the guinea pig (~10) → **save baseline**: `cp .agent-ready/agent-ready-scores.json .agent-ready/baseline.json`.
- 👁 One-time reveal: `/agent-ready scan . --agents claude` to light up the target layer — then back to portable.
- 🔍 "Now your repo": `/agent-ready scan ~/your-project`.

### PHASE 2 — INSTRUCT (20 min) · slides 18–21
- 💻 Ask Claude: *"write a concise AGENTS.md (<200 lines)…"* → review → save.
- `ln -s AGENTS.md CLAUDE.md` (bridge, no drift).
- ⚡ Re-scan **bare** `/agent-ready scan .`: INSTRUCT jumps. **Concise beats bloated** (v2 penalty).
- 🔍 Do it on your repo. Catch-up: `git checkout step-1-instruct`.

> 📦 **`step-1-instruct` brings** (vs `step-0-bare`):
> - **`AGENTS.md`** (new) — the portable primary instruction file → D1 `primary_instruction_file`, `instruction_quality`, `instruction_conciseness`.
> - **`CLAUDE.md`** (new symlink → AGENTS.md) → D1 `cross_agent_bridge` (target; counts only with `--agents`).
> - **`README.md`** (expanded), **`CONTRIBUTING.md`** (new) → D2 `readme_overview` (also helps NAVIGATE).
> - **`specs/TEMPLATE.md`**, **`docs/adr/0001-*.md`**, **`.github/ISSUE_TEMPLATE/*`**, **`pull_request_template.md`**, **`CHANGELOG.md`** (new) → D7 `spec_tasks_dir`, `acceptance_criteria`, `issue_pr_templates`, `adr_decisions`, `docs_comprehension_signals`.
> - **Scan impact:** INSTRUCT (D1+D7) jumps hard; small NAVIGATE bump from README.
> - **Mindset:** cheapest, highest-leverage axis. One good AGENTS.md + light process scaffolding = the agent knows *what* the project is and *how* to work before touching code. Live we only do AGENTS.md (D1, the headline); the branch is the full INSTRUCT state (adds D7).

### PHASE 3 — NAVIGATE (18 min) · slides 22–24
- 💻 `/agent-ready fix navigability_code_intelligence` (then `agent_tooling_capabilities`) → agent generates ARCHITECTURE / repo map, `.mcp.json` (Serena), `scripts/`. **Scoped on purpose** — bare `fix` would close VALIDATE+SECURE too.
- Disambiguation: code *supports* semantic nav (D2) vs tooling *wired up* (D5).
- ⚡ Re-scan **bare**. Catch-up: `git checkout step-2-navigate`.

> 📦 **`step-2-navigate` brings** (vs `step-1-instruct`):
> - **`ARCHITECTURE.md`** (new) → D2 `repo_map_availability`.
> - **`quicknote/storage.py`** (modified: type hints) → D2 `semantic_nav_amenability` (typed code an LSP/Serena can navigate).
> - **`.editorconfig`** (new) → D2 consistency signal.
> - **`.mcp.json`** (new, Serena) → D5 `mcp_declaration` + `nav_comprehension_mcp_servers`.
> - **`scripts/dev.sh`** (new) → D5 `bundled_helper_scripts`.
> - **Scan impact:** NAVIGATE (D2+D5) jumps.
> - **Mindset:** now the agent can *find its way* — a map to read, typed code it can navigate by symbol, and an MCP server actually wired up so it stops grepping. D2 = the codebase *supports* nav; D5 = the tooling is *plugged in*. You want both.

### PHASE 4 — VALIDATE (18 min) · slides 25–28
- 💻 Ask Claude for CI (ruff + mypy + pytest) and tests with descriptive assertions.
- Feedback *quality* is the lever — tests are the agent's only signal.
- ⚡ Re-scan **bare**. Catch-up: `git checkout step-3-validate`.
- *(Governance not covered by the two prompts — mention `/agent-ready fix cicd_automation_governance` or note the branch adds it.)*

> 📦 **`step-3-validate` brings** (vs `step-2-navigate`):
> - **`tests/`** (new: `test_storage.py`, `test_cli.py`, `conftest.py`) with descriptive assertion messages → D3 `test_suite_present`, `feedback_quality`.
> - **`pyproject.toml`** (modified: dev deps, ruff/mypy/pytest/coverage config) → D3 `test_commands_documented`, `coverage_reasonable`, `feedback_quality` (mypy strict).
> - **`.github/workflows/ci.yml`** (new: ruff + mypy + pytest) → D4 `ci_runs_tests_lint`, `lint_format_automated`.
> - **`.pre-commit-config.yaml`** (new: ruff + gitleaks) → D4 `pre_commit_hooks`.
> - **`.github/dependabot.yml`**, **`.github/CODEOWNERS`** (new) → D4 `governance`.
> - **Scan impact:** VALIDATE (D3+D4) jumps.
> - **Mindset:** now the agent can *verify its work*. Tests aren't for finding bugs — they're the only signal the agent has that it didn't break something. CI gates regressions; governance keeps deps fresh. Live we do tests+CI; the branch also closes governance (D4).

### PHASE 5 — SECURE, the 4th axis (18 min) · slides 29–30
- 🛡️ `/agent-ready fix security_sandbox --agents claude` → `docs/agent-execution.md` (LINCE among options),
  `.env.example`, `.gitignore` secrets, lockfile flagged. `--agents` so the target permission policy is *surfaced* (manual).
- ⚡⚡⚡ Slide 30 — narrate the **full 4-axis picture** with Portable/Target maxes + explained findings (why/consequence/fix/effort). (Live re-scan stays **bare** for journey consistency; the slide shows the `--agents claude` view.)
- Catch-up: `git checkout step-4-secure`.

> 📦 **`step-4-secure` brings** (vs `step-3-validate`):
> - **`docs/agent-execution.md`** (new) → D6 `documented_execution_policy` (where non-detectable host sandboxes earn credit).
> - **`.devcontainer/devcontainer.json`** (new) → D6 `committed_isolation_config`.
> - **`.env.example`** (new) + **`.gitignore`** (modified: secret patterns + `.agent-ready/`) → D6 `secret_hygiene`.
> - **`requirements.txt`** (new committed lockfile) → D6 `supply_chain_pinning` (with the Dependabot from step-3).
> - **`SECURITY.md`** (new) → reinforces injection/disclosure posture (`injection_hygiene`).
> - **Scan impact:** SECURE (D6) jumps; 5 of 6 sub-criteria are portable. The 6th, `agent_permission_policy`, is target + manual (only surfaced, see step-5).
> - **Mindset:** now the agent can *run safely* — a documented sandbox contains untrusted code, no secrets to leak, pinned deps so the supply chain can't shift. The repo earns security credit by **documenting** posture, because runtime sandbox usage isn't detectable by a scan.

### PHASE 6 — Wrap (20 min) · slides 31–36
- 📊 Radar (31, now 4 axes) or the playground.
- 🔧 Fix recap (32). 🎯 **Journey diff against the saved baseline**: `/agent-ready diff .agent-ready/baseline.json` (bare `diff` would compare only against the last scan → ~0). Then `/agent-ready report --format html` → `.agent-ready/` (33).
- `git checkout step-5-complete` → `/agent-ready scan . --agents claude` → ~85/100, "Optimized" (finale *does* use `--agents` to show the vendor layer).
- 🎁 Take-home (34): skills are global; `/agent-ready init` (in an **empty dir**) for greenfield; AGENTS.md is cross-vendor.
- Greenfield slide (35), thanks + poll (36): "who gained ≥15 points?"

> 📦 **`step-5-complete` brings** (vs `step-4-secure`):
> - **`.claude/skills/changelog-entry/SKILL.md`** (new) → D5 `standard_skills` (the project itself ships a conformant Skill).
> - **`.claude/settings.json`** (new: restrictive deny rules) → D6 `agent_permission_policy` (target — counts with `--agents claude`).
> - **`AGENTS.md`** (modified: fast-feedback note) → D3 `fast_feedback_loop`.
> - **Scan impact:** pushes overall to ~85 → 🏆 L4 Optimized (esp. with `--agents claude`).
> - **Mindset:** the last mile — the project *ships* agent tooling (a Skill) and *constrains* what the agent may do (deny rules). L4 = quality gates + the agent operating under explicit guardrails.

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
