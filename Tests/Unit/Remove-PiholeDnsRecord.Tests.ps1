BeforeAll {
    Import-Module "$PSScriptRoot/../../PSPiHole.psd1" -Force
    . "$PSScriptRoot/_Common.ps1"
}

Describe 'Remove-PiholeDnsRecord' {
    BeforeEach {
        Reset-PiholeModuleState
        Set-PiholeContext -Server 'pihole.test' -Credential (New-PiholeTestCredential)
    }

    It 'DELETEs a URL-encoded record from /api/config/dns/hosts' {
        Mock -ModuleName PSPiHole Invoke-PiholeApi {}

        Remove-PiholeDnsRecord -Hostname 'pihole1.lan' -IPAddress '192.168.10.91' -Confirm:$false

        Should -Invoke -ModuleName PSPiHole Invoke-PiholeApi -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'DELETE' -and
            $Path   -eq 'config/dns/hosts/192.168.10.91%20pihole1.lan'
        }
    }

    It 'accepts Get-PiholeDnsRecord output via the pipeline' {
        Mock -ModuleName PSPiHole Invoke-PiholeApi {}

        # Records of the same shape Get-PiholeDnsRecord emits
        $records = @(
            [pscustomobject]@{PSTypeName = 'PSPiHole.DnsRecord'; Hostname = 'a.lan'; IPAddress = '10.0.0.1'}
            [pscustomobject]@{PSTypeName = 'PSPiHole.DnsRecord'; Hostname = 'b.lan'; IPAddress = '10.0.0.2'}
        )

        $records | Remove-PiholeDnsRecord -Confirm:$false

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

        Remove-PiholeDnsRecord -Hostname 'x.lan' -IPAddress '10.0.0.1' -WhatIf

        Should -Invoke -ModuleName PSPiHole Invoke-PiholeApi -Times 0 -Exactly
    }

    It 'uses an explicit -Context when supplied' {
        $explicit = New-PiholeTestContext -Server 'other.lan' -WithSession
        Mock -ModuleName PSPiHole Invoke-PiholeApi {}

        Remove-PiholeDnsRecord -Hostname 'x.lan' -IPAddress '10.0.0.1' -Context $explicit -Confirm:$false

        Should -Invoke -ModuleName PSPiHole Invoke-PiholeApi -Times 1 -Exactly -ParameterFilter {
            $Context.Server -eq 'other.lan'
        }
    }

    It 'throws when no context is set and none is supplied' {
        Reset-PiholeModuleState

        {Remove-PiholeDnsRecord -Hostname 'x.lan' -IPAddress '10.0.0.1' -Confirm:$false} |
            Should -Throw '*No Pi-hole context*'
    }
}
