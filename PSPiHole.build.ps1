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

if (Get-Command Get-PlumberReleaseTaskLoader -ErrorAction SilentlyContinue) {
    . (Get-PlumberReleaseTaskLoader) -Config @{
        ModuleManifest = 'PSPiHole.psd1'
    }
}
