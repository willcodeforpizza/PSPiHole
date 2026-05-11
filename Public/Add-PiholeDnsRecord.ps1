function Add-PiholeDnsRecord {
    <#
    .SYNOPSIS
        Adds a local DNS record to Pi-hole.

    .DESCRIPTION
        Sends PUT /api/config/dns/hosts/{record} where {record} is a
        URL-encoded "IP Hostname" pair. Pi-hole accepts the PUT idempotently -
        re-adding an existing record is a no-op.

        Pipeline-bound on Hostname and IPAddress so output from
        Get-PiholeDnsRecord can be piped in directly (e.g. mass migrations
        between servers).

    .PARAMETER Hostname
        Fully-qualified hostname.

    .PARAMETER IPAddress
        IP address the hostname should resolve to.

    .PARAMETER Context
        Override the default context for this call.

    .EXAMPLE
        Add-PiholeDnsRecord -Hostname pihole1.lan -IPAddress 192.168.10.91

    .EXAMPLE
        @(
            [pscustomobject]@{Hostname = 'a.lan'; IPAddress = '10.0.0.1'}
            [pscustomobject]@{Hostname = 'b.lan'; IPAddress = '10.0.0.2'}
        ) | Add-PiholeDnsRecord
    #>
    [CmdletBinding(SupportsShouldProcess)]
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

        if ($PSCmdlet.ShouldProcess($resolvedContext.Server, "Add DNS record: $target")) {
            $apiSplat = @{
                Context = $resolvedContext
                Method  = 'PUT'
                Path    = "config/dns/hosts/$segment"
            }
            Invoke-PiholeApi @apiSplat | Out-Null
        }
    }
}
