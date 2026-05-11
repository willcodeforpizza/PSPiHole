function Add-PiholeDomain {
    <#
    .SYNOPSIS
        Adds allow or deny domains to Pi-hole.

    .DESCRIPTION
        Sends POST /api/domains/{type}/{kind} with one or more domains in the
        JSON body. Use Type allow/deny and Kind exact/regex to choose the list.

    .PARAMETER Domain
        Domain or regular expression to add.

    .PARAMETER Type
        Domain list type: allow or deny.

    .PARAMETER Kind
        Domain match kind: exact or regex.

    .PARAMETER Comment
        Optional comment for the domain entry.

    .PARAMETER GroupId
        Optional Pi-hole group IDs assigned to the entry.

    .PARAMETER Enabled
        Whether the entry is enabled. Defaults to true.

    .PARAMETER Context
        Override the default context for this call.

    .EXAMPLE
        Add-PiholeDomain -Type deny -Kind exact -Domain ads.example.com

    .EXAMPLE
        '(^|\.)tracking\.example$' | Add-PiholeDomain -Type deny -Kind regex
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]
        $Domain,

        [Parameter(Mandatory)]
        [ValidateSet('allow', 'deny')]
        [string]
        $Type,

        [Parameter(Mandatory)]
        [ValidateSet('exact', 'regex')]
        [string]
        $Kind,

        [string]
        $Comment,

        [int[]]
        $GroupId,

        [bool]
        $Enabled = $true,

        [psobject]
        $Context
    )

    begin {
        $resolvedContext = Resolve-PiholeContext -Context $Context
        $path = ConvertFrom-PiholeDomainPath -Type $Type -Kind $Kind
    }

    process {
        $boundParameters = @{} + $PSBoundParameters
        $boundParameters.Enabled = $true
        $bodySplat = @{
            Domain          = $Domain
            Comment         = $Comment
            GroupId         = $GroupId
            Enabled         = $Enabled
            BoundParameters = $boundParameters
        }
        $body = ConvertTo-PiholeDomainBody @bodySplat
        $target = '{0}/{1}: {2}' -f $Type, $Kind, ($Domain -join ', ')

        if ($PSCmdlet.ShouldProcess($resolvedContext.Server, "Add Pi-hole domain: $target")) {
            Invoke-PiholeApi -Context $resolvedContext -Method POST -Path $path -Body $body
        }
    }
}
