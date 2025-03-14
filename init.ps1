if (-not (Test-Path "$PSScriptRoot/.arcade")) {
    Invoke-WebRequest "https://raw.githubusercontent.com/nemonuri/arcade/master/script/ArcadeScript.ps1" | . Invoke-Expression
    Import-ArcadeScript -NM -Script "ArcadeScript"    
}

. "$PSScriptRoot/.arcade/.script/ArcadeScript.ps1"

if (-not (Test-Path "$PSScriptRoot/tool.ps1")) {
    @'
$ASRoot = "$PSScriptRoot/.arcade/.script"
. "$ASRoot/ArcadeScript.ps1"

'@ | Out-File -FilePath "$PSScriptRoot/tool.ps1" 
}