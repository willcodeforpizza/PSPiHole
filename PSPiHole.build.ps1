Add-BuildTask Tests {
    $testPath = (Resolve-Path (Join-Path $PSScriptRoot 'Tests')).Path
    Invoke-Pester -Path $testPath -EnableExit
}

Add-BuildTask Lint {
    $findings = Invoke-ScriptAnalyzer $PSScriptRoot -IncludeDefaultRules

    if ($findings) {
        $findings | Format-Table | Out-String
        Write-Error "PSSA errors found"
    }
}

Add-BuildTask Manifest {
    Test-ModuleManifest -Path "$PSScriptRoot\PSPiHole.psd1" > $null
}


Add-BuildTask Validate Tests, Lint