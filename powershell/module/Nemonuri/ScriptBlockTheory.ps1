
function Invoke-Safe {

    [OutputType([void], [psobject])]
    param (
        [Parameter(Mandatory, Position=0)]
        [scriptblock] $ScriptBlock,

        [Alias("Args")]
        [object[]] $ArgumentList,
        
        [switch] $PassThru,
        [switch] $NoExit,
        [switch] $WriteResult
    )

    Write-InvocationInfo $MyInvocation -D

    $result = $null

    if ($PassThru) {
        $result = (& $ScriptBlock @ArgumentList)
    } else {
        & $ScriptBlock @ArgumentList
    }

    if ($WriteResult) {
        if ($null -ne $result) {
            Out-Host $result
        }
    }

    if (-not $NoExit) {
        if ($LASTEXITCODE) {
            exit $LASTEXITCODE
        }
    }

    if ($null -ne $result) {
        return $result
    }
}

