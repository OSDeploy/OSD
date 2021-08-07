function Start-ScriptRepo {
    [CmdletBinding(DefaultParameterSetName = 'Standalone')]
    param (
        [Parameter(ParameterSetName = 'GitHub', Mandatory = $true, Position = 0)]
        [Alias('GitOwner')]
        [string]$Owner,
        
        [Parameter(ParameterSetName = 'GitHub', Mandatory = $true, Position = 1)]
        [Alias('GitRepo','Repository')]
        [string]$Repo,
        
        [Parameter(ParameterSetName = 'GitHub', Position = 2)]
        [Alias('GitPath')]
        [string]$Path,
        
        [Parameter(ParameterSetName = 'GitHub')]
        [Alias('OAuthToken')]
        [string]$OAuth
    )
    #=======================================================================
    #   GitHub
    #=======================================================================
    if ($PSCmdlet.ParameterSetName -eq 'GitHub') {
        $Uri = "https://api.github.com/repos/$Owner/$Repo/contents/$Path"
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
            Write-Host -ForegroundColor DarkGray 'Use the OAuth parameter to enable ScriptRepo Child-Item support'
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

        Write-Host -ForegroundColor DarkGray "================================================"
        $Results = foreach ($Item in $GitHubApiContent) {
            #$FileContent = Invoke-RestMethod -UseBasicParsing -Uri $Item.git_url
            Write-Host -ForegroundColor DarkGray $Item.download_url
            if ($Item.type -eq 'dir') {
                $ObjectProperties = @{
                    Owner           = $Owner
                    Repo            = $Repo
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
                try {
                    $ScriptWebRequest = Invoke-WebRequest -Uri $Item.download_url -UseBasicParsing -ErrorAction Ignore
                }
                catch {
                    Write-Warning $_
                    $ScriptWebRequest = $null
                    Continue
                }
        
                $ObjectProperties = @{
                    Owner           = $Owner
                    Repo            = $Repo
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
    
        $Global:ScriptRepo = $Results
    }
    else {
        $Global:ScriptRepo = $null
    }
    #=======================================================================
    #   ScriptRepo.ps1
    #=======================================================================
    & "$($MyInvocation.MyCommand.Module.ModuleBase)\GUI\ScriptRepo.ps1"
    #=======================================================================
}
function Show-OSDCloudExamples {
    [CmdletBinding()]
    param (
        [ValidateSet('Setup','Deploy')]
        [Alias('GitPath')]
        [string]$Path = 'Setup',

        [Alias('OAuthToken')]
        [string]$OAuth
    )

    if ($OAuth) {
        $ScriptRepoParams = @{
            Owner   = 'OSDeploy'
            Repo    = 'ScriptRepo'
            Path    = "OSDCloud/$Path"
            OAuth   = $OAuth
        }
    }
    else {
        $ScriptRepoParams = @{
            Owner   = 'OSDeploy'
            Repo    = 'ScriptRepo'
            Path    = "OSDCloud/$Path"
        }
    }
    Start-ScriptRepo @ScriptRepoParams
}