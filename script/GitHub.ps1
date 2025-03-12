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

        [Parameter()]
        [Alias("o")]
        [string]$OutPath
    )

    
    Write-Debug (Get-PSCallStack)[0]

    if (-not $IsCoreCLR) {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    }

    if ([string]::IsNullOrWhiteSpace($JoinedFilePath)) {
        $uri = "https://raw.githubusercontent.com/${Owner}/${repo}/${branch}/${FilePath}"
    } else {
        $uri = "https://raw.githubusercontent.com/${JoinedFilePath}"
    }
    
    Write-Debug "uri: $uri"

    $result = Invoke-WebRequest $uri
    
    if (-not [string]::IsNullOrWhiteSpace($OutPath)) {
        Write-Debug "OutPath: $OutPath"
        Out-File -FilePath $OutPath -InputObject $result.Content
    }

    Write-Verbose @"
result:
$result
"@ 

    return $result
}
