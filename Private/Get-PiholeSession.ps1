function Get-PiholeSession {
    <#
    .SYNOPSIS
        Authenticates against Pi-hole and returns a session object.

    .DESCRIPTION
        Posts the context's stored credential to /api/auth and returns a
        session object containing the sid and CSRF token. The plain-text
        password lives in scope only for the duration of the POST.

        This is the lazy-auth entry point used by Invoke-PiholeApi when no
        cached session is present (or after a 401).

    .PARAMETER Context
        A PSPiHole.Context built by Set-PiholeContext.

    .EXAMPLE
        Get-PiholeSession -Context $script:PiholeContext
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [psobject]
        $Context
    )

    if (-not $Context.Credential) {
        throw 'Pi-hole context has no credential. Run Set-PiholeContext first.'
    }

    $netCred = $Context.Credential.GetNetworkCredential()
    $body    = @{password = $netCred.Password} | ConvertTo-Json -Compress

    $splat = @{
        Uri         = "$($Context.BaseUri)/auth"
        Method      = 'POST'
        Body        = $body
        ContentType = 'application/json'
    }
    if ($Context.SkipCertificateCheck) {
        $splat.SkipCertificateCheck = $true
    }

    $response = Invoke-RestMethod @splat

    if (-not $response.session.valid) {
        throw "Pi-hole authentication failed for $($Context.Server): $($response.session.message)"
    }

    [pscustomobject]@{
        PSTypeName = 'PSPiHole.Session'
        Sid        = $response.session.sid
        Csrf       = $response.session.csrf
        Validity   = $response.session.validity
        AuthedAt   = Get-Date
    }
}