param([switch]$CheckRuntime)

$ErrorActionPreference = 'Stop'
. ([IO.Path]::Combine($PSScriptRoot, 'Initialize-PowerShell.ps1'))
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# Check encryption BEFORE asking for a real key.
$probe = ConvertTo-SecureString 'FDE-runtime-probe-not-an-api-key' -AsPlainText -Force
$probeEncrypted = ConvertFrom-SecureString $probe
$probeRestored = ConvertTo-SecureString $probeEncrypted
$probeCredential = [Management.Automation.PSCredential]::new('probe', $probeRestored)
if ($probeCredential.GetNetworkCredential().Password -ne 'FDE-runtime-probe-not-an-api-key') {
    throw 'Credential encryption self-check failed. No real key has been requested.'
}
$probe.Dispose()
$probeRestored.Dispose()
$probeCredential = $null
if ($CheckRuntime) {
    Write-Output ('Runtime check passed: PowerShell ' + $PSVersionTable.PSVersion + '; DPAPI encryption OK; no API request made.')
    exit 0
}
Write-Host 'Create an API key at https://platform.deepseek.com/api_keys .'
Write-Host 'Paste it below. Input is masked; the key will not be written into this project.'
$secret = Read-Host 'DeepSeek API key' -AsSecureString
if ($secret.Length -eq 0) { throw 'API key cannot be empty.' }
$credential = [System.Management.Automation.PSCredential]::new('deepseek', $secret)
$plain = $credential.GetNetworkCredential().Password.Trim()
$normalizedSecret = ConvertTo-SecureString $plain -AsPlainText -Force
$secret.Dispose()
$secret = $normalizedSecret
$headers = @{ 'x-api-key' = $plain; 'anthropic-version' = '2023-06-01' }
$body = @{ model = 'deepseek-flash'; max_tokens = 32; thinking = @{ type = 'disabled' }; messages = @(@{role = 'user'; content = 'Reply only OK.'}) } | ConvertTo-Json -Depth 8 -Compress
try {
    Write-Host 'Checking authentication and a small model request...'
    $response = Invoke-RestMethod -Uri 'https://api.deepseek.com/anthropic/v1/messages' -Method Post -Headers $headers -ContentType 'application/json' -Body $body -TimeoutSec 60
    if (-not $response.content) { throw 'Unexpected response.' }
} catch {
    $status = 'network or response error'
    if ($_.Exception.Response -and $_.Exception.Response.StatusCode) { $status = [int]$_.Exception.Response.StatusCode }
    Write-Host "Connection check failed ($status). Key was not saved. 401: key; 402: balance; 429: rate limit."
    exit 1
} finally {
    $headers.Clear()
    $plain = $null
    $credential = $null
}
$storage = Join-Path $env:LOCALAPPDATA 'FDEClaudeCode'
New-Item -ItemType Directory -Path $storage -Force | Out-Null
$keyFile = Join-Path $storage 'deepseek-key.dpapi'
$encrypted = ConvertFrom-SecureString $secret
[IO.File]::WriteAllText($keyFile, $encrypted, [Text.UTF8Encoding]::new($false))
$secret.Dispose()
Write-Host 'DeepSeek API check passed. Key saved encrypted for your Windows user.'
Write-Host 'Open a NEW Claude Code conversation in Cursor. Existing conversations may need a reload.'
