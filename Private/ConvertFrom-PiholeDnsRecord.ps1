function ConvertFrom-PiholeDnsRecord {
    <#
    .SYNOPSIS
        Encodes hostname + IP into a Pi-hole API path segment.

    .DESCRIPTION
        Pi-hole's hosts endpoint expects the record to be embedded in the URL
        path as a single URL-encoded "IP Hostname" string. This helper builds
        that segment.

    .PARAMETER Hostname
        Fully-qualified hostname.

    .PARAMETER IPAddress
        IP the hostname should resolve to.

    .EXAMPLE
        ConvertFrom-PiholeDnsRecord -Hostname pihole1.lan -IPAddress 192.168.10.91

        Returns '192.168.10.91%20pihole1.lan'.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string]
        $Hostname,

        [Parameter(Mandatory)]
        [string]
        $IPAddress
    )

    [System.Uri]::EscapeDataString("$IPAddress $Hostname")
}
