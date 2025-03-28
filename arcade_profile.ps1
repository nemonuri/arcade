$script:moduleRoot = Join-Path $PSScriptRoot "powershell/module" -Resolve
$script:rootModuleName = "Nemonuri"

# Test root arcade module is already imported
$script:v = Get-Module -Name $script:rootModuleName | Where-Object { (Join-Path $script:moduleRoot $script:rootModuleName) -eq $_.ModuleBase }
if ($script:v.Count -gt 0) {
    Write-Debug "This profile already imported. found: $script:v"
    return
}

Import-Module (Join-Path $script:moduleRoot $script:rootModuleName)
Add-ModulePath $script:moduleRoot
Set-Alias -Name build -Value (Join-Path "$PSScriptRoot" ".." "build.ps1")
Initialize-Arcade $PSScriptRoot
Initialize-ArcadeRootModule (Get-Module -Name $script:rootModuleName)