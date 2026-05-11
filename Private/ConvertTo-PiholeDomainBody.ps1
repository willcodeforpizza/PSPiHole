function ConvertTo-PiholeDomainBody {
    <#
    .SYNOPSIS
        Creates a JSON-ready request body for Pi-hole domain endpoints.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [string[]]
        $Domain,

        [string]
        $Comment,

        [int[]]
        $GroupId,

        [bool]
        $Enabled,

        [string]
        $Type,

        [string]
        $Kind,

        [Parameter(Mandatory)]
        [hashtable]
        $BoundParameters
    )

    $body = @{}

    if ($BoundParameters.ContainsKey('Domain')) {
        if ($Domain.Count -eq 1) {
            $body.domain = $Domain[0]
        }
        else {
            $body.domain = $Domain
        }
    }

    if ($BoundParameters.ContainsKey('Comment')) {
        $body.comment = $Comment
    }

    if ($BoundParameters.ContainsKey('GroupId')) {
        $body.groups = $GroupId
    }

    if ($BoundParameters.ContainsKey('Enabled')) {
        $body.enabled = $Enabled
    }

    if ($BoundParameters.ContainsKey('NewType')) {
        $body.type = $Type
    }

    if ($BoundParameters.ContainsKey('NewKind')) {
        $body.kind = $Kind
    }

    $body
}
