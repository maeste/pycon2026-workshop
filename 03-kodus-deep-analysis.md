# Fase 2b: Deep Dive — Kodus (kodustech/agent-readiness)

## 🎯 Obiettivo
Analisi completa della codebase Kodus per identificare elementi integrabili in due contesti:
- **Set A**: Workshop PyCon (5 giorni di prep, deve funzionare live)
- **Set B**: Progetto post-workshop (nessun vincolo temporale)

---

## 1. Architettura Kodus — Mappatura Completa

### Stack Tecnologico
```
Language:    TypeScript (ESM)
Runtime:     Bun (Node.js compatibile)
CLI:         Commander.js
Web UI:      React + Vite + Tailwind + Recharts (radar chart)
Engine:      Custom pipeline (detector → analyzer → scorer → recommender)
LLM:         OpenAI API (optional, --ai flag)
Output:      Terminal (chalk) + JSON + Web Dashboard
Install:     bunx kodus-agent-readiness | npx
```

### Pipeline di Esecuzione
```
detectProject()          ← Rileva tipo linguaggio + monorepo
       ↓
AnalysisEngine.run()    ← Esegue tutti i 7 pillar in parallelo
       ↓
calculatePillarScores() ← % passed/total per pillar
       ↓
calculateLevel()        ← Livello maturità 1-5 (gate 80%)
       ↓
generateRecommendations() ← Top 10 failed, sorted by impact/effort
       ↓
renderReport() OR startServer()  ← Terminal o Web Dashboard
```

---

## 2. I 7 Pillar e 39 Checks — Elenco Completo

### 🎨 Pillar 1: Style & Linting (6 checks)

| ID | Nome | Level | LLM? | Cosa Controlla |
|----|------|-------|------|----------------|
| `editorconfig` | EditorConfig present | 1 | ❌ | `.editorconfig` esiste |
| `linter` | Linter configured | 2 | ❌ | ESLint, Biome, Ruff, golangci-lint, detekt, etc. (15+ tool supportati) |
| `formatter` | Formatter configured | 2 | ❌ | Prettier, Biome, Black, gofmt, rustfmt, etc. |
| `type-checker` | Type checker configured | 3 | ❌ | TS strict, mypy, pyright (auto-pass per linguaggi statici) |
| `pre-commit-hooks` | Pre-commit hooks | 3 | ❌ | Husky, Lefthook, pre-commit, lint-staged |
| `naming-conventions` | Naming conventions | 5 | ✅ | **LLM**: valuta coerenza naming in file e codice |

### 🧪 Pillar 2: Testing (6 checks)

| ID | Nome | Level | LLM? | Cosa Controlla |
|----|------|-------|------|----------------|
| `test-framework` | Test framework | 2 | ❌ | Jest, Vitest, pytest, Go test, JUnit, Kotest, etc. |
| `test-files-exist` | Test files exist | 2 | ❌ | Glob per *.test.*, *_test.go, *Test.kt, etc. |
| `test-script` | Test script defined | 2 | ❌ | npm test, Makefile test, gradlew test, cargo test, etc. |
| `coverage-config` | Coverage configured | 4 | ❌ | .coveragerc, Jest coverage, JaCoCo, tarpaulin |
| `e2e-tests` | E2E tests | 5 | ✅ | **LLM**: cerca Playwright, Cypress, E2E patterns |
| `test-quality` | Test quality | 5 | ✅ | **LLM**: valuta qualità test (nomi, edge cases, behavior vs impl) |

### 📚 Pillar 3: Documentation (8 checks)

| ID | Nome | Level | LLM? | Cosa Controlla |
|----|------|-------|------|----------------|
| `readme` | README with substance | 1 | ❌ | README.md esiste con >500 char |
| `contributing` | Contributing guide | 2 | ❌ | CONTRIBUTING.md o docs/contributing* |
| `api-docs` | API documentation | 3 | ❌ | OpenAPI, JSDoc, TypeDoc, docs/api |
| `codeowners` | CODEOWNERS | 3 | ❌ | CODEOWNERS file |
| `ai-context` | AI context files | 3 | ❌ | CLAUDE.md, .cursorrules, copilot-instructions.md |
| `architecture-docs` | Architecture docs | 4 | ❌ | ARCHITECTURE.md, docs/architecture, docs/adr |
| `readme-quality` | README quality | 5 | ✅ | **LLM**: valuta completezza README |
| `docs-agent-friendliness` | Docs agent-friendliness | 5 | ✅ | **LLM**: valuta utilità docs per agenti |

### 🔧 Pillar 4: Dev Environment (5 checks)

| ID | Nome | Level | LLM? | Cosa Controlla |
|----|------|-------|------|----------------|
| `lock-file` | Lock file present | 1 | ❌ | package-lock.json, yarn.lock, poetry.lock, go.sum, etc. |
| `env-documentation` | Env vars documented | 2 | ❌ | .env.example, .env.template |
| `setup-script` | Setup script | 2 | ❌ | Makefile setup, scripts/setup, dev command |
| `version-pinned` | Runtime version pinned | 2 | ❌ | .nvmrc, .python-version, go.mod, etc. |
| `containerization` | Containerization | 3 | ❌ | Dockerfile, docker-compose, .devcontainer |

### ⚙️ Pillar 5: CI/CD (6 checks)

| ID | Nome | Level | LLM? | Cosa Controlla |
|----|------|-------|------|----------------|
| `ci-config` | CI configuration | 2 | ❌ | GitHub Actions, GitLab CI, CircleCI, Jenkins, Travis |
| `ci-runs-tests` | CI runs tests | 3 | ❌ | Cerca pattern test nei workflow YAML |
| `ci-runs-linters` | CI runs linters | 3 | ❌ | Cerca pattern lint nei workflow YAML |
| `build-automated` | Build automated | 3 | ❌ | build script, CI build step, Makefile build |
| `deploy-pipeline` | Deploy pipeline | 4 | ❌ | deploy stage, Vercel/Netlify/Fly config, Terraform |
| `branch-protection` | Branch protection | 4 | ❌ | .github/settings, CONTRIBUTING mentions |

### 💚 Pillar 6: Code Health (3 checks)

| ID | Nome | Level | LLM? | Cosa Controlla |
|----|------|-------|------|----------------|
| `no-outdated-deps` | Deps recently updated | 3 | ❌ | Lock file modificato < 6 mesi fa |
| `dead-code-detection` | Dead code detection | 4 | ❌ | knip, vulture, detekt UnusedPrivateMember, Roslynator |
| `bundle-analysis` | Bundle analysis | 5 | ❌ | webpack-bundle-analyzer, size-limit |

### 🔒 Pillar 7: Security (5 checks)

| ID | Nome | Level | LLM? | Cosa Controlla |
|----|------|-------|------|----------------|
| `license` | License file | 1 | ❌ | LICENSE, LICENSE.md, LICENCE |
| `security-policy` | SECURITY.md | 3 | ❌ | SECURITY.md o .github/SECURITY.md |
| `dep-update-automation` | Dependabot/Renovate | 3 | ❌ | .github/dependabot.yml, renovate.json |
| `secrets-detection` | Secrets detection | 4 | ❌ | Gitleaks, detect-secrets, trufflehog in CI/pre-commit |
| `security-scanning` | Security scanning in CI | 4 | ❌ | CodeQL, Snyk, Trivy, Semgrep, OWASP |

### Totale: **39 checks** (33 statici + 6 LLM-powered)

---

## 3. Sistema di Maturità — Il Modello a 5 Livelli

```
Level 1: FOUNDATIONAL   "Il progetto esiste"
  ├── EditorConfig, README, Lock file, License
  
Level 2: GUIDED        "C'è una guida"  
  ├── Linter, Formatter, Test framework, Test files, Test script
  ├── Contributing guide, Env docs, Setup script, Version pinning
  ├── CI config
  
Level 3: STRUCTURED    "Tutto è automatizzato"
  ├── Type checker, Pre-commit hooks, Containerization
  ├── API docs, Codeowners, AI context files
  ├── CI runs tests+linters, Build automated
  ├── Security policy, Dep update automation
  ├── Deps updated < 6 mesi
  
Level 4: OPTIMIZED     "Qualità misurabile"
  ├── Coverage configured, Dead code detection
  ├── Architecture docs, Deploy pipeline, Branch protection
  ├── Secrets detection, Security scanning in CI
  
Level 5: AUTONOMOUS    "Un agente può lavorare da solo"
  ├── E2E tests (LLM), Bundle analysis
  ├── Naming conventions (LLM), Test quality (LLM)
  ├── README quality (LLM), Docs agent-friendliness (LLM)
```

**Regola del gate**: ≥80% dei criteria di un livello devono passare per avanzare.
I livelli sono **sequenziali**: non puoi essere Level 5 senza aver passato 1-4.

---

## 4. Motore di Recommender — Effort/Impact Matrix

Ogni criterio fallito genera una raccomandazione con:

```typescript
{
  title: string           // Nome human-readable
  description: string    // Cosa fare
  reason: string         // PERCHÉ importa (agent-focused!)
  effort: "low" | "medium" | "high"
  impact: "high" | "medium" | "low"  // Basato sulla distanza dal livello corrente
  pillarId: string
  criterionId: string
}
```

**Ordinamento intelligente**:
1. Criteria del **prossimo livello** prima (priorità assoluta)
2. Poi per **impact** decrescente (high → medium → low)
3. Poi per **effort** crescente (low → medium → high) — quick wins prima
4. Max **10 raccomandazioni** output (non overwhelm)

**Esempio reasoning agent-focused**:
> *"Auto-formatting removes style debates and lets agents produce consistently formatted code without guesswork"*
> *"A good README helps agents understand the project context, conventions, and how to get started quickly"*

Questo è **oro puro** per il nostro storytelling — ogni raccomandazione è già collegata al value proposition degli agenti AI.

---

## 5. Visualizzazione — Web Dashboard

### Componenti React
```
Dashboard (layout principale)
├── Header                    (repo name, level badge, timestamp)
├── OverallProgress           (barra di progresso livello corrente → prossimo)
├── [Grid 2 colonne]
│   ├── RadarChart            (Recharts: 7 axis radar, 0-100%)
│   └── PillarSummaryBars     (barre orizzontali per pillar con colori)
├── Detailed Breakdown        (grid card per pillar con check pass/fail)
├── RecommendationList        (lista ordinata effort/impact)
└── Footer                   (powered by Kodus)
```

### Color Coding
- **≥80%**: `.bg-pass` (verde)
- **≥50%**: `.bg-accent` (giallo/arancione)
- **<50%**: `.bg-fail` (rosso)

### Radar Chart Tech
- **Libreria**: Recharts (`RadarChart`, `PolarGrid`, `PolarAngleAxis`)
- **Data shape**: `[{pillar: string, score: number, fullMark: 100}]`
- **Style**: Dark theme (`#1a1a25` bg, `#f59e0b` accent)
- **Responsive**: `ResponsiveContainer width="100%" height={300}`

---

## 6. LLM Client — Design Pattern

```typescript
// OpenAI-compatible, structured output (JSON mode)
interface LLMClient {
  evaluate(prompt: string, context: string): Promise<{
    pass: boolean;
    message: string;
    details?: string;
  }>
}
```

- **Model default**: `gpt-5-mini`
- **API**: OpenAI-compatible (`/chat/completions`)
- **Response format**: `{ type: "json_object" }` (forced JSON)
- **System prompt**: Valuta se il repository soddisfa un criterio specifico
- **Fallback**: Se LLM fallisce → `{pass: false, message: "error"}`
- **Attivazione**: Solo con `--ai` flag + API key

---

## 7. Config System

```yaml
# .kodus-readiness.yml
pillars:
  style-linting: true
  testing: true
  documentation: true
  # ... disabilita pillar interi

criteria:
  linter: true
  bundle-analysis: false  # disabilita singoli criteria

thresholds:
  # custom thresholds per criterion

aiEnabled: false
apiKey: ""
apiBaseUrl: ""
```

Generato con `--init`, caricato automaticamente.

---

## SET A: Integrazioni per il WORKSHOP

### Criterio di selezione: Deve essere implementabile in ≤200 righe Python, testabile in 2h live, zero dipendenze complesse.

#### A1. 🏆 Scanner Statico Ispirato ai 33 Check Deterministici ⭐⭐⭐

**Cosa prendere**: La logica dei check file-existence-based di Kodus, adattata al nostro modello 3-axis.

**Perché**: Il nostro repo ha solo scoring LLM (non-deterministico). Per un workshop live dove 30 persone scannerizzano contemporaneamente, abbiamo bisogno di qualcosa che:
- Funzioni **senza API key**
- Dia risultati **deterministici** (stesso repo = stesso risultato)
- Sia **veloce** (< 5 secondi)

**Implementazione proposta**: `scripts/scan_static.py`
```python
# Struttura semplificata per workshop (15-20 check invece di 33)
CHECKS = {
    # AXIS 1: INSTRUCT (~38%)
    "agent_instructions": {"files": ["CLAUDE.md", ".cursorrules"], "weight": 20},
    "readme": {"files": ["README.md"], "min_chars": 500, "weight": 8},
    "contributing": {"files": ["CONTRIBUTING.md"], "weight": 0},  # bonus
    
    # AXIS 2: NAVIGATE (~30%)
    "editorconfig": {".editorconfig": True, "weight": 2},
    "linter": {"files": [".ruff.toml", "ruff.toml", "pyproject.toml"], "check_content": "[tool.ruff]", "weight": 4},
    "formatter": {"files": ["pyproject.toml"], "check_content": "[tool.black]|[tool.ruff.format]", "weight": 4},
    "type_checker": {"files": ["pyrightconfig.json", "mypy.ini", ".mypy.ini"], "weight": 4},
    
    # AXIS 3: VALIDATE (~28%)
    "test_framework": {"files": ["pytest.ini", "conftest.py", "pyproject.toml"], "check_content": "[tool.pytest]", "weight": 6},
    "test_files": {"glob": ["tests/**/*.py", "test_*.py", "*_test.py"], "min_count": 3, "weight": 5},
    "ci_config": {"files": [".github/workflows/*.yml", ".gitlab-ci.yml"], "weight": 4},
    "lock_file": {"files": ["poetry.lock", "Pipfile.lock", "uv.lock"], "weight": 2},
}
```

**Sforzo stimato**: ~150 righe Python stdlib + `pathlib` + `tomllib` (Python 3.11+)
**Dipendenze**: ZERO (solo stdlib)
**Tempo di implementazione**: 2-3 ore

---

#### A2. 📊 Radar Chart HTML/JS Standalone ⭐⭐⭐

**Cosa prendere**: Il design del RadarChart di Kodus, riscritto come single-file HTML/JS.

**Perché**: Visualizzazione immediata del Three-Axis Model. I partecipanti aprono un file HTML locale e vedono il loro score.

**Implementazione proposta**: `templates/radar.html`
- **Libreria**: Chart.js (CDN) invece di Recharts (zero build step)
- **3 axis** invece di 7 (Instruct / Navigate / Validate)
- **Color scheme**: Adatto a proiezione (dark theme come Kodus)
- **Interattività**: Hover per vedere dettagli per axis
- **Input**: JSON generato da `scan_static.py`

**Sforzo stimato**: ~120 righe HTML + ~60 righe JS
**Dipendenze**: Chart.js da CDN (offline-friendly con bundle locale)

---

#### A3. 🎯 Maturity Level Badge System ⭐⭐

**Cosa prendere**: Il concetto dei 5 livelli sequenziali con gate 80%.

**Perché**: Dà un goal tangibile ai partecipanti. Invece di "ho fatto 67 punti", dico "sono Level 2: Guided".

**Mapping proposto** (nostro 3-axis → 5 livelli):
```
Level 1: FOUNDATIONAL  (≥40% totale)   "L'agent trova i file base"
Level 2: GUIDED       (≥55% totale)   "L'agent segue le istruzioni"
Level 3: STRUCTURED   (≥70% totale)   "L'agent naviga autonomamente"
Level 4: OPTIMIZED    (≥85% totale)   "L'agent valida il suo lavoro"
Level 5: AUTONOMOUS   (≥95% totale)   "L'agent è un team member"
```

**Implementazione**: Semplice funzione Python nel scanner + badge nel report.

**Sforzo stimato**: ~30 righe

---

#### A4. 📋 Effort/Impact Recommender (Semplificato) ⭐⭐

**Cosa prendere**: Il pattern delle raccomandazioni ordinate per effort/impact.

**Perché**: Dopo lo scan, i partecipanti vogliono sapere "cosa faccio prima?".

**Implementazione proposta**: Lista pre-definita di top-5 improvements per axis:
```python
RECOMMENDATIONS = [
    ("Aggiungi CLAUDE.md", "axis_instruct", "low", "high"),
    ("Configura Ruff", "axis_navigate", "low", "high"),  
    ("Aggiungi 3 test pytest", "axis_validate", "medium", "high"),
    ("Crea .github/workflows/ci.yml", "axis_validate", "medium", "medium"),
    ("Aggiungi CONTRIBUTING.md", "axis_instruct", "low", "medium"),
]
```

**Sforzo stimato**: ~40 righe

---

### Riassunto Set A — Workshop

| Elemento | Righe Python | Ore | Dipendenze | Priorità |
|----------|-------------|-----|------------|----------|
| A1. Scan statico | ~150 | 2-3 | stdlib | **Must have** |
| A2. Radar chart HTML | ~180 | 2-3 | Chart.js CDN | **Must have** |
| A3. Maturity badges | ~30 | 0.5 | nessuna | Nice to have |
| A4. Recommender | ~40 | 1 | nessuna | Nice to have |
| **Totale** | **~400** | **~6-8** | | |

---

## SET B: Integrazioni per PROGETTO POST-WORKSHOP

### Criterio di selezione: Massima potenza, niente rush, qualità production-grade.

#### B1. 🚀 Porting Completo dei 39 Checks in Python ⭐⭐⭐

**Cosa prendere**: TUTTI i 39 checks, riscritti in Python con architettura plugin-based.

**Perché**: Diventa il **scanner più completo** per agent readiness nell'ecosistema Python. Nessuno ha sia i 39 checks deterministici CHE l'analisi LLM semantica.

**Architettura proposta**:
```
agent_ready/
├── __init__.py
├── checker.py           # Engine principale (ispirato a AnalysisEngine)
├── detectors/
│   ├── __init__.py
│   ├── project_type.py  # Porting di detectProject()
│   └── monorepo.py      # Porting di detectMonorepo()
├── pillars/
│   ├── __init__.py
│   ├── base.py          # Pillar + Criterion dataclasses
│   ├── style_linting.py # 6 checks (Python-focused)
│   ├── testing.py       # 6 checks
│   ├── documentation.py # 8 checks
│   ├── dev_environment.py # 5 checks
│   ├── ci_cd.py         # 6 checks
│   ├── code_health.py   # 3 checks
│   └── security.py      # 5 checks
├── scorer.py            # Porting di calculatePillarScores + calculateLevel
├── recommender.py       # Porting di generateRecommendations
├── llm_client.py        # OpenAI-compatible client (6 LLM checks)
├── config.py            # YAML config (.agent-ready.yml)
└── cli.py               # Click/Typer CLI
```

**Differenza vs Kodus**:
- Kodus è universal-language → noi siamo **Python-first** (più profondo sui check Python-specific)
- Kodus ha 6 LLM checks → noi ne abbiamo **8 dimensioni LLM** (già nel repo)
- Noi aggiungiamo **auto-fix** e **diff tracking** (Kodus non ha)

**Sforzo stimato**: ~2000-2500 righe Python
**Dipendenze**: `click`, `pyyaml`, `rich` (terminal beauty), `openai` (opzionale)
**Tempo di implementazione**: 1-2 settimane

---

#### B2. 🖥️ Web Dashboard Full Feature ⭐⭐

**Cosa prendere**: L'intero dashboard React di Kodus, riscritto.

**Opzione A**: **Port in Python** (FastAPI + HTMX/Jinja2)
- Pro: Stesso linguaggio del progetto, facile da mantenere
- Contro: Meno interattivo lato client

**Opzione B**: **Keep React/TypeScript** ma come submodule/separato
- Pro: UX migliore, animazioni, reattività
- Contro: Due linguaggi, build step

**Opzione C** (raccomandata): **Single-page vanilla JS** (Alpine.js o Pet Micro-Framework)
- Zero build step
- Dashboard completa con radar chart + barre + recommendations
- Possibile servire da uno script Python static server

**Feature da includere**:
- Radar chart 3-axis (noi) + 7-pillar (Kodus) toggle
- Timeline di progresso (prima/dopo fix)
- Export PNG/SVG per slides
- Comparison mode (repo A vs repo B)

**Sforzo stimato**: ~800-1200 righe (HTML+JS+CSS)

---

#### B3. 🔗 CI Integration Mode ⭐⭐

**Cosa prendere**: `--ci --min-level N` che exit-code 1 se sotto soglia.

**Perché**: Questo trasforma il tool da "workshop toy" a **production DevOps tool**.

**Implementazione**:
```yaml
# .github/workflows/agent-ready.yml
name: Agent Readiness Check
on: [push, pull_request]
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: pip install agent-ready
      - run: agent-ready scan --ci --min-level 2 --format json > report.json
      - uses: actions/upload-artifact@v4
        with:
          name: agent-ready-report
          path: report.json
      - run: agent-ready scan --ci --min-level 3  # Fail PR se < Level 3
```

**Sforzo stimato**: ~50 righe (CLI flag + exit code logic)

---

#### B4. 📦 Config System + Custom Profiles ⭐

**Cosa prendere**: `.kodus-readiness.yml` → `.agent-ready.yml` con profiles.

**Perché**: Team diversi hanno standard diversi. Una startup non ha gli stessi requisiti di un'enterprise.

**Profiles proposti**:
```yaml
# .agent-ready.yml
profile: "strict"  # | "standard" | "lenient" | "custom"

profiles:
  strict:
    min_level: 4
    require_ai_context: true
    require_tests: true
    min_coverage: 80
  standard:
    min_level: 3
    require_ai_context: true
    require_tests: false
  lenient:
    min_level: 2
    require_ai_context: false
    require_tests: false
custom:
  pillars:
    security: false  # Disabilita pillar interi
  criteria:
    bundle-analysis: false  # Disabilita singoli criteria
  weights:
    testing: 1.5  # Overweight testing
    documentation: 0.5  # Underweight docs
```

**Sforzo stimato**: ~150 righe (config loader + profile resolver)

---

#### B5. 🔄 Delta Tracking + History ⭐⭐

**Cosa prendere**: Estendere il nostro `agent-ready-diff` con history persistente.

**Perché**: "Siamo migliorati dall'ultimo mese?" è la domanda che i team si pongono.

**Implementazione**:
```bash
agent-ready scan --save          # Salva .agent-ready/snapshots/YYYY-MM-DD.json
agent-ready history              # Tabella trend
agent-ready diff HEAD~1..HEAD    # Confronto tra commit
agent-ready trend --chart        # Genera HTML con trend line chart
```

**Storage**: `.agent-ready/snapshots/` gitignored (o committed per public dashboards)

**Sforzo stimato**: ~300 righe

---

#### B6. 🤝 Hybrid Mode: Static + LLM Combined Score ⭐⭐⭐

**Cosa prendere**: Il meglio dei due mondi — Kodus (deterministico) + nostro repo (semantico).

**Perché**: Questo è il **killer feature** che nessuno ha.

**Formula proposta**:
```
FinalScore(axis) = α × StaticScore + β × LLMScore

Dove:
  α = 0.6 (peso deterministico — "fatti, non opinioni")
  β = 0.4 (peso semantico — "qualità, non presenza")
  
Ogni axis ha score separati:
  Axis INSTRUCT:  static=60% (file exist) + llm=45% (quality) → final = 51%
  Axis NAVIGATE:  static=75% + llm=60% → final = 69%
  Axis VALIDATE: static=30% + llm=50% → final = 38%
```

**Output combinato**:
```
╭─────────────────────────────────────────────╮
│  AGENT READINESS REPORT                     │
│  ═════════════════════════════════════════  │
│                                             │
│  Overall: 53%  │  Level 2: GUIDED          │
│                                             │
│  ┌─────────────┬────────┬────────┬────────┐ │
│  │ Axis        │ Static │  LLM   │ Final  │ │
│  ├─────────────┼────────┼────────┼────────┤ │
│  │ 📝 INSTRUCT │   60%  │   45%  │   51%  │ │
│  │ 🧭 NAVIGATE │   75%  │   60%  │   69%  │ │
│  │ ✅ VALIDATE │   30%  │   50%  │   38%  │ │
│  └─────────────┴────────┴────────┴────────┘ │
│                                             │
│  Top 3 Quick Wins:                          │
│  1. +12% → Aggiungi CLAUDE.md (low effort)  │
│  2. +10% → Configura Ruff (low effort)      │
│  3. +15% → Aggiungi 3 test (med effort)     │
╰─────────────────────────────────────────────╯
```

**Sforzo stimato**: ~200 righe (combiner + formatter)

---

### Riassumo Set B — Post-Workshop

| Elemento | Righe | Settimane | Dipendenze | Priorità |
|----------|------|-----------|------------|----------|
| B1. 39 checks port | ~2500 | 1-2 | click, rich, openai | **Pillar** |
| B2. Web dashboard | ~1000 | 1 | fastapi o none | High |
| B3. CI integration | ~50 | 0.5 | none | **Must have** |
| B4. Config profiles | ~150 | 0.5 | pyyaml | High |
| B5. Delta/history | ~300 | 1 | none | Medium |
| B6. Hybrid scoring | ~200 | 0.5 | openai | **Killer feature** |
| **Totale** | **~4200** | **3-5** | | |

---

## 8. Mapping: Kodus 7 Pillars ↔ Nostro 3-Axis Model

Questa è la chiave di integrazione — come i 39 checks si mappano sul nostro modello:

```
KODUS 7 PILLARS                    →    NOSTRO 3 AXES
═══════════════════════════════════════════════════════════

🎨 Style & Linting (6 checks)     →    🧭 NAVIGATE (60%)
    editorconfig, linter, formatter, 
    type-checker, pre-commit, naming
    
📚 Documentation (8 checks)        →    📝 INSTRUCT (70%)
    readme, contributing, api-docs,
    codeowners, ai-context ★★★, 
    architecture-docs, readme-quality,
    docs-friendliness
    
🔧 Dev Environment (5 checks)      →    🧭 NAVIGATE (30%) + 📝 INSTRUCT (10%)
    lock-file, env-docs, setup-script,
    version-pinned, containerization
    
⚙️ CI/CD (6 checks)               →    ✅ VALIDATE (100%)
    ci-config, ci-tests, ci-linters,
    build, deploy, branch-protection
    
💚 Code Health (3 checks)          →    ✅ VALIDATE (40%) + 🧭 NAVIGATE (20%)
    deps-freshness, dead-code, bundle
    
🔒 Security (5 checks)            →    ✅ VALIDATE (30%)
    license, security-policy, dep-updates,
    secrets-detection, security-scanning
    
🧪 Testing (6 checks)             →    ✅ VALIDATE (60%)
    test-framework, test-files, test-script,
    coverage, e2e-tests, test-quality
```

**Insight chiave**: I nostri 3 axis sono una **semantic compression** dei 7 pillar di Kodus. Non perdiamo informazioni — le raggruppiamo per **domanda fondamentale**:

| Axis | Domanda | Copre Kodus Pillars |
|------|---------|---------------------|
| 📝 INSTRUCT | "L'agent capisce cosa vogliamo?" | Documentation + parte DevEnv |
| 🧭 NAVIGATE | "L'agent trova la strada?" | Style/Linting + parte DevEnv + parte CodeHealth |
| ✅ VALIDATE | "L'agent sa se ha fatto bene?" | CI/CD + Testing + Security + parte CodeHealth |

---

## 9. Cosa NON prendere da Kodus

| Elemento | Perché NO |
|----------|-----------|
| **Universal language support** | Noi siamo Python-focused (PyCon!) — supportare Go/Rust/Kotlin/C#/Ruby/etc. è overhead inutile |
| **Bun runtime** | Restiamo in ecosistema Python |
| **Recharts dependency** | Troppo pesante per un workshop — Chart.js o Canvas vanilla |
| **OpenAI-only LLM** | Noi supportiamo qualsiasi LLM via agent skill |
| **Flat pass/fail** | Il nostro modello 0-100 è più informativo del binario pass/fail |
| **Monorepo detection complessa** | Overkill per un primo workshop |

---

## 10. Verdetto Finale

### Kodus è il competitor OSS migliore perché:
1. ✅ **39 checks reali** (non teorici) — codice leggibile e ben strutturato
2. ✅ **Recommender agent-focused** — ogni reason collega alla value proposition AI
3. ✅ **Radar chart** — visualizzazione immediatamente comprensibile
4. ✅ **Maturity levels** — gamification implicita (vuoi salire di livello)
5. ✅ **CI-ready** — può vivere in pipeline
6. ✅ **MIT License** — possiamo fare quello che vogliamo

### Cosa Kodus NON ha (il nostro spazio):
1. 🚫 **Nessun auto-fix** → ce l'abbiamo (agent-ready-fix)
2. 🚫 **Nessun delta tracking** → ce l'abbiamo (agent-ready-diff)
3. 🚫 **Nessun scoring semantico** → ce l'abbiamo (8 dim LLM 0-100)
4. 🚫 **Nessun modello 3-axis** → nostra innovazione concettuale
5. 🚫 **Nessuna hybrid approach** → nostra killer feature futura

### Strategia consigliata:
> **Non competere con Kodus — completalo.**
> 
> Kodus = "c'è il file?" (statico, binario)
> Noi = "il file è buono?" (semantico, continuo)
> Insieme = "c'è il file ED è buono?" (completo, unico)
