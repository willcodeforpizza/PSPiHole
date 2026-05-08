function Invoke-PiholeApi {
    <#
    .SYNOPSIS
        Sends an authenticated request to the Pi-hole v6 API.

    .DESCRIPTION
        The single HTTP boundary for the module. Resolves and lazily auths
        the supplied context, attaches the sid header, and sends the request.

        On a 401 response (sid expired or revoked), re-auths once and retries
        the request. Any other error is rethrown as-is.

    .PARAMETER Context
        A PSPiHole.Context (typically from Resolve-PiholeContext).

    .PARAMETER Method
        HTTP method. GET, POST, PUT, DELETE, or PATCH.

    .PARAMETER Path
        API path relative to /api/ (e.g. 'config/dns').

    .PARAMETER Body
        Optional request body. Serialised to JSON.

    .EXAMPLE
        Invoke-PiholeApi -Context $ctx -Method GET -Path 'config/dns'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [psobject]
        $Context,

        [Parameter(Mandatory)]
        [ValidateSet('GET', 'POST', 'PUT', 'DELETE', 'PATCH')]
        [string]
        $Method,

        [Parameter(Mandatory)]
        [string]
        $Path,

        [object]
        $Body
    )

    if (-not $Context.Session) {
        $Context.Session = Get-PiholeSession -Context $Context
    }

    $hasBody = $PSBoundParameters.ContainsKey('Body')

    $sendRequest = {
        $splat = @{
            Uri     = "$($Context.BaseUri)/$Path"
            Method  = $Method
            Headers = @{sid = $Context.Session.Sid}
        }
        if ($hasBody) {
            $splat.Body        = ($Body | ConvertTo-Json -Compress)
            $splat.ContentType = 'application/json'
        }
        if ($Context.SkipCertificateCheck) {
            $splat.SkipCertificateCheck = $true
        }
        Invoke-RestMethod @splat
    }

    try {
        & $sendRequest
    }
    catch {
        $status = $null
        if ($_.Exception.PSObject.Properties['Response'] -and $_.Exception.Response) {
            $status = [int]$_.Exception.Response.StatusCode
        }

        if ($status -eq 401) {
            $Context.Session = Get-PiholeSession -Context $Context
            & $sendRequest
        }
        else {
            throw
        }
    }
}