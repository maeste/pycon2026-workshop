# Fase 1: Repo Assessment — Fit/Gap Analysis per Workshop

## 📋 Contesto
Valutazione di ogni componente del repo `agent-ready-skill` rispetto ai requisiti del workshop PyCon IT 2026:
- **Target**: Developer mid/senior (1-5+ anni)
- **Formato**: Hands-on puro (laptop obbligatorio)
- **Durata**: 2 ore esatte
- **Obiettivo**: Scoperta progressiva + takeaway riutilizzabili
- **Repo cavia**: Il loro repo reale (o uno fornito)

---

## 🔍 Analisi per Skill/Componente

### 1. agent-ready (Router Skill)
| Aspetto | Valutazione | Note |
|---------|------------|------|
| Concept | ✅ Ottimo | Entry point naturale, routing chiaro |
| Dimostrabilità in 10min | ✅ Si | `/agent-ready scan` produce output immediato |
| Value per workshop | ✅ Alto | È il "hello world" del workshop |
| Modifiche necessarie | Minime | Aggiungere flag `--workshop-mode` per output più verboso |

**Verdetto**: ✅ **KEEP** — punto di partenza perfetto

---

### 2. agent-ready-scan (Core Diagnostic)
| Aspetto | Valutazione | Note |
|---------|------------|------|
| Copertura | ✅ Completa | 8 dimensioni, 30+ sub-criteria |
| Approccio | ⚠️ LLM-based | Richiede Claude Code per funzionare — **non è automatizzato** |
| Output | ✅ Ricco | Score + bar chart + evidence JSON |
| Tempo esecuzione | ⚠️ Variabile | Dipende da dimensione repo + velocità LLM |
| Riproducibilità | ⚠️ Non-deterministica | Due scan possono dare score diversi (LLM judgment) |

**🔴 CRITICO PER WORKSHOP**: Lo scan è **LLM-judgment based**, non script deterministico.
- **Pro**: Insegna il concetto che "agent readiness" richiede comprensione semantica
- **Con**: In un workshop di 2h con 30+ persone, impossibile debuggare perché lo score differisce
- **Opportunity**: Creare uno **script Python di pre-scan statico** (check deterministici) come primo passo, poi lo scan LLM come approfondimento

**Verdetto**: ✅ **KEEP ma estendere** — aggiungere scanner statico Python come "Layer 0"

---

### 3. agent-ready-fix (Auto-fix Generator)
| Aspetto | Valutazione | Note |
|---------|------------|------|
| Utilità | ✅ Alta | Genera file contestuali, non boilerplate |
| Safety | ✅ Buona | Confirmation gate, non sovrascrive |
| Demo value | ✅ Molto alto | "Before → After" visuale è impattante |
| Rischio workshop | ⚠️ Medio | Genera molti file — può confondere |

**Verdetto**: ✅ **KEEP** — momento "magico" del workshop. Limitare a top-3 fix in modalità workshop.

---

### 4. agent-ready-report (Detailed Report)
| Aspetto | Valutazione | Note |
|---------|------------|------|
| Detail level | ⚠️ Troppo alto per demo | Report completo è overkill in 2h |
| Format | ✅ Markdown | Leggibile, portabile |
| Workshop fit | 🔶 Opzionale | Utile come takeaway post-workshop |

**Verdetto**: 🔶 **DEMOTE** — non nel flusso principale, materiale bonus/extra

---

### 5. agent-ready-diff (Delta Comparison)
| Aspetto | Valutazione | Note |
|---------|------------|------|
| Concept | ✅ Forte | Misura miglioramento — chiude il cerchio |
| Demo value | ✅ Alto | Mostra progressione → soddisfazione |
| Prerequisito | ⚠️ Richiede 2 scan | Deve aver già fatto scan + fix |
| Workshop fit | ✅ Ottimo closing | Perfetto per ultimi 15 min |

**Verdetto**: ✅ **KEEP** — ottimo finale del workshop ("guardate quanto avete migliorato")

---

## 🎯 Il Problema dei "Three-Axis"

Il titolo dice **"Three-Axis Maturity Model"** ma il repo ha **8 dimensioni**.

### Proposta di Raggruppamento in 3 Assi

```
┌─────────────────────────────────────────────────────┐
│           THREE-AXIS MATURITY MODEL                  │
├──────────┬──────────────────────────────────────────┤
│          │                                          │
│  AXIS 1  │  📝 INSTRUCT                             │
│  (Weight │  "Can the agent understand              │
│   ~38%)  │   what we want?"                        │
│          │                                          │
│          │  • Agent Instructions (20)               │
│          │  • Spec-Driven Workflow (10)             │
│          │  • Documentation & Comp. (8)             │
│          │                                          │
├──────────┼──────────────────────────────────────────┤
│          │                                          │
│  AXIS 2  │  🧭 NAVIGATE                             │
│  (Weight │  "Can the agent find its                │
│   ~30%)  │   way around?"                          │
│          │                                          │
│          │  • Project Navigability (18)             │
│          │  • Skills & Tooling (8)                 │
│          │  • Claude-Specific (8)                   │
│          │                                          │
├──────────┼──────────────────────────────────────────┤
│          │                                          │
│  AXIS 3  │  ✅ VALIDATE                            │
│  (Weight │  "Can the agent verify                  │
│   ~28%)  │   its work is correct?"                 │
│          │                                          │
│          │  • Testing & Validation (16)             │
│          │  • CI/CD & Automation (12)              │
│          │                                          │
└──────────┴──────────────────────────────────────────┘
```

**Perché questi 3 assi?**
1. **Instruct** = Input all'agent (istruzioni, specs, docs)
2. **Navigate** = Capacità di orientamento (struttura, tooling, configurazione)
3. **Validate** = Feedback loop (test, CI/CD, quality gates)

Ogni axis ha una **domanda fondamentale** facile da ricordare.

---

## 📊 Gap Analysis — Cosa Manca per il Workshop

### Gap Critici (Must-Have)

| # | Gap | Impatto | Soluzione proposta |
|---|-----|---------|-------------------|
| G1 | **Nessuno scanner automatico/deterministico** | 🔴 Alto | Script Python (`scan_static.py`) che fa check statici (file existence, config parsing) — output JSON identico allo scoring schema |
| G2 | **Nessun repo cavia strutturato** | 🔴 Alto | Repo ad-hoc con branch per ogni livello di maturità (vedi sotto) |
| G3 | **Nessuna visualizzazione interattiva** | 🟡 Medio | Single-page HTML/JS con radar chart delle 3 axis + 8 dimensions |
| G4 | **Nessuna guida step-by-step** | 🟡 Medio | `WORKSHOP.md` con exercizi sequenziali |
| G5 | **Dipendenza da Claude Code** | 🟡 Medio | Il workshop richiede CC — va bene (target sa cos'è) ma serve prep-guide |

### Gap Nice-to-Have

| # | Gap | Soluzione |
|---|-----|-----------|
| N1 | Slides di supporto | HTML/JS presentation (Reveal.js o simile) |
| N2 | Certificate/badge di completamento | Generato dallo script scan |
| N3 | Cheat sheet stampabile | A4 con i 3 assi + checklist |

---

## 🏗️ Architettura Proposal per Workshop

```
agent-ready-workshop/
├── README.md                    # Setup instructions
├── WORKSHOP.md                  # Guida step-by-step
├── skills/                      # [ESISTENTI] Le 5 skills attuali
│   ├── agent-ready/
│   ├── agent-ready-scan/
│   ├── agent-ready-fix/
│   ├── agent-ready-report/
│   └── agent-ready-diff/
├── scripts/                     # [NUOVO] Tooling workshop
│   ├── scan_static.py           # Scanner deterministico Python
│   ├── visualize.py             # Genera HTML report interattivo
│   └── workshop_setup.py        # Check prerequisiti
├── guinea-pig/                  # [NUOVO] Repo cavia
│   ├── 00-baseline/             # Branch: repo "non ready"
│   ├── 01-instruct-fixed/       # Branch: axis 1 migliorato
│   ├── 02-navigate-fixed/       # Branch: axis 2 migliorato
│   └── 03-optimized/            # Branch: fully optimized
├── slides/                      # [NUOVO] Presentazione
│   └── index.html               # Reveal.js o custom
└── www/                         # [NUOVO] Spiegazione visuale
    ├── three-axis-model.html    # Visualizzazione interattiva del modello
    └── how-agents-read.html     # Animazione: come un agent legge un repo
```

---

## ⚠️ Rischi Identificati

| Rischio | Probabilità | Impatto | Mitigazione |
|---------|-------------|---------|-------------|
| Setup Claude Code fallisce per qualcuno | Media | Alto | Prep-guide inviata 1 settimana prima + slot troubleshooting inizio |
| Scan LLM dà risultati inconsistenti | Alta | Medio | Scanner statico come baseline oggettiva |
| 2 ore non bastano per hands-on completo | Media | Medio | Designare con "escape hatches" — se si è in ritardo, saltare diff |
| Repo cavia troppo complesso/simple | Bassa | Medio | Testare con 3 repo diversi prima dell'evento |
| Domande tecniche profonde rallentano | Media | Basso | Q&A alla fine, non durante gli exercizi |

---

*Prossimo passo: Fase 2 — Competitive Deep Dive*
