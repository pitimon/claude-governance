# EU AI Act Compliance — Full Obligation Checklist

Full 9-obligation reference. Loaded from `SKILL.md` during Step 1 when the user runs the actual compliance check. Every item cites the specific article/paragraph in Regulation (EU) 2024/1689.

## Obligation 1: Risk Management (Article 9)

**Mapped skill**: `/governance-check` (security + architecture categories), `governance-reviewer` agent

- [ ] **[MUST]** Risk register exists for known and reasonably foreseeable risks (Art. 9 ¶2(a))
- [ ] **[MUST]** Each identified risk has a documented mitigation measure (Art. 9 ¶2(d))
- [ ] **[MUST]** Residual risk judged acceptable per hazard and overall (Art. 9 ¶5)
- [ ] **[MUST]** Testing against pre-defined metrics and probabilistic thresholds (Art. 9 ¶8)
- [ ] **[SHOULD]** Reasonably foreseeable misuse scenarios explicitly considered (Art. 9 ¶2(b))
- [ ] **[SHOULD]** Process for incorporating post-market monitoring findings (Art. 9 ¶2(c))
- [ ] **[COULD]** Adverse impact on persons under 18 + vulnerable groups considered (Art. 9 ¶9)

**Evidence file**: `docs/compliance/eu-ai-act/01-risk-mgmt/risk-register.md`

## Obligation 2: Data Governance (Article 10)

**Mapped skill**: `/governance-check` (architecture category), `/spec-driven-dev`, `examples/DATA-CLASSIFICATION.md.example`

- [ ] **[MUST]** Bias examination for health/safety/fundamental-rights/discrimination impact (Art. 10 ¶2(f))
- [ ] **[MUST]** Bias detect/prevent/mitigate measures applied (Art. 10 ¶2(g))
- [ ] **[MUST]** Datasets relevant, sufficiently representative, best-effort error-free, complete (Art. 10 ¶3)
- [ ] **[SHOULD]** Data governance practices documented (design, collection, preparation) (Art. 10 ¶2(a)-(c))
- [ ] **[SHOULD]** Data origin and original purpose documented (Art. 10 ¶2(b))
- [ ] **[SHOULD]** Statistical properties appropriate for target population (Art. 10 ¶3)
- [ ] **[COULD]** Geographical/contextual/behavioural setting considered (Art. 10 ¶4)
- [ ] **[COULD]** (Non-ML systems) ¶2-5 apply only to test data sets (Art. 10 ¶6)

**Evidence file**: `docs/compliance/eu-ai-act/02-data-gov/data-inventory.md`

## Obligation 3: Technical Documentation (Article 11)

**Mapped skill**: `/spec-driven-dev`, `/create-adr`

- [ ] **[MUST]** Technical documentation drawn up before market placement (Art. 11 ¶1)
- [ ] **[MUST]** Documentation contains all elements of Annex IV at minimum (Art. 11 ¶1)
- [ ] **[SHOULD]** Documentation kept up-to-date through lifecycle (Art. 11 ¶1)
- [ ] **[SHOULD]** Documentation written for clarity to authorities + notified bodies (Art. 11 ¶1)
- [ ] **[COULD]** (SME/startup) Simplified Annex IV form may be used (Art. 11 ¶1)

**Evidence file**: `docs/compliance/eu-ai-act/03-tech-docs/annex-iv/`

## Obligation 4: Record-Keeping (Article 12)

**Mapped skill**: **External** — runtime monitoring is outside this plugin's scope. Use `pitimon/8-habit-ai-dev`'s `/monitor-setup` skill (defines logging strategy) plus a runtime telemetry system (Datadog, OpenTelemetry, etc.) for the actual log infrastructure.

- [ ] **[MUST]** System technically allows automatic event recording over lifetime (Art. 12 ¶1)
- [ ] **[SHOULD]** Logs enable identification of risk-presenting situations (Art. 12 ¶2(a))
- [ ] **[SHOULD]** Logs enable post-market monitoring per Art. 72 (Art. 12 ¶2(b))
- [ ] **[COULD]** (Annex III 1(a) systems) Log start/end of use, reference DB, input/match, verifying persons (Art. 12 ¶3)

**Evidence file**: `docs/compliance/eu-ai-act/04-records/logging-config.md`

> ℹ️ Article 12 does NOT specify retention duration, granularity, or immutability. Those are operational best practices but not legal requirements.

## Obligation 5: Transparency to Deployers (Article 13)

**Mapped skill**: `/spec-driven-dev`

- [ ] **[MUST]** Instructions for use exist, "relevant, accessible, comprehensible" (Art. 13 ¶2)
- [ ] **[MUST]** Accuracy/robustness/cybersecurity levels with metrics declared (Art. 13 ¶3(b)(ii))
- [ ] **[MUST]** Human oversight measures from Art. 14 referenced (Art. 13 ¶3(d))
- [ ] **[SHOULD]** System designed for sufficient transparency to deployers (Art. 13 ¶1)
- [ ] **[SHOULD]** Provider identity + contact details documented (Art. 13 ¶3(a))
- [ ] **[SHOULD]** Intended purpose stated (Art. 13 ¶3(b)(i))
- [ ] **[SHOULD]** Known foreseeable circumstances affecting performance documented (Art. 13 ¶3(b)(iii))
- [ ] **[SHOULD]** Output interpretation guidance provided (Art. 13 ¶3(b)(vii))
- [ ] **[SHOULD]** Predetermined changes documented (Art. 13 ¶3(c))
- [ ] **[SHOULD]** Computational resources, lifetime, maintenance documented (Art. 13 ¶3(e))
- [ ] **[SHOULD]** Log collection/storage/interpretation mechanism per Art. 12 (Art. 13 ¶3(f))

**Evidence file**: `docs/compliance/eu-ai-act/05-transparency/instructions-for-use.md`

## Obligation 6: Human Oversight (Article 14) ⭐ Three Loops Anchor

**Mapped skill**: `governance-reviewer` agent + Three Loops Decision Model (`docs/adr/ADR-002-consequence-based-authorization.md`). The 2D matrix (Task Type × Consequence) plus the irreversible-ops-always-In-the-Loop override rule satisfies Art. 14 ¶4(a-e) capabilities.

- [ ] **[MUST]** Overseers can disregard, override, reverse output (Art. 14 ¶4(d))
- [ ] **[MUST]** Overseers can intervene OR trigger 'stop' button for safe halt (Art. 14 ¶4(e))
- [ ] **[MUST]** Overseers can understand capacities + limitations + detect anomalies (Art. 14 ¶4(a))
- [ ] **[SHOULD]** Oversight measures designed to prevent/minimise risk to fundamental rights (Art. 14 ¶1)
- [ ] **[SHOULD]** Measures commensurate with risk, autonomy level, context (Art. 14 ¶3)
- [ ] **[SHOULD]** Oversight built into system before market placement OR identified for deployer implementation (Art. 14 ¶3(a)-(b))
- [ ] **[SHOULD]** Overseers aware of automation bias risk (Art. 14 ¶4(b))
- [ ] **[SHOULD]** Overseers can correctly interpret output (Art. 14 ¶4(c))
- [ ] **[COULD]** (Annex III 1(a) biometric) Identification verified by ≥2 natural persons (Art. 14 ¶5)

**Evidence file**: `docs/compliance/eu-ai-act/06-oversight/oversight-design.md`

> 🔗 The Three Loops design pattern (Out/On/In-the-Loop) is one valid way to satisfy Article 14 ¶4(a-e). Three Loops terminology is from human-autonomy teaming literature (Endsley 1999, DARPA), NOT EU law. Cite Article 14 ¶ refs in audit, not Three Loops labels.

## Obligation 7: Accuracy (Article 15 ¶1-3)

**Mapped skill**: **External** — accuracy benchmarking and drift monitoring are runtime concerns. Use `pitimon/8-habit-ai-dev`'s `/review-ai` (captures baselines) and `/monitor-setup` (drift strategy) plus runtime ML observability tooling.

- [ ] **[MUST]** Accuracy level appropriate to intended purpose (Art. 15 ¶1)
- [ ] **[MUST]** Accuracy metrics declared in instructions for use (Art. 15 ¶3)
- [ ] **[SHOULD]** Performs consistently throughout lifecycle (Art. 15 ¶1)
- [ ] **[SHOULD]** Uses benchmarks/measurement methodologies as available (Art. 15 ¶2)

**Evidence file**: `docs/compliance/eu-ai-act/07-accuracy/baselines.md`

## Obligation 8: Robustness (Article 15 ¶4)

**Mapped skill**: `/governance-check` (security category), `governance-reviewer` agent

- [ ] **[MUST]** System resilient to errors/faults/inconsistencies (Art. 15 ¶4)
- [ ] **[SHOULD]** Resilience to interaction with natural persons + other systems (Art. 15 ¶4)
- [ ] **[SHOULD]** Technical AND organisational measures for resilience (Art. 15 ¶4)
- [ ] **[COULD]** (If applicable) Redundancy/backup/fail-safe plans (Art. 15 ¶4)
- [ ] **[COULD]** (Continuous-learning systems) Feedback loop mitigation for biased outputs (Art. 15 ¶4)

**Evidence file**: `docs/compliance/eu-ai-act/08-robustness/resilience-design.md`

## Obligation 9: Cybersecurity (Article 15 ¶5) ⭐ DSGAI Anchor

**Mapped skill**: `/governance-check` (security category) + `docs/compliance/DSGAI-MAPPING.md` (full 11-control mapping with bidirectional Article 15 ¶5 cross-references)

- [ ] **[MUST]** System resilient to unauthorized alteration of use/outputs/performance (Art. 15 ¶5)
- [ ] **[MUST]** Data poisoning prevent/detect/respond capability (Art. 15 ¶5)
- [ ] **[MUST]** Model poisoning prevent/detect/respond capability (Art. 15 ¶5)
- [ ] **[MUST]** Adversarial examples / model evasion prevent/detect/respond capability (Art. 15 ¶5)
- [ ] **[MUST]** Confidentiality attacks mitigation (Art. 15 ¶5)
- [ ] **[MUST]** Model flaws mitigation (Art. 15 ¶5)
- [ ] **[SHOULD]** Cybersecurity measures appropriate to risks (Art. 15 ¶5)

**Evidence file**: `docs/compliance/eu-ai-act/09-cybersecurity/threat-model.md`

> 🔗 Article 15 ¶5 names exactly 5 attack categories. OWASP DSGAI 11 controls operationalize each category with concrete checks. See `docs/compliance/DSGAI-MAPPING.md` "EU AI Act Cross-References" section for the full mapping table.

## Tier Summary (for default-mode runners)

| Tier       | Item count | Default behavior                                                                      |
| ---------- | ---------- | ------------------------------------------------------------------------------------- |
| **MUST**   | 25         | Always run; any FAIL = release blocker                                                |
| **SHOULD** | 27         | Run with `--full`; FAIL = warning                                                     |
| **COULD**  | 8          | Run with `--full` only if context applies (SME, biometric, continuous-learning, etc.) |
| **Total**  | 60         | —                                                                                     |

> **Verify counts**: `grep -c '^- \[ \] \*\*\[MUST\]\*\*' skills/eu-ai-act-check/reference.md`
