# Shared helpers for PSPiHole unit tests. Dot-sourced from each *.Tests.ps1
# inside its BeforeAll, so it runs after the module is imported.

function New-PiholeTestCredential {
    param([string]$Password = 'pw')
    [pscredential]::new('pihole', (ConvertTo-SecureString $Password -AsPlainText -Force))
}

function New-PiholeTestContext {
    param(
        [string]$Server = 'pihole.test',
        [switch]$WithSession,
        [switch]$SkipCertificateCheck
    )

    $ctx = [pscustomobject]@{
        PSTypeName           = 'PSPiHole.Context'
        Server               = $Server
        BaseUri              = "https://$Server/api"
        SkipCertificateCheck = [bool]$SkipCertificateCheck
        Credential           = New-PiholeTestCredential
        Session              = $null
    }

    if ($WithSession) {
        $ctx.Session = [pscustomobject]@{
            PSTypeName = 'PSPiHole.Session'
            Sid        = 'sid-test'
            Csrf       = 'csrf-test'
            Validity   = 1800
            AuthedAt   = Get-Date
        }
    }

    $ctx
}

function New-Pihole401Exception {
    # Fakes the shape Invoke-PiholeApi inspects: $_.Exception.Response.StatusCode.
    # Constructing a real HttpResponseException is awkward in tests; a
    # NoteProperty-decorated exception is enough for the catch-block check.
    $resp = [pscustomobject]@{StatusCode = [System.Net.HttpStatusCode]::Unauthorized}
    $exc  = [System.Exception]::new('Unauthorized')
    Add-Member -InputObject $exc -MemberType NoteProperty -Name Response -Value $resp -Force
    $exc
}

function Reset-PiholeModuleState {
    InModuleScope PSPiHole {$script:PiholeContext = $null}
}