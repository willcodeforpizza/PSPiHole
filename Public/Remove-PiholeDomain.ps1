function Remove-PiholeDomain {
    <#
    .SYNOPSIS
        Removes a Pi-hole allow or deny domain.

    .DESCRIPTION
        Sends DELETE /api/domains/{type}/{kind}/{domain}.

    .PARAMETER Domain
        Domain or regular expression to remove.

    .PARAMETER Type
        Domain list type: allow or deny.

    .PARAMETER Kind
        Domain match kind: exact or regex.

    .PARAMETER Context
        Override the default context for this call.

    .EXAMPLE
        Remove-PiholeDomain -Type deny -Kind exact -Domain ads.example.com

    .EXAMPLE
        Get-PiholeDomain -Type allow -Kind regex | Remove-PiholeDomain -Confirm:$false
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
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

        [psobject]
        $Context
    )

    begin {
        $resolvedContext = Resolve-PiholeContext -Context $Context
    }

    process {
        $path = ConvertFrom-PiholeDomainPath -Type $Type -Kind $Kind -Domain $Domain
        $target = '{0}/{1}: {2}' -f $Type, $Kind, $Domain

        if ($PSCmdlet.ShouldProcess($resolvedContext.Server, "Remove Pi-hole domain: $target")) {
            Invoke-PiholeApi -Context $resolvedContext -Method DELETE -Path $path | Out-Null
        }
    }
}
