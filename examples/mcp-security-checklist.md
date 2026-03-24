# MCP & Plugin Security Checklist

> Reference: OWASP DSGAI06 — Tool, Plugin & Agent Data Exchange Risks

## Before Installing a Plugin or MCP Server

- [ ] Source is a known/trusted repository or marketplace
- [ ] Plugin/server has been reviewed (check stars, issues, recent commits)
- [ ] Required permissions are understood and justified
- [ ] No overly broad tool access (`"allowed-tools": ["*"]` is a red flag)
- [ ] Data handling terms reviewed (retention, training opt-out, cross-border)

## MCP Server Configuration Review

- [ ] Each MCP server has minimal required tools enabled
- [ ] Credentials use environment variables (not hardcoded in `.mcp.json`)
- [ ] MCP servers do not have write access to sensitive directories
- [ ] Network-accessible MCP servers use authentication (mTLS preferred)
- [ ] Server descriptions do not contain suspicious instructions (tool poisoning)

## Plugin Permission Audit

| Plugin/MCP Server | Tools Granted | Justification      | Data Exposure            | Last Reviewed |
| ----------------- | ------------- | ------------------ | ------------------------ | ------------- |
| _example-plugin_  | _Read, Grep_  | _Code search only_ | _Source code (Internal)_ | _2026-01-15_  |

## Periodic Review

- Review MCP server configs quarterly
- Check for plugin updates monthly
- Audit tool permissions when adding new MCP servers
- Remove unused plugins and MCP servers promptly
- Re-evaluate after any plugin/server update (post-update compromise risk)
