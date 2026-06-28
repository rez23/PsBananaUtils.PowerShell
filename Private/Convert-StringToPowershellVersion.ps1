class PowerShellVersion {
    [int]$Major
    [int]$Minor
    [int]$Build
    [int]$Revision

    PowerShellVersion([PsCustomObject]$version) {
        $this.Major = $version.Major
        $this.Minor = $version.Minor
        $this.Build = $version.Build
        $this.Revision = $version.Revision
    }
    PowerShellVersion([int]$major, [int]$minor, [int]$build, [int]$revision) {
        $this.Major = $major
        $this.Minor = $minor
        $this.Build = $build
        $this.Revision = $revision
    }

    [string] ToString() {
        return "$($this.Major).$($this.Minor).$($this.Build).$($this.Revision)"
    }
}

function Convert-FromStringToPowerShellVersion {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$PwshPath,

        [Parameter(Mandatory = $false)]
        [switch]$Major,
        [Parameter(Mandatory = $false)]
        [switch]$Minor,
        [Parameter(Mandatory = $false)]
        [switch]$Build,
        [Parameter(Mandatory = $false)]
        [switch]$Revision,
        [Parameter(Mandatory = $false)]
        [switch]$Exact
    )

    # Example string: C:\Program Files\WindowsApps\Microsoft.PowerShell_7.6.3.0_x64__8wekyb3d8bbwe\pwsh.exe
    # Use regex to extract the version number from the string
    if ($PwshPath -match "(\d+)\.(\d+)\.*(\d*)\.*(\d*)") {
        $version = [PowerShellVersion]::new([PSCustomObject]@{
            Major    = [int]$matches[1]
            Minor    = [int]$matches[2]
            Build    = [int]$matches[3]
            Revision = [int]$matches[4]
        })
        
        if ($Major) {
            $version.Major
        }
        elseif ($Minor) {
            $version.Minor
        }
        elseif ($Build) {
            $version.Build
        }
        elseif ($Revision) {
            $version.Revision
        }
        elseif ($Exact) {
            if ($matches[0] -eq "1.0") {
                "5.0"
            }
            else {
                $matches[0]
            }
        }
        else {
            $version
        }
    }
    else {
        "?"
    }
}