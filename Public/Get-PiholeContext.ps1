function Get-PiholeContext {
    <#
    .SYNOPSIS
        Returns a view of the current default Pi-hole context.

    .DESCRIPTION
        Returns a sanitised view of $script:PiholeContext. The credential
        itself is never emitted — callers see HasCredential / SessionActive
        flags instead. Returns nothing if no context is set.

    .EXAMPLE
        Get-PiholeContext

        Server               : pihole1.lan
        BaseUri              : https://pihole1.lan/api
        SkipCertificateCheck : False
        HasCredential        : True
        SessionActive        : False
    #>
    [CmdletBinding()]
    param()

    if (-not $script:PiholeContext) {return}

    [pscustomobject]@{
        PSTypeName           = 'PSPiHole.ContextView'
        Server               = $script:PiholeContext.Server
        BaseUri              = $script:PiholeContext.BaseUri
        SkipCertificateCheck = $script:PiholeContext.SkipCertificateCheck
        HasCredential        = [bool]$script:PiholeContext.Credential
        SessionActive        = [bool]$script:PiholeContext.Session
    }
}