BeforeAll {
    Import-Module "$PSScriptRoot/../../PSPiHole.psd1" -Force
    . "$PSScriptRoot/_Common.ps1"
}

Describe 'ConvertTo-PiholeDnsRecord (private)' {
    It 'splits a "<IP> <Hostname>" string into properties' {
        InModuleScope PSPiHole {
            $rec = ConvertTo-PiholeDnsRecord -InputObject '192.168.10.91 pihole1.lan'

            $rec.IPAddress | Should -Be '192.168.10.91'
            $rec.Hostname  | Should -Be 'pihole1.lan'
            $rec.PSObject.TypeNames | Should -Contain 'PSPiHole.DnsRecord'
        }
    }

    It 'tolerates multiple whitespace between IP and hostname' {
        InModuleScope PSPiHole {
            $rec = ConvertTo-PiholeDnsRecord -InputObject "10.0.0.1`t`thost.lan"
            $rec.IPAddress | Should -Be '10.0.0.1'
            $rec.Hostname  | Should -Be 'host.lan'
        }
    }

    It 'returns nothing for empty input' {
        InModuleScope PSPiHole {
            (ConvertTo-PiholeDnsRecord -InputObject '   ') | Should -BeNullOrEmpty
        }
    }

    It 'warns and emits nothing for malformed input' {
        InModuleScope PSPiHole {
            $convertSplat = @{
                InputObject   = 'no-spaces-here'
                WarningVariable = 'warns'
                WarningAction = 'SilentlyContinue'
            }
            $rec = ConvertTo-PiholeDnsRecord @convertSplat
            $rec   | Should -BeNullOrEmpty
            $warns | Should -Not -BeNullOrEmpty
        }
    }

    It 'accepts pipeline input' {
        InModuleScope PSPiHole {
            $records = '1.1.1.1 a.lan', '2.2.2.2 b.lan' | ConvertTo-PiholeDnsRecord
            $records.Count          | Should -Be 2
            $records[0].Hostname    | Should -Be 'a.lan'
            $records[1].IPAddress   | Should -Be '2.2.2.2'
        }
    }
}

Describe 'ConvertFrom-PiholeDnsRecord (private)' {
    It 'URL-encodes "<IP> <Hostname>" as a single path segment' {
        InModuleScope PSPiHole {
            ConvertFrom-PiholeDnsRecord -Hostname 'pihole1.lan' -IPAddress '192.168.10.91' |
                Should -Be '192.168.10.91%20pihole1.lan'
        }
    }

    It 'escapes special characters in the hostname' {
        InModuleScope PSPiHole {
            ConvertFrom-PiholeDnsRecord -Hostname 'a&b.lan' -IPAddress '10.0.0.1' |
                Should -Be '10.0.0.1%20a%26b.lan'
        }
    }
}
