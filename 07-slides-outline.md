# Fase 5: Slides & Visual Support — Piano Dettagliato

## 🎯 Obiettivo
Slide deck HTML interattivo per PyCon 2026 Workshop.
- **Zero dipendenze** (inline CSS+JS, font da CDN)
- **Dark theme** coerente con radar chart
- **Speaker notes** integrate
- **Animazioni progressive** (click-to-reveal)
- **Esportabile PDF** via browser print

---

## 🎨 Design System

```
Background:    #0f0f1a (deep navy)
Surface:       #1a1a2e (card bg)
Primary:       #4f8cff (blue accent)
Secondary:     #a855f7 (purple)
Success:       #22c55e (green)
Warning:       #f59e0b (amber)
Error:         #ef4444 (red)
Text primary:  #e2e8f0
Text dim:      #94a3b8
Font:          Inter (headings) + JetBrains Mono (code)
Border radius: 12px
Shadow:        0 4px 24px rgba(0,0,0,0.3)
```

---

## 📑 Struttura Slide Deck (35 Slides)

### SEZIONE A: Opening [Slides 01–05]

| # | Titolo | Tipo | Animazione | Speaker Notes |
|---|--------|------|------------|--------------|
| **01** | Title Slide | Hero | Fade in | "Welcome — in 2 hours you'll measure how ready YOUR codebase is for AI agents" |
| **02** | About Me | Text + photo | Stagger | Quick bio, why I care about this topic |
| **03** | Agenda | Timeline visual | Build-up | "5 phases, 3 magic moments, 1 takeaway you can use Monday" |
| **04** | The Promise | Big statement | Scale up | Show end state FIRST (radar preview) |
| **05** | Room Poll | Interactive | Click reveal | "Raise hand if..." icebreaker |

### SEZIONE B: The Problem [Slides 06–10]

| # | Titolo | Tipo | Speaker Notes |
|---|--------|------|--------------|
| **06** | "It Worked on My Machine" → "It Worked in My Prompt" | Quote evolution | The new classic excuse |
| **07** | Horror Story (Live) | Storytelling | The Claude Code anecdote — wrong dir, old conventions, no schema finding |
| **08** | Why Agents Fail | Diagram (3 failure modes) | Visual tree of failure reasons |
| **09** | It's Not the Agent's Fault | Punchline | "Agents aren't stupid — they're UNINFORMED" |
| **10** | The Three Questions | Reveal one by one | WHAT / WHERE / RIGHT → maps to 3 axes |

### SEZIONE C: The Model [Slides 11–16]

| # | Titolo | Tipo | Speaker Notes |
|---|--------|------|--------------|
| **11** | Introducing the Three-Axis Model | Triangle diagram | Draw/build live |
| **12** | Axis 1: INSTRUCT | Card + icon | Does it understand WHAT we want? |
| **13** | Axis 2: NAVIGATE | Card + icon | Can it find its way? |
| **14** | Axis 3: VALIDATE | Card + icon | Can it tell if it did right? |
| **15** | Maturity Levels | Progress bar animation | 5 levels from Foundational to Autonomous |
| **16** | How Scoring Works | Formula reveal | Per-axis 0-100 → weighted overall → maturity level |

### SEZIONE D: Demo / Proof [Slides 17–21]

| # | Titolo | Tipo | Speaker Notes |
|---|--------|------|--------------|
| **17** | Meet the Test Subjects | Two repo cards | demo-bad vs demo-good intro |
| **18** | 🔴 Repo A: Chaos Monkey | Live scan output | Terrible scores, red everywhere |
| **19** | 🟢 Repo B: Agent Heaven | Live scan output | Great scores, green everywhere |
| **20** | Same Tool, Different Scores | Side-by-side comparison | ⚡ MAGIC MOMENT #1 |
| **21** | The Difference Isn't the Agent | Key insight | It's the CODEBASE |

### SEZIONE E: Hands-On Phases [Slides 22–32]

| # | Titolo | Tipo | Speaker Notes |
|---|--------|------|--------------|
| **22** | PHASE 1: INSTRUCT | Section divider | Transition to hands-on |
| **23** | Your Score (Axis 1) | Placeholder for live result | Participants run scan now |
| **24** | The Quickest Win: CLAUDE.md | Template reveal | One file = +20 points |
| **25** | Before & After | Delta visualization | ⚡ MAGIC MOMENT #2 |
| **26** | PHASE 2: NAVIGATE | Section divider | |
| **27** | Your Score (Axis 2) | Live results | |
| **28** | Pick Your Fix | Menu of options | A/B/C/D choices |
| **29** | PHASE 3: VALIDATE | Section divider | |
| **30** | Your Score (Axis 3) | Live results | |
| **31** | The Testing Paradox | Provocative statement | Tests are safety nets for agents |
| **32** | CI Template | Code walkthrough | |

### SEZIONE F: Hybrid Moment & Close [Slides 33–35]

| # | Titolo | Tipo | Speaker Notes |
|---|--------|------|--------------|
| **33** | ⚡ THE HYBRID MOMENT | Full report reveal | Static + LLM combined scoring |
| **34** | Radar Chart Reveal | Full-screen radar | ⚡ MAGIC MOMENT #3 |
| **35** | What You Take Home | Summary cards | Toolkit + mental model + badge |
| **36** | Thank You / Q&A | Final slide | Resources, repo URL, call to action |

---

## 🌐 Single Page Website — "Agent Readiness Explained"

Oltre alle slide, un **sito single-page** che spiega i concetti complessi in modo esperienziale:

### Concept: Interactive Playground

`templates/playground.html` — Una pagina dove l'utente può:

1. **Vedere il modello 3-axis** animato (SVG/CSS)
2. **Cliccare su ogni axis** e vedere quali checks contribuiscono
3. **Simulare uno score** togglando check on/off
4. **Vedere il radar chart aggiornarsi in real-time**
5. **Copiare il badge SVG** generato dal proprio score simulato

Questo serve sia COME supporto visuale durante il workshop, CHE come risorsa post-workshop da condividere.

---

## 📐 Layout Types per le Slide

```
┌─────────────────────────────────────┐
│  TYPE 1: HERO                      │
│                                     │
│        ══════════                   │
│       ╔═══════════╗                 │
│       ║  BIG      ║                 │
│       ║  TITLE    ║                 │
│       ║           ║                 │
│       ╚═══════════╝                 │
│        subtitle here                │
│                                     │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  TYPE 2: SPLIT (text | visual)      │
│                                     │
│  ┌──────────┐  ┌──────────────────┐ │
│  │          │  │                  │ │
│  │  TEXT    │  │   VISUAL / CODE  │ │
│  │  BLOCK   │  │                  │ │
│  │          │  │                  │ │
│  └──────────┘  └──────────────────┘ │
│                                     │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  TYPE 3: THREE-COLUMN (axes)        │
│                                     │
│  ┌───────┐ ┌───────┐ ┌───────┐    │
│  │ 📝    │ │ 🧭    │ │ ✅    │    │
│  │INSTR  │ │NAVI   │ │VALID  │    │
│  │       │ │       │ │       │    │
│  └───────┘ └───────┘ └───────┘    │
│                                     │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  TYPE 4: FULL VISUAL (diagram)      │
│                                     │
│           ┌─────────┐              │
│           │  SVG /   │              │
│           │ CHART /  │              │
│           │ DIAGRAM  │              │
│           └─────────┘              │
│         caption or annotation       │
│                                     │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  TYPE 5: CODE / TERMINAL            │
│                                     │
│  ┌──────────────────────────────┐  │
│  │ $ python scan_static.py ...  │  │
│  │ ╭────────────────────────╮   │  │
│  │ │  📝 AXIS 1: INSTRUCT   │   │  │
│  │ │  Score: 35% █████░░░░   │   │  │
│  │ │  ✅ README.md           │   │  │
│  │ │  ❌ CLAUDE.md           │   │  │
│  │ ╰────────────────────────╯   │  │
│  └──────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  TYPE 6: SECTION DIVIDER            │
│                                     │
│  ═════════════════════════════      │
│                                     │
│        PHASE 2                       │
│    ────────────────                  │
│      🧭 NAVIGATE                     │
│                                     │
│    "Can the agent find its way?"    │
│                                     │
│  ═════════════════════════════      │
│                                     │
└─────────────────────────────────────┘
```
