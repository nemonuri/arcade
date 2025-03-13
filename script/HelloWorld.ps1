
function Write-HelloWorld {
    param (
    )
    
    $v = Join-String -InputObject $args -Separator ', '
    Write-Host "Hello, World! $v"
}