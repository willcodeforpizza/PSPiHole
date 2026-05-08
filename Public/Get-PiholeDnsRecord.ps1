function Get-PiholeDnsRecord {
    <#
    .SYNOPSIS
        Lists local DNS records from Pi-hole.

    .DESCRIPTION
        Queries /api/config/dns and returns each local host record as a
        PSPiHole.DnsRecord object with IPAddress and Hostname properties.

        Optionally filters by hostname using PowerShell wildcard syntax.

    .PARAMETER Hostname
        Hostname filter (wildcards allowed). Applied client-side.

    .PARAMETER Context
        Override the default context for this call. Useful when targeting
        an HA pair member directly.

    .EXAMPLE
        Get-PiholeDnsRecord

        IPAddress     Hostname
        ---------     --------
        192.168.10.91 pihole1.lan
        192.168.10.92 pihole2.lan

    .EXAMPLE
        Get-PiholeDnsRecord -Hostname 'pihole*'

        Returns only records whose hostname starts with 'pihole'.

    .EXAMPLE
        Get-PiholeDnsRecord -Hostname 'old*' | Remove-PiholeDnsRecord

        Pipes matching records into Remove-PiholeDnsRecord.
    #>
    [CmdletBinding()]
    param(
        [SupportsWildcards()]
        [string]
        $Hostname,

        [psobject]
        $Context
    )

    $resolvedContext = Resolve-PiholeContext -Context $Context
    $response        = Invoke-PiholeApi -Context $resolvedContext -Method GET -Path 'config/dns'

    $records = foreach ($entry in @($response.config.dns.hosts)) {
        ConvertTo-PiholeDnsRecord -InputObject $entry
    }

    if ($Hostname) {
        $records = $records | Where-Object {$_.Hostname -like $Hostname}
    }

    $records | Sort-Object Hostname
}