
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
        [Parameter(Mandatory, ValueFromPipeline, Position=0)]
        [ValidateNotNullOrEmpty()]
        [System.Uri]$Uri,

        [Parameter(Mandatory, val)]
    )
}
