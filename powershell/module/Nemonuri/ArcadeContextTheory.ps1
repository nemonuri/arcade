
#--- Arcade ---
function Test-Arcade {
    [OutputType([bool])]
    param ()

    return Test-NemonuriContextItem "Arcade"
}

function Initialize-Arcade {
    param (
        [Parameter(Mandatory, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string] $Path,

        [switch] $Force
    )
    
    Initialize-NemonuriContextItem "Arcade" $Path -Force:$Force
}

function Get-Arcade {
    [OutputType([string])]
    param ()

    Get-NemonuriContextItem "Arcade"
}
#---|

#--- ArcadeRootModule ---
function Test-ArcadeRootModule {
    [OutputType([bool])]
    param ()

    return Test-NemonuriContextItem "ArcadeRootModule"
}

function Initialize-ArcadeRootModule {
    param (
        [Parameter(Mandatory, Position=0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSModuleInfo] $Module,

        [switch] $Force
    )
    
    Initialize-NemonuriContextItem "ArcadeRootModule" $Module -Force:$Force
}

function Get-ArcadeRootModule {
    [OutputType([string])]
    param ()

    Get-NemonuriContextItem "ArcadeRootModule"
}
#---|