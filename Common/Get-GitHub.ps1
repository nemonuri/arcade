# Reference: https://computer-science-student.tistory.com/297

function Get-GitHub {
    [CmdletBinding(DefaultParameterSetName="Joined")]
    param (
        [Parameter(Mandatory, Position=0, ParameterSetName="Splitted")]
        [string]$Owner,

        [Parameter(Mandatory, Position=1, ParameterSetName="Splitted")]
        [string]$Repo,

        [Parameter(Mandatory, Position=2, ParameterSetName="Splitted")]
        [string]$Branch,

        [Parameter(Mandatory, Position=3, ParameterSetName="Splitted")]
        [string]$FilePath,

        [Parameter(Mandatory, Position=0, ParameterSetName="Joined")]
        [string]$JoinedFilePath,

        [Parameter(Mandatory, ParameterSetName="Splitted")]
        [Parameter(Mandatory, ParameterSetName="Joined")]
        [Alias("o")]
        [string]$OutPath
    )

    if (-not $IsCoreCLR) {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    }

    if ([string]::IsNullOrWhiteSpace($OutPath)) {
        $uri = "https://raw.githubusercontent.com/${Owner}/${repo}/${branch}/${FilePath}"
    } else {
        $uri = "https://raw.githubusercontent.com/${OutPath}"
    }
    
    Write-Verbose "URI: $uri"
    Invoke-WebRequest $uri -OutFile $OutPath
}

Get-Help Get-GitHub
