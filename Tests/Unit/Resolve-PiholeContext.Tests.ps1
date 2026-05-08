BeforeAll {
    Import-Module "$PSScriptRoot/../../PSPiHole.psd1" -Force
    . "$PSScriptRoot/_Common.ps1"
}

Describe 'Resolve-PiholeContext (private)' {
    BeforeEach {
        Reset-PiholeModuleState
    }

    It 'returns the explicit -Context when supplied' {
        $explicit = New-PiholeTestContext -Server 'explicit.lan'

        InModuleScope PSPiHole -Parameters @{Explicit = $explicit} {
            param($Explicit)
            (Resolve-PiholeContext -Context $Explicit).Server | Should -Be 'explicit.lan'
        }
    }

    It 'falls back to the module default when -Context is omitted' {
        Set-PiholeContext -Server 'default.lan' -Credential (New-PiholeTestCredential)

        InModuleScope PSPiHole {
            (Resolve-PiholeContext).Server | Should -Be 'default.lan'
        }
    }

    It 'prefers the explicit -Context over the module default' {
        Set-PiholeContext -Server 'default.lan' -Credential (New-PiholeTestCredential)
        $explicit = New-PiholeTestContext -Server 'explicit.lan'

        InModuleScope PSPiHole -Parameters @{Explicit = $explicit} {
            param($Explicit)
            (Resolve-PiholeContext -Context $Explicit).Server | Should -Be 'explicit.lan'
        }
    }

    It 'throws a clear error when no context is available' {
        InModuleScope PSPiHole {
            {Resolve-PiholeContext} | Should -Throw '*No Pi-hole context*'
        }
    }
}