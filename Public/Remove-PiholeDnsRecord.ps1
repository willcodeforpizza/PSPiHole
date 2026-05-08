function Remove-PiholeDnsRecord {
    <#
    .SYNOPSIS
        Removes a local DNS record from Pi-hole.

    .DESCRIPTION
        Sends DELETE /api/config/dns/hosts/{record} where {record} is a
        URL-encoded "IP Hostname" pair.

        Pipeline-bound on Hostname and IPAddress so Get-PiholeDnsRecord
        output flows directly in:

            Get-PiholeDnsRecord -Hostname 'old*' | Remove-PiholeDnsRecord

    .PARAMETER Hostname
        Fully-qualified hostname of the record to remove.

    .PARAMETER IPAddress
        IP address of the record to remove.

    .PARAMETER Context
        Override the default context for this call.

    .EXAMPLE
        Remove-PiholeDnsRecord -Hostname stale.lan -IPAddress 192.168.10.50

    .EXAMPLE
        Get-PiholeDnsRecord -Hostname '*.old.lan' | Remove-PiholeDnsRecord -Confirm:$false
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $Hostname,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $IPAddress,

        [psobject]
        $Context
    )

    begin {
        $resolvedContext = Resolve-PiholeContext -Context $Context
    }

    process {
        $segment = ConvertFrom-PiholeDnsRecord -Hostname $Hostname -IPAddress $IPAddress
        $target  = "$IPAddress -> $Hostname"

        if ($PSCmdlet.ShouldProcess($resolvedContext.Server, "Remove DNS record: $target")) {
            $apiSplat = @{
                Context = $resolvedContext
                Method  = 'DELETE'
                Path    = "config/dns/hosts/$segment"
            }
            Invoke-PiholeApi @apiSplat | Out-Null
        }
    }
}