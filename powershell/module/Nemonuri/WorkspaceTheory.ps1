
function Get-Workspace {

    Join-Path (Get-Arcade) ".." -Resolve

}

function Get-Src {
    
    Join-Path (Get-Workspace) "src" -Resolve
    
}