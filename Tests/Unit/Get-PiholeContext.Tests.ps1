BeforeAll {
    Import-Module "$PSScriptRoot/../../PSPiHole.psd1" -Force
    . "$PSScriptRoot/_Common.ps1"
}

Describe 'Get-PiholeContext' {
    BeforeEach {
        Reset-PiholeModuleState
    }

    It 'returns nothing when no context is set' {
        Get-PiholeContext | Should -BeNullOrEmpty
    }

    It 'returns a sanitised view when a context is set' {
        Set-PiholeContext -Server 'pihole.test' -Credential (New-PiholeTestCredential) -SkipCertificateCheck

        $view = Get-PiholeContext

        $view                      | Should -Not -BeNullOrEmpty
        $view.Server               | Should -Be 'pihole.test'
        $view.BaseUri              | Should -Be 'https://pihole.test/api'
        $view.SkipCertificateCheck | Should -BeTrue
        $view.HasCredential        | Should -BeTrue
        $view.SessionActive        | Should -BeFalse
    }

    It 'never exposes the credential object' {
        Set-PiholeContext -Server 'pihole.test' -Credential (New-PiholeTestCredential)

        $view = Get-PiholeContext

        ($view.PSObject.Properties.Name -contains 'Credential') | Should -BeFalse
    }

    It 'reports SessionActive=$true once a session has been cached' {
        Set-PiholeContext -Server 'pihole.test' -Credential (New-PiholeTestCredential)

        InModuleScope PSPiHole {
            $script:PiholeContext.Session = [pscustomobject]@{
                PSTypeName = 'PSPiHole.Session'
                Sid        = 'sid-x'
                Csrf       = 'c'
                Validity   = 1800
                AuthedAt   = Get-Date
            }
        }

        (Get-PiholeContext).SessionActive | Should -BeTrue
    }
}