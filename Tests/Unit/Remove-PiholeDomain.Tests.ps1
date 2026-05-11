BeforeAll {
    Import-Module "$PSScriptRoot/../../PSPiHole.psd1" -Force
    . "$PSScriptRoot/_Common.ps1"
}

Describe 'Remove-PiholeDomain' {
    BeforeEach {
        Reset-PiholeModuleState
        Set-PiholeContext -Server 'pihole.test' -Credential (New-PiholeTestCredential)
    }

    It 'DELETEs a URL-encoded domain resource' {
        Mock -ModuleName PSPiHole Invoke-PiholeApi {}

        Remove-PiholeDomain -Type deny -Kind regex -Domain '(^|\.)ads\.example$' -Confirm:$false

        Should -Invoke -ModuleName PSPiHole Invoke-PiholeApi -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'DELETE' -and
            $Path -eq 'domains/deny/regex/%28%5E%7C%5C.%29ads%5C.example%24'
        }
    }

    It 'accepts Get-PiholeDomain output via the pipeline' {
        Mock -ModuleName PSPiHole Invoke-PiholeApi {}
        $domains = @(
            [pscustomobject]@{PSTypeName = 'PSPiHole.Domain'; Domain = 'a.example'; Type = 'allow'; Kind = 'exact'}
            [pscustomobject]@{PSTypeName = 'PSPiHole.Domain'; Domain = 'b.example'; Type = 'deny'; Kind = 'regex'}
        )

        $domains | Remove-PiholeDomain -Confirm:$false

        Should -Invoke -ModuleName PSPiHole Invoke-PiholeApi -Times 2 -Exactly
        Should -Invoke -ModuleName PSPiHole Invoke-PiholeApi -Times 1 -Exactly -ParameterFilter {
            $Path -eq 'domains/allow/exact/a.example'
        }
        Should -Invoke -ModuleName PSPiHole Invoke-PiholeApi -Times 1 -Exactly -ParameterFilter {
            $Path -eq 'domains/deny/regex/b.example'
        }
    }

    It 'honours -WhatIf (no API call)' {
        Mock -ModuleName PSPiHole Invoke-PiholeApi {}

        Remove-PiholeDomain -Type deny -Kind exact -Domain 'ads.example.com' -WhatIf

        Should -Invoke -ModuleName PSPiHole Invoke-PiholeApi -Times 0 -Exactly
    }

    It 'uses an explicit -Context when supplied' {
        $explicit = New-PiholeTestContext -Server 'other.lan' -WithSession
        Mock -ModuleName PSPiHole Invoke-PiholeApi {}

        Remove-PiholeDomain -Type deny -Kind exact -Domain 'ads.example.com' -Context $explicit -Confirm:$false

        Should -Invoke -ModuleName PSPiHole Invoke-PiholeApi -Times 1 -Exactly -ParameterFilter {
            $Context.Server -eq 'other.lan'
        }
    }

    It 'throws when no context is set and none is supplied' {
        Reset-PiholeModuleState

        {Remove-PiholeDomain -Type deny -Kind exact -Domain 'ads.example.com' -Confirm:$false} |
            Should -Throw '*No Pi-hole context*'
    }
}
