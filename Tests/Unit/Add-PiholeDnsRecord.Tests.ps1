BeforeAll {
    Import-Module "$PSScriptRoot/../../PSPiHole.psd1" -Force
    . "$PSScriptRoot/_Common.ps1"
}

Describe 'Add-PiholeDnsRecord' {
    BeforeEach {
        Reset-PiholeModuleState
        Set-PiholeContext -Server 'pihole.test' -Credential (New-PiholeTestCredential)
    }

    It 'PUTs a URL-encoded record to /api/config/dns/hosts' {
        Mock -ModuleName PSPiHole Invoke-PiholeApi {}

        Add-PiholeDnsRecord -Hostname 'pihole1.lan' -IPAddress '192.168.10.91'

        Should -Invoke -ModuleName PSPiHole Invoke-PiholeApi -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'PUT' -and
            $Path   -eq 'config/dns/hosts/192.168.10.91%20pihole1.lan'
        }
    }

    It 'accepts pipeline input by property name' {
        Mock -ModuleName PSPiHole Invoke-PiholeApi {}

        @(
            [pscustomobject]@{Hostname = 'a.lan'; IPAddress = '10.0.0.1'}
            [pscustomobject]@{Hostname = 'b.lan'; IPAddress = '10.0.0.2'}
        ) | Add-PiholeDnsRecord

        Should -Invoke -ModuleName PSPiHole Invoke-PiholeApi -Times 2 -Exactly
        Should -Invoke -ModuleName PSPiHole Invoke-PiholeApi -Times 1 -Exactly -ParameterFilter {
            $Path -eq 'config/dns/hosts/10.0.0.1%20a.lan'
        }
        Should -Invoke -ModuleName PSPiHole Invoke-PiholeApi -Times 1 -Exactly -ParameterFilter {
            $Path -eq 'config/dns/hosts/10.0.0.2%20b.lan'
        }
    }

    It 'honours -WhatIf (no API call)' {
        Mock -ModuleName PSPiHole Invoke-PiholeApi {}

        Add-PiholeDnsRecord -Hostname 'x.lan' -IPAddress '10.0.0.1' -WhatIf

        Should -Invoke -ModuleName PSPiHole Invoke-PiholeApi -Times 0 -Exactly
    }

    It 'uses an explicit -Context when supplied' {
        $explicit = New-PiholeTestContext -Server 'other.lan' -WithSession
        Mock -ModuleName PSPiHole Invoke-PiholeApi {}

        Add-PiholeDnsRecord -Hostname 'x.lan' -IPAddress '10.0.0.1' -Context $explicit

        Should -Invoke -ModuleName PSPiHole Invoke-PiholeApi -Times 1 -Exactly -ParameterFilter {
            $Context.Server -eq 'other.lan'
        }
    }

    It 'throws when no context is set and none is supplied' {
        Reset-PiholeModuleState

        {Add-PiholeDnsRecord -Hostname 'x.lan' -IPAddress '10.0.0.1'} |
            Should -Throw '*No Pi-hole context*'
    }
}