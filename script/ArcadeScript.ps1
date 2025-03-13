using namespace System.IO

function Set-ScriptArtifactDirectoryPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position=0)]
        [string]
        $Path
    )

    Write-Debug (Get-PSCallStack)[0]
    Write-Debug "Path: $Path"

    $env:ScriptArtifactDirectoryPath = $Path
}

function Get-ScriptArtifactDirectoryPath {
    return $env:ScriptArtifactDirectoryPath
}

function Get-ScriptArtifactDirectory {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $CreateIfNotExist
    )
}

function Import-ArcadeScript {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, Position=0, HelpMessage="Download uri")]
        [ValidateNotNullOrEmpty()]
        [string]$Uri,

        [Parameter(Mandatory, Position=1, HelpMessage="Arcade script directory path")]
        [ValidateNotNullOrEmpty()]
        [string]$RootPath,

        [Parameter()]
        [string]$SubPath,

        [Parameter(Mandatory, Position=2, HelpMessage="Arcade script name without extension")]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter()]
        [switch]$CreateRootDirectoryIfNotExist,

        [Parameter()]
        [switch]$Force
    )

    Write-Debug (Get-PSCallStack)[0]
    Write-Debug "Uri: $Uri"
    Write-Debug "RootPath: $RootPath"
    Write-Debug "SubPath: $SubPath"
    Write-Debug "Name: $Name"
    Write-Debug "CreateRootDirectoryIfNotExist: $CreateRootDirectoryIfNotExist"
    Write-Debug "Force: $Force"

    #--- If arcade script root directory does not exist, create it ---
    [bool]$doesArcadeScriptRootDirectoryExist = [Directory]::Exists($RootPath)
    Write-Debug "doesArcadeScriptRootDirectoryExist: $doesArcadeScriptRootDirectoryExist"

    if (-not $doesArcadeScriptRootDirectoryExist) {
        if ($CreateRootDirectoryIfNotExist) {
            [Directory]::CreateDirectory($RootPath)
            Write-Host "Arcade script directory created. RootPath: $RootPath"
        } else {
            throw "Arcade script directory not exist. RootPath: $RootPath"
        }
    }
    #---|

    #--- Get script parent directory path ---
    [string]$scriptParentDirectoryPath = $RootPath

    if (-not [string]::IsNullOrWhiteSpace($SubPath)) {
        $scriptParentDirectoryPath = [Path]::Combine($scriptParentDirectoryPath, $SubPath)
    }

    Write-Debug "scriptParentDirectoryPath: $scriptParentDirectoryPath"
    #---|

    #--- If arcade script does not exist (or force switch enabled), download it ---
    [string]$scriptPath = [Path]::Combine($scriptParentDirectoryPath, "${Name}.ps1")
    Write-Debug "scriptPath: $scriptPath"

    [bool]$doesArcadeScriptExist = [File]::Exists($scriptPath)
    Write-Debug "doesArcadeScriptExist: $doesArcadeScriptExist"

    if ((-not $doesArcadeScriptExist) -or $Force) {
        Write-Host "Downloading from $Uri"
        $v = Invoke-WebRequest -Uri $Uri -OutFile $scriptPath -PassThru
        Write-Host "Saved to $scriptPath"

        $v | Out-String | Write-Verbose
        Write-Verbose @"
Content:
$($v.Content)
"@
    }
    #---|

    #--- Dot sourcing script ---
    Write-Host "Dot sourcing script. $scriptPath"
    . $scriptPath
    #---|

}
