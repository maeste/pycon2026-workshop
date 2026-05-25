# Fase 2: Competitive Analysis — Agent Readiness Landscape

## 🎯 Obiettivo
Capire cosa esiste, cosa fanno meglio di noi, cosa possiamo imparare/integrare.

---

## 1. Factory.ai Agent Readiness (Il Pioneer)

### Panoramica
- **Tipo**: SaaS proprietario (token-based billing)
- **Data lancio**: Gennaio 2026
- **Pillars**: **8 categorie** (non "pillars" nel senso tradizionale)
- **Maturity Levels**: 5 (Functional → Documented → Standardized → Optimized → Autonomous)
- **Approccio**: Cloud-only, richiede Droid CLI

### Gli 8 Pillars Factory

| # | Pillar | Descrizione |
|---|--------|-------------|
| 1 | **Style & Validation** | Linter, formatter, type checker, code style |
| 2 | **Build System** | Build reproducibile, dependency management |
| 3 | **Testing** | Test suite, coverage, E2E, quality |
| 4 | **Documentation** | README, API docs, AGENTS.md, architecture |
| 5 | **Dev Environment** | Devcontainer, setup scripts, environment docs |
| 6 | **Debugging & Observability** | Logging, tracing, monitoring, error tracking |
| 7 | **Security** | Secret scanning, dependency audit, security policies |
| 8 | **Task Discovery** | Issue templates, PRD, specs, experiment tracking |

### I 5 Maturity Levels (con gate 80%)

| Level | Nome | Cosa richiede |
|-------|------|---------------|
| L1 | Functional | README, linter, type checker, unit tests |
| L2 | Documented | AGENTS.md, devcontainer, pre-commit hooks, branch protection |
| L3 | Standardized | Integration tests, secret scanning, distributed tracing, metrics |
| L4 | Optimized | Fast CI feedback, deploy frequency, flaky test detection |
| L5 | Autonomous | Self-improving systems, auto-decomposition of requirements |

### Punti di Forza vs Noi
✅ **Debugging & Observability** pillar — noi non abbiamo questo (interessante da aggiungere)
✅ **Task Discovery** come categoria separata — noi lo abbiamo dentro Spec-Driven (10%)
✅ **Maturity levels con gate 80%** — progressione chiara, nostra è solo score-based
✅ **Dashboard enterprise** — trend storici, multi-repo
✅ **Scope distinction**: Repository vs Application (importante per monorepo)

### Punti Deboli vs Noi
❌ Proprietario, cloud-only, costoso
❌ Vendor lock-in (solo Factory Droids)
❌ Nessun fix/remediation automatico (coming soon)
❌ Non agent-agnostic

---

## 2. Kodus/kodustech agent-readiness (L'OSS Challenger)

### Panoramica
- **Tipo**: OSS CLI (MIT License), **completamente gratuito**
- **Command**: `npx @kodus/agent-readiness .` o `bunx @kodus/agent-readiness .`
- **Checks**: **39 automated checks deterministici**
- **Pillars**: **7 pillars**
- **Maturity Levels**: 5 (Foundational → Guided → Structured → Optimized → Autonomous)
- **Languages**: 10+ (Node, Python, Go, Rust, Java, Kotlin, C#, Ruby, PHP, Swift)

### I 7 Pillars Kodus

| # | Pillar | # Checks | Mappa alle nostre dimensioni |
|---|--------|----------|---------------------------|
| 🎨 | **Style & Linting** | 6 | Parziale: nostro CI/CD (12) + Instructions (20) |
| 🧪 | **Testing** | 6 | ≈ Testing & Validation (16) |
| 📚 | **Documentation** | 8 | Spacca su: Navigability (18) + Docs (8) + Instructions (20) |
| 🔧 | **Dev Environment** | 5 | Parziale: Navigability (18) — lock files, env, container |
| ⚙️ | **CI/CD** | 6 | ≈ CI/CD & Automation (12) |
| 💚 | **Code Health** | 3 | ❌ **Noi non abbiamo** (dead code, outdated deps, bundle) |
| 🔒 | **Security** | 5 | ❌ **Noi non abbiamo** (secrets, licenses, scanning) |

### I 5 Maturity Levels Kodus (80% gate)

| Level | Nome | Descrizione |
|-------|------|-------------|
| L1 | Foundational | README, license, lock file, editorconfig |
| L2 | Guided | Linters, formatters, test framework, CI basics |
| L3 | Structured | Type checking, pre-commit hooks, security policies, containerization |
| L4 | Optimized | Coverage reporting, E2E tests, deploy pipelines, security scanning |
| L5 | Autonomous | AI context files, architecture docs, naming conventions, bundle analysis |

### Feature Uniche Kodus
- ✅ **Web dashboard interattivo** (radar charts!) — genera HTML locale
- ✅ **AI-powered mode** (`--ai`) per analisi più profonda
- ✅ **CI/CD gate** (`--ci --min-level 3`) — exit code per pipeline
- ✅ **JSON output** per integrazioni
- ✅ **Monorepo detection** (npm workspaces, Lerna, Nx, Turborepo)
- ✅ **Configurabile** via `.kodus-readiness.yml`

### Punti di Forza vs Noi
✅ **39 checks AUTOMATICI e DETERMINISTICI** — questo è il killer feature
✅ **Zero dipendenza da LLM** — funziona ovunque, sempre
✅ **Web dashboard built-in** — visualizzazione immediata
✅ **CI-ready** — può essere usato in pipeline
✅ **Monorepo-aware**

### Punti Deboli vs Noi
❌ Superficiale nei giudizi (check binari, no nuanced scoring 0-100)
❌ Nessuna capacità di **fix/generare file**
❌ Nessun **diff/delta** tra scan
❌ Nessun concetto di **layer agnostic vs specific**
❌ Documentation pillar è un mix confuso di cose diverse

---

## 3. ACMM — AI Codebase Maturity Model (OpenSSF)

### Panoramica
- **Tipo**: OSS Dashboard (console.kubestellar.io/acmm)
- **Contesto**: Proposal per OpenSSF scorecard integration
- **Levels**: 5 levels
- **Focus**: GitHub repository readiness for AI-assisted engineering

### Note
- Molto nuovo (Aprile 2026), ancora in proposal stage
- Focus su integrazione con OpenSSF security scorecard
- Meno maturo dei precedenti, ma interessante per il legame security + AI readiness

---

## 4. jpequegn/agent-readiness-score

### Panoramica
- **Tipo**: OSS Framework (Python-based)
- **Ispirazione**: Factory.ai methodology
- **Approccio**: Score basato su check statici
- **Stato**: Early stage, meno features

---

## 📊 Matrice Competitiva Comparativa

| Caratteristica | **Nostro Repo** | **Factory.ai** | **Kodus** | **ACMM** |
|----------------|:--------------:|:-------------:|:--------:|:--------:|
| **Tipo** | Agent Skills | SaaS | CLI OSS | Dashboard |
| **Costo** | Free (req CC) | 💰💰💰 | Free | Free |
| **Deterministico** | ❌ LLM-based | ❌ LLM-based | ✅ **Static** | ✅ Static |
| **Auto-fix** | ✅ | Planned | ❌ | ❌ |
| **Delta/Diff** | ✅ | ❌ | ❌ | ❌ |
| **Visual** | ❌ | ✅ Dashboard | ✅ Web chart | ✅ Dashboard |
| **CI-ready** | ❌ | ✅ API | ✅ `--ci` | ❌ |
| **Agent-agnostic** | ✅ (parz.) | ❌ | ✅ | ✅ |
| **Dimensions/Pillars** | 8 (2 layers) | 8 | 7 | ~5 |
| **Granularity scoring** | ✅ 0-100 | Level-based | Binary/check | Level-based |
| **Maturity levels** | ❌ (solo range) | ✅ 5 (80% gate) | ✅ 5 (80% gate) | ✅ 5 |
| **Multi-language** | ✅ (LLM judge) | Limited | ✅ 10+ | GitHub-based |
| **Security pillar** | ❌ | ✅ | ✅ | ✅ (OpenSSF) |
| **Code Health pillar** | ❌ | ❌ | ✅ | ❌ |
| **Observability** | ❌ | ✅ | ❌ | ❌ |

---

## 🔑 Elementi da "Rubare" (Integrare)

### DA KODUS (Priorità Alta)

1. **Scanner statico deterministico** → Il nostro `scan_static.py`
   - Check file existence, config parsing, count test files
   - Output JSON compatibile con nostro schema
   - Base oggettiva prima del judgment LLM

2. **Web dashboard locale** → Il nostro `visualize.py`
   - Radar chart 3-axis + breakdown 8 dimensions
   - Genera HTML standalone (nessuna dipendenza server)
   - Confronto before/after side-by-side

3. **CI mode** → `--ci` flag per il nostro scanner
   - Exit code non-zero se sotto threshold
   - Usabile in GitHub Actions

4. **Maturity levels con 80% gate** → Aggiungere al nostro modello
   - Oltre allo score 0-100, assegna level 1-5
   - Progressione significativa: "sei passato da L2 a L3!"

### DA FACTORY (Priorità Media)

5. **Debugging & Observability pillar** → Nuova dimensione 9 (o integrare in Validate axis)
   - Logging structure, error handling patterns
   - Monitoring integration, health checks

6. **Scope distinction** (Repo vs App) → Per monorepo support
   - Utile ma maybe overkill per workshop v1

7. **Task Discovery separato** → Ampliare Spec-Driven Workflow
   - Issue templates, PRD structure, experiment tracking

---

## 🎯 Posizionamento Unico del Nostro Workshop

Dopo l'analisi, ecco dove stiamo **davvero** rispetto ai competitor:

```
                    DETERMINISTICO          LLM-BASED
                   ┌─────────────────┬─────────────────┐
                   │                 │                 │
    CI/PIPELINE    │   Kodus         │                 │
    FOCUS          │   (39 checks)   │                 │
                   │                 │                 │
    WORKSHOP       │   [NOI] ◄──────┼──► [NOI]        │
    /EDUCATIONAL   │   scan_static   │   skills LLM    │
                   │                 │                 │
    ENTERPRISE     │                 │   Factory.ai    │
    DASHBOARD      │   ACMM          │   (8 pillars)   │
                   │                 │                 │
                   └─────────────────┴─────────────────┘
```

**Il nostro vantaggio competitivo per il workshop**: siamo **l'unico che combina entrambi**.
- Layer statico (come Kodus) = baseline oggettiva, dimostrabile, ripetibile
- Layer LLM (nostro USP) = analisi semantica profonda, contestuale, generativa
- Fix automation = nessuno lo fa (tranne Factory "coming soon")
- Delta tracking = unico

Questo è lo **storytelling del workshop**:
> "Agent readiness ha due layer: ciò che uno script può vedere (statico) e ciò che solo un agent può comprendere (semantico). Il migliore tooling usa entrambi."

---

*Prossimo passo: Fase 3 — Struttura Workshop (sequenza e timing)*
