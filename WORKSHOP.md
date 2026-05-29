# Workshop: Measuring AI-Readiness

**PyCon Italia 2026 — Venerdì 29 Maggio, 11:00-13:00**

A maturity model for agent-optimized codebases. We started with **three axes**
— and building v2, security forced a **fourth**.

| Axis | Weight | Question | Dimensions (v2) |
|------|--------|----------|-----------------|
| 📝 **INSTRUCT** | 28% | Does the agent understand WHAT we want? | Agent Instructions & Context (18) + Spec-Driven Workflow & Docs (10) |
| 🧭 **NAVIGATE** | 30% | Can the agent find its way & reach for tools? | Navigability & Code Intelligence (18) + Agent Tooling & Capabilities (12) |
| ✅ **VALIDATE** | 30% | Can the agent verify it did it right? | Testing & Feedback (16) + CI/CD, Automation & Governance (14) |
| 🛡️ **SECURE** | 12% | Can the agent run safely? | Security & Sandbox (12) |

Every check is **portable** (counts for any agent) or **target-specific**
(only scored when you declare an agent with `--agents`).

---

## Prerequisites

- [ ] **Python 3.11+**
- [ ] **Claude Code** installed and working
- [ ] **Git**
- [ ] A GitHub account
- [ ] Optionally: a Python project of your own to test on

## Setup (do this at the start)

### 1. Install the Agent-Ready skills (6 skills)

The skills power `/agent-ready scan | fix | report | diff | init`. Choose one:

**Method A — Quick copy (fastest)**

```bash
git clone https://github.com/RisorseArtificiali/agent-ready-skill.git /tmp/agent-ready-skill
mkdir -p ~/.claude/skills
cp -r /tmp/agent-ready-skill/skills/* ~/.claude/skills/
rm -rf /tmp/agent-ready-skill
```

**Method B — Clone + symlink (recommended, stays updated)**

```bash
git clone https://github.com/RisorseArtificiali/agent-ready-skill.git ~/agent-ready-skill
cd ~/agent-ready-skill
for skill in agent-ready agent-ready-scan agent-ready-fix agent-ready-report agent-ready-diff agent-ready-init; do
  ln -sf "$(pwd)/skills/$skill" "$HOME/.claude/skills/$skill"
done
```

With method B, a future `git pull` in `~/agent-ready-skill` updates all skills.

> **Verify:** restart Claude Code and type `/agent-ready` — you should see it listed.

### 2. Clone the workshop project

```bash
git clone https://github.com/maeste/quicknote-demo.git
cd quicknote-demo
git checkout step-0-bare
```

> **Catch-up tip:** to jump to a later branch, run `git stash` first if git
> complains about local changes (`git stash pop` brings your work back).

### 3. Verify everything works

```
/agent-ready scan .
```

If you see a 4-axis assessment with a score, you're ready.

---

## Phase 1: The First Scan + Layers (15 min)

### Scan the guinea pig

```
/agent-ready scan .
```

The agent analyzes 7 dimensions across the 4 axes. Expect **~10-15/100** — that's the point.

### Portable vs Target — declare your agent

By default the scan is **portable** (counts for any AI agent). To also score
vendor-specific signals, declare a target:

```
/agent-ready scan . --agents claude
```

Now target sub-criteria activate (e.g. a `CLAUDE.md` bridge, restrictive
permission rules). Without `--agents`, those are marked `n/a` and excluded —
a portable repo is never penalized for vendor files it doesn't need.

### Try on YOUR repo

```
/agent-ready scan /path/to/your/project
```

Who scored higher than the guinea pig?

---

## Phase 2: INSTRUCT — Tell the Agent What You Want (20 min)

**INSTRUCT (28%)** = Agent Instructions & Context (18) + Spec-Driven Workflow & Docs (10).

### The quickest win: AGENTS.md

`AGENTS.md` is the cross-vendor standard — one file every agent reads. Don't
hand-write it; ask Claude:

```
Read this project and write a concise AGENTS.md (under 200 lines): overview,
build/test/lint commands, structure, conventions, and a short safe-to-run note.
```

Review it, then bridge it for Claude Code with a symlink (no duplicate, no drift):

```bash
ln -s AGENTS.md CLAUDE.md
```

Codex, opencode, and pi read `AGENTS.md` natively.

> **v2 penalizes bloat.** A focused 150-line AGENTS.md beats a 600-line wall of
> text. Concise wins.

### Re-scan

```
/agent-ready scan . --agents claude
```

INSTRUCT should jump. **One file (plus a symlink). That's it.**

### Try on your repo, then catch up if needed

```bash
git checkout step-1-instruct
```

---

## Phase 3: NAVIGATE — Orient + Tooling (18 min)

**NAVIGATE (30%)** = Navigability & Code Intelligence (18) + Agent Tooling & Capabilities (12).

### Let the agent fix the gaps — scoped to this axis

```
/agent-ready fix navigability_code_intelligence
/agent-ready fix agent_tooling_capabilities
```

The agent loads your scores, finds gaps, and **generates contextualized files** —
an `ARCHITECTURE.md` / repo map, an `.mcp.json` declaring a nav server (Serena),
a `scripts/` helper. Not boilerplate — tailored to YOUR project.

> **Why scoped?** Bare `/agent-ready fix` (no argument) fixes **every** impactful
> gap across all axes at once. We pass a dimension id to keep this phase focused on
> NAVIGATE — so VALIDATE and SECURE stay for their own phases. On a real project,
> running it unscoped to fix everything in one pass is perfectly fine.

> **Disambiguation:** Navigability is whether your code *supports* semantic
> navigation (typed, analyzable). Agent Tooling is whether a nav MCP server is
> *actually wired up*. You want both.

### Re-scan, then catch up if needed

```
/agent-ready scan .
git checkout step-2-navigate
```

---

## Phase 4: VALIDATE — Let the Agent Check Its Work (18 min)

**VALIDATE (30%)** = Testing & Feedback (16) + CI/CD, Automation & Governance (14).

### Add tests + CI with Claude's help

```
Create a GitHub Actions CI workflow that runs ruff check, mypy, and pytest.
```
```
Write pytest tests for the storage module, with descriptive assertion messages.
```

> The key word is **feedback**: tests are the agent's only signal. v2 scores
> feedback *quality* — descriptive assertions (not bare `assert`) and a type
> checker the agent can run.

### Re-scan, then catch up if needed

```
/agent-ready scan .
git checkout step-3-validate
```

---

## Phase 5: SECURE — The Fourth Axis (18 min)

**SECURE (12%)** = Security & Sandbox. The axis v2 added — because an agent that
understands, navigates, and validates perfectly can still leak secrets or get
prompt-injected.

### Fix the security baseline

```
/agent-ready fix security_sandbox
```

The agent generates a vendor-neutral **`docs/agent-execution.md`** (sandbox /
execution policy — devcontainer, OS-sandbox, hosted, or [LINCE](https://lince.sh)),
a redacted **`.env.example`**, secret patterns in **`.gitignore`**, and flags
lockfiles to commit.

What it scores:
- **Committed isolation** (devcontainer with default-deny egress)
- **Documented execution policy** (where non-detectable host sandboxes earn credit)
- **Secret hygiene** + **supply-chain pinning** (committed lockfiles, Dependabot)
- **Injection hygiene** (instructions only in trusted files)
- **Permission policy** *(target — with `--agents`)*: restrictive deny rules

### Re-scan, then catch up if needed

```
/agent-ready scan . --agents claude
git checkout step-4-secure
```

---

## Phase 6: The Complete Picture (15 min)

### See your journey

```
/agent-ready diff
```

Shows before/after across all dimensions — overall ~10 → ~65+.

```
/agent-ready report --format html
```

A layered report in `.agent-ready/` with **explained findings** (every gap ships
*why it matters · consequence · how to fix · effort*) and a `badge.svg`.

### See what "Optimized" looks like

```bash
git checkout step-5-complete
/agent-ready scan . --agents claude
```

A fully agent-ready project scoring ~85/100.

### Take-home

- The 6 skills are installed globally — `/agent-ready` works on **every** project.
- Starting a **new** project? `/agent-ready init . --agents claude` scaffolds an
  agent-ready baseline (AGENTS.md, secret hygiene, execution policy, CI) from day one.
- `AGENTS.md` is the cross-vendor standard — it pays off whatever agent you use.

---

## Maturity Levels

| Level | Name | Threshold |
|-------|------|-----------|
| L1 | Foundational | ≥ 40% |
| L2 | Guided | ≥ 55% |
| L3 | Structured | ≥ 70% |
| L4 | Optimized | ≥ 85% |
| L5 | Autonomous | ≥ 95% |

## Resources

- **Skills repo**: https://github.com/RisorseArtificiali/agent-ready-skill
- **Guinea pig repo**: https://github.com/maeste/quicknote-demo
- **Interactive playground**: open `playground.html`
- **Slides**: open `slides.html`

---

*Workshop by Stefano Maestri (@maeste) — PyCon Italia 2026*
