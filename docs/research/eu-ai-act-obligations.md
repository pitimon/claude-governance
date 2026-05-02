# EU AI Act — 9 Obligations for High-Risk AI Systems

**Status**: Internal research artifact (Task T1 of Issue #57) — **VERIFIED against primary source**
**Source regulation**: Regulation (EU) 2024/1689 ("EU AI Act"), Official Journal version of 13 June 2024
**Primary source**: Law text fetched from artificialintelligenceact.eu (Future of Life Institute) via web archive — full text confirmed for all 7 articles
**Articles covered**: 9, 10, 11, 12, 13, 14, 15
**Enforcement date**: 2 August 2026
**Scope**: High-risk AI systems as defined in Annex III
**Purpose**: Foundation reference for `skills/eu-ai-act-check/SKILL.md` (T3) and `guides/eu-ai-act-mapping.md` (T2)

## Verification Note (Important)

This document was originally drafted from secondary sources (Dataiku blog + A&O Shearman law firm article). After cross-verification against the **primary law text** of all 7 articles, the following corrections were applied:

- ❌ **Removed**: "Minimum quarterly risk reassessment" — Dataiku invention, NOT in Article 9. Law says "regular systematic review and updating" without specifying cadence.
- ❌ **Removed**: "≥36 months log retention" — NOT in Article 12. Law says "over the lifetime of the system" without specifying duration.
- ❌ **Removed**: "Annual penetration testing" — NOT in Article 15. Law requires resilience but not specific test cadence.
- ❌ **Removed**: "Quarterly log retrieval testing" — NOT in Article 12. Dataiku recommendation.
- ⚠️ **Disclosed**: Our "9 obligations from 7 articles" grouping splits Article 15 into 3 sub-obligations (accuracy/robustness/cybersecurity). **Article 15 is legally ONE article**. The split is interpretive for skill design.
- ⚠️ **Disclosed**: The "Three Loops" model is **conceptually aligned** with Article 14 but uses different terminology. Article 14 mandates oversight via stop/override/intervene capabilities but does NOT formally name "Out-of/On-the/In-the-Loop" modes.
- ✅ **Confirmed**: All article-level concepts (continuous risk mgmt, bias detection, Annex IV, automation bias, adversarial examples, data/model poisoning, "stop button") verified against primary source.

### Post-Verifier Corrections (research-verifier agent findings, applied 2026-04-08)

After dispatching the `research-verifier` agent for independent cross-check, **3 additional credibility issues** were identified and fixed:

- 🔧 **Renamed sub-article labels**: "Article 15a/15b/15c" → "Article 15 ¶1-3 / ¶4 / ¶5". Article 15 is one article with **numbered subsections**, not letter sub-articles. The previous labels would not survive scrutiny by a lawyer or regulator.
- 🔧 **Reframed Three Loops claim**: Changed from "Article 14 IS the legal backing for Three Loops" → "Article 14's requirements are addressed by a Three Loops design". The Three Loops model is from human-autonomy teaming literature (Endsley 1999, DARPA), not EU law. Article 14 mandates capabilities; Three Loops is one design pattern that satisfies them.
- 🔧 **Added EC Service Desk as verified secondary**: https://ai-act-service-desk.ec.europa.eu/en/ai-act/article-9 through article-15 actually resolves (EC official). Promoted to verified source list.
- ℹ️ **Noted Digital Omnibus caveat**: The 2 August 2026 date is firm in current text, but the Commission has proposed linking it to availability of harmonized standards (Digital Omnibus package). Mentioned in verification table for legal accuracy.

Each obligation below includes a **"Verified Quote"** block from the primary law text.

---

## Obligation Grouping (7 Articles → 9 Obligations)

| #   | Obligation                | Article      | 8-Habit Skill                        |
| --- | ------------------------- | ------------ | ------------------------------------ |
| 1   | Risk Management           | Art. 9       | /security-check, /design             |
| 2   | Data Governance           | Art. 10      | /design, /requirements               |
| 3   | Technical Documentation   | Art. 11      | /design, /requirements, /build-brief |
| 4   | Record-Keeping            | Art. 12      | /monitor-setup, /reflect             |
| 5   | Transparency to Deployers | Art. 13      | /requirements, /design               |
| 6   | Human Oversight           | Art. 14      | /design (Three Loops), /review-ai    |
| 7   | Accuracy                  | Art. 15 ¶1-3 | /review-ai, /monitor-setup           |
| 8   | Robustness                | Art. 15 ¶4   | /security-check, /review-ai          |
| 9   | Cybersecurity             | Art. 15 ¶5   | /security-check                      |

---

## 1. Risk Management System (Article 9)

**Continuous?**: ✅ Yes — explicit "throughout the entire lifecycle"

**Verified Quote (Art. 9 ¶2)**:

> "The risk management system shall be understood as a **continuous iterative process** planned and run throughout the entire lifecycle of a high-risk AI system, requiring **regular systematic review and updating**. It shall comprise the following steps: (a) the identification and analysis of the **known and the reasonably foreseeable risks**... (b) the estimation and evaluation of the risks that may emerge when the high-risk AI system is used in accordance with its intended purpose, **and under conditions of reasonably foreseeable misuse**; (c) the evaluation of other risks possibly arising, based on the analysis of data gathered from the post-market monitoring system... (d) the adoption of appropriate and targeted risk management measures..."

**Maps to 8-habit skills**: `/security-check`, `/design`

**Checklist items** (derived directly from Art. 9):

- [ ] Risk register exists for known **and reasonably foreseeable** risks (¶2(a))
- [ ] Reasonably foreseeable **misuse scenarios** explicitly considered (¶2(b))
- [ ] Each identified risk has a documented mitigation measure (¶2(d))
- [ ] Process for incorporating post-market monitoring findings (¶2(c), refs Art. 72)
- [ ] **Residual risk** judged acceptable per hazard and overall (¶5)
- [ ] Testing against "prior defined metrics and probabilistic thresholds" before market placement (¶8)
- [ ] Adverse impact on persons under 18 + vulnerable groups considered (¶9)

**Evidence required**: Risk register with timestamps, mitigation linkage, residual risk assessment, testing protocol with predefined thresholds

---

## 2. Data Governance (Article 10)

**Verified Quote (Art. 10 ¶2-3)**:

> "Training, validation and testing data sets shall be subject to data governance and management practices appropriate for the intended purpose... Those practices shall concern in particular: (a) the relevant design choices; (b) data collection processes and the origin of data... (f) **examination in view of possible biases** that are likely to affect the health and safety of persons, have a negative impact on fundamental rights or lead to discrimination... (g) appropriate measures to **detect, prevent and mitigate possible biases**... Training, validation and testing data sets shall be **relevant, sufficiently representative, and to the best extent possible, free of errors and complete** in view of the intended purpose."

**Maps to 8-habit skills**: `/design`, `/requirements`

**Checklist items** (derived directly from Art. 10):

- [ ] Data governance practices documented for design choices, collection, preparation (¶2(a)-(c))
- [ ] Data origin and original purpose documented (¶2(b))
- [ ] Bias examination performed for health/safety/fundamental-rights/discrimination impact (¶2(f))
- [ ] Bias detect/prevent/mitigate measures applied (¶2(g))
- [ ] Datasets are relevant, sufficiently representative, best-effort error-free, complete (¶3)
- [ ] Statistical properties appropriate for target population (¶3)
- [ ] Geographical/contextual/behavioural setting considered (¶4)
- [ ] For non-ML systems: ¶2-5 apply to testing data sets only (¶6)

**Evidence required**: Data governance plan, bias examination report, representativeness assessment, statistical property documentation

---

## 3. Technical Documentation (Article 11)

**Verified Quote (Art. 11 ¶1)**:

> "The technical documentation of a high-risk AI system shall be **drawn up before that system is placed on the market or put into service** and shall be **kept up-to date**. The technical documentation shall be drawn up in such a way as to demonstrate that the high-risk AI system complies with the requirements set out in this Section and to provide national competent authorities and notified bodies with the necessary information in a clear and comprehensive form to assess the compliance of the AI system with those requirements. It shall contain, **at a minimum, the elements set out in Annex IV**. SMEs, including start-ups, may provide the elements of the technical documentation specified in Annex IV in a simplified manner."

**Maps to 8-habit skills**: `/design`, `/requirements`, `/build-brief`

**Checklist items** (derived directly from Art. 11):

- [ ] Technical documentation drawn up **before market placement / put into service** (¶1)
- [ ] Documentation **kept up-to-date** through lifecycle (¶1)
- [ ] Documentation contains all elements of **Annex IV** at minimum (¶1)
- [ ] Documentation written for clarity to authorities + notified bodies (¶1)
- [ ] If SME/startup: simplified Annex IV form may be used (¶1)
- [ ] If product covered by Union harmonisation: single combined doc set (¶2)

**Evidence required**: Annex IV-mapped documentation folder, version history with dates, conformity assessment readiness

---

## 4. Record-Keeping (Article 12)

**Verified Quote (Art. 12 ¶1-2)**:

> "High-risk AI systems shall **technically allow for the automatic recording of events (logs) over the lifetime of the system**. In order to ensure a level of traceability of the functioning of a high-risk AI system that is appropriate to the intended purpose of the system, logging capabilities shall enable the recording of events relevant for: (a) **identifying situations that may result in the high-risk AI system presenting a risk** within the meaning of Article 79(1) or in a substantial modification; (b) facilitating the **post-market monitoring** referred to in Article 72; and (c) monitoring the operation of high-risk AI systems referred to in Article 26(5)."

**Maps to 8-habit skills**: `/monitor-setup`, `/reflect`

**Checklist items** (derived directly from Art. 12):

- [ ] System **technically allows automatic event recording** over lifetime (¶1)
- [ ] Logs enable identification of risk-presenting situations (¶2(a))
- [ ] Logs enable post-market monitoring per Art. 72 (¶2(b))
- [ ] For Annex III point 1(a) systems: log start/end of use, reference DB, input data with matches, verifying persons (¶3)

**Evidence required**: Logging architecture documentation, log schema mapping to Art. 12 requirements

> ⚠️ **Note**: Article 12 does NOT specify retention duration, granularity standards, immutability, or retrieval testing. These are operational best practices but not legal requirements under Art. 12.

---

## 5. Transparency to Deployers (Article 13)

**Verified Quote (Art. 13 ¶1-3)**:

> "High-risk AI systems shall be designed and developed in such a way as to ensure that **their operation is sufficiently transparent to enable deployers to interpret a system's output and use it appropriately**... High-risk AI systems shall be accompanied by **instructions for use** in an appropriate digital format or otherwise that include concise, complete, correct and clear information that is **relevant, accessible and comprehensible to deployers**. The instructions for use shall contain at least the following information: (a) the identity and contact details of the provider... (b) the characteristics, capabilities and limitations of performance... including: (i) intended purpose; (ii) the level of accuracy, including its metrics, robustness and cybersecurity..."

**Maps to 8-habit skills**: `/requirements`, `/design`

**Checklist items** (derived directly from Art. 13):

- [ ] System designed for sufficient transparency to deployers (¶1)
- [ ] Instructions for use exist, "relevant, accessible, comprehensible" (¶2)
- [ ] Provider identity + contact details documented (¶3(a))
- [ ] Intended purpose stated (¶3(b)(i))
- [ ] Accuracy/robustness/cybersecurity levels with metrics declared (¶3(b)(ii))
- [ ] Known foreseeable circumstances affecting performance documented (¶3(b)(iii))
- [ ] Output interpretation guidance provided (¶3(b)(vii))
- [ ] Predetermined changes documented (¶3(c))
- [ ] Human oversight measures from Art. 14 referenced (¶3(d))
- [ ] Computational resources, lifetime, maintenance documented (¶3(e))
- [ ] Log collection/storage/interpretation mechanism per Art. 12 (¶3(f))

**Evidence required**: Instructions-for-use document covering all ¶3 items

---

## 6. Human Oversight (Article 14) ⭐ Three Loops Anchor

**Verified Quote (Art. 14 ¶1, 4)**:

> "Human oversight shall aim to **prevent or minimise the risks** to health, safety or fundamental rights... the high-risk AI system shall be provided to the deployer in such a way that natural persons to whom human oversight is assigned are enabled, as appropriate and proportionate: (a) to properly **understand the relevant capacities and limitations** of the high-risk AI system and be able to duly monitor its operation, including in view of detecting and addressing anomalies, dysfunctions and unexpected performance; (b) to remain aware of the possible tendency of automatically relying or **over-relying on the output** produced by a high-risk AI system (**automation bias**)...; (c) to correctly interpret the high-risk AI system's output...; (d) to decide, in any particular situation, **not to use the high-risk AI system or to otherwise disregard, override or reverse the output**...; (e) to **intervene** in the operation of the high-risk AI system or **interrupt the system through a 'stop' button** or a similar procedure that allows the system to come to a halt in a safe state."

**Maps to 8-habit skills**: `/design` (Three Loops decision model — Issue #59), `/review-ai`

**Checklist items** (derived directly from Art. 14):

- [ ] Oversight measures designed to prevent/minimise risk to fundamental rights (¶1)
- [ ] Measures commensurate with risk, autonomy level, context (¶3)
- [ ] Oversight built into system **before market placement** OR identified for deployer implementation (¶3(a)-(b))
- [ ] Overseers can understand capacities + limitations + detect anomalies (¶4(a))
- [ ] Overseers aware of **automation bias** risk (¶4(b))
- [ ] Overseers can correctly interpret output (¶4(c))
- [ ] Overseers can **disregard, override, reverse** output (¶4(d))
- [ ] Overseers can **intervene** or trigger **'stop' button** for safe halt (¶4(e))
- [ ] For Annex III 1(a) (biometric): identification verified by **at least 2 natural persons** (¶5)

**Evidence required**: Oversight design document, automation-bias training material, override/stop mechanism specs, intervention audit trail

**🔗 Integration with Issue #59 (F2 Three Loops)** — _Important framing_:

Article 14 does NOT use or endorse "Three Loops" terminology. The Three Loops model originates from human-autonomy teaming literature (e.g., Endsley 1999; DARPA autonomy research), not EU law. The accurate framing is:

> ✅ **"Article 14's requirements are addressed by a Three Loops design"**
> ❌ NOT "Article 14 IS the legal backing for Three Loops"

The Three Loops framework is a **design pattern** that, when implemented, satisfies Article 14's mandated capabilities:

- **In-the-Loop** design satisfies Art. 14 ¶4(d-e) (override + stop per decision)
- **On-the-Loop** design satisfies Art. 14 ¶4(a-c) (monitor + intervene on anomalies)
- **Out-of-Loop** design must still satisfy Art. 14 ¶3(a) (measures built-in pre-market) and ¶4(e) (stop button always required, regardless of Loop)

For audit/compliance discussions, cite Article 14's specific paragraphs (e.g., "¶4(d)") rather than Three Loops labels.

---

## 7. Accuracy (Article 15 ¶1-3)

**Verified Quote (Art. 15 ¶1-3)**:

> "High-risk AI systems shall be designed and developed in such a way that they achieve an **appropriate level of accuracy, robustness, and cybersecurity**, and that they perform consistently in those respects throughout their lifecycle... To address the technical aspects of how to measure the appropriate levels of accuracy and robustness... the Commission shall... encourage... the development of benchmarks and measurement methodologies. The **levels of accuracy and the relevant accuracy metrics** of high-risk AI systems shall be **declared in the accompanying instructions of use**."

**Maps to 8-habit skills**: `/review-ai`, `/monitor-setup`

**Checklist items** (derived directly from Art. 15 ¶1-3):

- [ ] Accuracy level appropriate to intended purpose (¶1)
- [ ] Performs **consistently** throughout lifecycle (¶1)
- [ ] Accuracy metrics **declared in instructions for use** (¶3)
- [ ] Uses benchmarks/measurement methodologies as available (¶2)

**Evidence required**: Accuracy benchmarks with methodology, instructions-for-use accuracy declaration, lifecycle consistency monitoring

---

## 8. Robustness (Article 15 ¶4)

**Verified Quote (Art. 15 ¶4)**:

> "High-risk AI systems shall be **as resilient as possible regarding errors, faults or inconsistencies** that may occur within the system or the environment in which the system operates, in particular due to their interaction with natural persons or other systems. Technical and organisational measures shall be taken in this regard. The robustness of high-risk AI systems may be achieved through **technical redundancy solutions, which may include backup or fail-safe plans**. High-risk AI systems that **continue to learn after being placed on the market** or put into service shall be developed in such a way as to **eliminate or reduce as far as possible the risk of possibly biased outputs influencing input for future operations (feedback loops)**, and as to ensure that any such feedback loops are duly addressed with appropriate mitigation measures."

**Maps to 8-habit skills**: `/security-check`, `/review-ai`

**Checklist items** (derived directly from Art. 15 ¶4):

- [ ] System resilient to errors/faults/inconsistencies from internal + environment (¶4)
- [ ] Resilience to interaction with natural persons + other systems (¶4)
- [ ] Technical AND organisational measures for resilience (¶4)
- [ ] If applicable: redundancy/backup/fail-safe plans (¶4)
- [ ] If continuous-learning system: feedback loop mitigation for biased outputs (¶4)

**Evidence required**: Resilience design document, fault tolerance test results, feedback loop mitigation plan (if applicable)

---

## 9. Cybersecurity (Article 15 ¶5) ⭐ DSGAI Anchor

**Verified Quote (Art. 15 ¶5)**:

> "High-risk AI systems shall be **resilient against attempts by unauthorised third parties to alter their use, outputs or performance by exploiting system vulnerabilities**. The technical solutions aiming to ensure the cybersecurity of high-risk AI systems shall be appropriate to the relevant circumstances and the risks. The technical solutions to address AI specific vulnerabilities shall include, where appropriate, measures to **prevent, detect, respond to, resolve and control for attacks trying to manipulate the training data set (data poisoning)**, or **pre-trained components used in training (model poisoning)**, **inputs designed to cause the AI model to make a mistake (adversarial examples or model evasion)**, **confidentiality attacks or model flaws**."

**Maps to 8-habit skills**: `/security-check` (DSGAI mapping — Issue #60)

**Checklist items** (derived directly from Art. 15 ¶5):

- [ ] System resilient to unauthorized alteration of use/outputs/performance (¶5)
- [ ] Cybersecurity measures appropriate to risks (¶5)
- [ ] **Data poisoning** prevent/detect/respond capability (¶5)
- [ ] **Model poisoning** prevent/detect/respond capability (¶5)
- [ ] **Adversarial examples / model evasion** prevent/detect/respond capability (¶5)
- [ ] **Confidentiality attacks** mitigation (¶5)
- [ ] **Model flaws** mitigation (¶5)

**Evidence required**: Threat model covering 5 named attack types, mitigation implementation, security test results

**🔗 Integration with Issue #60 (F6 DSGAI)**: Article 15 ¶5 names exactly 5 AI-specific attack categories. OWASP DSGAI 11 controls provide the concrete operational checklist for each category. The mapping is direct: Art. 15 ¶5 = the "WHAT to defend against"; DSGAI = the "HOW to defend".

---

## Quick-Reference Table

| #   | Obligation                | Article | Continuous?              | Primary Skill           | Key Evidence                             |
| --- | ------------------------- | ------- | ------------------------ | ----------------------- | ---------------------------------------- |
| 1   | Risk Management           | 9       | Yes (lifecycle)          | /security-check         | Risk register + residual risk assessment |
| 2   | Data Governance           | 10      | At dataset changes       | /design                 | Data governance plan + bias report       |
| 3   | Technical Documentation   | 11      | Pre-market + updates     | /design                 | Annex IV folder                          |
| 4   | Record-Keeping            | 12      | Continuous (runtime)     | /monitor-setup          | Logging architecture + schema            |
| 5   | Transparency to Deployers | 13      | At release               | /requirements           | Instructions-for-use document            |
| 6   | Human Oversight           | 14      | Per decision + design    | /design (Three Loops)   | Override/stop specs + audit trail        |
| 7   | Accuracy                  | 15 ¶1-3 | Continuous               | /review-ai              | Benchmark methodology                    |
| 8   | Robustness                | 15 ¶4   | Pre-release + on changes | /security-check         | Resilience design                        |
| 9   | Cybersecurity             | 15 ¶5   | Continuous               | /security-check (DSGAI) | Threat model for 5 attack types          |

---

## Scope Notes for `/eu-ai-act-check` Skill (T3)

### Skip If (scope-check pre-flight)

- Project is **not high-risk** under Annex III (most internal tools, dev tools, non-safety AI fall outside)
- Project does **not target EU market** (no EU users, no EU deployment)
- Provide a one-line "/eu-ai-act-check --scope" pre-flight that returns "OUT OF SCOPE" with explanation

### Out of Scope for Issue #57 (deferred to v2.4.0+)

- ❌ Articles 16-29 (deployer obligations, post-market monitoring details)
- ❌ Article 50 (transparency for general-purpose AI — different rules)
- ❌ Annex III risk classification automation (manual judgment for now)
- ❌ Auto-generation of full Annex IV documentation
- ❌ Conformity assessment procedures (Article 43)

### In Scope for Issue #57

- ✅ 9-obligation checklist with pass/fail/N-A per item
- ✅ Cross-reference to existing 8-habit skills
- ✅ Output report mappable to evidence artifacts
- ✅ Article 14 checkpoint integration with /design (T5)

---

## Sources Cited (with verification status)

| #   | Source                                                                | URL                                                                                                                                        | Verification                                | Use                                                                                          |
| --- | --------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------- | -------------------------------------------------------------------------------------------- |
| 1   | **Regulation (EU) 2024/1689** (primary law)                           | EUR-Lex CELEX:32024R1689                                                                                                                   | ❌ Direct fetch blocked (AWS WAF)           | —                                                                                            |
| 2   | **artificialintelligenceact.eu/article/9-15** (FLI mirror of OJ text) | via web.archive.org                                                                                                                        | ✅ **Full text fetched for all 7 articles** | **All Verified Quotes above**                                                                |
| 3   | **Dataiku — EU AI Act High-Risk Requirements**                        | https://www.dataiku.com/stories/blog/eu-ai-act-high-risk-requirements                                                                      | ✅ WebFetched                               | Initial draft (since corrected)                                                              |
| 4   | **A&O Shearman — Zooming in on AI #10**                               | https://www.aoshearman.com/en/insights/ao-shearman-on-tech/zooming-in-on-ai-10-eu-ai-act-what-are-the-obligations-for-high-risk-ai-systems | ✅ WebFetched                               | Initial draft (since corrected)                                                              |
| 5   | **Implementation Timeline**                                           | https://artificialintelligenceact.eu/implementation-timeline/                                                                              | ⚠️ Snippet only                             | Aug 2 2026 enforcement date (subject to Digital Omnibus harmonized standards conditionality) |
| 6   | **EC AI Act Service Desk** (official Commission)                      | https://ai-act-service-desk.ec.europa.eu/en/ai-act/article-9 (and articles 10-15)                                                          | ✅ Verified by research-verifier agent      | Independent EC official confirmation of Articles 9, 11, 14, 15 content                       |

**Verification methodology**:

1. Initial draft from sources 3 + 4 (vendor + law firm interpretations)
2. Cross-verification by fetching full primary law text from source 2 via `curl + web.archive.org` (workaround for AWS WAF block)
3. Each obligation anchored by **direct verbatim quote** from the law
4. Items NOT supported by primary text removed (4 items: quarterly cadence, 36-month retention, annual pen test, quarterly retrieval test)
5. Interpretive items (Article 15 split, Three Loops mapping) explicitly disclosed as our framework, not law
6. Independent agent verification (`research-verifier`) cross-checked claims against EC Service Desk (source 6); 3 additional issues found and fixed (sub-article labels, Three Loops framing, Service Desk recognition)

**Verification status**: 2/6 sources directly verified for primary law content (source 2 = OJ text mirror via archive; source 6 = EC Service Desk via independent agent). All 9 obligations have verified quotes anchored to ¶ references. **Recommend additional verification by qualified EU AI lawyer before production use** — this document is a developer reference, not legal advice.

---

## Handoff to T2

T2 (`guides/eu-ai-act-mapping.md`) is the user-facing version. It should:

1. Copy the Quick-Reference Table
2. Expand "Maps to skill" with concrete invocation examples
3. Add "How to use this guide" intro for end users
4. Remove internal scope notes
5. Add disclaimer: "Not legal advice — consult counsel"

T3 (`/eu-ai-act-check` skill) reads the 9 sections above and turns each "Checklist items" block into the skill's process steps. The Verified Quote blocks should be referenced (not copied verbatim) in the skill output to anchor each check.

---

**Document size**: ~351 lines
**Sources verified**: 2/6 directly verified (source 2 = OJ text mirror via web.archive.org; source 6 = EC Service Desk via research-verifier agent) + 2/6 secondary deep-fetch + 2/6 snippet
**Coverage**: 9/9 obligations with Verified Quotes anchored to ¶ references
**Corrections from secondary sources**: 4 items removed (quarterly review, 36-month retention, annual pen test, quarterly retrieval test)
**Post-verifier fixes**: 3 additional (sub-article labels 15a/b/c → ¶1-3/¶4/¶5, Three Loops reframing, EC Service Desk source promotion)
