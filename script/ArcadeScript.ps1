using namespace System.IO

function Import-ArcadeScript {
    [CmdletBinding(DefaultParameterSetName="Default")]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName="Default", HelpMessage="Download uri")]
        [ValidateNotNullOrEmpty()]
        [string]$Uri,

        [Parameter(Mandatory, ParameterSetName="Default", HelpMessage="Arcade script directory path")]
        [ValidateNotNullOrEmpty()]
        [string]$RootPath,

        [Parameter(ParameterSetName="Default")]
        [Parameter(ParameterSetName="NemonuriPreset")]
        [string]$SubPath,

        [Parameter(Mandatory, ParameterSetName="Default", HelpMessage="Arcade script name without extension")]
        [Parameter(Mandatory, ParameterSetName="NemonuriPreset", HelpMessage="Arcade script name without extension")]
        [ValidateNotNullOrEmpty()]
        [Alias("n")]
        [string]$Name,

        [Parameter(ParameterSetName="Default")]
        [Parameter(ParameterSetName="NemonuriPreset")]
        [Alias("cr")]
        [switch]$CreateRootDirectoryIfNotExist,

        [Parameter(ParameterSetName="NemonuriPreset")]
        [Alias("np")]
        [switch]$NemonuriPreset,

        [Parameter(ParameterSetName="NemonuriPreset")]
        [string]$RootParentPath,

        [Parameter()]
        [switch]$Force
    )

    Write-Debug (Get-PSCallStack)[0]
    Write-Debug "Uri: $Uri"
    Write-Debug "RootPath: $RootPath"
    Write-Debug "SubPath: $SubPath"
    Write-Debug "Name: $Name"
    Write-Debug "CreateRootDirectoryIfNotExist: $CreateRootDirectoryIfNotExist"

    Write-Debug "NemonuriPreset: $NemonuriPreset"
    Write-Debug "RootParentPath: $RootParentPath"
    Write-Debug "Force: $Force"


    #--- Set Nemonuri preset if switch actived ---
    if ($NemonuriPreset) {
        Write-Debug "Apply NemonuriPreset"

        if ([string]::IsNullOrWhiteSpace($RootParentPath)) {
            Write-Debug "RootParentPath is empty"
            $RootParentPath = (Get-Location).Path
            Write-Debug "Set RootParentPath: $RootParentPath"
        }

        $RootPath = [Path]::Combine($RootParentPath, ".arcade", ".script")
        Write-Debug "Set RootPath: $RootPath"

        $uriSubPathSegment = ""
        if (-not [string]::IsNullOrWhiteSpace($SubPath)) {
            $uriSubPathSegment = "${SubPath}/"
        }
        Write-Debug "uriSubPathSegment: $uriSubPathSegment"

        $Uri = "https://raw.githubusercontent.com/nemonuri/nemonuri-arcade/master/script/${uriSubPathSegment}${Name}.ps1"
        Write-Debug "Uri: $Uri"
    }
    #---|

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
