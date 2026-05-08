task Tests {
    $testPath = (Resolve-Path (Join-Path $PSScriptRoot 'Tests')).Path
    Invoke-Pester -Path $testPath -EnableExit
}

task Lint {
    $findings = Invoke-ScriptAnalyzer $PSScriptRoot -IncludeDefaultRules

    if ($findings) {
        $findings | Format-Table | Out-String
        Write-Error "PSSA errors found"
    }
}

task Manifest {
    Test-ModuleManifest -Path "$PSScriptRoot\PSPiHole.psd1" > $null
}


task Validate Tests, Lint