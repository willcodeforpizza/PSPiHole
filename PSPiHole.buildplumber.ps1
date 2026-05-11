$module = Get-Module Plumber
if (-not $module) {
    $module = Import-Module Plumber -PassThru
}

. (Get-PlumberTaskLoader) -Config @{
    ModuleManifest = 'PSPiHole.psd1'
}
