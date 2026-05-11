function ConvertFrom-PiholeDomainPath {
    <#
    .SYNOPSIS
        Builds a Pi-hole domains API path from optional domain filters.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [string]
        $Type,

        [string]
        $Kind,

        [string]
        $Domain
    )

    $segments = [System.Collections.Generic.List[string]]::new()
    $segments.Add('domains')

    if ($Type) {
        $segments.Add($Type)
    }

    if ($Kind) {
        $segments.Add($Kind)
    }

    if ($Domain) {
        $segments.Add([System.Uri]::EscapeDataString($Domain))
    }

    $segments -join '/'
}
