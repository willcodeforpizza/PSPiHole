BeforeAll {
    Import-Module "$PSScriptRoot/../../PSPiHole.psd1" -Force
    . "$PSScriptRoot/_Common.ps1"
}

Describe 'Get-PiholeDnsRecord' {
    BeforeEach {
        Reset-PiholeModuleState
        Set-PiholeContext -Server 'pihole.test' -Credential (New-PiholeTestCredential)
    }

    It 'returns parsed records sorted by hostname' {
        Mock -ModuleName PSPiHole Invoke-PiholeApi {
            @{
                config = @{
                    dns = @{
                        hosts = @(
                            '192.168.10.92 z-host.lan'
                            '192.168.10.91 a-host.lan'
                        )
                    }
                }
            }
        }

        $records = Get-PiholeDnsRecord

        $records.Count                  | Should -Be 2
        $records[0].Hostname            | Should -Be 'a-host.lan'
        $records[0].IPAddress           | Should -Be '192.168.10.91'
        $records[1].Hostname            | Should -Be 'z-host.lan'
        $records[0].PSObject.TypeNames  | Should -Contain 'PSPiHole.DnsRecord'
    }

    It 'filters by -Hostname using wildcards' {
        Mock -ModuleName PSPiHole Invoke-PiholeApi {
            @{
                config = @{
                    dns = @{
                        hosts = @(
                            '10.0.0.1 alpha.lan'
                            '10.0.0.2 beta.lan'
                            '10.0.0.3 gamma.lan'
                        )
                    }
                }
            }
        }

        $records = Get-PiholeDnsRecord -Hostname 'a*'

        $records.Count        | Should -Be 1
        $records[0].Hostname  | Should -Be 'alpha.lan'
    }

    It 'returns nothing when the hosts array is empty' {
        Mock -ModuleName PSPiHole Invoke-PiholeApi {
            @{config = @{dns = @{hosts = @()}}}
        }

        Get-PiholeDnsRecord | Should -BeNullOrEmpty
    }

    It 'uses the explicit -Context when supplied' {
        $explicit = New-PiholeTestContext -Server 'other.lan' -WithSession
        Mock -ModuleName PSPiHole Invoke-PiholeApi {
            @{config = @{dns = @{hosts = @()}}}
        }

        Get-PiholeDnsRecord -Context $explicit | Out-Null

        Should -Invoke -ModuleName PSPiHole Invoke-PiholeApi -Times 1 -Exactly -ParameterFilter {
            $Context.Server -eq 'other.lan'
        }
    }

    It 'throws when no context is set and none is supplied' {
        Reset-PiholeModuleState

        {Get-PiholeDnsRecord} | Should -Throw '*No Pi-hole context*'
    }
}