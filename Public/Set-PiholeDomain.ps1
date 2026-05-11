function Set-PiholeDomain {
    <#
    .SYNOPSIS
        Updates an existing Pi-hole allow or deny domain.

    .DESCRIPTION
        Sends PUT /api/domains/{type}/{kind}/{domain}. Comment, GroupId, and
        Enabled update entry metadata. NewType and NewKind can move an entry
        between allow/deny and exact/regex lists and must be supplied together.

    .PARAMETER Domain
        Existing domain or regular expression to update.

    .PARAMETER Type
        Existing domain list type: allow or deny.

    .PARAMETER Kind
        Existing domain match kind: exact or regex.

    .PARAMETER NewType
        Destination domain list type when moving an entry.

    .PARAMETER NewKind
        Destination match kind when moving an entry.

    .PARAMETER Comment
        Updated comment for the domain entry.

    .PARAMETER GroupId
        Updated Pi-hole group IDs assigned to the entry.

    .PARAMETER Enabled
        Updated enabled state.

    .PARAMETER Context
        Override the default context for this call.

    .EXAMPLE
        Set-PiholeDomain -Type deny -Kind exact -Domain ads.example.com -Comment 'Telemetry'

    .EXAMPLE
        Get-PiholeDomain -Type allow -Kind exact -Domain ads.example.com |
            Set-PiholeDomain -NewType deny -NewKind exact
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $Domain,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateSet('allow', 'deny')]
        [string]
        $Type,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateSet('exact', 'regex')]
        [string]
        $Kind,

        [ValidateSet('allow', 'deny')]
        [string]
        $NewType,

        [ValidateSet('exact', 'regex')]
        [string]
        $NewKind,

        [string]
        $Comment,

        [int[]]
        $GroupId,

        [bool]
        $Enabled,

        [psobject]
        $Context
    )

    begin {
        $resolvedContext = Resolve-PiholeContext -Context $Context
    }

    process {
        $isMove = $PSBoundParameters.ContainsKey('NewType') -or $PSBoundParameters.ContainsKey('NewKind')
        $hasNewType = $PSBoundParameters.ContainsKey('NewType')
        $hasNewKind = $PSBoundParameters.ContainsKey('NewKind')
        if ($isMove -and -not ($hasNewType -and $hasNewKind)) {
            throw 'NewType and NewKind must be supplied together when moving a domain.'
        }

        $hasUpdate = $PSBoundParameters.ContainsKey('Comment') -or
            $PSBoundParameters.ContainsKey('GroupId') -or
            $PSBoundParameters.ContainsKey('Enabled') -or
            $isMove
        if (-not $hasUpdate) {
            throw 'Specify at least one property to update.'
        }

        $bodySplat = @{
            Comment         = $Comment
            GroupId         = $GroupId
            Enabled         = $Enabled
            Type            = $NewType
            Kind            = $NewKind
            BoundParameters = $PSBoundParameters
        }
        $body = ConvertTo-PiholeDomainBody @bodySplat
        $path = ConvertFrom-PiholeDomainPath -Type $Type -Kind $Kind -Domain $Domain
        $target = '{0}/{1}: {2}' -f $Type, $Kind, $Domain

        if ($PSCmdlet.ShouldProcess($resolvedContext.Server, "Set Pi-hole domain: $target")) {
            Invoke-PiholeApi -Context $resolvedContext -Method PUT -Path $path -Body $body
        }
    }
}
