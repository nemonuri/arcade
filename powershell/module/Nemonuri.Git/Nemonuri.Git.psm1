#Requires -Modules Nemonuri

function Add-Submodule {
    param (
        [Parameter(Mandatory, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string] $Repository,

        [Parameter(Position=1)]
        [string] $Path = "",

        [switch] $PassThru,
        [switch] $NoExit,
        [switch] $WriteResult
    )

    Write-InvocationInfo $MyInvocation -D

    $fwd1 = @{
        PassThru = $PassThru
        NoExit = $NoExit
        WriteResult = $WriteResult
    }

    Invoke-Safe { & git submodule add $Repository $Path } @fwd1
}

function New-GitRepository {
    param (
        [Parameter(Position=0)]
        [string] $Path = "",

        [ValidateSet("None", "Empty", "Dotnet")]
        [string] $GitIgnore = "Empty",

        [switch] $ForceGitIgnore,
        [switch] $NoNewDirectory
    )

    Write-InvocationInfo $MyInvocation -D

    [string]$repositoryFullPath = Get-NotEmptyString "$Path" (Get-Location).Path
    $repositoryFullPath = [System.IO.Path]::GetFullPath($repositoryFullPath)
    Write-Debug "repositoryFullPath: $repositoryFullPath"

    # Test repository directory does not exist
    if (-not (Test-Path $repositoryFullPath -PathType 'Container')) {
        if ($NoNewDirectory) {
            Write-Error "NoNewDirectory: $NoNewDirectory"
            Write-Error "Path: $Path"
            Write-Error "repositoryFullPath: $repositoryFullPath"
            throw "Directory does not exist at Path." 
        }

        #--- Create new repository directory ---
        $v = New-Item -Path $repositoryFullPath -ItemType 'Directory'
        if (Test-Debug) {
            Write-Debug "New repositoy directory created."
            Out-Host $v
        }
        #---|
    }

    #--- Set location to repository directory ---
    Push-Location

    Set-Location $repositoryFullPath
    #---|

    try {

        #--- git init ---
        Invoke-Safe { & git status } -NoExit
        if ($LASTEXITCODE -eq 128) {
            Invoke-Safe { & git init }
        }
        #---|

        #--- Create .gitignore ---
        [string]$gitIgnorePath = Join-Path $repositoryFullPath ".gitignore"
        if ($GitIgnore -eq "None") {
            if ($ForceGitIgnore) {
                if ((Test-Path $gitIgnorePath -PathType 'Leaf')) {
                    Remove-Item -Path $gitIgnorePath
                    Write-Debug ".gitignore removed. gitIgnorePath: $gitIgnorePath"
                }
            }
        } elseif ($GitIgnore -eq "Empty") {
            New-Item -Path ".gitignore" -ItemType 'File' -Force $ForceGitIgnore
        } elseif ($GitIgnore -eq "Dotnet") {
            $forceArg = Get-IfElse $ForceGitIgnore "--force" ""
            Invoke-Safe { & dotnet new gitignore $forceArg }
        }
        #---|

    } finally {
        Pop-Location
    }

}