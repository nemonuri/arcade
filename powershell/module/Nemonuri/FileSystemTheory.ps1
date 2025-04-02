using namespace System.IO

function Get-FullPath {

    [OutputType([string])]
    param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline)]
        [string] $Path
    )

    Write-InvocationInfo $MyInvocation -D

    [string]$fullPath = [Path]::GetFullPath($Path);
    Write-Debug "fullPath: $fullPath"

    return $fullPath
}

function Get-ParentItem {

    [OutputType([void], [string])]
    param (
        [Parameter(Mandatory, Position=0)]
        [string[]] $Include,

        [string] $Path = "",
        [uint] $Depth = 1,
        [Microsoft.PowerShell.Commands.TestPathType] $PathType = 'Any',
        [switch] $AllowZeroDepth
    )
    
    Write-InvocationInfo $MyInvocation -D

    [string]$currentFullPath = $Path
    #--- Init currentFullPath ---
    $currentFullPath = Get-NotEmptyString "$currentFullPath" (Get-Location).Path
    $currentFullPath = [Path]::GetFullPath($currentFullPath)
    #---|

    [string]$prevFullPath = ""

    [uint]$currentDepth = 0

    while ($currentDepth -le $Depth) {
        if (-not (($currentDepth -eq 0) -and (-not $AllowZeroDepth))) {
            $founds = @(
                $Include | 
                    ForEach-Object { 
                        Write-Debug "currentDepth: $currentDepth, currentFullPath: $currentFullPath, psitem: $_"
                        $Local:result = @()
                        if (($PathType -eq 'Any') -or ($PathType -eq 'Container')) {
                            if ($currentFullPath -like $_) {
                                $Local:result += $currentFullPath
                            }
                        }
                        $Local:result += [Directory]::GetFileSystemEntries($currentFullPath, $_, [SearchOption]::TopDirectoryOnly)
                        Write-Debug "local result: $Local:result, Count: $(($Local:result).Count), Rank: $(($Local:result).Rank)"
                        return $Local:result
                    } |
                    ForEach-Object { $_ }
                    ) |
                Where-Object { $_ -is [string] } |
                Where-Object { Test-Path $_ -PathType $PathType }
            
            if (Test-Debug) {
                if ($null -eq $founds) {
                    Write-Debug "founds: (null)"
                } else {
                    Write-Debug "founds: $founds, $($founds.GetType())"
                }
            }

            if ($founds -is [string]) {
                return $founds
            } elseif ($founds -is [System.Collections.ArrayList]) {
                Write-Debug "founds[0]: $($founds[0]), $($founds[0].GetType())"
                return $founds[0]
            }
        }

        $prevFullPath = $currentFullPath
        $currentFullPath = [Path]::GetFullPath((Join-Path $currentFullPath ".."))

        if ($prevFullPath -eq $currentFullPath) {
            return
        }

        $currentDepth += 1
    }
}

function Invoke-ParentFile {
    
    [OutputType([object])]
    param (
        [Parameter(Mandatory, Position=0)]
        [string[]] $Include,
        
        [string] $Path = "",
        [uint] $Depth = 1,
        [switch] $AllowZeroDepth,

        [object[]] $ArgumentList,

        [switch] $AllowThrow
    )

    Write-InvocationInfo $MyInvocation -D

    $fwd = @{
        Path = $Path
        Depth = $Depth
        AllowZeroDepth = $AllowZeroDepth
    }

    [string]$parentFilePath = Get-ParentItem -Include $Include -PathType 'Leaf' @fwd

    if ([string]::IsNullOrWhiteSpace($parentFilePath)) {
        $msg = "Cannot find file. Include: $Include"
        if ($AllowThrow) {
            throw $msg
        } else {
            Write-Debug $msg
            return $null
        }
    }

    Write-Debug "Found parent file. Path: $parentFilePath"

    $result = & $parentFilePath @ArgumentList
    return $result
}