BeforeAll {
    Import-Module "$PSScriptRoot/../../PSPiHole.psd1" -Force
    . "$PSScriptRoot/_Common.ps1"
}

Describe 'Set-PiholeContext' {
    BeforeEach {
        Reset-PiholeModuleState
        Remove-Item Env:PIHOLE_PASSWORD -ErrorAction SilentlyContinue
    }

    Context 'with -Credential' {
        It 'stores a context with the supplied credential' {
            $cred = New-PiholeTestCredential -Password 'secret'

            Set-PiholeContext -Server 'pihole.test' -Credential $cred

            InModuleScope PSPiHole {
                $script:PiholeContext | Should -Not -BeNullOrEmpty
                $script:PiholeContext.Server | Should -Be 'pihole.test'
                $script:PiholeContext.BaseUri | Should -Be 'https://pihole.test/api'
                $script:PiholeContext.SkipCertificateCheck | Should -BeFalse
                $testCred = $script:PiholeContext.Credential.GetNetworkCredential().Password
                $testCred | Should -Be 'secret'
                $script:PiholeContext.Session | Should -BeNullOrEmpty
            }
        }

        It 'sets SkipCertificateCheck when the switch is passed' {
            Set-PiholeContext -Server 'pihole.test' -Credential (New-PiholeTestCredential) -SkipCertificateCheck

            InModuleScope PSPiHole {
                $script:PiholeContext.SkipCertificateCheck | Should -BeTrue
            }
        }

        It 'returns the context object with -PassThru' {
            $result = Set-PiholeContext -Server 'pihole.test' -Credential (New-PiholeTestCredential) -PassThru

            $result                | Should -Not -BeNullOrEmpty
            $result.Server         | Should -Be 'pihole.test'
            $result.PSObject.TypeNames | Should -Contain 'PSPiHole.Context'
        }

        It 'returns nothing without -PassThru' {
            $result = Set-PiholeContext -Server 'pihole.test' -Credential (New-PiholeTestCredential)

            $result | Should -BeNullOrEmpty
        }
    }

    Context 'with -Password' {
        It 'wraps the SecureString into a credential' {
            $secure = ConvertTo-SecureString 'topsecret' -AsPlainText -Force

            Set-PiholeContext -Server 'pihole.test' -Password $secure

            InModuleScope PSPiHole {
                $script:PiholeContext.Credential.GetNetworkCredential().Password | Should -Be 'topsecret'
            }
        }
    }

    Context 'env-var fallback' {
        It 'uses $env:PIHOLE_PASSWORD when neither -Credential nor -Password is supplied' {
            $env:PIHOLE_PASSWORD = 'fromenv'

            Set-PiholeContext -Server 'pihole.test' -WarningVariable warnings -WarningAction SilentlyContinue

            $warnings.Count | Should -BeGreaterThan 0
            ($warnings -join ' ') | Should -Match 'PIHOLE_PASSWORD'

            InModuleScope PSPiHole {
                $script:PiholeContext.Credential.GetNetworkCredential().Password | Should -Be 'fromenv'
            }
        }

        It 'throws when nothing is supplied and the env var is not set' {
            {Set-PiholeContext -Server 'pihole.test'} | Should -Throw '*No credential supplied*'
        }
    }

    Context 'idempotency / replacement' {
        It 'overwrites a previously set context' {
            Set-PiholeContext -Server 'first.lan' -Credential (New-PiholeTestCredential -Password 'a')
            Set-PiholeContext -Server 'second.lan' -Credential (New-PiholeTestCredential -Password 'b')

            InModuleScope PSPiHole {
                $script:PiholeContext.Server                                       | Should -Be 'second.lan'
                $script:PiholeContext.Credential.GetNetworkCredential().Password   | Should -Be 'b'
            }
        }
    }
}