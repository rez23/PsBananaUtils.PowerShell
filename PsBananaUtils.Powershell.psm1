. "$PSScriptRoot\Public\Find-PowershellHistory.ps1"
. "$PSScriptRoot\Public\Get-PathFromCommand.ps1"
. "$PSScriptRoot\Public\Reset-Module.ps1"
. "$PSScriptRoot\Private\Convert-FromStringToPowerShellVersions.ps1"

Set-Alias whereis -Value "Get-PathFromCommand"
Set-Alias shistory -Value "Find-PowershellHistory"

Export-ModuleMember `
    -Function (Get-ChildItem "$PSScriptRoot\Public\*.ps1" -Recurse | ForEach-Object { $_.BaseName }) `
    -Alias whereis, shistory
