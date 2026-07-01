# PsBananaUtils.PowerShell
This is a part of [PsBananaUtils](https://github.com/rez23/PsBananaUtils) module.
# Install the module
Install the module via Install-Module or Install-PsResource
```powershell
# Install the module
Install-PsResource -Name PsBananaUtils.PowerShell -TrustedRepo -Scope CurrentUser

# Then import in your session
Import-Module PsBananaUtils.PowerShell
```
# About the module
Here a list of the main commands from this module:
- `Find-PowerShellHistory`: Permit to find in powershell history and also export `shsearch` alias
- `Get-PathFromCommand`: Ecquivalent of `whereis` on linux (export also `whereis` alias)
- `Get-PowerShellVersions`: List all available PowerShell version founded on the current machine
- `Invoke-CustomPowerShell`: Permit to launch command inside custom PowerShell session withouth lose serialization and withouth the need of exiting from your actual session.

    For example inside PowerShell 5.1:

    ```powershell
    $SomeInputObject | Invoke-PowerShellCustom {Start-CmdletNotCompatibleWithLegacyPowerShell} | ? {
        # this is perfectly tollerated becouse the Invoke-PowerShellCustom produce a serialized valid object
        $_.MyProps -match "MyString"
    }
    ```
    
    `Invoke-PowerShellCustom` also support user defined 

    ```powershell
    $SomeInputObject | Invoke-PowerShellCustom -PsCustomPath ".\Path\To\pwsh.exe" -Command {Start-CmdletNotCompatibleWithLegacyPowerShell} | ? {
        # this is perfectly tollerated becouse the Invoke-PowerShellCustom produce a serialized valid object
        $_.MyProps -match "MyString"
    }
    ```
- `Uninstall-ModuleOneDrive`: Uninistall module placed on OneDrive module folder that for a know bug thrigger Permnission Error using legacy Uninstall-Module   

# Support the project
If you like my work, leave a star on this repository or donate me a coffee:
- [PayPall.me](https://paypal.me/rez23774)
- [Ko-Fi](https://ko-fi.com/spartacoamadei)
