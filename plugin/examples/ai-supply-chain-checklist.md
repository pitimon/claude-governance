# AI Supply Chain Security Checklist

> Vetting checklist for AI models, datasets, and dependencies. Reference: OWASP DSGAI04.

## Model Vetting

Before loading or deploying any AI model:

- [ ] **Provenance verified**: Model source is a trusted registry (Hugging Face verified org, official vendor, internal registry)
- [ ] **License reviewed**: Model license is compatible with intended use (commercial, research, derivatives)
- [ ] **Known vulnerabilities checked**: Search for CVEs or security advisories related to the model or its framework
- [ ] **Checksum verified**: Model file hash matches published checksum before loading
- [ ] **No unsafe deserialization**: Model does not require `pickle.load()` or `torch.load()` without `weights_only=True`
- [ ] **Inference-layer artifacts reviewed**: Chat templates, loader configs, and quantization files inspected for hidden instructions

## Dataset Provenance

Before using datasets for training or RAG indexing:

- [ ] **Source documented**: Dataset origin, collection method, and date recorded
- [ ] **Bias assessment**: Known biases documented and mitigation strategies identified
- [ ] **Consent and licensing**: Data collection complies with applicable privacy laws and terms of use
- [ ] **PII scrubbed**: Personal identifiable information redacted before ingestion
- [ ] **Integrity verified**: Checksums or signatures validated; no evidence of tampering

## AI Dependency Pinning

- [ ] **Version pinned**: All AI packages in requirements.txt/pyproject.toml use exact versions (`==`), not ranges (`>=`)
- [ ] **Lock file committed**: `poetry.lock`, `pip-compile` output, or equivalent committed to version control
- [ ] **Trusted registries only**: pip/conda configured to use trusted registries; no arbitrary URLs
- [ ] **Dependency audit**: Run SCA scan (Grype, `pip-audit`, `npm audit`) before deployment

## Unsafe Deserialization Patterns

| Pattern              | Risk                                | Safe Alternative                                                         |
| -------------------- | ----------------------------------- | ------------------------------------------------------------------------ |
| `torch.load(path)`   | Arbitrary code execution via pickle | `torch.load(path, weights_only=True)` or `safetensors.torch.load_file()` |
| `pickle.load(f)`     | Arbitrary code execution            | `json.load()`, `safetensors`, or schema-validated formats                |
| `pickle.loads(data)` | Remote code execution               | Validated JSON/Protobuf deserialization                                  |
| `yaml.unsafe_load()` | Code execution via YAML tags        | `yaml.safe_load()`                                                       |
| `joblib.load(path)`  | Pickle-based execution              | Validate source; prefer safetensors for model weights                    |

## Pre-Deployment Review

| Check                           | Status | Reviewer          | Date         |
| ------------------------------- | ------ | ----------------- | ------------ |
| _Model provenance verified_     | _Pass_ | _ML Engineer_     | _2026-XX-XX_ |
| _Dependencies pinned + audited_ | _Pass_ | _DevSecOps_       | _2026-XX-XX_ |
| _No unsafe deserialization_     | _Pass_ | _Security Review_ | _2026-XX-XX_ |
| _Dataset PII scrubbed_          | _Pass_ | _Data Engineer_   | _2026-XX-XX_ |
