param([string]$KeyFile = [IO.Path]::Combine($env:LOCALAPPDATA, 'FDEClaudeCode', 'deepseek-key.dpapi'))

$ErrorActionPreference = 'Stop'
. ([IO.Path]::Combine($PSScriptRoot, 'Initialize-PowerShell.ps1'))
if (-not (Test-Path -LiteralPath $keyFile)) {
    [Console]::Error.WriteLine('DeepSeek key not configured. Run tools/Set-DeepSeekKey.ps1 in your own terminal.')
    exit 1
}
try {
    $encrypted = [IO.File]::ReadAllText($keyFile).Trim()
    $secret = ConvertTo-SecureString $encrypted
    $credential = [System.Management.Automation.PSCredential]::new('deepseek', $secret)
    [Console]::Out.Write($credential.GetNetworkCredential().Password)
} catch {
    [Console]::Error.WriteLine('Cannot decrypt DeepSeek key for this Windows user. Configure it again.')
    exit 1
}
