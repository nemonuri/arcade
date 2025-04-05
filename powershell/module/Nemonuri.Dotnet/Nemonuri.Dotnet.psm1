#Requires -Modules Nemonuri

function Test-Solution {
    [OutputType([bool])]
    param (
        [Parameter(Position=0)]
        [ValidateNotNullOrWhiteSpace()]
        [SupportsWildcards()]
        [string] $Name = "*",

        [string] $BasePath = "",
        [switch] $NoAppendSlnExtension
    )
    
    Write-InvocationInfo $MyInvocation -D

    $appending = Get-IfElse ($NoAppendSlnExtension) "" ".sln"

    $correctedBasePath = Get-NotEmptyString "$BasePath" (Get-Src)
    $v = Get-ChildItem -Path $correctedBasePath -File -Filter "$Name$appending" # | Where-Object { $_ -like $Name }
    return $v.Count -gt 0
}

function New-Solution {
    param (
        [Parameter(Mandatory, Position=0)]
        [string] $Name,

        [string] $BasePath = "",

        [Alias("Args")]
        [object[]] $ArgumentList = @()
    )

    Write-InvocationInfo $MyInvocation -D

    $correctedBasePath = Get-NotEmptyString "$BasePath" (Get-Src)
    Write-Debug "correctedBasePath: $correctedBasePath"

    if (-not (Test-Path $correctedBasePath -PathType 'Container')) {
        $v = New-Item $correctedBasePath -ItemType 'Directory'
        Write-Debug "New directory created. Path: $v"
    }

    #$nameArgs = Get-IfElse [string]::IsNullOrWhiteSpace($Name) @() @("--name", $Name)
    $nameArgs = @("--name", $Name)
    Invoke-Safe { & dotnet new sln @nameArgs --output $correctedBasePath @ArgumentList }
}

function New-Project {
    param (
        [Parameter(Mandatory, Position=0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Name,

        [Parameter(Position=1)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Template = "classlib",

        [string] $BasePath = "",
        [string] $SolutionName = "",

        [switch] $NoNewSolution,
        [switch] $NoSlnAdd,

        [uint] $SolutionDepth = 1,

        [Alias("Args")]
        [object[]] $DotnetNewArgumentList = @()
    )
    
    Write-InvocationInfo $MyInvocation -D

    $correctedBasePath = Get-NotEmptyString "$BasePath" (Get-Src)

    if (-not [string]::IsNullOrWhiteSpace($SolutionName)) {
        if (-not (Test-Solution -Name $SolutionName -BasePath $correctedBasePath)) {
            if (-not $NoNewSolution) {
                New-Solution -Name $SolutionName -BasePath $correctedBasePath
            } else {
                throw "Can't find solution. "
            }
        }
    }

    $projectDirectory = Join-Path $correctedBasePath $Name
    if (Test-Path -Path $projectDirectory -PathType Container) {
        throw "Project directory already exists. Path: $projectDirectory"
    }

    New-Item $projectDirectory -ItemType Directory
    Write-Debug "projectDirectory: $projectDirectory"

    Invoke-Safe { & dotnet new $Template --name $Name --output $projectDirectory @DotnetNewArgumentList }

    if (Test-Debug) {
        Get-ChildItem -Path $projectDirectory -File | Out-Host
    }
    $projectFile = Get-ChildItem -Path $projectDirectory -Filter "*.*proj" -File

    Write-Debug "projectFile: $projectFile"

    $addingSln = Get-ParentItem -Include "*.sln" -Path $projectDirectory -PathType Leaf -Depth $SolutionDepth -AllowZeroDepth
    if (-not [string]::IsNullOrWhiteSpace($addingSln)) {
        if (-not $NoSlnAdd) {
            Invoke-Safe { & dotnet sln $addingSln add $projectFile }
        }
    }
}