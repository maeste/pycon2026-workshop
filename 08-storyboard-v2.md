# Workshop Storyboard v2 — Skills-First Approach

> **Replaces**: `04-workshop-storyboard.md` (which was based on `scan_static.py`)
> **Workshop**: PyCon Italia 2026, Fri May 29, 11:00-13:00 (120 min)
> **Approach**: Use existing `agent-ready-skill` skills directly — no Python scripts to build

## Key Differences from v1

| Aspect | v1 (storyboard v1) | v2 (this document) |
|--------|-------|-------|
| Core tool | `scan_static.py` (deterministic Python script) | `/agent-ready scan` (agent skill) |
| Fix mechanism | `apply_fix.py` (Jinja2 templates) | `/agent-ready fix` (agent generates contextual files) |
| Reports | `report_gen.py` | `/agent-ready report` + `/agent-ready diff` |
| Dependencies | `pip install rich pyyaml jinja2` | Claude Code only |
| Determinism | 100% deterministic | Agent-based (intentional — it's the point) |
| Unique value | Same as Kodus/Factory | **Agent assesses and fixes itself** |

## Conventions

```
🎤  = Teacher speaks / demo
💻  = Participants work in Claude Code
🔍  = Participants analyze their OWN repo
⚡  = "Magic moment"
🎁  = Deliverable / takeaway
[Sn] = Slide reference
```

## Guinea Pig: quicknote-demo

A simple Python CLI for managing notes. Branches:

```
step-0-bare        ~10/100   Bare project
step-1-scan        ~10/100   + scan skills
step-2-instruct    ~35/100   + CLAUDE.md, README, CONTRIBUTING
step-3-fix-ready   ~35/100   + fix skill (no codebase changes)
step-4-validate    ~65/100   + report/diff skills + CI + tests
step-5-complete    ~85/100   Fully optimized
```

---

## FULL TIMELINE (120 min)

### PHASE 0: Setup & Icebreaker [00:00–00:10] (10 min) — Slides 1-5

```
00:00  🎤  Welcome + poll (2 min)
       - Written Python in production?
       - Used an AI coding agent?
       - Had an agent mess up your codebase?

00:02  🎤  The Promise (3 min)
       "In 2 hours you'll measure how ready YOUR codebase is for
        AI agents, fix the most impactful gaps, and walk out with
        a reusable toolkit."

00:05  💻  Setup Check (5 min)
       - Everyone: git clone quicknote-demo && cd quicknote-demo
       - Verify Claude Code works
       - git checkout step-0-bare
```

---

### PHASE 1: The Problem + First Scan [00:10–00:25] (15 min) — Slides 6-17

```
00:10  🎤  Why Agents Fail — Storytime (5 min)
       "Last month I asked Claude Code to add validation to our API.
        It added tests in the wrong directory.
        It followed linting rules from 2 years ago.
        It couldn't find where we keep request schemas."

       → Agents are NOT stupid. They are UNINFORMED.

00:15  🎤  Introduce Three-Axis Model (3 min)
              📝 INSTRUCT
             /            \
            /              \
      🧭 NAVIGATE —— ✅ VALIDATE

       "Does it know WHAT? Can it find WHERE? Can it check HOW?"

00:18  💻  First Scan — The Moment of Truth (4 min)
       git checkout step-1-scan
       /agent-ready scan .

       Score: ~10/100 😬
       Watch the agent work in real-time — it reads files,
       checks structure, evaluates content.

00:22  🔍  Try on YOUR repo (3 min)
       /agent-ready scan ~/your-real-project
       "Who scored higher than the guinea pig?"
       (Everyone. Laughs. But also surprises.)
```

---

### PHASE 2: INSTRUCT [00:25–00:50] (25 min) — Slides 18-21

```
00:25  🎤  Introduce INSTRUCT axis (3 min)
       "Your agent just landed. It knows nothing.
        What's the FIRST thing it needs?"
       → Instructions. Context. MEANING.

       Dimensions: Agent Instructions (20) + Spec-Driven (10) + Claude-Specific (8)

00:28  💻  The Quickest Win: CLAUDE.md (10 min)
       Don't write it from scratch. Ask Claude:

       "Read this project and write me a CLAUDE.md that describes
        what the project is, where things are, how to run/test/lint,
        and what conventions to follow."

       Claude reads the code → generates CLAUDE.md → 30 seconds.
       Review it. Tweak if needed. Save.

00:38  💻  Re-scan (3 min)
       /agent-ready scan .

       ⚡ MAGIC MOMENT #1: INSTRUCT jumps from ~0% to ~50-60%
       "ONE FILE. One conversation with Claude. That's it."

00:41  🔍  Try on YOUR repo (7 min)
       "Ask Claude to write a CLAUDE.md for your real project."
       Those who finish early: also improve their README.

00:48  🎤  Catch-up + transition (2 min)
       Falling behind? git checkout step-2-instruct
       "Your agent now knows WHAT to do. But does it know WHERE?"
```

---

### PHASE 3: NAVIGATE + Fix Skill [00:50–01:10] (20 min) — Slides 22-24

```
00:50  🎤  Introduce NAVIGATE axis (3 min)
       "Your agent opens a file... 5000 lines of spaghetti.
        It can't find where tests live. Formats code wrong."

       Dimensions: Navigability (18) + Documentation (8) + Skills & Tooling (8)

00:53  💻  Get the fix skill (2 min)
       git checkout step-3-fix-ready
       (Adds agent-ready-fix skill, codebase stays at step-2 state)

00:55  💻  THE MAGIC MOMENT: /agent-ready fix (10 min)
       /agent-ready fix

       ⚡ MAGIC MOMENT #2: The agent:
       1. Loads previous scores
       2. Identifies gaps: ".editorconfig missing, .env.example missing..."
       3. Asks: "Shall I generate these files?"
       4. Creates them — CONTEXTUALIZED to this specific project

       "This is what static tools CAN'T do. The agent reads YOUR code
        and creates files tailored to it."

01:05  🔍  Try on YOUR repo (5 min)
       /agent-ready scan ~/your-project  (focus on NAVIGATE score)
       Optional: /agent-ready fix on their real repo
```

---

### PHASE 4: VALIDATE + Diff/Report [01:10–01:40] (30 min) — Slides 25-32

```
01:10  🎤  Introduce VALIDATE axis (3 min)
       "This separates 'fun toy' from 'production tool'.
        Validation is how you TRUST an agent."

       Dimensions: Testing (16) + CI/CD (12)

01:13  💻  Add CI + tests with Claude's help (12 min)
       "Claude, create a GitHub Actions CI workflow for this project."
       "Claude, write pytest tests for the storage module."

       Claude generates the files. Review. Save.
       The effort to add CI + tests: 5 minutes with an agent.

01:25  💻  Get remaining skills + catch up (2 min)
       git checkout step-4-validate
       (Adds report + diff skills + all improvements as catch-up)

01:27  💻  See Your Journey — /agent-ready diff (5 min)
       /agent-ready diff

       Shows: before vs after across all 8 dimensions.
       Overall: ~10 → ~65 points.

01:32  💻  Full Report (3 min)
       /agent-ready report

       Comprehensive assessment document with:
       - Per-dimension breakdown
       - Evidence for each score
       - Prioritized recommendations

01:35  📊  Playground — Radar Chart (5 min)
       Open playground.html in browser
       Enter your scores → see the radar chart
       Visualize the 8-dim → 3-axis mapping
```

---

### PHASE 5: Wrap [01:40–02:00] (20 min) — Slides 33-35

```
01:40  🎤  The Complete Picture (3 min)
       git checkout step-5-complete
       /agent-ready scan .
       Score: ~85/100 — Optimized.
       "This is what agent-ready looks like."

01:43  🎤  Take-Home: Install Skills Globally (3 min)
       git clone agent-ready-skill
       for skill in skills/*/; do
         ln -sf "$(pwd)/$skill" ~/.claude/skills/$(basename $skill)
       done

       "Now /agent-ready works on EVERY project."

01:46  🎤  What's Next (3 min)
       - Multi-agent support (Cursor, Copilot, Windsurf)
       - CI gate: fail PRs below maturity threshold
       - History tracking and trends
       - Community-contributed skills

01:49  🎤  Final Reflection (3 min)
       "Two hours ago you didn't know how agent-ready your codebase was.
        Now you have:
        ✅ A mental model (3 axes, 3 questions)
        ✅ A number (your score, your improvement)
        ✅ A toolkit (5 skills, install once, use everywhere)"

01:52  ⚡  Final Magic Moment (3 min)
       "Show of hands — who improved their score by at least 20 points?"
       (Most hands go up)
       "That's 20 points closer to having agents that HELP you
        instead of HURTING you."

01:55  🎤  Q&A (5 min)

02:00  🎉  END
```

---

## Risk Register

| Risk | Prob | Impact | Mitigation |
|------|------|--------|------------|
| Claude Code setup fails | Med | High | Pre-event setup guide via email. Pair up. |
| Scan results vary between participants | High | Low | Feature, not bug. Focus on direction, not exact numbers. |
| Scan takes >60 seconds | Med | Low | Use wait time for discussion. "Watch the agent work." |
| API rate limits with 30+ people | Med | Med | Stagger scans. Pre-computed fallback results in slides. |
| Someone already at 85%+ | Low | Low | Challenge: "Can you hit 95? What's missing?" |
| git checkout conflicts | Low | Med | Clean checkouts only. No local changes to lose. |
| `/agent-ready fix` generates bad content | Low | Med | Review before accepting. Teaching moment about AI oversight. |
