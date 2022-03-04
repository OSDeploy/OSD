function Start-OSDPad {
    [CmdletBinding(DefaultParameterSetName = 'Standalone')]
    param (
        [Parameter(ParameterSetName = 'GitHub', Mandatory = $true, Position = 0)]
        [Alias('Owner','GitOwner')]
        [string]$RepoOwner,
        
        [Parameter(ParameterSetName = 'GitHub', Mandatory = $true, Position = 1)]
        [Alias('Repository','GitRepo')]
        [string]$RepoName,
        
        [Parameter(ParameterSetName = 'GitHub', Position = 2)]
        [Alias('GitPath','Folder')]
        [string]$RepoFolder,
        
        [Parameter(ParameterSetName = 'GitHub')]
        [Alias('OAuthToken')]
        [string]$OAuth,

        [Alias('BrandingTitle')]
        [string]$Brand = 'OSDPad',
        [Alias('BrandingColor')]
        [string]$Color = '#01786A',
        
        [ValidateSet('Branding','Script')]
        [string[]]$Hide
    )
    #================================================
    #   Branding
    #================================================
    $Global:OSDPadBranding = $null
    $Global:OSDPadBranding = @{
        Title   = $Brand
        Color   = $Color
    }
    #================================================
    #   GitHub
    #================================================
    if ($PSCmdlet.ParameterSetName -eq 'GitHub') {
        $Uri = "https://api.github.com/repos/$RepoOwner/$RepoName/contents/$RepoFolder"
        Write-Host -ForegroundColor DarkCyan $Uri

        if ($OAuth) {
            $Params = @{
                Headers = @{Authorization = "Bearer $OAuth"}
                Method = 'GET'
                Uri = $Uri
                UseBasicParsing = $true
            }
        }
        else {
            $GitHubApiRateLimit = Invoke-RestMethod -UseBasicParsing -Uri 'https://api.github.com/rate_limit' -Method Get
            Write-Host -ForegroundColor DarkGray "You have used $($GitHubApiRateLimit.rate.used) of your $($GitHubApiRateLimit.rate.limit) GitHub API Requests"
            Write-Host -ForegroundColor DarkGray "You can create an OAuth Token at https://github.com/settings/tokens"
            Write-Host -ForegroundColor DarkGray 'Use the OAuth parameter to enable OSDPad Child-Item support'
            $Params = @{
                Method = 'GET'
                Uri = $Uri
                UseBasicParsing = $true
            }
        }

        $GitHubApiContent = @()
        try {
            $GitHubApiContent = Invoke-RestMethod @Params -ErrorAction Stop
        }
        catch {
            Write-Warning $_
            Break
        }      
        
        if ($OAuth) {
            foreach ($Item in $GitHubApiContent) {
                if ($Item.type -eq 'dir') {
                    Write-Host -ForegroundColor DarkCyan $Item.url
                    $GitHubApiContent += Invoke-RestMethod -UseBasicParsing -Uri $Item.url -Method Get -Headers @{Authorization = "Bearer $OAuth" }
                }
            }
        }

        #$GitHubApiContent = $GitHubApiContent | Where-Object {$_.type -eq 'file'} | Where-Object {($_.name -match 'README.md') -or ($_.name -like "*.ps1")}
        $GitHubApiContent = $GitHubApiContent | Where-Object {($_.type -eq 'dir') -or ($_.name -like "*.md") -or ($_.name -like "*.ps1")}

        Write-Host -ForegroundColor DarkGray "========================================================================="
        $Results = foreach ($Item in $GitHubApiContent) {
            #$FileContent = Invoke-RestMethod -UseBasicParsing -Uri $Item.git_url
            if ($Item.type -eq 'dir') {
                Write-Host -ForegroundColor DarkCyan "Directory: Start-OSDPad $RepoOwner $RepoName $($Item.name)"
                
                $ObjectProperties = @{
                    RepoOwner       = $RepoOwner
                    RepoName        = $RepoName
                    RepoFolder      = $RepoFolder
                    Name            = $Item.name
                    Type            = $Item.type
                    Guid            = New-Guid
                    Path            = $Item.path
                    Size            = $Item.size
                    SHA             = $Item.sha
                    Git             = $Item.git_url
                    Download        = $Item.download_url
                    ContentRAW      = $null
                    #NodeId         = $FileContent.node_id
                    #Content        = $FileContent.content
                    #Encoding       = $FileContent.encoding
                }
                #New-Object -TypeName PSObject -Property $ObjectProperties
            }
            else {
                Write-Host -ForegroundColor DarkGray $Item.download_url
                try {
                    $ScriptWebRequest = Invoke-WebRequest -Uri $Item.download_url -UseBasicParsing -ErrorAction Ignore
                }
                catch {
                    Write-Warning $_
                    $ScriptWebRequest = $null
                    Continue
                }
        
                $ObjectProperties = @{
                    RepoOwner       = $RepoOwner
                    RepoName        = $RepoName
                    RepoFolder      = $RepoFolder
                    Name            = $Item.name
                    Type            = $Item.type
                    Guid            = New-Guid
                    Path            = $Item.path
                    Size            = $Item.size
                    SHA             = $Item.sha
                    Git             = $Item.git_url
                    Download        = $Item.download_url
                    ContentRAW      = $ScriptWebRequest.Content
                    #NodeId         = $FileContent.node_id
                    #Content        = $FileContent.content
                    #Encoding       = $FileContent.encoding
                }
                New-Object -TypeName PSObject -Property $ObjectProperties
            }
        }
        $Global:OSDPad = $Results
        
    }
    else {
        $Global:OSDPad = $null
    }
    #================================================
    #   OSDPad.ps1
    #================================================
    & "$($MyInvocation.MyCommand.Module.ModuleBase)\Projects\OSDPad.ps1"
    #================================================
}