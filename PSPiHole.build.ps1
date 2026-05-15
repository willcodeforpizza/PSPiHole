$moduleList = (Import-PowerShellDataFile (Join-Path $PSScriptRoot 'PSPiHole.psd1')).ModuleList
foreach ($module in $moduleList) {
    $availableModule = Get-Module -ListAvailable -Name $module.ModuleName
    if ($availableModule) {
        continue
    }

    Install-Module -Name $module.ModuleName -RequiredVersion $module.ModuleVersion -Scope CurrentUser -Force
}

Import-Module Plumber -RequiredVersion 0.0.29 -Force
Import-Module Plumber.Release -RequiredVersion 0.1.0 -Force

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
