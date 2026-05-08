BeforeAll {
    Import-Module "$PSScriptRoot/../../PSPiHole.psd1" -Force
    . "$PSScriptRoot/_Common.ps1"
}

Describe 'Clear-PiholeContext' {
    BeforeEach {
        Reset-PiholeModuleState
    }

    It 'is a no-op when no context is set' {
        Mock -ModuleName PSPiHole Invoke-RestMethod {}

        Clear-PiholeContext

        Should -Invoke -ModuleName PSPiHole Invoke-RestMethod -Times 0 -Exactly
    }

    It 'clears the context when no session is cached' {
        Set-PiholeContext -Server 'pihole.test' -Credential (New-PiholeTestCredential)
        Mock -ModuleName PSPiHole Invoke-RestMethod {}

        Clear-PiholeContext

        Should -Invoke -ModuleName PSPiHole Invoke-RestMethod -Times 0 -Exactly
        InModuleScope PSPiHole {$script:PiholeContext | Should -BeNullOrEmpty}
    }

    It 'fires DELETE /api/auth and clears state when a session is cached' {
        Set-PiholeContext -Server 'pihole.test' -Credential (New-PiholeTestCredential)
        InModuleScope PSPiHole {
            $script:PiholeContext.Session = [pscustomobject]@{
                Sid = 'sid-x'; Csrf = 'c'; Validity = 1800; AuthedAt = Get-Date
            }
        }

        Mock -ModuleName PSPiHole Invoke-RestMethod {}

        Clear-PiholeContext

        Should -Invoke -ModuleName PSPiHole Invoke-RestMethod -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'DELETE' -and
            $Uri -eq 'https://pihole.test/api/auth' -and
            $Headers.sid -eq 'sid-x'
        }

        InModuleScope PSPiHole {$script:PiholeContext | Should -BeNullOrEmpty}
    }

    It 'still clears local state when the DELETE call throws' {
        Set-PiholeContext -Server 'pihole.test' -Credential (New-PiholeTestCredential)
        InModuleScope PSPiHole {
            $script:PiholeContext.Session = [pscustomobject]@{
                Sid = 'sid-x'; Csrf = 'c'; Validity = 1800; AuthedAt = Get-Date
            }
        }

        Mock -ModuleName PSPiHole Invoke-RestMethod {throw 'pihole down'}

        {Clear-PiholeContext} | Should -Not -Throw
        InModuleScope PSPiHole {$script:PiholeContext | Should -BeNullOrEmpty}
    }

    It 'honours -WhatIf' {
        Set-PiholeContext -Server 'pihole.test' -Credential (New-PiholeTestCredential)
        Mock -ModuleName PSPiHole Invoke-RestMethod {}

        Clear-PiholeContext -WhatIf

        InModuleScope PSPiHole {$script:PiholeContext | Should -Not -BeNullOrEmpty}
    }
}