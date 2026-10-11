$ErrorActionPreference = 'Stop'
. ([IO.Path]::Combine($PSScriptRoot, 'Initialize-PowerShell.ps1'))
$project = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $project
$keyFile = Join-Path $env:LOCALAPPDATA 'FDEClaudeCode\deepseek-key.dpapi'
if (-not (Test-Path -LiteralPath $keyFile)) {
    & (Join-Path $PSScriptRoot 'Set-DeepSeekKey.ps1')
    if (-not (Test-Path -LiteralPath $keyFile)) { exit 1 }
}
$native = Join-Path $env:USERPROFILE '.local\bin\claude.exe'
if (Test-Path -LiteralPath $native) {
    & $native
} else {
    $npmLauncher = Join-Path $env:APPDATA 'npm\claude.cmd'
    if (Test-Path -LiteralPath $npmLauncher) { & $npmLauncher } else { & claude }
}
