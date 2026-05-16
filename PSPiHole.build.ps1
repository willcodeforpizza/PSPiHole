. (Get-PlumberTaskLoader) -Config @{
    ModuleManifest = 'PSPiHole.psd1'
    Tasks          = @{
        PublicFunctionPrefix = @{
            Prefix = 'Pihole'
        }
    }
}

. (Get-PlumberReleaseTaskLoader) -Config @{
    ModuleManifest = 'PSPiHole.psd1'
}
