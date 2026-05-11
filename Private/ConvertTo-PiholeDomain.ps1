function ConvertTo-PiholeDomain {
    <#
    .SYNOPSIS
        Normalises a Pi-hole domain API object.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [psobject]
        $InputObject
    )

    process {
        [pscustomobject]@{
            PSTypeName    = 'PSPiHole.Domain'
            Domain        = $InputObject.domain
            Unicode       = $InputObject.unicode
            Type          = $InputObject.type
            Kind          = $InputObject.kind
            Comment       = $InputObject.comment
            Groups        = @($InputObject.groups)
            Enabled       = $InputObject.enabled
            Id            = $InputObject.id
            DateAdded     = $InputObject.date_added
            DateModified  = $InputObject.date_modified
        }
    }
}
