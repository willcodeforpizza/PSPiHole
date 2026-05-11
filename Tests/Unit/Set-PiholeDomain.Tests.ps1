BeforeAll {
    Import-Module "$PSScriptRoot/../../PSPiHole.psd1" -Force
    . "$PSScriptRoot/_Common.ps1"
}

Describe 'Set-PiholeDomain' {
    BeforeEach {
        Reset-PiholeModuleState
        Set-PiholeContext -Server 'pihole.test' -Credential (New-PiholeTestCredential)
    }

    It 'PUTs updates to a URL-encoded domain resource' {
        Mock -ModuleName PSPiHole Invoke-PiholeApi {}

        $setParams = @{
            Type    = 'deny'
            Kind    = 'regex'
            Domain  = '(^|\.)ads\.example$'
            Comment = 'Ads'
            GroupId = 0
            Enabled = $false
        }

        Set-PiholeDomain @setParams

        Should -Invoke -ModuleName PSPiHole Invoke-PiholeApi -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'PUT' -and
            $Path -eq 'domains/deny/regex/%28%5E%7C%5C.%29ads%5C.example%24' -and
            $Body.comment -eq 'Ads' -and
            $Body.enabled -eq $false -and
            $Body.groups[0] -eq 0
        }
    }

    It 'can move a domain when NewType and NewKind are supplied together' {
        Mock -ModuleName PSPiHole Invoke-PiholeApi {}

        Set-PiholeDomain -Type allow -Kind exact -Domain 'ads.example.com' -NewType deny -NewKind exact

        Should -Invoke -ModuleName PSPiHole Invoke-PiholeApi -Times 1 -Exactly -ParameterFilter {
            $Body.type -eq 'deny' -and
            $Body.kind -eq 'exact'
        }
    }

    It 'accepts Get-PiholeDomain output via the pipeline' {
        Mock -ModuleName PSPiHole Invoke-PiholeApi {}
        $domain = [pscustomobject]@{
            PSTypeName = 'PSPiHole.Domain'
            Domain     = 'ads.example.com'
            Type       = 'deny'
            Kind       = 'exact'
        }

        $domain | Set-PiholeDomain -Enabled:$false

        Should -Invoke -ModuleName PSPiHole Invoke-PiholeApi -Times 1 -Exactly -ParameterFilter {
            $Path -eq 'domains/deny/exact/ads.example.com' -and
            $Body.enabled -eq $false
        }
    }

    It 'requires NewType and NewKind together' {
        Mock -ModuleName PSPiHole Invoke-PiholeApi {}

        {Set-PiholeDomain -Type allow -Kind exact -Domain 'ads.example.com' -NewType deny} |
            Should -Throw '*NewType and NewKind*'

        Should -Invoke -ModuleName PSPiHole Invoke-PiholeApi -Times 0 -Exactly
    }

    It 'requires at least one update property' {
        Mock -ModuleName PSPiHole Invoke-PiholeApi {}

        {Set-PiholeDomain -Type allow -Kind exact -Domain 'ads.example.com'} |
            Should -Throw '*at least one property*'

        Should -Invoke -ModuleName PSPiHole Invoke-PiholeApi -Times 0 -Exactly
    }

    It 'honours -WhatIf (no API call)' {
        Mock -ModuleName PSPiHole Invoke-PiholeApi {}

        Set-PiholeDomain -Type deny -Kind exact -Domain 'ads.example.com' -Enabled:$false -WhatIf

        Should -Invoke -ModuleName PSPiHole Invoke-PiholeApi -Times 0 -Exactly
    }
}
