if (-not (Test-Path "$(Get-Location)/.arcade")) {
    Invoke-WebRequest "https://raw.githubusercontent.com/nemonuri/arcade/master/script/ArcadeScript.ps1" | . Invoke-Expression
    Import-ArcadeScript -NM -Script "ArcadeScript"    
}

. "$(Get-Location)/.arcade/.script/ArcadeScript.ps1"

if (-not (Test-Path "$(Get-Location)/tool.ps1")) {
    @'
$ASRoot = "$PSScriptRoot/.arcade/.script"
. "$ASRoot/ArcadeScript.ps1"

'@ | Out-File -FilePath "$(Get-Location)/tool.ps1" 
}