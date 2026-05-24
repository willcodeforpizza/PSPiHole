. (Get-PlumberTaskLoader) -Config @{
    ModuleManifest = 'PSPiHole.psd1'
    Tasks          = @{
        ModuleVersion        = @{
            RunWhen = 'OnRelease'
        }
        ChangelogUpdated     = @{
            RunWhen = 'OnRelease'
        }
        PublicFunctionPrefix = @{
            Prefix = 'Pihole'
        }
    }
}

. (Get-PlumberReleaseTaskLoader) -Config @{
    ModuleManifest = 'PSPiHole.psd1'
}
