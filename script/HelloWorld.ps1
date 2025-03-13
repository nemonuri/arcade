
Write-Debug "HelloWorld.ps1 Invoked"

function Write-HelloWorld {
    param (
    )
    
    $v = Join-String -InputObject $args -Separator ', '
    Write-Host "Hello, World! $v"
}