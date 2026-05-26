# Workshop: Measuring AI-Readiness

**PyCon Italia 2026 — Venerdì 29 Maggio, 11:00-13:00**

A Three-Axis Maturity Model for Agent-Optimized Codebases.

---

## Prerequisites

Before the workshop, make sure you have:

- [ ] **Python 3.11+** installed
- [ ] **Claude Code** installed and working (with an active API key or subscription)
- [ ] **Git** installed
- [ ] A GitHub account (for cloning)
- [ ] Optionally: a Python project of your own to test on

## Setup (do this at the start)

### 1. Clone the workshop project

```bash
git clone https://github.com/maeste/quicknote-demo.git
cd quicknote-demo
git checkout step-0-bare
```

> **Catch-up tip:** If you need to switch to a later branch and git complains
> about local changes, run `git stash` first (or `git checkout -- .` to discard
> your changes). Your work isn't lost — `git stash pop` brings it back.

### 2. Verify Claude Code works

Open Claude Code in the `quicknote-demo` directory and type something.
If it responds, you're ready.

---

## Phase 1: The First Scan (15 min)

### Get the scan skills

```bash
git checkout step-1-scan
```

This adds the `/agent-ready` skills to your project (under `.claude/skills/`).

### Run your first assessment

In Claude Code:

```
/agent-ready scan .
```

Watch the agent analyze your project across 8 dimensions. You'll see a score
around **10-15/100** — don't worry, that's the point!

### Try on YOUR repo

If you brought a real project:

```
/agent-ready scan /path/to/your/project
```

Compare your real project's score with the guinea pig. Who scored higher?

---

## Phase 2: INSTRUCT — Tell the Agent What You Want (25 min)

The **INSTRUCT** axis measures: *"Does the agent understand WHAT we want?"*

It covers:
- Agent Instructions (CLAUDE.md) — weight: 20
- Spec-Driven Workflow — weight: 10
- Claude-Specific config — weight: 8

### The quickest win: CLAUDE.md

Ask Claude to help you create it. In Claude Code, type:

```
Read this project and write me a CLAUDE.md that describes what the project is,
where things are, how to run/test/lint, and what conventions to follow.
```

Claude will read your code and generate a contextualized CLAUDE.md. Review it,
adjust if needed, and save.

### Re-scan

```
/agent-ready scan .
```

Your INSTRUCT score should jump significantly. **One file. That's it.**

### Try on your repo

Ask Claude to write a CLAUDE.md for your real project too. The effort is
minimal and the impact is enormous.

### Falling behind?

```bash
git checkout step-2-instruct
```

This gives you a pre-made CLAUDE.md and improved README.

---

## Phase 3: NAVIGATE — Show the Agent Where Things Are (20 min)

The **NAVIGATE** axis measures: *"Can the agent find its way around?"*

It covers:
- Project Navigability — weight: 18
- Documentation & Comprehension — weight: 8
- Skills & Tooling — weight: 8

### Get the fix skill

```bash
git checkout step-3-fix-ready
```

This adds the `/agent-ready fix` skill while keeping your INSTRUCT improvements.

### Let the agent fix the gaps

In Claude Code:

```
/agent-ready fix
```

The agent will:
1. Load the previous scan results
2. Identify missing files (`.editorconfig`, `.env.example`, `ARCHITECTURE.md`, etc.)
3. Ask for your confirmation
4. Generate contextualized files — not boilerplate!

**This is the magic moment.** The agent reads YOUR project and creates files
tailored to it. This is what static analysis tools cannot do.

### Re-scan and compare

```
/agent-ready scan .
```

NAVIGATE should improve noticeably.

### Try on your repo

Run `/agent-ready fix` on your real project and see what it suggests.

---

## Phase 4: VALIDATE — Let the Agent Check Its Work (25 min)

The **VALIDATE** axis measures: *"Can the agent verify its work is correct?"*

It covers:
- Testing & Validation — weight: 16
- CI/CD & Automation — weight: 12

### Add tests and CI with Claude's help

Ask Claude:

```
Create a basic GitHub Actions CI workflow for this project that runs
ruff check and pytest.
```

And:

```
Write pytest tests for the storage module. Cover add, delete, search,
and update operations.
```

The agent writes the files. You review. Done.

### Get report and diff skills

```bash
git checkout step-4-validate
```

### See your journey

```
/agent-ready diff
```

This compares your current state with the initial assessment and shows
exactly what improved and by how much.

```
/agent-ready report
```

This generates a full assessment report you can share with your team.

### Falling behind?

The `step-4-validate` branch includes pre-made CI, tests, and config files
as a catch-up checkpoint.

---

## Phase 5: The Complete Picture (15 min)

### See what "Optimized" looks like

```bash
git checkout step-5-complete
/agent-ready scan .
```

This is a fully agent-ready project scoring ~85/100.

### Take-home: install the skills globally

To use these skills on any project:

```bash
git clone https://github.com/maeste/agent-ready-skill.git
cd agent-ready-skill
for skill in skills/*/; do
  ln -sf "$(pwd)/$skill" "$HOME/.claude/skills/$(basename $skill)"
done
```

Now `/agent-ready scan`, `/agent-ready fix`, `/agent-ready report`, and
`/agent-ready diff` work in every project you open with Claude Code.

---

## The Three-Axis Model

The 8 scoring dimensions map to 3 axes:

| Axis | Weight | Question | Dimensions |
|------|--------|----------|------------|
| **INSTRUCT** | 38% | Does the agent understand WHAT we want? | Agent Instructions (20) + Spec-Driven (10) + Claude-Specific (8) |
| **NAVIGATE** | 34% | Can the agent find its way around? | Navigability (18) + Documentation (8) + Skills & Tooling (8) |
| **VALIDATE** | 28% | Can the agent verify its work? | Testing (16) + CI/CD (12) |

### Maturity Levels

| Level | Name | Threshold |
|-------|------|-----------|
| L1 | Foundational | ≥ 40% |
| L2 | Guided | ≥ 55% |
| L3 | Structured | ≥ 70% |
| L4 | Optimized | ≥ 85% |
| L5 | Autonomous | ≥ 95% |

---

## Resources

- **Skills repo**: https://github.com/maeste/agent-ready-skill
- **Interactive playground**: Open `playground.html` in your browser
- **Slides**: Open `slides.html` in your browser

---

*Workshop by Stefano Maestri (@maeste) — PyCon Italia 2026*
