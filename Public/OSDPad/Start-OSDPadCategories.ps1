function Start-OSDPadCategories {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [Alias('Owner','GitOwner')]
        [string]$RepoOwner,
        
        [Parameter(Mandatory = $true, Position = 1)]     
        [Alias('Repository','GitRepo')]
        [string]$RepoName,

        [Parameter(ParameterSetName = 'GitHub')]
        [Alias('OAuthToken')]
        [string]$OAuth
    )
    #================================================
    #   Set Global Variables
    #================================================
    $Global:OSDPadRepository = @{
        Owner = $RepoOwner
        Name = $RepoName
    }
    $Global:OSDPadBranding = @{
        Title = $RepoName
        Color = '#01786A'
    }
    #================================================
    #   GitHub
    #================================================
    # Set Params
    $Params = @{
        Method          = 'GET'
        Uri             = "https://api.github.com/repos/$RepoOwner/$RepoName/contents"
        UseBasicParsing = $true
    }

    if ($OAuth) {
        $Params.add("Headers", @{"PRIVATE-TOKEN" = "$OAuth"})
    }
    else {
        $GitHubApiRateLimit = Invoke-RestMethod -UseBasicParsing -Uri 'https://api.github.com/rate_limit' -Method Get
        Write-Host -ForegroundColor DarkGray "You have used $($GitHubApiRateLimit.rate.used) of your $($GitHubApiRateLimit.rate.limit) GitHub API Requests"
        Write-Host -ForegroundColor DarkGray "You can create an OAuth Token at https://github.com/settings/tokens"
    }


    $Global:OSDPadCategories = @()
    try {
        $Global:OSDPadCategories = Invoke-RestMethod @Params -ErrorAction Stop
    }
    catch {
        Write-Warning $_
        Break
    }
    $Global:OSDPadCategories = $Global:OSDPadCategories | Where-Object {($_.type -eq 'dir')} | Sort-Object Name
    $Global:OSDPad = $null
    #================================================
    #   OSDPadCategories.ps1
    #================================================
    & "$($MyInvocation.MyCommand.Module.ModuleBase)\Projects\OSDPadCategories.ps1"
    #================================================
}