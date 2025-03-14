if (-not (Test-Path "$PSScriptRoot/.arcade")) {
    Invoke-WebRequest "https://raw.githubusercontent.com/nemonuri/arcade/master/script/ArcadeScript.ps1" | . Invoke-Expression
    Import-ArcadeScript -NM -Script "ArcadeScript"    
}

. "$PSScriptRoot/.arcade/.script"