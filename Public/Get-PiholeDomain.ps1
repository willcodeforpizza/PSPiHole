function Get-PiholeDomain {
    <#
    .SYNOPSIS
        Lists Pi-hole allow and deny domains.

    .DESCRIPTION
        Queries /api/domains and returns each domain as a PSPiHole.Domain
        object. Optional Type, Kind, and Domain parameters narrow the request
        to allow/deny and exact/regex entries.

    .PARAMETER Type
        Domain list type: allow or deny.

    .PARAMETER Kind
        Domain match kind: exact or regex.

    .PARAMETER Domain
        Domain or regular expression to retrieve.

    .PARAMETER Context
        Override the default context for this call.

    .EXAMPLE
        Get-PiholeDomain -Type deny -Kind exact

    .EXAMPLE
        Get-PiholeDomain -Type allow -Kind regex -Domain '^ads\.example\.com$'
    #>
    [CmdletBinding()]
    param(
        [ValidateSet('allow', 'deny')]
        [string]
        $Type,

        [ValidateSet('exact', 'regex')]
        [string]
        $Kind,

        [string]
        $Domain,

        [psobject]
        $Context
    )

    $resolvedContext = Resolve-PiholeContext -Context $Context
    $path = ConvertFrom-PiholeDomainPath -Type $Type -Kind $Kind -Domain $Domain
    $response = Invoke-PiholeApi -Context $resolvedContext -Method GET -Path $path

    $domains = foreach ($entry in @($response.domains)) {
        ConvertTo-PiholeDomain -InputObject $entry
    }

    $domains | Sort-Object Type, Kind, Domain
}
