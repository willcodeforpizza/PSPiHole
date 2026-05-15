@{
    RootModule = 'PSPiHole.psm1'
    ModuleVersion = '0.1.5'
    GUID = '828c7782-4c83-429a-9d3a-c82eb174c0de'
    Author = 'Martin Howlett'
    Description = 'PowerShell wrapper around the Pi-hole v6 API.'
    PowerShellVersion = '7.0'
    FunctionsToExport = @(
        'Add-PiholeDomain',
        'Add-PiholeDnsRecord',
        'Clear-PiholeContext',
        'Get-PiholeContext',
        'Get-PiholeDomain',
        'Get-PiholeDnsRecord',
        'Remove-PiholeDomain',
        'Remove-PiholeDnsRecord',
        'Set-PiholeDomain',
        'Set-PiholeContext'
    )
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    ModuleList = @(
        @{
            ModuleName = 'Plumber'
            ModuleVersion = '0.0.27'
        }
        @{
            ModuleName = 'Plumber.Release'
            ModuleVersion = '0.1.0'
        }
        @{
            ModuleName = 'InvokeBuild'
            ModuleVersion = '5.14.23'
        }
        @{
            ModuleName = 'Pester'
            ModuleVersion = '5.7.1'
        }
        @{
            ModuleName = 'PSScriptAnalyzer'
            ModuleVersion = '1.25.0'
        }
        @{
            ModuleName = 'powershell-yaml'
            ModuleVersion = '0.4.12'
        }
        @{
            ModuleName = 'Microsoft.PowerShell.PSResourceGet'
            ModuleVersion = '1.2.0'
        }
    )
    PrivateData = @{
        PSData = @{
            Tags = @('Pi-hole', 'PiHole', 'DNS', 'API')
            LicenseUri = 'https://github.com/willcodeforpizza/PSPiHole/blob/main/LICENSE'
            ProjectUri = 'https://github.com/willcodeforpizza/PSPiHole'
            ReleaseNotes = 'https://github.com/willcodeforpizza/PSPiHole/blob/main/CHANGELOG.md'
        }
    }
}
