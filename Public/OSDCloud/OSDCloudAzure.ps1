function Connect-OSDCloudAzure {
    <#
    .SYNOPSIS
    Connect to Azure and initialize OSDCloudAzure session state.

    .DESCRIPTION
    Installs the Azure and Microsoft Graph modules required by OSDCloudAzure, signs in to Azure,
    optionally prompts for a subscription when multiple subscriptions are available, and populates
    the global context, token, and header variables used by the Azure deployment workflow.

    .PARAMETER UseDeviceAuthentication
    Use device-code authentication instead of the interactive Azure sign-in flow.

    .EXAMPLE
    Connect-OSDCloudAzure
    Signs in to Azure using the interactive browser-based authentication flow.

    .EXAMPLE
    Connect-OSDCloudAzure -UseDeviceAuthentication
    Signs in to Azure by using device-code authentication.

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Updated help to repo standard

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .LINK
    https://github.com/OSDeploy/OSD/blob/master/docs/Connect-OSDCloudAzure.md
    #>
    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]
        $UseDeviceAuthentication
    )
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Green "Connect-OSDCloudAzure"

    if ($env:SystemDrive -eq 'X:') {
        $UseDeviceAuthentication = $true
        $OSDCloudLogs = "$env:TEMP\osdcloud-logs"
        if (-not (Test-Path $OSDCloudLogs)) {
            New-Item $OSDCloudLogs -ItemType Directory -Force | Out-Null
        }
    }
    Invoke-Expression -Command (Invoke-RestMethod -Uri functions.osdcloud.com)
    osdcloud-InstallPowerShellModule -Name 'AzureAD'
    osdcloud-InstallPowerShellModule -Name 'Az.Accounts'
    osdcloud-InstallPowerShellModule -Name 'Az.KeyVault'
    osdcloud-InstallPowerShellModule -Name 'Az.Resources'
    osdcloud-InstallPowerShellModule -Name 'Az.Storage'
    osdcloud-InstallPowerShellModule -Name 'Microsoft.Graph.Authentication'
    osdcloud-InstallPowerShellModule -Name 'Microsoft.Graph.DeviceManagement'

    Import-Module -Name 'Az.Accounts' -Force

    if ($UseDeviceAuthentication) {
        Connect-AzAccount -UseDeviceAuthentication -AuthScope Storage -ErrorAction Stop
    }
    else {
        Connect-AzAccount -AuthScope Storage -ErrorAction Stop
    }

    $Global:AzSubscription = Get-AzSubscription

    if (($Global:AzSubscription).Count -ge 2) {
        $i = $null
        $Results = foreach ($Item in $Global:AzSubscription) {
            $i++

            $ObjectProperties = @{
                Number  = $i
                Name    = $Item.Name
                Id      = $Item.Id
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
        }

        $Results | Select-Object -Property Number, Name, Id | Format-Table | Out-Host

        do {
            $SelectReadHost = Read-Host -Prompt "Select an Azure Subscription by Number"
        }
        until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $Results.Number))))

        $Results = $Results | Where-Object {$_.Number -eq $SelectReadHost}

        $Global:AzContext = Set-AzContext -Subscription $Results.Id
    }
    else {
        $Global:AzContext = Get-AzContext
    }

    if ($Global:AzContext) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Green 'Welcome to Azure OSDCloud!'
        $Global:AzAccount = $Global:AzContext.Account
        $Global:AzEnvironment = $Global:AzContext.Environment
        $Global:AzTenantId = $Global:AzContext.Tenant
        $Global:AzSubscription = $Global:AzContext.Subscription

        Write-Host -ForegroundColor Cyan        'Account:           ' $Global:AzAccount
        Write-Host -ForegroundColor Cyan        'AzEnvironment:     ' $Global:AzEnvironment
        Write-Host -ForegroundColor Cyan        'AzTenantId:        ' $Global:AzTenantId
        Write-Host -ForegroundColor Cyan        'AzSubscription:    ' $Global:AzSubscription
        if ($null -eq $Global:AzContext.Subscription) {
            Write-Warning 'You do not have access to an Azure Subscriptions'
            Write-Warning 'This is likely due to not having rights to Azure Resources or Azure Storage'
            Write-Warning 'Contact your Azure administrator to resolve this issue'
            Break
        }

        #Write-Host ''
        #Write-Host -ForegroundColor DarkGray    'Azure Context:             $Global:AzContext'
        #Write-Host -ForegroundColor DarkGray    'Access Tokens:             $Global:Az*AccessToken'
        #Write-Host -ForegroundColor DarkGray    'Headers:                   $Global:Az*Headers'
        #Write-Host ''

        if ($OSDCloudLogs) {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Logging $OSDCloudLogs\AzSubscription.json"
            $Global:AzSubscription | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzSubscription.json" -Encoding ascii -Width 2000 -Force

            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Logging $OSDCloudLogs\AzContext.json"
            $Global:AzContext | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzContext.json" -Encoding ascii -Width 2000 -Force
        }
        #=================================================
        #	AAD Graph
        #=================================================
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Generating AadGraph Access Tokens"
        $Global:AzAadGraphAccessToken = Get-AzAccessToken -ResourceTypeName AadGraph
        $Global:AzAadGraphHeaders = @{
            'Authorization' = 'Bearer ' + $Global:AzAadGraphAccessToken.Token
            'Content-Type'  = 'application/json'
            'ExpiresOn'     = $Global:AzAadGraphAccessToken.ExpiresOn
        }
        if ($OSDCloudLogs) {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Logging $OSDCloudLogs\AzAadGraphAccessToken.json"
            $Global:AzAadGraphAccessToken | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzAadGraphAccessToken.json" -Encoding ascii -Width 2000 -Force

            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Logging $OSDCloudLogs\AzAadGraphHeaders.json"
            $Global:AzAadGraphHeaders | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzAadGraphHeaders.json" -Encoding ascii -Width 2000 -Force
        }
        #=================================================
        #	Azure KeyVault
        #=================================================
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Generating KeyVault Access Tokens"
        $Global:AzKeyVaultAccessToken = Get-AzAccessToken -ResourceTypeName KeyVault
        $Global:AzKeyVaultHeaders = @{
            'Authorization' = 'Bearer ' + $Global:AzKeyVaultAccessToken.Token
            'Content-Type'  = 'application/json'
            'ExpiresOn'     = $Global:AzKeyVaultAccessToken.ExpiresOn
        }
        if ($OSDCloudLogs) {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Logging $OSDCloudLogs\AzKeyVaultAccessToken.json"
            $Global:AzKeyVaultAccessToken | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzKeyVaultAccessToken.json" -Encoding ascii -Width 2000 -Force

            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Logging $OSDCloudLogs\AzKeyVaultHeaders.json"
            $Global:AzKeyVaultHeaders | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzKeyVaultHeaders.json" -Encoding ascii -Width 2000 -Force
        }
        #=================================================
        #	Azure MSGraph
        #=================================================
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Generating MSGraph Access Tokens"
        $Global:AzMSGraphAccessToken = Get-AzAccessToken -ResourceTypeName MSGraph
        $Global:AzMSGraphHeaders = @{
            'Authorization' = 'Bearer ' + $Global:AzMSGraphAccessToken.Token
            'Content-Type'  = 'application/json'
            'ExpiresOn'     = $Global:AzMSGraphHeaders.ExpiresOn
        }
        if ($OSDCloudLogs) {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Logging $OSDCloudLogs\AzMSGraphAccessToken.json"
            $Global:AzMSGraphAccessToken | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzMSGraphAccessToken.json" -Encoding ascii -Width 2000 -Force

            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Logging $OSDCloudLogs\AzMSGraphHeaders.json"
            $Global:AzMSGraphHeaders | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzMSGraphHeaders.json" -Encoding ascii -Width 2000 -Force
        }
        #=================================================
        #	Azure Storage
        #=================================================
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Generating Storage Access Tokens"
        $Global:AzStorageAccessToken = Get-AzAccessToken -ResourceTypeName Storage
        $Global:AzStorageHeaders = @{
            'Authorization' = 'Bearer ' + $Global:AzStorageAccessToken.Token
            'Content-Type'  = 'application/json'
            'ExpiresOn'     = $Global:AzStorageHeaders.ExpiresOn
        }
        if ($OSDCloudLogs) {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Logging $OSDCloudLogs\AzStorageAccessToken.json"
            $Global:AzStorageAccessToken | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzStorageAccessToken.json" -Encoding ascii -Width 2000 -Force

            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Logging $OSDCloudLogs\AzStorageHeaders.json"
            $Global:AzStorageHeaders | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzStorageHeaders.json" -Encoding ascii -Width 2000 -Force
        }
        #=================================================
        #	AzureAD
        #=================================================
        #$Global:MgGraph = Connect-MgGraph -AccessToken $Global:AzMSGraphAccessToken.Token -Scopes DeviceManagementConfiguration.Read.All,DeviceManagementServiceConfig.Read.All
        #Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Connecting to AzureAD"
        #$Global:AzureAD = Connect-AzureAD -AadAccessToken $Global:AzAadGraphAccessToken.Token -AccountId $Global:AzContext.Account.Id
    }
    else {
        Write-Warning "Unable to get AzContext"
    }
}
function Start-OSDCloudAzure {
    <#
    .SYNOPSIS
    Start an OSDCloud deployment from Azure Storage.

    .DESCRIPTION
    Runs from WinPE, installs the OSDCloudAzure dependencies, connects to Azure, discovers
    available OSDCloud resources, and starts the deployment workflow when an image is available.

    .PARAMETER Force
    Reset OSDCloudAzure state before continuing.

    .EXAMPLE
    Start-OSDCloudAzure
    Starts an Azure-backed OSDCloud deployment using the current selection.

    .EXAMPLE
    Start-OSDCloudAzure -Force
    Resets the current Azure image selection and restarts the deployment flow.

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Updated help to repo standard

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .LINK
    https://github.com/OSDeploy/OSD/blob/master/docs/Start-OSDCloudAzure.md
    #>

    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]
        #Resets everything to initial settings
        $Force
    )
    if ($env:SystemDrive -eq 'X:') {
        if ($Force) {
            $Force = $false
            $Global:AzOSDCloudBlobImage = $null
        }

        $Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Start-OSDCloudAzure.log"
        $null = Start-Transcript -Path (Join-Path "$env:SystemRoot\Temp" $Transcript) -ErrorAction Ignore
        Invoke-Expression -Command (Invoke-RestMethod -Uri functions.osdcloud.com)
        osdcloud-StartWinPE -OSDCloud
        Connect-OSDCloudAzure
        Get-OSDCloudAzureResources
        $null = Stop-Transcript -ErrorAction Ignore

        if ($Global:AzOSDCloudBlobImage) {
            Write-Host -ForegroundColor DarkGray '========================================================================='
            Write-Host -ForegroundColor Green 'Start-OSDCloudAzure'
            & "$($MyInvocation.MyCommand.Module.ModuleBase)\Projects\OSDCloudAzure\MainWindow.ps1"
            Start-Sleep -Seconds 2

            if ($Global:StartOSDCloud.AzOSDCloudImage) {
                Write-Host -ForegroundColor DarkGray '========================================================================='
                Write-Host -ForegroundColor Green "Invoke-OSDCloud ... Starting in 5 seconds..."
                Start-Sleep -Seconds 5
                Invoke-OSDCloud
            }
            else {
                Write-Warning "Unable to get a Windows Image from OSDCloudAzure to handoff to Invoke-OSDCloud"
            }
        }
        else {
            Write-Warning 'Unable to find resources to OSDCloudAzure'
        }
    }
    else {
        Write-Warning "OSDCloudAzure must be run from WinPE"
    }
}
