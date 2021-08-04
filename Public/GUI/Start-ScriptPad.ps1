function Start-ScriptPad {
    [CmdletBinding(DefaultParameterSetName = 'Standalone')]
    param (
        [Parameter(ParameterSetName = 'GitHub', Mandatory = $true, Position = 0)]
        [string]
        $GitOwner,
        
        [Parameter(ParameterSetName = 'GitHub', Mandatory = $true, Position = 1)]
        [string]
        $GitRepo,
        
        [Parameter(ParameterSetName = 'GitHub', Position = 2)]
        [string]
        $GitPath,
        
        [Parameter(ParameterSetName = 'GitHub')]
        [string]
        $OAuthToken
    )
    #=======================================================================
    #   GitHub
    #=======================================================================
    if ($PSCmdlet.ParameterSetName -eq 'GitHub') {
        $Uri = "https://api.github.com/repos/$GitOwner/$GitRepo/contents/$GitPath"
        Write-Host -ForegroundColor DarkCyan $Uri


        if ($OAuthToken) {
            $Params = @{
                Headers = @{Authorization = "Bearer $OAuthToken"}
                Method = 'GET'
                Uri = $Uri
                UseBasicParsing = $true
            }
        }
        else {
            $GitHubApiRateLimit = Invoke-RestMethod -UseBasicParsing -Uri 'https://api.github.com/rate_limit' -Method Get
            Write-Host -ForegroundColor DarkGray "You have used $($GitHubApiRateLimit.rate.used) of your $($GitHubApiRateLimit.rate.limit) GitHub API Requests"
            Write-Host -ForegroundColor DarkGray "You can create an OAuth Token at https://github.com/settings/tokens"
            Write-Host -ForegroundColor DarkGray 'Use the OAuthToken parameter to enable ScriptPad Child-Item support'
            $Params = @{
                Method = 'GET'
                Uri = $Uri
                UseBasicParsing = $true
            }
        }

        $GitHubApiContent = @()
        $GitHubApiContent = Invoke-RestMethod @Params
        
        if ($OAuthToken) {
            foreach ($Item in $GitHubApiContent) {
                if ($Item.type -eq 'dir') {
                    Write-Host -ForegroundColor DarkCyan $Item.url
                    $GitHubApiContent += Invoke-RestMethod -UseBasicParsing -Uri $Item.url -Method Get -Headers @{Authorization = "Bearer $OAuthToken" }
                }
            }
        }

        $GitHubApiContent = $GitHubApiContent | Where-Object {$_.type -eq 'file'} | Where-Object {($_.name -match 'README.md') -or ($_.name -like "*.ps1")}

        Write-Host -ForegroundColor DarkGray "================================================"
        $Results = foreach ($Item in $GitHubApiContent) {
            #$FileContent = Invoke-RestMethod -UseBasicParsing -Uri $Item.git_url
    
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
                GitOwner    = $GitOwner
                GitRepo     = $GitRepo
                Name            = $Item.name
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
    
        $Global:ScriptPad = $Results
    }
    else {
        $Global:ScriptPad = $null
    }
    #=======================================================================
    #   ScriptPad.ps1
    #=======================================================================
    & "$($MyInvocation.MyCommand.Module.ModuleBase)\GUI\ScriptPad.ps1"
    #=======================================================================
}
function Start-OSDCloudScriptPad {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = 'GitHub')]
        [string]
        $OAuthToken
    )


    if ($OAuthToken) {
        $ScriptPadParams = @{
            GitOwner = 'OSDeploy'
            GitRepo = 'OSDCloud'
            GitPath = 'ScriptPad'
            OAuthToken = $OAuthToken
        }
    }
    else {
        $ScriptPadParams = @{
            GitOwner = 'OSDeploy'
            GitRepo = 'OSDCloud'
            GitPath = 'ScriptPad'
        }
    }

    Start-ScriptPad @ScriptPadParams
}