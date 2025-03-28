
function Get-IfElse {

    param (
        [Parameter(Mandatory, Position=0)]
        [bool] $Condition,

        [Parameter(Mandatory, Position=1)]
        [object] $IfTrue,

        [Parameter(Mandatory, Position=2)]
        [object] $IfFalse
    )

    Write-InvocationInfo $MyInvocation -D

    if ($Condition) {
        return $IfTrue
    } else {
        return $IfFalse
    }
}

function Get-NotEmptyString {

    [OutputType([string])]
    param (
        [Parameter(Mandatory, Position=0)]
        [AllowEmptyString()]
        [string] $Target,

        [Parameter(Mandatory, Position=1)]
        [AllowEmptyString()]
        [string] $Other
    )

    if ([string]::IsNullOrWhiteSpace($Target)) {
        return $Other
    } else {
        return $Target
    }
}