<#
.SYNOPSIS
    Retrieves installed PowerShell versions.

.DESCRIPTION
    This function lists all installed PowerShell versions on the system.
    If the -All switch is specified, it includes all versions, otherwise only the default version is returned.

.PARAMETER All
    If specified, returns all installed PowerShell versions.
#>
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