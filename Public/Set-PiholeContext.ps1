function Set-PiholeContext {
    <#
    .SYNOPSIS
        Configures the default Pi-hole context for subsequent cmdlets.

    .DESCRIPTION
        Stores the target Pi-hole server and credential in module scope.

        Authentication happens lazily on the first cmdlet that needs it. The session id is cached
        on the context and reused until it expires.

        If neither -Credential nor -Password is supplied, falls back to $env:PIHOLE_PASSWORD

    .PARAMETER Server
        Pi-hole server hostname or IP (e.g. 'pihole1.lan').

    .PARAMETER Credential
        PSCredential whose Password is the Pi-hole web/app password. The
        username is ignored - Pi-hole has no username concept.

    .PARAMETER Password
        SecureString password. Alternative to -Credential.

    .PARAMETER SkipCertificateCheck
        Skip TLS certificate validation. Use for self-signed homelab certs.

    .PARAMETER PassThru
        Emit the resulting context object.

    .EXAMPLE
        Set-PiholeContext -Server pihole1.lan -Credential (Get-Credential)

        Configures pihole1.lan as the default target. Subsequent cmdlets
        will auth lazily on first call.

    .EXAMPLE
        $env:PIHOLE_PASSWORD = '...'
        Set-PiholeContext -Server pihole1.lan -SkipCertificateCheck

        Picks up the password from the environment and trusts the Pi-hole's
        self-signed cert.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingConvertToSecureStringWithPlainText',
        '',
        Justification = 'PIHOLE_PASSWORD is a documented plaintext environment variable fallback.'
    )]
    [CmdletBinding(DefaultParameterSetName = 'Credential', SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]
        $Server,

        [Parameter(ParameterSetName = 'Credential')]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'Password')]
        [securestring]
        $Password,

        [switch]
        $SkipCertificateCheck,

        [switch]
        $PassThru
    )

    if (-not $Credential -and -not $Password) {
        if ($env:PIHOLE_PASSWORD) {
            Write-Warning 'Using password from $env:PIHOLE_PASSWORD.'
            $Password = ConvertTo-SecureString $env:PIHOLE_PASSWORD -AsPlainText -Force
        }
        else {
            throw 'No credential supplied. Pass -Credential, -Password, or set $env:PIHOLE_PASSWORD.'
        }
    }

    if ($Password) {$Credential = [pscredential]::new('pihole', $Password)}

    if ($PSCmdlet.ShouldProcess($Server, 'Set Pi-hole context')) {
        $script:PiholeContext = [pscustomobject]@{
            PSTypeName           = 'PSPiHole.Context'
            Server               = $Server
            BaseUri              = "https://$Server/api"
            SkipCertificateCheck = [bool]$SkipCertificateCheck
            Credential           = $Credential
            Session              = $null
        }

        if ($PassThru) {
            $script:PiholeContext
        }
    }
}
