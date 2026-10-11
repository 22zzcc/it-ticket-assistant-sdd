# Cursor can pass PowerShell 7 module paths to Windows PowerShell 5.1.
# Explicitly load this runtime's built-in modules rather than autoloading by name.
foreach ($moduleName in @('Microsoft.PowerShell.Security', 'Microsoft.PowerShell.Utility', 'Microsoft.PowerShell.Management')) {
    $manifest = [IO.Path]::Combine($PSHOME, 'Modules', $moduleName, ($moduleName + '.psd1'))
    Import-Module -Name $manifest -ErrorAction Stop
}
