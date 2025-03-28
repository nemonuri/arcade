function Get-NemonuriContext {

    [OutputType([hashtable])]
    param ()

    #--- Ensure NMContext ---
    if (-not (Test-Path variable:global:__NemonuriContext)) {
        $global:__NemonuriContext = @{
        }
    }
    #---|
    
    $global:__NemonuriContext
}

function Test-NemonuriContextItem {

    [OutputType([bool])]
    param (
        [Parameter(Mandatory, Position=0)]
        [ValidateNotNull()]
        [object] $Key
    )
    
    return ($null -ne (Get-NemonuriContext)[$Key])
}

function Initialize-NemonuriContextItem {
    param (
        [Parameter(Mandatory, Position=0)]
        [ValidateNotNull()]
        [object] $Key,

        [Parameter(Mandatory, Position=1)]
        [ValidateNotNull()]
        [object] $Value,

        [switch] $Force
    )
    
    Write-InvocationInfo $MyInvocation -D

    $nmContext = Get-NemonuriContext

    if (Test-NemonuriContextItem -Key $Key) {
        if (-not $Force) {
            throw "$Key is already initialized. ${Key}: $($nmContext[$Key])"
        }
    }

    $nmContext[$Key] = $Value
}

function Get-NemonuriContextItem {

    [OutputType([object])]
    param (
        [Parameter(Mandatory, Position=0)]
        [ValidateNotNull()]
        [object] $Key
    )

    if (-not (Test-NemonuriContextItem -Key $Key)) {
        throw "$Key is not initialized."
    }

    (Get-NemonuriContext)[$Key]
}