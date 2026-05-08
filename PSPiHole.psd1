@{
    RootModule = 'PSPiHole.psm1'
    ModuleVersion = '0.1.0'
    GUID = '828c7782-4c83-429a-9d3a-c82eb174c0de'
    Author = 'Martin Howlett'
    Description = 'PowerShell wrapper around the Pi-hole v6 API.'
    PowerShellVersion = '7.0'
    FunctionsToExport = @(
        'Add-PiholeDnsRecord',
        'Clear-PiholeContext',
        'Get-PiholeContext',
        'Get-PiholeDnsRecord',
        'Remove-PiholeDnsRecord',
        'Set-PiholeContext'
    )
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('Pi-hole', 'PiHole', 'DNS', 'API')
        }
    }
}
