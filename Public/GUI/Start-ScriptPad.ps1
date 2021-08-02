function Start-ScriptPad {
    [CmdletBinding(DefaultParameterSetName = 'Standalone')]
    param (
        [Parameter(ParameterSetName = 'GitHub', Mandatory = $true)]
        [string]
        $GitOwner,
        
        [Parameter(ParameterSetName = 'GitHub', Mandatory = $true)]
        [string]
        $GitRepo,
        
        [Parameter(ParameterSetName = 'GitHub')]
        [string]
        $GitPath
    )
    #=======================================================================
    #   GitHub
    #=======================================================================
    if ($PSCmdlet.ParameterSetName -eq 'GitHub') {
        $Uri = "https://api.github.com/repos/$GitOwner/$GitRepo/contents/$GitPath"
        Write-Host -ForegroundColor DarkCyan $Uri

        #Get the Content from API
        if ($OAuthToken) {
            $GitHubApiContent = Invoke-RestMethod -UseBasicParsing -Uri $Uri -Method Get -Headers @{Authorization = "Bearer $OAuthToken"}
        }
        else {
            $GitHubApiContent = Invoke-RestMethod -UseBasicParsing -Uri $Uri -Method Get
        }
        $GitHubApiContent = $GitHubApiContent | Where-Object {$_.type -eq 'file'} | Where-Object {$_.name -like "*.ps1"}


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
    param ()

    $ScriptPadParams = @{
        GitOwner = 'OSDeploy'
        GitRepo = 'OSDCloud'
        GitPath = 'ScriptPad'
    }

    Start-ScriptPad @ScriptPadParams
}