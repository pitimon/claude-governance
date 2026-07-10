#Requires -Version 5.1
# test-secret-scanner.ps1 - Windows-side parity test for secret-scanner.ps1.
# Runs the shared fixtures (tests/fixtures/scanner-cases.jsonl) through the
# PowerShell scanner and asserts exit code + WARNING behaviour matches the
# expected outcome (the same fixtures the bash suite is checked against, so the
# .ps1 and .sh stay behaviourally identical). Exits 1 on any mismatch.
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$scanner  = Join-Path $repoRoot 'hooks\secret-scanner.ps1'
$fixtures = Join-Path $PSScriptRoot 'fixtures\scanner-cases.jsonl'

if (-not (Test-Path $scanner))  { Write-Host "scanner not found: $scanner"; exit 1 }
if (-not (Test-Path $fixtures)) { Write-Host "fixtures not found: $fixtures"; exit 1 }

$pass = 0; $fail = 0
foreach ($line in (Get-Content -Path $fixtures)) {
  if (-not $line.Trim()) { continue }
  $o = $line | ConvertFrom-Json
  $inF  = [System.IO.Path]::GetTempFileName()
  $outF = [System.IO.Path]::GetTempFileName()
  $errF = [System.IO.Path]::GetTempFileName()
  [System.IO.File]::WriteAllText($inF, $o.payload)
  $p = Start-Process -FilePath 'powershell' `
        -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File',"`"$scanner`"" `
        -RedirectStandardInput $inF -RedirectStandardOutput $outF -RedirectStandardError $errF `
        -NoNewWindow -PassThru -Wait
  $ec = $p.ExitCode
  $err = Get-Content -Path $errF -Raw
  $warn = [bool]($err -match 'WARNING')
  Remove-Item $inF,$outF,$errF -Force

  switch ($o.expect) {
    'block' { $ok = ($ec -eq 2) }
    'allow' { $ok = (($ec -eq 0) -and (-not $warn)) }
    'warn'  { $ok = (($ec -eq 0) -and $warn) }
    default { $ok = $false }
  }
  if ($ok) {
    $pass++
    Write-Host ("  PASS {0} ({1})" -f $o.id, $o.expect)
  } else {
    $fail++
    Write-Host ("  FAIL {0}: expect={1} exit={2} warn={3}" -f $o.id, $o.expect, $ec, $warn)
  }
}

Write-Host ("`n=== PowerShell scanner parity: PASS={0} FAIL={1} ===" -f $pass, $fail)
if ($fail -gt 0) { exit 1 } else { Write-Host 'All PowerShell scanner tests passed!'; exit 0 }
