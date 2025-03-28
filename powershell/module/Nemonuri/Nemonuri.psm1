using namespace System.IO

. "$PSScriptRoot/DebugTheory.ps1"
. "$PSScriptRoot/NemonuriContextTheory.ps1"
. "$PSScriptRoot/ConditionalTheory.ps1"
. "$PSScriptRoot/ArcadeContextTheory.ps1"
. "$PSScriptRoot/FileSystemTheory.ps1"
. "$PSScriptRoot/WorkspaceTheory.ps1"
. "$PSScriptRoot/ScriptBlockTheory.ps1"

function Test-InvokedScript {

    [OutputType([bool])]
    param (
        [Parameter(Mandatory, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string] $ScriptPath
    )

    Write-InvocationInfo $MyInvocation -D

    [string]$scriptFullPath = [Path]::GetFullPath($ScriptPath)

    $nmContext = Get-NemonuriContext

    if ($nmContext.InvokedProfile -in $scriptFullPath) {
        return $false
    }

    $nmContext.InvokedProfile += $scriptFullPath
    return $true
}

function Test-ModulePath {

    [OutputType([void])]
    param (
        [Parameter(Mandatory, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string] $ModulePath
    )

    Write-InvocationInfo $MyInvocation -D
    
    $modulePaths = $env:PSModulePath -split ([Path]::PathSeparator)
    $result = ($modulePaths -ccontains $ModulePath)

    Write-Debug "Test-ModulePath result: $result"

    return $result
}

function Add-ModulePath {

    [OutputType([void])]
    param (
        [Parameter(Mandatory, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string] $ModulePath,

        [switch] $AllowInvalid
    )

    Write-InvocationInfo $MyInvocation -D

    [string]$normalizedModulePath = [Path]::GetFullPath($ModulePath)
    Write-Debug "normalizedModulePath: $normalizedModulePath"

    if (-not $AllowInvalid) {
        if (-not (Test-Path -Path $normalizedModulePath -PathType Container)) {
            Write-Error "ModulePath: $normalizedModulePath"
            throw "ModulePath is invalid, or no directory at the path."
        }
    }

    [bool]$doesModulePathExist = Test-ModulePath $normalizedModulePath
    if (-not $doesModulePathExist) {
        $v = $env:PSModulePath
        $v = $normalizedModulePath + [Path]::PathSeparator + $v
        $env:PSModulePath = $v
    }

    $env:PSModulePath -split ([Path]::PathSeparator) | Write-Debug
}
