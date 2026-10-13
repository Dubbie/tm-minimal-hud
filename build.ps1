$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

if (Test-Path MinimalHUD.op) { Remove-Item MinimalHUD.op }

Compress-Archive -Path info.toml, src -DestinationPath MinimalHUD.zip -Force
Move-Item MinimalHUD.zip MinimalHUD.op -Force

Write-Host "Built MinimalHUD.op"