function Resolve-PiholeContext {
    <#
    .SYNOPSIS
        Returns the explicit context if supplied, otherwise the module default.

    .DESCRIPTION
        Public cmdlets accept an optional -Context parameter so users can
        target a non-default Pi-hole (e.g. an HA pair member). When no
        explicit context is supplied, the module default ($script:PiholeContext,
        set by Set-PiholeContext) is used.

        Throws a clear error if neither is available, telling the user how
        to recover.

    .PARAMETER Context
        An explicit PSPiHole.Context object. May be $null.

    .EXAMPLE
        Resolve-PiholeContext -Context $explicitCtx
    #>
    [CmdletBinding()]
    param(
        [psobject]
        $Context
    )

    if ($Context) {return $Context}
    if ($script:PiholeContext) {return $script:PiholeContext}
    throw 'No Pi-hole context. Run Set-PiholeContext first or pass -Context.'
}