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
        [string]$SubPath,

        [Parameter(Mandatory, ParameterSetName="Default", HelpMessage="Arcade script name without extension")]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter()]
        [switch]$NoNewRoot,

        [Parameter(Mandatory, ParameterSetName="NemonuriPreset")]
        [Alias("NM")]
        [switch]$NemonuriPreset,

        [Parameter(ParameterSetName="NemonuriPreset")]
        [string]$RootParentPath,

        [Parameter(Mandatory, ValueFromPipeline, Position=0, ParameterSetName="NemonuriPreset")]
        [ValidateNotNullOrEmpty()]
        [string]$ScriptPath,

        [Parameter()]
        [switch]$Force
    )

    if ($MyInvocation.CommandOrigin -ne 'Internal') {
        throw "Use dot sourcing. MyInvocation.CommandOrigin: $($MyInvocation.CommandOrigin)"
    }

    Write-Debug (Get-PSCallStack)[0]
    Write-Debug "Uri: $Uri"
    Write-Debug "RootPath: $RootPath"
    Write-Debug "SubPath: $SubPath"
    Write-Debug "Name: $Name"
    Write-Debug "CreateRootDirectory: $CreateRootDirectory"

    Write-Debug "NemonuriPreset: $NemonuriPreset"
    Write-Debug "RootParentPath: $RootParentPath"
    Write-Debug "ScriptPath: $ScriptPath"

    Write-Debug "Force: $Force"

    $CreateRootDirectory = -not $NoNewRoot

    #--- Set Nemonuri preset if switch actived ---
    if ($NemonuriPreset) {
        Write-Debug "Apply NemonuriPreset"

        if ([string]::IsNullOrWhiteSpace($RootParentPath)) {
            Write-Debug "RootParentPath is empty"

            Write-Debug "global:ArcadeScriptRootParentPath: $global:ArcadeScriptRootParentPath"
            if ([string]::IsNullOrWhiteSpace($global:ArcadeScriptRootParentPath)) {
                $RootParentPath = (Get-Location).Path
            } else {
                $RootParentPath = $global:ArcadeScriptRootParentPath
            }

            Write-Debug "Set RootParentPath: $RootParentPath"
        }

        $RootPath = [Path]::Combine($RootParentPath, ".arcade", ".script")
        Write-Debug "Set RootPath: $RootPath"

        $SubPath = [Path]::GetDirectoryName($ScriptPath)
        Write-Debug "Set SubPath: $SubPath"

        $Name = [Path]::GetFileNameWithoutExtension($ScriptPath)
        Write-Debug "Set Name: $Name"

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
        if ($CreateRootDirectory) {
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
