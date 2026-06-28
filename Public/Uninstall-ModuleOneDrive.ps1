<#
.SYNOPSIS
    Uninstalls a PowerShell module from OneDrive module folder, without annoying WindowsPowershell Net permission errors
.DESCRIPTION
    This function removes a specified PowerShell module from the OneDrive module folder. It addresses an issue in Windows PowerShell where the Remove-Module cmdlet does not remove the module folder when modules are stored on OneDrive. The function first removes the module from the current session and then deletes the module folder from the OneDrive path.
.PARAMETER Name
    The name of the PowerShell module to uninstall. This parameter is mandatory.
.NOTES
    This function address an issue on Windows Powershell where the Remove-Module cmdlet does not remove the module 
    folder when module are stored on OneDrive.
.EXAMPLE
    # Remove the OneDrive module folder
    Uninstall-ModuleOneDrive -ModuleName PsBananaUtils*
#>
function Uninstall-ModuleOneDrive {
    param(
        [Parameter(Mandatory = $true)]
        [ArgumentCompleter({
                param($commandName, $parameterName, $wordToComplete)

                $ModulePaths = $env:PSModulePath -split ';'
                $ModuleNames = @()

                $Modules = Get-ChildItem -Path $ModulePaths[0] -Directory | Select-Object -ExpandProperty Name
                $ModuleNames += $Modules

                $ModuleNames | Where-Object { $_ -like "$wordToComplete*" }
            })]
        [string]$Name
    )     
    $ModulePaths = $env:PSModulePath -split ';'
    $ModulePath = Join-Path -Path $ModulePaths[0] -ChildPath $Name

    if (-not (Test-Path -Path $ModulePath)) {
        throw "[!] Module folder '$ModulePath' does not exist."
    }
    
    Get-ChildItem -Path $ModulePath | ForEach-Object {
        Write-Host "[*] Unloading '$($_.BaseName)'" -ForegroundColor Magenta
        Remove-Module -Name $_.BaseName -Force -ErrorAction SilentlyContinue
        Write-Host "[*] Uninstalling '$($_.BaseName)'" -ForegroundColor Magenta
        Remove-Item -Path $_.FullName -Force
    }
}