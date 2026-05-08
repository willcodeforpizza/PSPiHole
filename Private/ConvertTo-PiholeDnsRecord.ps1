function ConvertTo-PiholeDnsRecord {
    <#
    .SYNOPSIS
        Parses a Pi-hole local DNS record string into an object.

    .DESCRIPTION
        Pi-hole returns local DNS host records as flat strings of the form
        "IP Hostname" (e.g. "192.168.10.91 pihole1.lan"). This helper splits
        the string into IPAddress and Hostname properties and applies the
        PSPiHole.DnsRecord type name so callers can rely on a stable shape.

    .PARAMETER InputObject
        The raw record string from the Pi-hole API.

    .EXAMPLE
        ConvertTo-PiholeDnsRecord '192.168.10.91 pihole1.lan'

        Returns a record with IPAddress=192.168.10.91 and Hostname=pihole1.lan.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]
        $InputObject
    )

    process {
        $trimmed = $InputObject.Trim()
        if (-not $trimmed) {return}

        $parts = $trimmed -split '\s+', 2
        if ($parts.Count -ne 2) {
            Write-Warning "Could not parse Pi-hole DNS record: '$InputObject'"
            return
        }

        [pscustomobject]@{
            PSTypeName = 'PSPiHole.DnsRecord'
            IPAddress  = $parts[0]
            Hostname   = $parts[1]
        }
    }
}