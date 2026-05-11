@{
    RootModule = 'PSPiHole.psm1'
    ModuleVersion = '0.1.3'
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
    PrivateData = @{
        PSData = @{
            Tags = @('Pi-hole', 'PiHole', 'DNS', 'API')
            LicenseUri = 'https://github.com/willcodeforpizza/PSPiHole/blob/main/LICENSE'
            ProjectUri = 'https://github.com/willcodeforpizza/PSPiHole'
            ReleaseNotes = 'https://github.com/willcodeforpizza/PSPiHole/blob/main/CHANGELOG.md'
        }
    }
}
