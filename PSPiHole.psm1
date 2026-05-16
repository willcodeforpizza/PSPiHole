$script:moduleRoot = $PSScriptRoot

$privateRoot = Join-Path $script:moduleRoot 'Private'
$publicRoot  = Join-Path $script:moduleRoot 'Public'

foreach ($file in @(Get-ChildItem $privateRoot -Filter '*.ps1' -File)) {. $file.FullName}
foreach ($file in @(Get-ChildItem $publicRoot -Filter '*.ps1' -File)) {. $file.FullName}
