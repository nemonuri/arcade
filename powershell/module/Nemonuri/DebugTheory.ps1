
function Test-Debug {

    [OutputType([bool])]
    param ()
    
    return ($DebugPreference -eq 'Continue')
}

function Write-InvocationInfo {

    [OutputType([void])]
    param (
        [Parameter(Mandatory, Position=0)]
        [ValidateNotNull()]
        [System.Management.Automation.InvocationInfo] $InvocationInfo,

        [Alias("D")]
        [switch] $DebugOnly
    )
    
    if ($DebugOnly) {
        if (-not (Test-Debug)) {
            return
        }
    }

    $InvocationInfo |
        Select-Object -Property MyCommand, PositionMessage |
        Format-List | 
        Out-Host
    
    $parameterFormat = @{Label = "Parameter"; Expression = {$_.Key}}
    $argumentFormat = @{Label = "Argument"; Expression = {$_.Value}}
    $InvocationInfo.BoundParameters |
        Format-Table -Property $parameterFormat, $argumentFormat -ShowError -DisplayError | 
        Out-Host
    
    Get-PSCallStack | Out-Host
}