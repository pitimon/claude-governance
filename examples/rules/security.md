# Security Guidelines

## Mandatory Security Checks

Before ANY commit:

- [ ] No hardcoded secrets (API keys, passwords, tokens)
- [ ] All user inputs validated
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (sanitized HTML)
- [ ] CSRF protection enabled
- [ ] Authentication/authorization verified
- [ ] Rate limiting on all endpoints
- [ ] Error messages don't leak sensitive data

## Secret Management

```typescript
// NEVER: Hardcoded secrets
const apiKey = "sk-proj-xxxxx";

// ALWAYS: Environment variables
const apiKey = process.env.API_KEY;

if (!apiKey) {
  throw new Error("API_KEY not configured");
}
```

## Agent & Plugin Security [DSGAI02, DSGAI06]

- No hardcoded OAuth/bearer/refresh tokens in code or config
- MCP server configurations use least-privilege tool access
- Plugin permissions reviewed before installation
- Agent credential rotation policy documented

## PII Protection [DSGAI01]

PII patterns are flagged as warnings (not blocked) by the secret scanner:

- Email addresses, SSN patterns, credit card numbers
- Review warnings before committing — ensure PII handling complies with privacy policies
- Use DATA-CLASSIFICATION.md to document data sensitivity levels

## AI Artifact Security [DSGAI04]

- Model files (.onnx, .safetensors, .gguf, .pt) must NOT be committed to git — use Git LFS or artifact registry
- AI dependencies must be version-pinned (exact `==`, not `>=`)
- `torch.load()` requires `weights_only=True`; prefer `safetensors` format over pickle-based
- Verify model checksums before loading from external sources

## Telemetry Hygiene [DSGAI14]

- Never log full prompts, completions, or conversation contexts in production
- Redact PII before sending to observability platforms (Datadog, Sentry, OpenTelemetry)
- Capture metrics (latency, token count, error rate), not content
- Patterns to avoid: `logger.info(f"Prompt: {prompt}")`, `console.log(messages)`, `log.debug(request.body)`

## Session Isolation [DSGAI11]

- Agent memory and state must be scoped per-project and per-user
- Cache keys must include user/project/session identifiers
- Multi-tenant systems must enforce tenant isolation at query level
- Never share conversation context between different users or projects
- File-based caches must use project-scoped paths

## Security Response Protocol

If security issue found:

1. STOP immediately
2. Fix CRITICAL issues before continuing
3. Rotate any exposed secrets
4. Review entire codebase for similar issues
