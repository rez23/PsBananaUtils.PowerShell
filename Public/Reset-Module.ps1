$Script:TestValidPath = {
    param([string]$Path)

    $null = [System.Management.Automation.Language.Parser]::ParseInput(
        "`"$Path`"", [ref]$null, [ref]$null
    )

    return $?
}

<#
.SYNOPSIS
    Resets a PowerShell module.

.DESCRIPTION
    This function unloads and reloads a specified PowerShell module.
    If no module name is provided, it resets all loaded modules.

.PARAMETER Name
    The name of the module to reset.

.PARAMETER Quiet
    If specified, suppresses verbose output.
#>
function Reset-Module {
    param(
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ArgumentCompleter({
                param($commandName, $parameterName, $wordToComplete)

                Get-Module |
                Select-Object -ExpandProperty Name |
                Where-Object { $_ -like "$wordToComplete*" }
            })]
        [string] $Name,
        [Parameter(Mandatory = $false)]
        [switch] $Quiet
    )

    $Module = $null
   
    # Unload the module if it's already loaded
    if ($Name) {
        if ((& $Script:TestValidPath -Path $Name)) {
            $LocalModule = Get-Item -Path $Name
            $Module = [pscustomobject]@{
                Name            = $LocalModule.BaseName
                LocalModulePath = $LocalModule
            }
        }
        else {
            $Module = Get-Module -Name $Name
        }
    }
    else {
        $Module = Get-Module
    }

    # Force reload off all module in $Module
    $Module | ForEach-Object {
        Write-Verbose "Stopping $($_.Name)"
        Remove-Module -Name $_.Name -Force
        Import-Module -Name "$(if ($_.LocalModulePath) { $_.LocalModulePath } else { $_.Name })" -Force
    }
}