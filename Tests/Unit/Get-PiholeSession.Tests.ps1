[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingConvertToSecureStringWithPlainText',
    '',
    Justification = 'Unit tests use deterministic fake credentials only.'
)]
param()

BeforeAll {
    Import-Module "$PSScriptRoot/../../PSPiHole.psd1" -Force
    . "$PSScriptRoot/_Common.ps1"
}

Describe 'Get-PiholeSession (private)' {
    BeforeEach {
        Reset-PiholeModuleState
    }

    It 'POSTs the password to /api/auth and returns a session object' {
        InModuleScope PSPiHole {
            Mock Invoke-RestMethod {
                @{session = @{valid = $true; sid = 'sid-abc'; csrf = 'csrf-abc'; validity = 1800}}
            }

            $ctx = [pscustomobject]@{
                PSTypeName           = 'PSPiHole.Context'
                Server               = 'pihole.test'
                BaseUri              = 'https://pihole.test/api'
                SkipCertificateCheck = $false
                Credential           = [pscredential]::new(
                    'pihole',
                    (ConvertTo-SecureString 'mypw' -AsPlainText -Force)
                )
                Session              = $null
            }

            $session = Get-PiholeSession -Context $ctx

            $session.Sid                | Should -Be 'sid-abc'
            $session.Csrf               | Should -Be 'csrf-abc'
            $session.Validity           | Should -Be 1800
            $session.PSObject.TypeNames | Should -Contain 'PSPiHole.Session'

            Should -Invoke Invoke-RestMethod -Times 1 -Exactly -ParameterFilter {
                $Uri    -eq 'https://pihole.test/api/auth' -and
                $Method -eq 'POST' -and
                ($Body | ConvertFrom-Json).password -eq 'mypw'
            }
        }
    }

    It 'throws when the API reports invalid credentials' {
        InModuleScope PSPiHole {
            Mock Invoke-RestMethod {
                @{session = @{valid = $false; message = 'wrong password'}}
            }

            $ctx = [pscustomobject]@{
                BaseUri              = 'https://pihole.test/api'
                Server               = 'pihole.test'
                SkipCertificateCheck = $false
                Credential           = [pscredential]::new(
                    'pihole',
                    (ConvertTo-SecureString 'bad' -AsPlainText -Force)
                )
            }

            {Get-PiholeSession -Context $ctx} | Should -Throw '*authentication failed*'
        }
    }

    It 'forwards SkipCertificateCheck to Invoke-RestMethod' {
        InModuleScope PSPiHole {
            Mock Invoke-RestMethod {
                @{session = @{valid = $true; sid = 's'; csrf = 'c'; validity = 1}}
            }

            $ctx = [pscustomobject]@{
                BaseUri              = 'https://pihole.test/api'
                Server               = 'pihole.test'
                SkipCertificateCheck = $true
                Credential           = [pscredential]::new(
                    'pihole',
                    (ConvertTo-SecureString 'pw' -AsPlainText -Force)
                )
            }

            Get-PiholeSession -Context $ctx | Out-Null

            Should -Invoke Invoke-RestMethod -Times 1 -Exactly -ParameterFilter {
                $SkipCertificateCheck -eq $true
            }
        }
    }

    It 'throws when the context has no credential' {
        InModuleScope PSPiHole {
            $ctx = [pscustomobject]@{BaseUri = 'https://x/api'; Server = 'x'; Credential = $null}
            {Get-PiholeSession -Context $ctx} | Should -Throw '*no credential*'
        }
    }
}
