<# `$dencode = [Text.Encoding]::Unicode.GetString([Convert]::FromBase64String(""$encoded""))
    `$sb = [ScriptBlock]::Create(""`$dencode"") #>

$script:CreatePsRemoteScript = {
    param([string]$ScriptBlock, [psobject]$PsInputObject = $null)
    "
`$payload = @{}    
`$WarningPreference = 'SilentlyContinue'
`$ErrorActionPreference = 'Stop'
`$VerbosePreference = 'SilentlyContinue'
`$DebugPreference = 'SilentlyContinue'
try {
    $(if ($PsInputObject) {
        "`$inputObject = [System.Management.Automation.PSSerializer]::Deserialize(`$PsInputObject)
         `$Result = Invoke-Command -ScriptBlock { `$inputObject | `$scriptBlock }"
    } else {
       "`$Result = Invoke-Command -ScriptBlock { $scriptBlock } 
        `$payload = @{ ok = `$true; result = `$Result }"     
    })
} catch {
    `$payload = @{ ok = `$false; error = `$_.Exception.Message }     
}
[System.Management.Automation.PSSerializer]::Serialize(`$payload)"
}

<#
.SYNOPSIS
Executes a script block in a specified PowerShell version and returns the result as serialized powershell object.
.DESCRIPTION
This function allows you to execute a script block in a specified version of PowerShell, including custom paths, 
and returns the result as a serialized PowerShell object. It handles errors and warnings gracefully, 
ensuring that the output is always in a consistent format.
.PARAMETER Command
The script block to execute in the specified PowerShell version.
.PARAMETER PowerShellVersion
The version of PowerShell to use for executing the script block.
.PARAMETER CustomPowerShellPath
An optional custom path to a PowerShell executable. If provided, this path will be used instead of the default PowerShell versions.
.EXAMPLE
Invoke-CustomPowerShell -Command { Get-Process } -PowerShellVersion 7 | Select-Object -Property Name, Id
#>
function Invoke-CustomPowerShell {
    param(
        [Parameter(Mandatory = $false, Position = 1)]
        [scriptblock]$Command,
        [Parameter(Mandatory = $false, Position = 2)]
        [ArgumentCompleter({
                param($commandName, $parameterName, $wordToComplete)

                Get-PowerShellVersions -All | 
                Select-Object -ExpandProperty Version | 
                Where-Object { $_ -like "$wordToComplete*" }
            })]
        [string]$PowerShellVersion = "7",
        [Parameter(Mandatory = $false, Position = 0)]
        [string]$CustomPowerShellPath = $null,

        # This is needed for pipeline object propagation, 
        # -Command with a scriptblock is almost certanly enough 
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [System.Management.Automation.HiddenAttribute()]
        [psobject]$PsInputObject = $null
    )

    $CommandString = &$script:CreatePsRemoteScript $Command

    # Base64 encode (Unicode)
    $encoded = [Convert]::ToBase64String(
        [Text.Encoding]::Unicode.GetBytes($CommandString)
    )

    if ($PsInputObject) {
        # if input object exists, serialize it to XML
        $PsInputObject = [System.Management.Automation.PSSerializer]::Serialize($PsInputObject)
    }

    $PsVersions = $null

    # Use custom path if provided
    if ($CustomPowerShellPath) {
        $PsVersions = @{Path = $CustomPowerShellPath; Version = Convert-FromStringToPowerShellVersion "$(&$CustomPowerShellPath -NoProfile -Command ""`$PSVersionTable.PSVersion.ToString()"" )" }
    }
    else {
        $PsVersions = Get-PowerShellVersions -All | Where-Object { $_ -match $PowerShellVersion }
    }

    if ($PsVersions.Count -gt 1) {
        Write-Warning "Multiple PowerShell versions found matching '$PowerShellVersion'. Be more specific."
        $PsVersions
    }
    else {

        $SelectedVersion = $PsVersions
        $Raw = & $SelectedVersion.Path -NoLogo -NoProfile -EncodedCommand $encoded 2>&1

        #$Raw
        # Rimuovi sequenze ANSI
        $Clean = $Raw | ForEach-Object { $_ -replace "`e\[[0-9;]*[A-Za-z]", "" }

        # Prendi solo l’ultima riga
        $Xml = $Clean

        # Verifica che sia XML
        if (-not ($Xml -match '<Objs')) {
            throw "Remote output is not XML: $Xml"
        }

        # Deserializza
        $payload = [System.Management.Automation.PSSerializer]::Deserialize($Xml)

        if ($payload.ok) {
            return $payload.result
        }
        else {
            throw "Remote error: $($payload.error)"
        }
    }
}