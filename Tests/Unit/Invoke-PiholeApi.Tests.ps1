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

Describe 'Invoke-PiholeApi (private)' {
    BeforeEach {
        Reset-PiholeModuleState
    }

    Context 'lazy auth' {
        It 'auths on first call when no session is cached, then sends sid header' {
            InModuleScope PSPiHole {
                Mock Invoke-RestMethod -ParameterFilter {$Uri -match '/auth$'} -MockWith {
                    @{session = @{valid = $true; sid = 'sid-1'; csrf = 'c'; validity = 1800}}
                }
                Mock Invoke-RestMethod -ParameterFilter {$Uri -match '/config/dns$'} -MockWith {
                    @{config = @{dns = @{hosts = @()}}}
                }

                $ctx = [pscustomobject]@{
                    PSTypeName           = 'PSPiHole.Context'
                    Server               = 'pihole.test'
                    BaseUri              = 'https://pihole.test/api'
                    SkipCertificateCheck = $false
                    Credential           = [pscredential]::new(
                        'pihole',
                        (ConvertTo-SecureString 'pw' -AsPlainText -Force)
                    )
                    Session              = $null
                }

                Invoke-PiholeApi -Context $ctx -Method GET -Path 'config/dns' | Out-Null

                $ctx.Session.Sid | Should -Be 'sid-1'

                Should -Invoke Invoke-RestMethod -Times 1 -Exactly -ParameterFilter {$Uri -match '/auth$'}
                Should -Invoke Invoke-RestMethod -Times 1 -Exactly -ParameterFilter {
                    $Uri -match '/config/dns$' -and $Headers.sid -eq 'sid-1'
                }
            }
        }

        It 'reuses an already-cached session without re-authing' {
            InModuleScope PSPiHole {
                Mock Invoke-RestMethod -ParameterFilter {$Uri -match '/auth$'} -MockWith {
                    @{session = @{valid = $true; sid = 'should-not-be-used'; csrf = 'c'; validity = 1800}}
                }
                Mock Invoke-RestMethod -ParameterFilter {$Uri -match '/config/dns$'} -MockWith {
                    @{ok = $true}
                }

                $ctx = [pscustomobject]@{
                    BaseUri              = 'https://pihole.test/api'
                    Server               = 'pihole.test'
                    SkipCertificateCheck = $false
                    Credential           = [pscredential]::new(
                        'pihole',
                        (ConvertTo-SecureString 'pw' -AsPlainText -Force)
                    )
                    Session              = [pscustomobject]@{
                        Sid = 'cached-sid'; Csrf = 'cached'; Validity = 1800; AuthedAt = Get-Date
                    }
                }

                Invoke-PiholeApi -Context $ctx -Method GET -Path 'config/dns' | Out-Null

                Should -Invoke Invoke-RestMethod -Times 0 -Exactly -ParameterFilter {$Uri -match '/auth$'}
                Should -Invoke Invoke-RestMethod -Times 1 -Exactly -ParameterFilter {
                    $Headers.sid -eq 'cached-sid'
                }
            }
        }
    }

    Context '401 retry' {
        It 're-auths and retries once on a 401' {
            InModuleScope PSPiHole {
                $script:sessionCallCount = 0
                Mock Invoke-RestMethod -ParameterFilter {$Uri -match '/auth$'} -MockWith {
                    $script:sessionCallCount++
                    @{
                        session = @{
                            valid    = $true
                            sid      = "sid-$script:sessionCallCount"
                            csrf     = 'c'
                            validity = 1800
                        }
                    }
                }

                $script:dnsCallCount = 0
                Mock Invoke-RestMethod -ParameterFilter {$Uri -match '/config/dns$'} -MockWith {
                    $script:dnsCallCount++
                    if ($script:dnsCallCount -eq 1) {
                        $resp = [pscustomobject]@{StatusCode = [System.Net.HttpStatusCode]::Unauthorized}
                        $exc  = [System.Exception]::new('Unauthorized')
                        Add-Member -InputObject $exc -MemberType NoteProperty -Name Response -Value $resp -Force
                        throw $exc
                    }
                    @{ok = $true}
                }

                $ctx = [pscustomobject]@{
                    BaseUri              = 'https://pihole.test/api'
                    Server               = 'pihole.test'
                    SkipCertificateCheck = $false
                    Credential           = [pscredential]::new(
                        'pihole',
                        (ConvertTo-SecureString 'pw' -AsPlainText -Force)
                    )
                    Session              = [pscustomobject]@{
                        Sid = 'stale-sid'; Csrf = 'c'; Validity = 1800; AuthedAt = Get-Date
                    }
                }

                Invoke-PiholeApi -Context $ctx -Method GET -Path 'config/dns' | Out-Null

                $script:sessionCallCount | Should -Be 1
                $script:dnsCallCount     | Should -Be 2
                $ctx.Session.Sid         | Should -Be 'sid-1'
            }
        }

        It 'rethrows non-401 errors without retry' {
            InModuleScope PSPiHole {
                Mock Invoke-RestMethod -ParameterFilter {$Uri -match '/auth$'} -MockWith {
                    @{session = @{valid = $true; sid = 's'; csrf = 'c'; validity = 1800}}
                }
                Mock Invoke-RestMethod -ParameterFilter {$Uri -match '/config/dns$'} -MockWith {
                    $resp = [pscustomobject]@{StatusCode = [System.Net.HttpStatusCode]::InternalServerError}
                    $exc  = [System.Exception]::new('boom')
                    Add-Member -InputObject $exc -MemberType NoteProperty -Name Response -Value $resp -Force
                    throw $exc
                }

                $ctx = [pscustomobject]@{
                    BaseUri              = 'https://pihole.test/api'
                    Server               = 'pihole.test'
                    SkipCertificateCheck = $false
                    Credential           = [pscredential]::new(
                        'pihole',
                        (ConvertTo-SecureString 'pw' -AsPlainText -Force)
                    )
                    Session              = [pscustomobject]@{
                        Sid = 's'; Csrf = 'c'; Validity = 1800; AuthedAt = Get-Date
                    }
                }

                {Invoke-PiholeApi -Context $ctx -Method GET -Path 'config/dns'} | Should -Throw

                Should -Invoke Invoke-RestMethod -Times 1 -Exactly -ParameterFilter {$Uri -match '/config/dns$'}
            }
        }
    }

    Context 'request shape' {
        It 'serialises -Body to JSON and sets Content-Type' {
            InModuleScope PSPiHole {
                Mock Invoke-RestMethod -ParameterFilter {$Uri -match '/auth$'} -MockWith {
                    @{session = @{valid = $true; sid = 's'; csrf = 'c'; validity = 1800}}
                }
                Mock Invoke-RestMethod -ParameterFilter {$Uri -notmatch '/auth$'} -MockWith {
                    @{ok = $true}
                }

                $ctx = [pscustomobject]@{
                    BaseUri              = 'https://pihole.test/api'
                    Server               = 'pihole.test'
                    SkipCertificateCheck = $false
                    Credential           = [pscredential]::new(
                        'pihole',
                        (ConvertTo-SecureString 'pw' -AsPlainText -Force)
                    )
                    Session              = [pscustomobject]@{
                        Sid = 's'; Csrf = 'c'; Validity = 1800; AuthedAt = Get-Date
                    }
                }

                Invoke-PiholeApi -Context $ctx -Method POST -Path 'foo' -Body @{a = 1} | Out-Null

                Should -Invoke Invoke-RestMethod -Times 1 -Exactly -ParameterFilter {
                    $Uri         -eq 'https://pihole.test/api/foo'           -and
                    $Method      -eq 'POST'                                  -and
                    $ContentType -eq 'application/json'                      -and
                    ($Body | ConvertFrom-Json).a -eq 1
                }
            }
        }

        It 'forwards SkipCertificateCheck' {
            InModuleScope PSPiHole {
                Mock Invoke-RestMethod -ParameterFilter {$Uri -match '/config/dns$'} -MockWith {@{ok = $true}}

                $ctx = [pscustomobject]@{
                    BaseUri              = 'https://pihole.test/api'
                    Server               = 'pihole.test'
                    SkipCertificateCheck = $true
                    Credential           = [pscredential]::new(
                        'pihole',
                        (ConvertTo-SecureString 'pw' -AsPlainText -Force)
                    )
                    Session              = [pscustomobject]@{
                        Sid = 's'; Csrf = 'c'; Validity = 1800; AuthedAt = Get-Date
                    }
                }

                Invoke-PiholeApi -Context $ctx -Method GET -Path 'config/dns' | Out-Null

                Should -Invoke Invoke-RestMethod -Times 1 -Exactly -ParameterFilter {
                    $SkipCertificateCheck -eq $true
                }
            }
        }
    }
}
