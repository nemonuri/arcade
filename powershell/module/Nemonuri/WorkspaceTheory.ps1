
function Get-Workspace {

    Join-Path (Get-Arcade) ".." -Resolve

}

function Get-Src {
    
    Join-Path (Get-Workspace) "src" -Resolve
    
}

function Get-VSCodeConfig {

    Join-Path (Get-Workspace) ".vscode" -Resolve
    
}

function Get-VSCodeConfigSetting {
    
    Join-Path (Get-VSCodeConfig) "settings.json" -Resolve

}

function Initialize-ProfiledPowershell {

    $text = @'
{
    "terminal.integrated.profiles.windows": {
        "Profiled Powershell": {
            "path": "pwsh.exe",
            "args": ["-NoExit", "-Command", "try { . (Join-Path \"${execPath}\" \"..\" \"resources\\app\\out\\vs\\workbench\\contrib\\terminal\\common\\scripts\\shellIntegration.ps1\"); . \"${workspaceFolder}\\profile.ps1\" } catch { Write-Warning $_ }"],
            "overrideName": true
        }
    },
    "terminal.integrated.defaultProfile.windows": "Profiled Powershell"
}
'@

    if (-not (Test-Path (Get-VSCodeConfig) -PathType Container)) {
        New-Item (Get-VSCodeConfig) -ItemType Directory
    }
    New-Item -Path (Get-VSCodeConfigSetting) -ItemType File -Value $text
    
}

function Initialize-Profile {

    $text = @'
if ((Test-Path "$PSScriptRoot/../preprofile.ps1")) {. "$PSScriptRoot/../preprofile.ps1"}
. "$PSScriptRoot/.arcade/arcade_profile.ps1"
if ((Test-Path "$PSScriptRoot/../postprofile.ps1")) {. "$PSScriptRoot/../postprofile.ps1"}
'@

    $path = Join-Path (Get-Workspace) "profile.ps1"
    New-Item -Path $path -ItemType File -Value $text

}