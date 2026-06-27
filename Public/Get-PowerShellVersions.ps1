function Get-PowerShellVersions {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [switch]$All
    )
    
    if ($All) {
        Get-Command pwsh,powershell -All | ForEach-Object {
            [PSCustomObject]@{
                Version = Convert-FromStringToPowerShellVersion "$(&$_.Source -NoProfile -Command ""`$PSVersionTable.PSVersion.ToString()"" )" 
                Path    = $_.Source
            }
        }
    } else {
        Get-Command pwsh,powershell | ForEach-Object {
            [PSCustomObject]@{
                Version = Convert-FromStringToPowerShellVersion "$(&$_.Source -NoProfile -Command ""`$PSVersionTable.PSVersion.ToString()"" )" 
                Path    = $_.Source
            }
        }
    }
}