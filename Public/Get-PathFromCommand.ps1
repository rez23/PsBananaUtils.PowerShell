<#
.SYNOPSIS
Shows the resolved executable/script path for a command.

.DESCRIPTION
Uses Get-Command to locate a command and outputs its Path property.
This is a simple PowerShell equivalent of where/which behavior.

.PARAMETER Cmd
Command name to resolve.

.EXAMPLE
Get-PathFromCommand -Cmd pwsh

Outputs the path of the pwsh executable.
#>
function Get-PathFromCommand {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [Alias('Command')]
        [string]$Cmd,
        [switch]$All
    )

    if ($All) {
        Get-Command $Cmd -ErrorAction Stop -All | Select-Object -Property Source
    } else {
        Get-Command $Cmd -ErrorAction Stop | Select-Object -Property Source
    }
}