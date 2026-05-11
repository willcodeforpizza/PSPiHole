BeforeAll {
    Import-Module "$PSScriptRoot/../../PSPiHole.psd1" -Force
    . "$PSScriptRoot/_Common.ps1"
}

Describe 'Add-PiholeDomain' {
    BeforeEach {
        Reset-PiholeModuleState
        Set-PiholeContext -Server 'pihole.test' -Credential (New-PiholeTestCredential)
    }

    It 'POSTs a domain to /api/domains/{type}/{kind}' {
        Mock -ModuleName PSPiHole Invoke-PiholeApi {}

        Add-PiholeDomain -Type deny -Kind exact -Domain 'ads.example.com' -Comment 'Ads' -GroupId 0, 2

        Should -Invoke -ModuleName PSPiHole Invoke-PiholeApi -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'POST' -and
            $Path -eq 'domains/deny/exact' -and
            $Body.domain -eq 'ads.example.com' -and
            $Body.comment -eq 'Ads' -and
            $Body.enabled -eq $true -and
            $Body.groups.Count -eq 2
        }
    }

    It 'accepts pipeline input by value' {
        Mock -ModuleName PSPiHole Invoke-PiholeApi {}

        'a.example', 'b.example' | Add-PiholeDomain -Type allow -Kind exact

        Should -Invoke -ModuleName PSPiHole Invoke-PiholeApi -Times 2 -Exactly
        Should -Invoke -ModuleName PSPiHole Invoke-PiholeApi -Times 1 -Exactly -ParameterFilter {
            $Body.domain -eq 'a.example'
        }
        Should -Invoke -ModuleName PSPiHole Invoke-PiholeApi -Times 1 -Exactly -ParameterFilter {
            $Body.domain -eq 'b.example'
        }
    }

    It 'can send multiple domains in one request' {
        Mock -ModuleName PSPiHole Invoke-PiholeApi {}

        Add-PiholeDomain -Type deny -Kind exact -Domain 'a.example', 'b.example' -Enabled:$false

        Should -Invoke -ModuleName PSPiHole Invoke-PiholeApi -Times 1 -Exactly -ParameterFilter {
            $Body.domain.Count -eq 2 -and
            $Body.enabled -eq $false
        }
    }

    It 'honours -WhatIf (no API call)' {
        Mock -ModuleName PSPiHole Invoke-PiholeApi {}

        Add-PiholeDomain -Type deny -Kind exact -Domain 'ads.example.com' -WhatIf

        Should -Invoke -ModuleName PSPiHole Invoke-PiholeApi -Times 0 -Exactly
    }

    It 'uses an explicit -Context when supplied' {
        $explicit = New-PiholeTestContext -Server 'other.lan' -WithSession
        Mock -ModuleName PSPiHole Invoke-PiholeApi {}

        Add-PiholeDomain -Type deny -Kind exact -Domain 'ads.example.com' -Context $explicit

        Should -Invoke -ModuleName PSPiHole Invoke-PiholeApi -Times 1 -Exactly -ParameterFilter {
            $Context.Server -eq 'other.lan'
        }
    }

    It 'throws when no context is set and none is supplied' {
        Reset-PiholeModuleState

        {Add-PiholeDomain -Type deny -Kind exact -Domain 'ads.example.com'} |
            Should -Throw '*No Pi-hole context*'
    }
}
