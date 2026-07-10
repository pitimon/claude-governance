#Requires -Version 5.1
# secret-scanner.ps1 - PowerShell port of secret-scanner.sh
# Runs as PreToolUse hook on Edit|Write|MultiEdit for Claude Code on native
# Windows without Git Bash (where the shell tool falls back to PowerShell).
# Exit 0 = allow (or warn for PII), Exit 2 = block (secrets/credentials).
#
# Parity contract with secret-scanner.sh:
#   - Case-SENSITIVE matching (-cmatch / [regex] default) to mirror grep -E.
#   - Line-by-line matching to mirror grep's per-line semantics (so ^ anchors
#     behave the same as in the bash version).
#   - Same two-stage DIGIT_REQUIRED check and same raw-scan fallback.

$ErrorActionPreference = 'Stop'

# Read the hook payload from stdin. ($input is a reserved automatic variable in
# PowerShell - never shadow it; this script uses $payload.)
$payload = [Console]::In.ReadToEnd()

# Parse tool_name via JSON (whitespace-agnostic - the fail-open the .sh grep had
# cannot occur here). Fall back to empty on any parse failure.
$toolName = ''
$obj = $null
try {
  $obj = $payload | ConvertFrom-Json
  if ($null -ne $obj.tool_name) { $toolName = [string]$obj.tool_name }
} catch {
  $toolName = ''
}

$content = ''
$recognized = $true
switch ($toolName) {
  'Write'     { try { $content = [string]$obj.tool_input.content } catch { $content = '' } }
  'Edit'      { try { $content = [string]$obj.tool_input.new_string } catch { $content = '' } }
  'MultiEdit' {
    try { $content = (($obj.tool_input.edits | ForEach-Object { [string]$_.new_string }) -join ' ') }
    catch { $content = '' }
  }
  default     { $recognized = $false }
}

# Fail-safe: never silently allow. If content extraction produced nothing -
# unparseable/unexpected tool_name, or a changed tool_input shape - scan the RAW
# payload so a secret cannot slip through on a payload we failed to parse. Only
# an unrecognized/unparseable tool warns, so a legitimate empty write is quiet.
$fellBack = $false
if ([string]::IsNullOrEmpty($content)) {
  $content = $payload
  if (-not $recognized) { $fellBack = $true }
}

# Quote chars, composed so this source file contains no bare quote-in-class that
# a naive scanner would trip over.
$q  = [char]0x27   # single quote
$dq = [char]0x22   # double quote

# --- Matching helpers (case-sensitive, line-by-line to mirror grep -E) ---
function Test-BlockPattern([string]$text, [string]$pattern) {
  foreach ($line in ($text -split "`n")) {
    if ($line -cmatch $pattern) { return $true }
  }
  return $false
}

function Write-BlockMessage([string]$desc) {
  [Console]::Error.WriteLine("Governance: Blocked - $desc detected in file content.")
  [Console]::Error.WriteLine("")
  [Console]::Error.WriteLine("Use environment variables instead of hardcoding secrets:")
  [Console]::Error.WriteLine("  JS/TS:  const value = process.env.YOUR_SECRET")
  [Console]::Error.WriteLine("  Python: value = os.environ[${q}YOUR_SECRET${q}]")
  [Console]::Error.WriteLine("  Go:     value := os.Getenv(${dq}YOUR_SECRET${dq})")
  [Console]::Error.WriteLine("")
  [Console]::Error.WriteLine("To fix: replace the hardcoded value with an environment variable reference.")
}

# === BLOCK PATTERNS (exit 2) - secrets and credentials ===
# [pattern, description]. Quote classes built from $dq/$q so the regex reaches
# the .NET engine as ["'] and [^'"].
$blockPatterns = @(
  @("API_KEY\s*=\s*[$dq$q][A-Za-z0-9_\-]{10,}[$dq$q]", 'Hardcoded API key'),
  @("api_key\s*=\s*[$dq$q][A-Za-z0-9_\-]{10,}[$dq$q]", 'Hardcoded API key'),
  @("password\s*=\s*[$dq$q][^$q$dq]{4,}[$dq$q]", 'Hardcoded password'),
  @("PASSWORD\s*=\s*[$dq$q][^$q$dq]{4,}[$dq$q]", 'Hardcoded password'),
  @("ghp_[A-Za-z0-9]{36,}", 'GitHub personal access token'),
  @("gho_[A-Za-z0-9]{36,}", 'GitHub OAuth token'),
  @("ghs_[A-Za-z0-9]{36,}", 'GitHub server token'),
  @("AKIA[A-Z0-9]{16}", 'AWS access key ID'),
  @("xox[bpsar]-[A-Za-z0-9\-]{10,}", 'Slack token'),
  @("-----BEGIN[A-Z ]*PRIVATE KEY-----", 'Private key block'),
  @("eyJ[A-Za-z0-9_-]{15,}\.[A-Za-z0-9_-]{15,}", 'JWT token'),
  @("AIza[0-9A-Za-z_-]{35}", 'Google API key'),
  @("DefaultEndpointsProtocol=https;AccountName=", 'Azure connection string'),
  @("mongodb(\+srv)?://[^\s]+", 'MongoDB connection string'),
  @("[Tt]oken\s*=\s*[$dq$q][A-Za-z0-9_\-]{10,}[$dq$q]", 'Hardcoded token'),
  @("GITHUB_TOKEN\s*=\s*[$dq$q][^$q$dq]{4,}[$dq$q]", 'GitHub token assignment'),
  @("GH_TOKEN\s*=\s*[$dq$q][^$q$dq]{4,}[$dq$q]", 'GitHub token assignment'),
  @("Bearer\s+[A-Za-z0-9_\-\.]{20,}", 'Bearer token in code'),
  @("Authorization:\s*Bearer\s+[A-Za-z0-9_\-\.]{20,}", 'Hardcoded Authorization header'),
  @("oauth_token\s*=\s*[$dq$q][A-Za-z0-9_\-]{10,}[$dq$q]", 'Hardcoded OAuth token'),
  @("refresh_token\s*=\s*[$dq$q][A-Za-z0-9_\-]{10,}[$dq$q]", 'Hardcoded refresh token'),
  @("client_secret\s*=\s*[$dq$q][A-Za-z0-9_\-]{10,}[$dq$q]", 'Hardcoded client secret')
)

foreach ($entry in $blockPatterns) {
  if (Test-BlockPattern $content $entry[0]) {
    Write-BlockMessage $entry[1]
    exit 2
  }
}

# === DIGIT-REQUIRED BLOCK PATTERNS (exit 2) - sk-shaped keys (issue #29) ===
# Two-stage: (1) base regex must match with a left boundary that rejects a
# preceding letter (the NIST AI ...risk-management slug); (2) the matched text
# must contain at least one digit.
$digitRequiredPatterns = @(
  @("(^|[^A-Za-z])sk-[A-Za-z0-9_-]{20,}", 'OpenAI/Stripe secret key'),
  @("(^|[^A-Za-z])sk-proj-[A-Za-z0-9_-]{20,}", 'OpenAI project key'),
  @("(^|[^A-Za-z])sk-ant-[A-Za-z0-9_-]{20,}", 'Anthropic API key')
)

foreach ($entry in $digitRequiredPatterns) {
  $matched = $false
  foreach ($line in ($content -split "`n")) {
    foreach ($m in [regex]::Matches($line, $entry[0])) {
      if ($m.Value -cmatch '[0-9]') { $matched = $true; break }
    }
    if ($matched) { break }
  }
  if ($matched) {
    Write-BlockMessage $entry[1]
    exit 2
  }
}

# === WARN PATTERNS (exit 0 + stderr) - PII detection [DSGAI01] ===
$warnPatterns = @(
  @("[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}", 'Possible email address (PII)'),
  @("\b[0-9]{3}-[0-9]{2}-[0-9]{4}\b", 'Possible SSN (PII)'),
  @("\b[0-9]{4}[- ]?[0-9]{4}[- ]?[0-9]{4}[- ]?[0-9]{4}\b", 'Possible credit card number (PII)')
)

$piiWarned = $false
foreach ($entry in $warnPatterns) {
  if (Test-BlockPattern $content $entry[0]) {
    [Console]::Error.WriteLine("Governance: WARNING - $($entry[1]). Review before committing.")
    $piiWarned = $true
  }
}

if ($piiWarned) {
  [Console]::Error.WriteLine("")
  [Console]::Error.WriteLine("PII detected. Ensure data handling complies with your data classification policy.")
  [Console]::Error.WriteLine("See: examples/DATA-CLASSIFICATION.md.example for guidance. [DSGAI01]")
}

# Surface a parse-failure fallback (never silent).
if ($fellBack) {
  $tn = if ([string]::IsNullOrEmpty($toolName)) { '<empty>' } else { $toolName }
  [Console]::Error.WriteLine("Governance: WARNING - could not parse tool payload (tool_name='$tn'); scanned raw input as a fallback, no secret found. If this recurs, the hook JSON parsing may need updating.")
}

exit 0
