# 🎯 Piano di Brainstorming — PyCon IT 2026 Workshop

## Contesto
- **Evento**: PyCon Italia 2026 — **Venerdì 29 Maggio, 11:00-13:00** (2 ore)
- **Titolo**: "Measuring AI-Readiness: A Three-Axis Maturity Model for Agent-Optimized Codebases"
- **Speaker**: Stefano Maestri (maeste)
- **Repo riferimento**: https://github.com/RisorseArtificiali/agent-ready-skill
- **Obiettivo**: Trasformare un prodotto/skill set in un **workshop esperienziale** dove i partecipanti scoprono i temi progressivamente

---

## 📊 Cosa sappiamo (Fatti verificati)

### Il Repo agent-ready-skill (stato attuale)
- **5 skills**: `agent-ready` (router), `agent-ready-scan`, `agent-ready-fix`, `agent-ready-report`, `agent-ready-diff`
- **8 dimensioni di scoring** (0-100):
  1. Agent Instructions (20) — CLAUDE.md, regole gerarchiche, build/test/lint docs
  2. Project Navigability (18) — struttura chiara, index files, README, naming
  3. Testing & Validation (16) — test suite, comandi documentati, coverage
  4. CI/CD & Automation (12) — pipeline, linting, pre-commit hooks
  5. Spec-Driven Workflow (10) — task specs, PRD, acceptance criteria, ADR
  6. Skills & Tooling (8) — local skills, Makefile, scripts, MCP config
  7. Documentation & Comprehension (8) — linked docs, API docs, architecture
  8. Claude-Specific (8) — .claude/ directory, settings, hooks, MCP
- **Due layer**: Agnostic (dim 1-5, max 76) + Claude-specific (dim 6-8, max 24)
- **Score levels**: 🔴 0-30 | 🟡 31-60 | 🟢 61-80 | 🏆 81-100
- **Formato**: Agent Skills (agentskills.io), progettato per Claude Code
- **Comandi**: `/agent-ready scan [repo-url]`, `/agent-ready fix`, `/agent-ready report`, `/agent-ready diff`

### Competitive Landscape (da verificare approfonditamente)

| Progetto | Tipo | Pillars/Dimensions | Approach |
|----------|------|-------------------|----------|
| **Factory.ai Agent Readiness** | Commerciale | 8 technical pillars, 5 maturity levels | SaaS, /readiness-report |
| **Kodus/kodustech agent-readiness** | OSS CLI | 7 pillars, 39 automated checks | `bunx @kodus/agent-readiness .` |
| **jpequegn/agent-readiness-score** | OSS Framework | Inspired by Factory | GitHub-based |
| **ACMM (AI Codebase Maturity Model)** | OSS Dashboard | 5 levels | console.kubestellar.io/acmm |
| **agent-next/agent-ready** | OSS | Measurable operability standards | GitHub |
| **Nostro repo** | Agent Skills | 8 dimensions, 2 layers | Claude Code native |

### Descrizione Evento (dal sito PyCon)
> "AI agents fail inside real repositories for reasons that static lint rules and architecture diagrams don't capture: context layouts that waste tokens, structures that hide intent, validation loops that never close."
> 
> Processo insegnato: **Scan → Report → Fix → Diff**
> Output: score 0-100 + per-dimension breakdown

---

## ❓ Domande Aperte (da confermare con Stefano)

- [ ] **Target partecipanti**: junior/mid/senior? Conoscenza base agenti AI?
- [ ] **Formato**: hands-on con laptop o demo + discussione?
- [ ] **Repo cavia**: esistente o ad-hoc?
- [ ] **Takeaway**: riutilizzabile subito su progetti reali?
- [ ] **Title dice "Three-Axis" ma repo ha 8 dimensions** — allineamento?

---

## 🗺️ Fasi del Brainstorming

### Fase 1 — Assessment Repo vs Workshop Fit
- Ogni dimensione: ha senso in un workshop? È dimostrabile in 10-15 min?
- C'è sovrapposizione da ridurre per le 2 ore?
- Il modello "Three-Axis" nel titolo corrisponde a cosa? Va ridefinito?
- **Output**: Tabella fit/gap per ogni componente del repo

### Fase 2 — Competitive Deep Dive
- Analizzare Factory.ai (8 pillars), Kodus (39 checks), ACMM (5 levels)
- Cosa fanno meglio/diverso da noi?
- Cosa possiamo "rubare" o integrare?
- **Output**: Matrice competitiva + elementi riutilizzabili

### Fase 3 — Struttura Workshop (2h)
- Sequenza di scoperta progressiva (non lecturing)
- Punti "aha!" pianificati
- Timing per ogni blocco
- Repo cavia: come strutturare i branch/states
- **Output**: Runbook dettagliato del workshop con timing

### Fase 4 — Deliverables da Costruire
- Skills nuove/modificate da creare
- Script Python necessari (scanner automatizzato?)
- Slides/visual interattivi (HTML/JS)
- Single-page website per concetti complessi
- Branch strategy per il repo cavia
- **Output**: Piano implementazione con specifiche

### Fase 5 — Review e Finalizzazione
- Allineamento titolo/descrizione/reale contenuto
- Risk assessment (cosa può andare storto?)
- Backup plan per ogni exercize
- **Output**: Piano finale approvato

---

## 📁 File prodotti durante brainstorming

```
pycon2026-workshop/
├── 00-brainstorming-plan.md        # Questo file
├── 01-repo-assessment.md           # Fase 1: Fit/Gap analysis
├── 02-competitive-analysis.md      # Fase 2: Competitive landscape
├── 03-workshop-structure.md        # Fase 3: Sequenza e timing
├── 04-deliverables-plan.md         # Fase 4: Cosa buildare
├── 05-final-plan.md                # Fase 5: Piano approvato
└── assets/                         # Sketch, note visive
```

---

## ⏰ Timeline Stimata
- Fase 1: Assessment repo — ~30 min discussione
- Fase 2: Competitive deep dive — ~45 min ricerca + analisi
- Fase 3: Struttura workshop — ~45 min design
- Fase 4: Deliverables — ~30 min specifiche
- Fase 5: Review — ~15 min

**Totale stimato**: 2.5-3 ore di brainstorming intenso

---

*Ultimo aggiornamento: creazione iniziale*
