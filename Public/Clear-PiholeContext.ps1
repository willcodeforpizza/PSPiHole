function Clear-PiholeContext {
    <#
    .SYNOPSIS
        Removes the default Pi-hole context and releases any cached session.

    .DESCRIPTION
        If the current context has an active session, fires a best-effort
        DELETE /api/auth so Pi-hole can drop the sid server-side. The local
        context is then cleared regardless of whether the DELETE succeeded -
        the worst that happens is an orphaned session that expires naturally.

    .EXAMPLE
        Clear-PiholeContext
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param()

    if (-not $script:PiholeContext) {return}

    $context = $script:PiholeContext
    if (-not $PSCmdlet.ShouldProcess($context.Server, 'Clear Pi-hole context')) {
        return
    }

    if ($context.Session) {
        try {
            $splat = @{
                Uri     = "$($context.BaseUri)/auth"
                Method  = 'DELETE'
                Headers = @{sid = $context.Session.Sid}
            }
            if ($context.SkipCertificateCheck) {
                $splat.SkipCertificateCheck = $true
            }
            Invoke-RestMethod @splat | Out-Null
        }
        catch {
            Write-Verbose "Failed to release Pi-hole session: $_"
        }
    }

    $script:PiholeContext = $null
}
