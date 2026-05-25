# Phase 2: Competitive Analysis — The Agent Readiness Landscape

## Executive Summary

Agent readiness is a young but crowded space. As of mid-2026 it splits cleanly into two camps:
commercial SaaS dashboards (Factory.ai) and open-source CLI scanners (Kodus, jpequegn,
agent-next), with one OpenSSF-adjacent dashboard proposal (ACMM) sitting between them.
Every existing tool optimizes for the same job — "tell me whether a codebase is ready for
AI coding agents" — but they disagree on three axes: whether scoring should be deterministic
or LLM-driven, whether the output should be a number, a level, or a remediation plan, and
whether the tool itself should be agent-agnostic or vendor-locked. The `agent-ready-skill`
repo this workshop builds on is the only Agent-Skills-native entry (`claude-skill` format,
prompt-only, no runtime) in the field.

> **How this doc relates to the workshop**
> This is context, not a spec. It tells the coding agent which competitor moves the workshop
> tooling deliberately copies (deterministic file checks, maturity levels, radar visualization)
> and which it deliberately rejects (SaaS dashboards, vendor lock-in, monorepo detection),
> so that subsequent implementation tasks land in the right design frame.

---

## 1. Factory.ai Agent Readiness (the pioneer)

### Overview
- **Type**: Proprietary SaaS, token-based billing
- **Launched**: January 2026
- **Model**: 8 pillars, 5 maturity levels (Functional → Documented → Standardized → Optimized → Autonomous), 80% gate between levels
- **Delivery**: Cloud-only; requires Factory's Droid CLI

### Approach
Factory ships an opinionated, vendor-integrated assessment. Each of the 8 pillars
(Style & Validation, Build System, Testing, Documentation, Dev Environment, Debugging &
Observability, Security, Task Discovery) is scored against a 5-level maturity ladder.
Repositories must clear 80% of a level's criteria before progressing.

### What they do better
- ✅ **Debugging & Observability** as a first-class pillar — no other competitor covers logging, tracing, and error handling explicitly
- ✅ **Task Discovery** as a separate pillar (issue templates, PRDs, experiment tracking)
- ✅ **5-level maturity ladder with 80% gate** — clearer progression than pure score-based models
- ✅ **Enterprise dashboard** with historical trends and multi-repo views
- ✅ **Repository vs. Application scope** distinction — matters for monorepos

### What they miss
- ❌ Proprietary, cloud-only, and expensive
- ❌ Vendor lock-in to Factory's Droid runtime — not agent-agnostic
- ❌ No automated fix / remediation (marked "coming soon")
- ❌ Closed-source means the rubric cannot be audited or forked

### What we can borrow
- The 5-level maturity ladder concept and the 80% gate between levels
- The idea of separating Task Discovery from generic Documentation
- The Repository vs. Application distinction, parked as a post-workshop concern
- The Observability pillar as a candidate addition once the core rubric is stable

### Level summary (Factory)
| Level | Name | Representative criteria |
|---|---|---|
| L1 | Functional | README, linter, type checker, unit tests |
| L2 | Documented | AGENTS.md, devcontainer, pre-commit hooks, branch protection |
| L3 | Standardized | Integration tests, secret scanning, distributed tracing, metrics |
| L4 | Optimized | Fast CI feedback, deploy frequency, flaky-test detection |
| L5 | Autonomous | Self-improving systems, auto-decomposition of requirements |

---

## 2. Kodus (`@kodus/agent-readiness`)

### Overview
- **Type**: Open-source CLI (MIT)
- **Invocation**: `bunx @kodus/agent-readiness .` or `npx @kodus/agent-readiness .`
- **Stack**: TypeScript (ESM) on Bun, React + Recharts dashboard
- **Model**: 7 pillars, 39 deterministic checks, 5 maturity levels with 80% gate
- **Languages**: 10+ (Node, Python, Go, Rust, Java, Kotlin, C#, Ruby, PHP, Swift)

### Approach
Kodus is the deterministic OSS counterweight to Factory. It runs 33 static file-existence
and config-parsing checks plus 6 optional LLM checks (`--ai` flag) across 7 pillars
(Style & Linting, Testing, Documentation, Dev Environment, CI/CD, Code Health, Security).
Output is a terminal report, a JSON payload, and a local web dashboard with a radar chart.
A `--ci` flag plus `--min-level N` gives a non-zero exit code for pipeline use.

> See `03-kodus-deep-analysis.md` for the per-check breakdown, recommender internals,
> and the proposed `kodus 7 pillars ↔ our 3 axes` mapping. This section stays high-level
> on purpose.

### What they do better
- ✅ **39 deterministic checks** — same repo, same result, no API key needed
- ✅ **Local web dashboard** with radar chart, generated as static HTML
- ✅ **CI-ready** (`--ci --min-level 3`) with proper exit codes
- ✅ **Monorepo-aware** (npm workspaces, Lerna, Nx, Turborepo)
- ✅ **Configurable** via `.kodus-readiness.yml`
- ✅ **Recommender** orders findings by effort/impact, with agent-focused reasoning

### What they miss
- ❌ Binary pass/fail per check — no nuanced 0-100 scoring
- ❌ No fix / file-generation capability
- ❌ No delta or diff between scans
- ❌ No distinction between agent-agnostic and agent-specific criteria
- ❌ Documentation pillar conflates several different concerns

### What we can borrow
- The deterministic static-check pattern (file existence, config parsing, glob counts)
- The local web dashboard with radar chart, simplified to vanilla JS for the workshop
- The maturity-level + 80%-gate concept, remapped to our 3-axis model
- The effort/impact recommender pattern with agent-focused "why this matters" copy

### Pillar breakdown (Kodus)
| Pillar | Checks | Workshop axis |
|---|---|---|
| 🎨 Style & Linting | 6 | NAVIGATE |
| 🧪 Testing | 6 | VALIDATE |
| 📚 Documentation | 8 | INSTRUCT (mostly) + NAVIGATE |
| 🔧 Dev Environment | 5 | NAVIGATE + INSTRUCT |
| ⚙️ CI/CD | 6 | VALIDATE |
| 💚 Code Health | 3 | VALIDATE + NAVIGATE |
| 🔒 Security | 5 | VALIDATE |

---

## 3. jpequegn/agent-readiness-score

### Overview
- **Type**: Open-source framework (Python)
- **Inspiration**: Factory.ai methodology, ported to OSS
- **Approach**: Static checks producing a composite score
- **Maturity**: Early stage, fewer features than Kodus

### Approach
A Python-native attempt to reproduce Factory's 8-pillar model in a script-friendly form.
The project demonstrates that the Factory framework is reproducible without the SaaS, but
the implementation has not yet caught up to Kodus in breadth, language coverage, or polish.

### What they do better
- ✅ **Python-native** — closer to a PyCon audience's tooling
- ✅ **Faithful to Factory's vocabulary** — useful as a reference implementation

### What they miss
- ❌ Smaller check set than Kodus
- ❌ No web dashboard, no recommender, no maturity-level UX
- ❌ Less active development

### What we can borrow
- The "Python-first OSS port of an existing rubric" framing — same posture the workshop takes
- A reminder that vocabulary alignment with Factory is cheap and worth doing

---

## 4. ACMM — AI Codebase Maturity Model

### Overview
- **Type**: Open-source dashboard / proposal (`console.kubestellar.io/acmm`)
- **Context**: Proposal aimed at OpenSSF scorecard integration
- **Model**: 5 levels, GitHub-repository-centric
- **Status**: Very new (April 2026), still in proposal stage

### Approach
ACMM treats agent readiness as an extension of repository security and provenance posture.
It is the closest the field has to an "OpenSSF for agents" — a public dashboard fed by
GitHub metadata and (eventually) scorecard signals.

### What they do better
- ✅ **Security/provenance angle** tied to OpenSSF — credible governance story
- ✅ **Public dashboard** model, useful for trends across many repos
- ✅ **GitHub-native** ingestion, low friction for hosted projects

### What they miss
- ❌ Limited to public GitHub repos; no local CLI
- ❌ Early stage — few checks, no recommender, no fix path
- ❌ Narrower than agent readiness as a whole (security-leaning)

### What we can borrow
- The framing of agent readiness as a measurable, comparable property of a repository
- The link to OpenSSF as a credibility lever, parked for post-workshop

---

## 5. `agent-next/agent-ready` (operability standards)

### Overview
- **Type**: Open-source standards effort
- **Focus**: Measurable operability criteria for agent-driven repositories
- **Approach**: Document-first — a checklist and specification rather than a scanner

### Approach
Where Kodus and Factory ship tools, `agent-next/agent-ready` ships a standard. It enumerates
what "agent-operable" means as measurable criteria, leaving implementation to consumers.

### What they do better
- ✅ **Standards-first** approach — vocabulary that other tools can adopt
- ✅ **Tool-agnostic** by construction

### What they miss
- ❌ No scanner, no scoring, no dashboard
- ❌ Adoption depends on someone else writing the tooling

### What we can borrow
- The discipline of writing each criterion as something measurable
- The agent-agnostic posture (no assumed runtime)

---

## Comparison Matrix

| | License | Determinism | Output format | Score model | Remediation | Agent-agnostic | Multi-repo |
|---|---|---|---|---|---|---|---|
| **Factory.ai** | Proprietary | LLM-based | SaaS dashboard | 5 maturity levels (80% gate) | Planned, none today | ❌ Droid-only | ✅ Enterprise |
| **Kodus** | MIT | ✅ Static (33) + LLM (6) | Terminal + JSON + local HTML | 5 levels (80% gate) + per-pillar % | ❌ Recommendations only | ✅ | ⚠️ Monorepo-aware, not multi-repo |
| **jpequegn** | OSS | Static | Score | Composite score | ❌ | ✅ | ❌ |
| **ACMM** | OSS proposal | Static (GitHub metadata) | Hosted dashboard | 5 levels | ❌ | ✅ | ✅ Public repos |
| **agent-next** | OSS standard | N/A (spec only) | Document | N/A | ❌ | ✅ | N/A |
| **`agent-ready-skill` (us)** | OSS | LLM-based today; static layer planned for workshop | Markdown report from skill | 8-dimension rubric, 0-100 weighted, 3-axis remap (38/34/28) | ✅ Planned (skill can emit edits) | ✅ Skill format is portable | ❌ Single repo |

---

## What This Means for the Workshop

The workshop's tooling has to pick a side on each design axis the field disagrees about.
Here is what we adopt, what we skip, and why.

**Adopt from Kodus**
- Deterministic file-existence and config-parsing checks as a baseline layer that runs
  without an API key. This makes the workshop reproducible for 30 people scanning at the
  same time and gives a fast, free signal before any LLM work.
- A local, static HTML radar chart for visualization. No build step, no server, no SaaS.
- The 5-level maturity ladder with an 80% gate, remapped on top of our 3-axis score so
  participants see both a number and a level.
- An effort/impact recommender pattern, with reasons phrased in terms of what the agent
  gains — Kodus already proved this framing works.

**Adopt from Factory**
- The vocabulary of maturity levels (Foundational/Guided/Structured/Optimized/Autonomous).
- The observation that Task Discovery deserves explicit weight, which is why our Spec-Driven
  Workflow dimension (D5) is its own thing rather than buried under Documentation.

**Skip**
- SaaS dashboards, hosted services, and any cloud dependency — workshop must run offline.
- Monorepo detection — overkill for a first workshop, parked as a post-workshop concern.
- Universal language support (10+ languages) — we are Python-first because this is PyCon.
- Pure binary pass/fail — our 8-dimension rubric stays 0-100 weighted, which is more
  informative for the LLM-judged dimensions where "how good" matters more than "exists".

**Why the 3-axis remap (38/34/28)**
Eight dimensions are correct for a rubric but heavy for a 90-minute workshop. The remap
preserves all 8 dimensions and their weights, but groups them by the *question the agent
is trying to answer*:

- **📝 INSTRUCT (38)** = D1 Agent Instructions (20) + D5 Spec-Driven Workflow (10) + D8 Claude-Specific (8) — "Does the agent understand what we want?"
- **🧭 NAVIGATE (34)** = D2 Project Navigability (18) + D7 Documentation & Comprehension (8) + D6 Skills & Tooling (8) — "Can the agent find its way around?"
- **✅ VALIDATE (28)** = D3 Testing & Validation (16) + D4 CI/CD & Automation (12) — "Can the agent tell whether it did the right thing?"

The radar chart shows three axes instead of eight, which is teachable in one slide. The
underlying 8-dimension scoring is preserved for the report and for anyone who wants to
drill in.

---

## Bottom-Line Takeaways

- 🏆 **Kodus is the OSS competitor to study** — 39 deterministic checks, MIT license, agent-focused recommender, local dashboard. It is the closest thing to the workshop's tooling target.
- 📝 **Factory.ai owns the vocabulary** — maturity levels, 80% gate, pillar names. Borrow the words, skip the runtime.
- 🧭 **No competitor today combines deterministic checks with LLM-based semantic scoring** — that hybrid is the workshop's distinctive contribution.
- ✅ **No competitor today emits fixes or tracks deltas between scans** — both are planned for the post-workshop project, not the workshop itself.
- ⚠️ **Vendor lock-in is the easiest mistake to make** — we stay agent-agnostic by shipping as a `claude-skill` (portable prompt) rather than a runtime-bound tool.
- 🟢 **The workshop's job is teaching, not winning benchmarks** — the 3-axis remap is a pedagogical compression of the rubric, not a replacement for it.
- 🔴 **Skip anything that needs a server, an account, or a paid API to demonstrate** — every workshop primitive must run from a laptop, offline if needed.
