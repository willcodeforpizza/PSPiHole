BeforeAll {
    Import-Module "$PSScriptRoot/../../PSPiHole.psd1" -Force
    . "$PSScriptRoot/_Common.ps1"
}

Describe 'Get-PiholeDomain' {
    BeforeEach {
        Reset-PiholeModuleState
        Set-PiholeContext -Server 'pihole.test' -Credential (New-PiholeTestCredential)
    }

    It 'returns parsed domains sorted by type, kind, and domain' {
        Mock -ModuleName PSPiHole Invoke-PiholeApi {
            @{
                domains = @(
                    @{
                        domain        = 'z.example'
                        unicode       = 'z.example'
                        type          = 'deny'
                        kind          = 'regex'
                        comment       = 'Z'
                        groups        = @(0, 2)
                        enabled       = $true
                        id            = 2
                        date_added    = 100
                        date_modified = 200
                    }
                    @{
                        domain        = 'a.example'
                        unicode       = 'a.example'
                        type          = 'allow'
                        kind          = 'exact'
                        comment       = $null
                        groups        = @(0)
                        enabled       = $false
                        id            = 1
                        date_added    = 90
                        date_modified = 190
                    }
                )
            }
        }

        $domains = Get-PiholeDomain

        $domains.Count                 | Should -Be 2
        $domains[0].Domain             | Should -Be 'a.example'
        $domains[0].Type               | Should -Be 'allow'
        $domains[0].Kind               | Should -Be 'exact'
        $domains[0].Enabled            | Should -BeFalse
        $domains[0].PSObject.TypeNames | Should -Contain 'PSPiHole.Domain'
        $domains[1].Domain             | Should -Be 'z.example'
    }

    It 'queries all domains when no filters are supplied' {
        Mock -ModuleName PSPiHole Invoke-PiholeApi {
            @{domains = @()}
        }

        Get-PiholeDomain | Out-Null

        Should -Invoke -ModuleName PSPiHole Invoke-PiholeApi -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'GET' -and
            $Path -eq 'domains'
        }
    }

    It 'queries a typed and kinded domain using a URL-encoded path' {
        Mock -ModuleName PSPiHole Invoke-PiholeApi {
            @{domains = @()}
        }

        Get-PiholeDomain -Type deny -Kind regex -Domain '(^|\.)ads\.example$' | Out-Null

        Should -Invoke -ModuleName PSPiHole Invoke-PiholeApi -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'GET' -and
            $Path -eq 'domains/deny/regex/%28%5E%7C%5C.%29ads%5C.example%24'
        }
    }

    It 'uses the explicit -Context when supplied' {
        $explicit = New-PiholeTestContext -Server 'other.lan' -WithSession
        Mock -ModuleName PSPiHole Invoke-PiholeApi {
            @{domains = @()}
        }

        Get-PiholeDomain -Context $explicit | Out-Null

        Should -Invoke -ModuleName PSPiHole Invoke-PiholeApi -Times 1 -Exactly -ParameterFilter {
            $Context.Server -eq 'other.lan'
        }
    }

    It 'throws when no context is set and none is supplied' {
        Reset-PiholeModuleState

        {Get-PiholeDomain} | Should -Throw '*No Pi-hole context*'
    }
}
