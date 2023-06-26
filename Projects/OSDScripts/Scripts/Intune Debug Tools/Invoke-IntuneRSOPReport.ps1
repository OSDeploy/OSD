If(-not(Get-InstalledModule PSWriteHtml -ErrorAction silentlycontinue)){
    Install-Module -name PSWriteHtml -scope CurrentUser -force -Confirm:$False
}
function Get-IntuneWin32App {
    <#
    .SYNOPSIS
    Function for showing Win32 apps deployed from Intune to local/remote computer.

    Apps details are gathered from clients registry (HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\IntuneManagementExtension\Win32Apps) and Intune log file ($env:ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log)

    .DESCRIPTION
    Function for showing Win32 apps deployed from Intune to local/remote computer.

    App details are gathered from clients registry (HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\IntuneManagementExtension\Win32Apps) and Intune log file ($env:ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log)

    .PARAMETER computerName
    Name of remote computer where you want to get Win32 apps from.

    .PARAMETER getDataFromIntune
    Switch for getting Apps and User names from Intune, so locally used IDs can be translated.
    If you omit this switch, local Intune logs will be searched for such information instead.

    .PARAMETER credential
    Credential object used for Intune authentication.

    .PARAMETER tenantId
    Azure Tenant ID.
    Requirement for Intune App authentication.

    .PARAMETER excludeSystemApp
    Switch for excluding Apps targeted to SYSTEM.

    .EXAMPLE
    Get-IntuneWin32App

    Get and show Win32App(s) deployed from Intune to local computer.
    IDs of targeted users and apps will be translated using information from local Intune log files.

    .EXAMPLE
    Get-IntuneWin32App -computerName PC-01 -getDataFromIntune credential (Get-Credentials)

    Get and show Win32App(s) deployed from Intune to computer PC-01. IDs of apps and targeted users will be translated to corresponding names.

    .EXAMPLE
    $win32AppData = Get-IntuneWin32App

    $myApp = ($win32AppData | ? DisplayName -eq 'MyApp')

    "Output complete object"
    $myApp

    "Detection script content for application 'MyApp'"
    $myApp.additionalData.DetectionRule.DetectionText.ScriptBody

    "Requirement script content for application 'MyApp'"
    $myApp.additionalData.ExtendedRequirementRules.RequirementText.ScriptBody

    "Install command for application 'MyApp'"
    $myApp.additionalData.InstallCommandLine

    Show various interesting information for 'MyApp' application deployment.
    #>

    [CmdletBinding()]
    param (
        [string] $computerName,

        [switch] $getDataFromIntune,

        [System.Management.Automation.PSCredential] $credential,

        [string] $tenantId,

        [switch] $excludeSystemApp
    )

    #region helper function
    # function translates user Azure ID or SID to its display name
    function _getTargetName {
        param ([string] $id)

        Write-Verbose "Translating account $id to its name (SID)"

        if (!$id) {
            Write-Verbose "Id was null"
            return
        } elseif ($id -eq 'device') {
            # xml nodes contains 'device' instead of 'Device'
            return 'Device'
        }

        $errPref = $ErrorActionPreference
        $ErrorActionPreference = "Stop"
        try {
            if ($id -eq '00000000-0000-0000-0000-000000000000' -or $id -eq 'S-0-0-00-0000000000-0000000000-000000000-000') {
                Write-Verbose "`t- Id belongs to device"
                return 'Device'
            } elseif ($id -match "^S-\d+-\d+-\d+") {
                # it is local account
                Write-Verbose "`t- Id is SID, trying to translate to local account name"
                return ((New-Object System.Security.Principal.SecurityIdentifier($id)).Translate([System.Security.Principal.NTAccount])).Value
            } else {
                # it is AzureAD account
                Write-Verbose "`t- Id belongs to AAD account"
                if ($getDataFromIntune) {
                    Write-Verbose "`t- Translating ID using Intune data"
                    return ($intuneUser | ? id -EQ $id).userPrincipalName
                } else {
                    Write-Verbose "`t- Getting SID that belongs to AAD ID, by searching Intune logs"
                    $userSID = Get-UserSIDForUserAzureID $id
                    if ($userSID) {
                        _getTargetName $userSID
                    } else {
                        return $id
                    }
                }
            }
        } catch {
            Write-Warning "Unable to translate $id to account name ($_)"
            $ErrorActionPreference = $errPref
            return $id
        }
    }

    # function for translating error codes to error messages
    function Get-Win32AppErrMsg {
        param (
            [string] $errorCode
        )

        if (!$errorCode -or $errorCode -eq 0) { return }

        # https://docs.microsoft.com/en-us/troubleshoot/mem/intune/app-install-error-codes
        $errorCodeList = @{
            "-942583883"  = "The app failed to install."
            "-942583878"  = "The app installation was canceled because the installation (APK) file was deleted after download, but before installation."
            "-942583877"  = "The app installation was canceled because the process was restarted during installation."
            "-2016345060" = "The application was not detected after installation completed successfully."
            "-942583886"  = "The download failed because of an unknown error."
            "-942583688"  = "The download failed because of an unknown error. The policy will be retried the next time the device syncs."
            "-942583887"  = "The end user canceled the app installation."
            "-942583787"  = "The file download process was unexpectedly stopped."
            "-942583684"  = "The file download service was unexpectedly stopped. The policy will be retried the next time the device syncs."
            "-942583880"  = "The app failed to uninstall."
            "-942583881"  = "The app installation APK file used for the upgrade does not match the signature for the current app on the device."
            "-942583879"  = "The end user canceled the app installation."
            "-942583876"  = "Uninstall of the app was canceled because the process was restarted during installation."
            "-942583882"  = "The app installation APK file cannot be installed because it was not signed."
            "-2016335610" = "Apple MDM Agent error: App installation command failed with no error reason specified. Retry app installation."
            "-2016333508" = "Network connection on the client was lost or interrupted. Later attempts should succeed in a better network environment."
            "-2016333507" = "Could not retrieve license for the app with iTunes Store ID"
            "-2016341112" = "iOS/iPadOS device is currently busy."
            "-2016330908" = "The app installation has failed."
            "-2016330906" = "The app is managed, but has expired or been removed by the user."
            "-2016330912" = "The app is scheduled for installation, but needs a redemption code to complete the transaction."
            "-2016330883" = "Unknown error."
            "-2016330910" = "The user rejected the offer to install the app."
            "-2016330909" = "The user rejected the offer to update the app."
            "-2016345112" = "Unknown error"
            "-2016330861" = "Can only install VPP apps on Shared iPad."
            "-2016330860" = "Can't install apps when App Store is disabled."
            "-2016330859" = "Can't find VPP license for app."
            "-2016330858" = "Can't install system apps with your MDM provider."
            "-2016330857" = "Can't install apps when device is in Lost Mode."
            "-2016330856" = "Can't install apps when device is in kiosk mode."
            "-2016330852" = "Can't install 32-bit apps on this device."
            "-2016330855" = "User must sign in to the App Store."
            "-2016330854" = "Unknown problem. Please try again."
            "-2016330853" = "The app installation failed. Intune will try again the next time the device syncs."
            "-2016330882" = "License Assignment failed with Apple error 'No VPP licenses remaining'"
            "-2016330898" = "App Install Failure 12024: Unknown cause."
            "-2016330881" = "Needed app configuration policy not present, ensure policy is targeted to same groups."
            "-2016330903" = "Device VPP licensing is only applicable for iOS/iPadOS 9.0+ devices."
            "-2016330865" = "The application is installed on the device but is unmanaged."
            "-2016330904" = "User declined app management"
            "-2016335971" = "Unknown error."
            "-2016330851" = "The latest version of the app failed to update from an earlier version."
            "-2016330897" = "Your connection to Intune timed out."
            "-2016330896" = "You lost connection to the Internet."
            "-2016330894" = "You lost connection to the Internet."
            "-2016330893" = "You lost connection to the Internet."
            "-2016330889" = "The secure connection failed."
            "-2016330880" = "CannotConnectToITunesStoreError"
            "-2016330849" = "The VPP App has an update available"
            "2016330850"  = "Can't enforce app uninstall setting. Retry installing the app."
            "-2147009281" = "(client error)"
            "-2133909476" = "(client error)"
            "-2147009296" = "The package is unsigned. The publisher name does not match the signing certificate subject. Check the AppxPackagingOM event log for information. For more information, see Troubleshooting packaging, deployment, and query of Windows Store apps."
            "-2147009285" = "Increment the version number of the app, then rebuild and re-sign the package. Remove the old package for every user on the system before you install the new package. For more information, see Troubleshooting packaging, deployment, and query of Windows Store apps."
        }

        $errorMessage = $errorCodeList.$errorCode
        if (!$errorMessage) {
            $errorMessage = "*unable to translate $errorCode*"
        }

        return $errorMessage
    }

    # create helper functions text definition for usage in remote sessions
    $allFunctionDefs = "function _getTargetName { ${function:_getTargetName} }; function Get-UserSIDForUserAzureID { ${function:Get-UserSIDForUserAzureID} }; function Get-Win32AppErrMsg { ${function:Get-Win32AppErrMsg} }; function Get-IntuneLogWin32AppData { ${function:Get-IntuneLogWin32AppData} }; function Get-IntuneLogWin32AppReportingResultData { ${function:Get-IntuneLogWin32AppReportingResultData} }"
    #endregion helper function

    #region prepare
    if ($getDataFromIntune) {
        if (!(Get-Module 'Microsoft.Graph.Intune') -and !(Get-Module 'Microsoft.Graph.Intune' -ListAvailable)) {
            throw "Module 'Microsoft.Graph.Intune' is required. To install it call: Install-Module 'Microsoft.Graph.Intune' -Scope CurrentUser"
        }

        if ($tenantId) {
            # app logon
            if (!$credential) {
                $credential = Get-Credential -Message "Enter AppID and AppSecret for connecting to Intune tenant" -ErrorAction Stop
            }
            Update-MSGraphEnvironment -AppId $credential.UserName -Quiet
            Update-MSGraphEnvironment -AuthUrl "https://login.windows.net/$tenantId" -Quiet
            $null = Connect-MSGraph -ClientSecret $credential.GetNetworkCredential().Password -ErrorAction Stop
        } else {
            # user logon
            if ($credential) {
                $null = Connect-MSGraph -Credential $credential -ErrorAction Stop
                # $header = New-GraphAPIAuthHeader -credential $credential -ErrorAction Stop
            } else {
                $null = Connect-MSGraph -ErrorAction Stop
                # $header = New-GraphAPIAuthHeader -ErrorAction Stop
            }
        }

        Write-Verbose "Getting Intune data"
        # filtering by ID is as slow as getting all data
        # Invoke-MSGraphRequest -Url 'https://graph.microsoft.com/beta/deviceAppManagement/mobileApps?$filter=(id%20eq%20%2756695a77-925a-4df0-be79-24ed039afa86%27)'
        $intuneApp = Invoke-MSGraphRequest -Url "https://graph.microsoft.com/beta/deviceAppManagement/mobileApps?select=id,displayname" | Get-MSGraphAllPages
        $intuneUser = Invoke-MSGraphRequest -Url 'https://graph.microsoft.com/beta/users?select=id,userPrincipalName' | Get-MSGraphAllPages
    }

    if ($computerName) {
        $session = New-PSSession -ComputerName $computerName -ErrorAction Stop
    }
    #endregion prepare

    #region get data
    $scriptBlock = {
        param($verbosePref, $excludeSystemApp, $getDataFromIntune, $intuneApp, $intuneUser, $allFunctionDefs)

        # inherit verbose settings from host session
        $VerbosePreference = $verbosePref

        # recreate functions from their text definitions
        . ([ScriptBlock]::Create($allFunctionDefs))

        # get additional data from Intune logs
        Write-Verbose "Getting additional Win32App data from client Intune logs"
        $logData = Get-IntuneLogWin32AppData
        $logReportingData = Get-IntuneLogWin32AppReportingResultData # to be able to translate IDs of apps which don't meet requirements

        $processedWin32AppId = @()

        foreach ($scope in (Get-ChildItem "HKLM:\SOFTWARE\Microsoft\IntuneManagementExtension\Win32Apps" -ErrorAction SilentlyContinue)) {
            $userAzureObjectID = Split-Path $scope.Name -Leaf

            if ($excludeSystemApp -and $userAzureObjectID -eq "00000000-0000-0000-0000-000000000000") {
                Write-Verbose "Skipping system deployments"
                continue
            }

            $userWin32AppRoot = $scope.PSPath
            $win32AppIDList = Get-ChildItem $userWin32AppRoot | select -ExpandProperty PSChildName | % { $_ -replace "_\d+$" } | select -Unique | ? { $_ -ne 'GRS' }

            $win32AppIDList | % {
                $win32AppID = $_

                Write-Verbose "Processing App ID $win32AppID"

                $processedWin32AppId += $win32AppID

                #region get Win32App data
                $newestWin32AppRecord = Get-ChildItem $userWin32AppRoot | ? PSChildName -Match ([regex]::escape($win32AppID)) | Sort-Object -Descending -Property PSChildName | select -First 1

                try {
                    $lastUpdatedTimeUtc = $null
                    $lastUpdatedTimeUtc = Get-ItemPropertyValue $newestWin32AppRecord.PSPath -Name LastUpdatedTimeUtc -ErrorAction Stop
                } catch {
                    Write-Verbose "`tUnable to get LastUpdatedTimeUtc data"
                }

                try {
                    $deploymentType = $null
                    $deploymentType = Get-ItemPropertyValue $newestWin32AppRecord.PSPath -Name Intent -ErrorAction Stop
                } catch {
                    Write-Verbose "`tUnable to get Intent data"
                }
                if ($deploymentType) {
                    switch ($deploymentType) {
                        1 { $deploymentType = "Available" }
                        3 { $deploymentType = "Required" }
                        4 { $deploymentType = "Uninstall" }
                        default { Write-Error "Undefined deployment type $deploymentType" }
                    }
                }

                try {
                    $complianceStateMessage = $null
                    $complianceStateMessage = Get-ItemPropertyValue "$($newestWin32AppRecord.PSPath)\ComplianceStateMessage" -Name ComplianceStateMessage -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
                } catch {
                    Write-Verbose "`tUnable to get Compliance State Message data"
                }

                $complianceState = $complianceStateMessage.ComplianceState
                if ($complianceState) {
                    switch ($complianceState) {
                        0 { $complianceState = "Unknown" }
                        1 { $complianceState = "Compliant" }
                        2 { $complianceState = "Not compliant" }
                        3 { $complianceState = "Conflict (Not applicable for app deployment)" }
                        4 { $complianceState = "Error" }
                        default { Write-Error "Undefined compliance status $complianceState" }
                    }
                }

                $desiredState = $complianceStateMessage.DesiredState
                if ($desiredState) {
                    switch ($desiredState) {
                        0	{ $desiredState = "None" }
                        1	{ $desiredState = "NotPresent" }
                        2	{ $desiredState = "Present" }
                        3	{ $desiredState = "Unknown" }
                        4	{ $desiredState = "Available" }
                        default { Write-Error "Undefined desired status $desiredState" }
                    }
                }

                try {
                    $enforcementStateMessage = $null
                    $enforcementStateMessage = Get-ItemPropertyValue "$($newestWin32AppRecord.PSPath)\EnforcementStateMessage" -Name EnforcementStateMessage -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
                } catch {
                    Write-Verbose "`tUnable to get Enforcement State Message data"
                }

                $enforcementState = $enforcementStateMessage.EnforcementState
                if ($enforcementState) {
                    switch ($enforcementState) {
                        1000	{ $enforcementState = "Succeeded" }
                        1003	{ $enforcementState = "Received command to install" }
                        2000	{ $enforcementState = "Enforcement action is in progress" }
                        2007	{ $enforcementState = "App enforcement will be attempted once all dependent apps have been installed" }
                        2008	{ $enforcementState = "App has been installed but is not usable until device has rebooted" }
                        2009	{ $enforcementState = "App has been downloaded but no installation has been attempted" }
                        3000	{ $enforcementState = "Enforcement action aborted due to requirements not being met" }
                        4000	{ $enforcementState = "Enforcement action could not be completed due to unknown reason" }
                        5000	{ $enforcementState = "Enforcement action failed due to error.  Error code needs to be checked to determine detailed status" }
                        5003	{ $enforcementState = "Client was unable to download app content." }
                        5999	{ $enforcementState = "Enforcement action failed due to error, will retry immediately." }
                        6000	{ $enforcementState = "Enforcement action has not been attempted.  No reason given." }
                        6001	{ $enforcementState = "App install is blocked because one or more of the app's dependencies failed to install." }
                        6002	{ $enforcementState = "App install is blocked on the machine due to a pending hard reboot." }
                        6003	{ $enforcementState = "App install is blocked because one or more of the app's dependencies have requirements which are not met." }
                        6004	{ $enforcementState = "App is a dependency of another application and is configured to not automatically install." }
                        6005	{ $enforcementState = "App install is blocked because one or more of the app's dependencies are configured to not automatically install." }
                        default { Write-Error "Undefined enforcement status $enforcementState" }
                    }
                }

                $lastError = $complianceStateMessage.ErrorCode
                if (!$lastError) { $lastError = 0 } # because of HTML conditional formatting ($null means that cell will have red background)
                #endregion get Win32App data

                #TODO I don't differentiate between user and device scope, but it seems log contains just user data?
                $appLogData = $logData | ? Id -EQ $win32AppID
                $appLogReportingData = $logReportingData | ? Id -EQ $win32AppID

                #region output the results
                # prepare final object properties
                $property = [ordered]@{
                    "Name"               = ''
                    "Id"                 = $win32AppID
                    "Scope"              = _getTargetName $userAzureObjectID
                    "LastUpdatedTimeUtc" = $lastUpdatedTimeUtc
                    "ComplianceState"    = $complianceState
                    "EnforcementState"   = $enforcementState
                    "EnforcementError"   = Get-Win32AppErrMsg $enforcementStateMessage.ErrorCode
                    "LastError"          = $lastError
                    "ProductVersion"     = $complianceStateMessage.ProductVersion
                    "DesiredState"       = $desiredState
                    # "EnforcementErrorCode" = $enforcementStateMessage.ErrorCode
                    "DeploymentType"     = $deploymentType
                    "ScopeId"            = $userAzureObjectID
                }
                if ($getDataFromIntune) {
                    $property.Name = ($intuneApp | ? id -EQ $win32AppID).DisplayName
                } else {
                    $property.Name = if ($appLogData.Name) { $appLogData.Name } else { $appLogReportingData.Name }
                }

                # add additional properties when possible
                if ($appLogData) {
                    Write-Verbose "Enrich app object data with information found in Intune log files"

                    $appLogData = $appLogData | select * -ExcludeProperty Id, Name

                    $newProperty = Get-Member -InputObject $appLogData -MemberType NoteProperty
                    $newProperty | % {
                        $propertyName = $_.Name
                        $propertyValue = $appLogData.$propertyName

                        $property.$propertyName = $propertyValue
                    }
                } else {
                    Write-Verbose "For app $win32AppID there are no extra information in Intune log files"
                }

                New-Object -TypeName PSObject -Property $property
                #endregion output the results
            }
        }

        #region warn about deployed but skip-installation apps
        if ($logReportingData) {
            $notProcessedApp = $logReportingData | ? { $_.Id -notin $processedWin32AppId }
            if ($notProcessedApp) {
                Write-Warning "Following apps didn't start installation: $($notProcessedApp.Name -join ', ')`n`nReason can be recent forced redeploy of such app or that deployment requirements are not met. For more information run 'Get-IntuneLogWin32AppReportingResultData'"
            }
        }
        #endregion warn about deployed but skip-installation apps
    }

    $param = @{
        scriptBlock  = $scriptBlock
        argumentList = ($VerbosePreference, $excludeSystemApp, $getDataFromIntune, $intuneApp, $intuneUser, $allFunctionDefs)
    }
    if ($computerName) {
        $param.session = $session
    }

    $win32App = Invoke-Command @param | select -Property * -ExcludeProperty PSComputerName, RunspaceId, PSShowComputerName
    #endregion get data

    #region let user redeploy chosen app
    if ($win32App) {
        $win32App
    } else {
        Write-Warning "No deployed Win32App detected"
    }
    #endregion let user redeploy chosen app

    if ($computerName) {
        Remove-PSSession $session
    }
}

function ConvertFrom-MDMDiagReportXML {
    <#
    .SYNOPSIS
    Function for converting Intune XML report generated by MdmDiagnosticsTool.exe to a PowerShell object.

    .DESCRIPTION
    Function for converting Intune XML report generated by MdmDiagnosticsTool.exe to a PowerShell object.
    There is also option to generate HTML report instead.

    .PARAMETER computerName
    (optional) Computer name from which you want to get data from.

    .PARAMETER MDMDiagReport
    Path to MDMDiagReport.xml.

    If not specified, new report will be generated and used.

    .PARAMETER asHTML
    Switch for outputting results as a HTML page instead of PowerShell object.
    PSWriteHtml module is required!

    .PARAMETER HTMLReportPath
    Path to html file where HTML report should be stored.

    Default is '<yourUserProfile>\IntuneReport.html'.

    .PARAMETER showEnrollmentIDs
    Switch for adding EnrollmentID property i.e. property containing Enrollment ID of given policy.
    From my point of view its useless :).

    .PARAMETER showURLs
    Switch for adding PolicyURL and PolicySettingsURL properties i.e. properties containing URL with Microsoft documentation for given CSP.

    Make running the function slower! Because I test each URL and shows just existing ones.

    .PARAMETER showConnectionData
    Switch for showing Intune connection data.
    Beware that this will add new object type to the output (but it doesn't matter if you use asHTML switch).

    .EXAMPLE
    $intuneReport = ConvertFrom-MDMDiagReportXML
    $intuneReport | Out-GridView

    Generates new Intune report, converts it into PowerShell object and output it using Out-GridView.

    .EXAMPLE
    ConvertFrom-MDMDiagReportXML -asHTML -showURLs

    Generates new Intune report (policies documentation URL included), converts it into HTML web page and opens it.
    #>

    [CmdletBinding()]
    param (
        [string] $computerName,

        [ValidateScript( {
                if ($_ -match "\.xml$") {
                    $true
                } else {
                    throw "$_ is not a valid path to MDM xml report"
                }
            })]
        [string] $MDMDiagReport,

        [switch] $asHTML,

        [ValidateScript( {
                if ($_ -match "\.html$") {
                    $true
                } else {
                    throw "$_ is not a valid path to html file. Enter something like 'C:\destination\intune.html'"
                }
            })]
        [string] $HTMLReportPath = (Join-Path $env:USERPROFILE "IntuneReport.html"),

        [switch] $showEnrollmentIDs,

        [switch] $showURLs,

        [switch] $showConnectionData
    )

    if (!(Get-Module 'CommonStuff') -and (!(Get-Module 'CommonStuff' -ListAvailable))) {
        throw "Module CommonStuff is missing. To get it use command: Install-Module CommonStuff -Scope CurrentUser"
    }

    Import-Module CommonStuff -Force # to override ConvertFrom-XML function in case user has module PoshFunctions 

    if ($asHTML) {
        # array of results that will be in the end transformed into HTML report
        $results = @()

        if (!(Get-Module 'PSWriteHtml') -and (!(Get-Module 'PSWriteHtml' -ListAvailable))) {
            throw "Module PSWriteHtml is missing. To get it use command: Install-Module PSWriteHtml -Scope CurrentUser"
        }

        # create parent directory if not exists
        [Void][System.IO.Directory]::CreateDirectory((Split-Path $HTMLReportPath -Parent))
    }

    if ($computerName) {
        $session = New-PSSession -ComputerName $computerName -ErrorAction Stop
    }

    if (!$MDMDiagReport) {
        ++$reportNotSpecified
        $MDMDiagReport = "$env:PUBLIC\Documents\MDMDiagnostics\MDMDiagReport.xml"
    }

    $MDMDiagReportFolder = Split-Path $MDMDiagReport -Parent

    # generate XML report if necessary
    if ($reportNotSpecified) {
        if ($computerName) {
            # XML report is on remote computer, transform to UNC path
            $MDMDiagReport = "\\$computerName\$($MDMDiagReport -replace ":", "$")"
            Write-Verbose "Generating '$MDMDiagReport'..."

            try {
                Invoke-Command -Session $session {
                    param ($MDMDiagReportFolder)

                    Start-Process MdmDiagnosticsTool.exe -Wait -ArgumentList "-out `"$MDMDiagReportFolder`"" -NoNewWindow -ErrorAction Stop
                } -ArgumentList $MDMDiagReportFolder -ErrorAction Stop
            } catch {
                throw "Unable to generate XML report`nError: $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
            }
        } else {
            Write-Verbose "Generating '$MDMDiagReport'..."
            Start-Process MdmDiagnosticsTool.exe -Wait -ArgumentList "-out `"$MDMDiagReportFolder`"" -NoNewWindow
        }
    }
    if (!(Test-Path $MDMDiagReport -PathType Leaf)) {
        Write-Verbose "'$MDMDiagReport' doesn't exist, generating..."
        Start-Process MdmDiagnosticsTool.exe -Wait -ArgumentList "-out `"$MDMDiagReportFolder`"" -NoNewWindow
    }

    Write-Verbose "Converting '$MDMDiagReport' to XML object"
    [xml]$xml = Get-Content $MDMDiagReport -Raw -ErrorAction Stop

    #region get enrollmentID
    Write-Verbose "Getting EnrollmentID"

    $scriptBlock = {
        Get-ScheduledTask -TaskName "*pushlaunch*" -TaskPath "\Microsoft\Windows\EnterpriseMgmt\*" | Select-Object -ExpandProperty TaskPath | Split-Path -Leaf
    }
    $param = @{
        scriptBlock = $scriptBlock
    }
    if ($computerName) {
        $param.session = $session
    }

    $userEnrollmentID = Invoke-Command @param

    Write-Verbose "Your EnrollmentID is $userEnrollmentID"
    #endregion get enrollmentID

    #region connection data
    if ($showConnectionData) {
        Write-Verbose "Getting connection data"
        $connectionInfo = $xml.MDMEnterpriseDiagnosticsReport.DeviceManagementAccount.Enrollment | ? EnrollmentId -EQ $userEnrollmentID

        if ($connectionInfo) {
            [PSCustomObject]@{
                "EnrollmentId"          = $connectionInfo.EnrollmentId
                "MDMServerName"         = $connectionInfo.ProtectedInformation.MDMServerName
                "LastSuccessConnection" = [DateTime]::ParseExact(($connectionInfo.ProtectedInformation.ConnectionInformation.ServerLastSuccessTime -replace "Z$"), 'yyyyMMddTHHmmss', $null)
                "LastFailureConnection" = [DateTime]::ParseExact(($connectionInfo.ProtectedInformation.ConnectionInformation.ServerLastFailureTime -replace "Z$"), 'yyyyMMddTHHmmss', $null)
            }
        } else {
            Write-Verbose "Unable to get connection data from $MDMDiagReport"
        }
    }
    #endregion connection data

    #region helper functions
    function _getTargetName {
        param ([string] $id)

        Write-Verbose "Translating $id"

        if (!$id) {
            Write-Verbose "id was null"
            return
        } elseif ($id -eq 'device') {
            # xml nodes contains 'device' instead of 'Device'
            return 'Device'
        }

        $errPref = $ErrorActionPreference
        $ErrorActionPreference = "Stop"
        try {
            if ($id -eq '00000000-0000-0000-0000-000000000000' -or $id -eq 'S-0-0-00-0000000000-0000000000-000000000-000') {
                return 'Device'
            } elseif ($id -match "^S-1-5-21") {
                # it is local account
                if ($computerName) {
                    Invoke-Command -Session $session {
                        param ($id)

                        $ErrorActionPreference = "Stop"
                        try {
                            return ((New-Object System.Security.Principal.SecurityIdentifier($id)).Translate([System.Security.Principal.NTAccount])).Value
                        } catch {
                            throw 1
                        }
                    } -ArgumentList $id
                } else {
                    return ((New-Object System.Security.Principal.SecurityIdentifier($id)).Translate([System.Security.Principal.NTAccount])).Value
                }
            } else {
                # it is AzureAD account
                if ($getDataFromIntune) {
                    return (Invoke-MSGraphRequest -Url "https://graph.microsoft.com/beta/users/$id").userPrincipalName
                } else {
                    # unable to translate ID to name because there is no connection to the Intune Graph API
                    return $id
                }
            }
        } catch {
            Write-Verbose "Unable to translate $id account name"
            $ErrorActionPreference = $errPref
            return $id
        }
    }

    function Test-URLStatus {
        param ($URL)

        try {
            $response = [System.Net.WebRequest]::Create($URL).GetResponse()
            $status = $response.StatusCode
            $response.Close()
            if ($status -eq 'OK') { return $true } else { return $false }
        } catch {
            return $false
        }
    }

    function _translateStatus {
        param ([int] $statusCode)

        $statusMessage = ""

        switch ($statusCode) {
            '10' { $statusMessage = "Initialized" }
            '20' { $statusMessage = "Download In Progress" }
            '25' { $statusMessage = "Pending Download Retry" }
            '30' { $statusMessage = "Download Failed" }
            '40' { $statusMessage = "Download Completed" }
            '48' { $statusMessage = "Pending User Session" }
            '50' { $statusMessage = "Enforcement In Progress" }
            '55' { $statusMessage = "Pending Enforcement Retry" }
            '60' { $statusMessage = "Enforcement Failed" }
            '70' { $statusMessage = "Enforcement Completed" }
            default { $statusMessage = $statusCode }
        }

        return $statusMessage
    }
    #endregion helper functions

    if ($showURLs) {
        $clientIsOnline = Test-URLStatus 'https://google.com'
    }

    #region enrollments
    Write-Verbose "Getting Enrollments (MDMEnterpriseDiagnosticsReport.Resources.Enrollment)"
    $enrollment = $xml.MDMEnterpriseDiagnosticsReport.Resources.Enrollment | % { ConvertFrom-XML $_ }

    if ($enrollment) {
        Write-Verbose "Processing Enrollments"

        $enrollment | % {
            <#
            <Resources>
                <Enrollment>
                    <EnrollmentID>5AFCD0A0-321F-4635-B3EB-2EBD28A0FD9A</EnrollmentID>
                    <Scope>
                    <ResourceTarget>device</ResourceTarget>
                    <Resources>
                        <Type>default</Type>
                        <ResourceName>./device/Vendor/MSFT/DeviceManageability/Provider/WMI_Bridge_Server</ResourceName>
                        <ResourceName>2</ResourceName>
                        <ResourceName>./device/Vendor/MSFT/VPNv2/K_AlwaysOn_VPN</ResourceName>
                    </Resources>
                    </Scope>
            #>
            $policy = $_
            $enrollmentId = $_.EnrollmentId

            $policy.Scope | % {
                $scope = _getTargetName $_.ResourceTarget

                foreach ($policyAreaName in $_.Resources.ResourceName) {
                    # some policies have just number instead of any name..I don't know what it means so I ignore them
                    if ($policyAreaName -match "^\d+$") {
                        continue
                    }
                    # get rid of MSI installations (I have them with details in separate section)
                    if ($policyAreaName -match "/Vendor/MSFT/EnterpriseDesktopAppManagement/MSI") {
                        continue
                    }
                    # get rid of useless data
                    if ($policyAreaName -match "device/Vendor/MSFT/DeviceManageability/Provider/WMI_Bridge_Server") {
                        continue
                    }

                    Write-Verbose "`nEnrollment '$enrollmentId' applied to '$scope' configures resource '$policyAreaName'"

                    #region get policy settings details
                    $settingDetails = $null
                    #TODO zjistit co presne to nastavuje
                    # - policymanager.configsource.policyscope.Area

                    <#
                    <ErrorLog>
                        <Component>ConfigManager</Component>
                        <SubComponent>
                            <Name>BitLocker</Name>
                            <Error>-2147024463</Error>
                            <Metadata1>CmdType_Set</Metadata1>
                            <Metadata2>./Device/Vendor/MSFT/BitLocker/RequireDeviceEncryption</Metadata2>
                            <Time>2021-09-23 07:07:05.463</Time>
                        </SubComponent>
                    #>
                    Write-Verbose "Getting Errors (MDMEnterpriseDiagnosticsReport.Diagnostics.ErrorLog)"
                    # match operator used for metadata2 because for example WIFI networks are saved there as ./Vendor/MSFT/WiFi/Profile/<wifiname> instead of ./Vendor/MSFT/WiFi/Profile
                    foreach ($errorRecord in $xml.MDMEnterpriseDiagnosticsReport.Diagnostics.ErrorLog) {
                        $component = $errorRecord.component
                        $errorRecord.subComponent | % {
                            $subComponent = $_

                            if ($subComponent.name -eq $policyAreaName -or $subComponent.Metadata2 -match [regex]::Escape($policyAreaName)) {
                                $settingDetails = $subComponent | Select-Object @{n = 'Component'; e = { $component } }, @{n = 'SubComponent'; e = { $subComponent.Name } }, @{n = 'SettingName'; e = { $policyAreaName } }, Error, @{n = 'Time'; e = { Get-Date $subComponent.Time } }
                                break
                            }
                        }
                    }

                    if (!$settingDetails) {
                        # try more "relaxed" search
                        if ($policyAreaName -match "/") {
                            # it is just common setting, try to find it using last part of the policy name
                            $policyAreaNameID = ($policyAreaName -split "/")[-1]
                            Write-Verbose "try to find just ID part ($policyAreaNameID) of the policy name in MDMEnterpriseDiagnosticsReport.Diagnostics.ErrorLog"
                            # I don't search substring of policy name in Metadata2 because there can be multiple similar policies (./user/Vendor/MSFT/VPNv2/VPN_Backup vs ./device/Vendor/MSFT/VPNv2/VPN_Backup)
                            foreach ($errorRecord in $xml.MDMEnterpriseDiagnosticsReport.Diagnostics.ErrorLog) {
                                $component = $errorRecord.component
                                $errorRecord.subComponent | % {
                                    $subComponent = $_

                                    if ($subComponent.name -eq $policyAreaNameID) {
                                        $settingDetails = $subComponent | Select-Object @{n = 'Component'; e = { $component } }, @{n = 'SubComponent'; e = { $subComponent.Name } }, @{n = 'SettingName'; e = { $policyAreaName } }, Error, @{n = 'Time'; e = { Get-Date $subComponent.Time } }
                                        break
                                    }
                                }
                            }
                        } else {
                            Write-Verbose "'$policyAreaName' doesn't contains '/'"
                        }

                        if (!$settingDetails) {
                            Write-Verbose "No additional data was found for '$policyAreaName' (it means it was successfully applied)"
                        }
                    }
                    #endregion get policy settings details

                    # get CSP policy URL if available
                    if ($showURLs) {
                        if ($policyAreaName -match "/") {
                            $pName = ($policyAreaName -split "/")[-2]
                        } else {
                            $pName = $policyAreaName
                        }
                        $policyURL = "https://docs.microsoft.com/en-us/windows/client-management/mdm/$pName-csp"
                        # check that URL exists
                        if ($clientIsOnline) {
                            if (!(Test-URLStatus $policyURL)) {
                                # URL doesn't exist
                                if ($policyAreaName -match "/") {
                                    # sometimes name of the CSP is not second from the end but third
                                    $pName = ($policyAreaName -split "/")[-3]
                                    $policyURL = "https://docs.microsoft.com/en-us/windows/client-management/mdm/$pName-csp"
                                    if (!(Test-URLStatus $policyURL)) {
                                        $policyURL = $null
                                    }
                                } else {
                                    $policyURL = "https://docs.microsoft.com/en-us/windows/client-management/mdm/policy-csp-$pName"
                                    if (!(Test-URLStatus $policyURL)) {
                                        $policyURL = $null
                                    }
                                }
                            }
                        }
                    }

                    #region return retrieved data
                    $property = [ordered] @{
                        Scope          = $scope
                        PolicyName     = $policyAreaName
                        SettingName    = $policyAreaName
                        SettingDetails = $settingDetails
                    }
                    if ($showEnrollmentIDs) { $property.EnrollmentId = $enrollmentId }
                    if ($showURLs) { $property.PolicyURL = $policyURL }
                    $result = New-Object -TypeName PSObject -Property $property

                    if ($asHTML) {
                        $results += $result
                    } else {
                        $result
                    }
                    #endregion return retrieved data
                }
            }
        }
    }
    #endregion enrollments

    #region policies
    Write-Verbose "Getting Policies (MDMEnterpriseDiagnosticsReport.PolicyManager.ConfigSource)"
    $policyManager = $xml.MDMEnterpriseDiagnosticsReport.PolicyManager.ConfigSource | % { ConvertFrom-XML $_ }
    # filter out useless knobs
    $policyManager = $policyManager | ? { $_.policyScope.Area.PolicyAreaName -ne 'knobs' }

    if ($policyManager) {
        Write-Verbose "Processing Policies"

        # get policies metadata
        Write-Verbose "Getting Policies Area metadata (MDMEnterpriseDiagnosticsReport.PolicyManager.AreaMetadata)"
        $policyAreaNameMetadata = $xml.MDMEnterpriseDiagnosticsReport.PolicyManager.AreaMetadata
        # get admx policies metadata
        # there are duplicities, so pick just last one
        Write-Verbose "Getting Policies ADMX metadata (MDMEnterpriseDiagnosticsReport.PolicyManager.IngestedAdmxPolicyMetadata)"
        $admxPolicyAreaNameMetadata = $xml.MDMEnterpriseDiagnosticsReport.PolicyManager.IngestedAdmxPolicyMetadata | ? { $_ } | % { ConvertFrom-XML $_ }

        Write-Verbose "Getting Policies winning provider (MDMEnterpriseDiagnosticsReport.PolicyManager.CurrentPolicies.CurrentPolicyValues)"
        $winningProviderPolicyAreaNameMetadata = $xml.MDMEnterpriseDiagnosticsReport.PolicyManager.CurrentPolicies.CurrentPolicyValues | % {
            $_.psobject.properties | ? { $_.Name -Match "_WinningProvider$" } | Select-Object Name, Value
        }

        $policyManager | % {
            $policy = $_
            $enrollmentId = $_.EnrollmentId

            $policy.policyScope | % {
                $scope = _getTargetName $_.PolicyScope
                $_.Area | % {
                    <#
                    <ConfigSource>
                        <EnrollmentId>AB068787-67D2-4F7C-AA87-A9127A87411F</EnrollmentId>
                        <PolicyScope>
                            <PolicyScope>Device</PolicyScope>
                            <Area>
                                <PolicyAreaName>BitLocker</PolicyAreaName>
                                <AllowWarningForOtherDiskEncryption>0</AllowWarningForOtherDiskEncryption>
                                <AllowWarningForOtherDiskEncryption_LastWrite>1</AllowWarningForOtherDiskEncryption_LastWrite>
                                <RequireDeviceEncryption>1</RequireDeviceEncryption>
                    #>

                    $policyAreaName = $_.PolicyAreaName
                    Write-Verbose "`nEnrollment '$enrollmentId' applied to '$scope' configures area '$policyAreaName'"
                    $policyAreaSetting = $_ | Select-Object -Property * -ExcludeProperty 'PolicyAreaName', "*_LastWrite"
                    if ($policyAreaSetting) {
                        $policyAreaSettingName = $policyAreaSetting | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty name
                    }
                    if ($policyAreaSettingName.count -eq 1 -and $policyAreaSettingName -eq "*") {
                        # bug? when there is just PolicyAreaName and none other object then probably because of exclude $policyAreaSettingName instead of be null returns one empty object '*'
                        $policyAreaSettingName = $null
                        $policyAreaSetting = $null
                    }

                    #region get policy settings details
                    $settingDetails = @()

                    if ($policyAreaSetting) {
                        Write-Verbose "`tIt configures these settings:"

                        # $policyAreaSetting is object, so I have to iterate through its properties
                        foreach ($setting in $policyAreaSetting.PSObject.Properties) {
                            $settingName = $setting.Name
                            $settingValue = $setting.Value

                            # PolicyAreaName property was already picked up so now I will ignore it
                            if ($settingName -eq "PolicyAreaName") { continue }

                            Write-Verbose "`t`t- $settingName ($settingValue)"

                            # makes test of url slow
                            # if ($clientIsOnline) {
                            #     if (!(Test-URLStatus $policyDetailsURL)) {
                            #         # URL doesn't exist
                            #         $policyDetailsURL = $null
                            #     }
                            # }

                            if ($showURLs) {
                                if ($policyAreaName -match "~Policy~OneDriveNGSC") {
                                    # doesn't have policy csp url
                                    $policyDetailsURL = $null
                                } else {
                                    $policyDetailsURL = "https://docs.microsoft.com/en-us/windows/client-management/mdm/policy-csp-$policyAreaName#$(($policyAreaName).tolower())-$(($settingName).tolower())"
                                }
                            }

                            # define base object
                            $property = [ordered]@{
                                "SettingName"     = $settingName
                                "Value"           = $settingValue
                                "DefaultValue"    = $null
                                "PolicyType"      = '*unknown*'
                                "RegKey"          = '*unknown*'
                                "RegValueName"    = '*unknown*'
                                "SourceAdmxFile"  = $null
                                "WinningProvider" = $null
                            }
                            if ($showURLs) { $property.PolicyDetailsURL = $policyDetailsURL }

                            $additionalData = $policyAreaNameMetadata | ? PolicyAreaName -EQ $policyAreaName | Select-Object -ExpandProperty PolicyMetadata | ? PolicyName -EQ $settingName | Select-Object PolicyType, Value, RegKeyPathRedirect, RegValueNameRedirect

                            if ($additionalData) {
                                Write-Verbose "Additional data for '$settingName' was found in policyAreaNameMetadata"
                                <#
                                <PolicyMetadata>
                                    <PolicyName>RecoveryEnvironmentAuthentication</PolicyName>
                                    <Behavior>49</Behavior>
                                    <highrange>2</highrange>
                                    <lowrange>0</lowrange>
                                    <mergealgorithm>3</mergealgorithm>
                                    <policytype>4</policytype>
                                    <RegKeyPathRedirect>Software\Policies\Microsoft\WinRE</RegKeyPathRedirect>
                                    <RegValueNameRedirect>WinREAuthenticationRequirement</RegValueNameRedirect>
                                    <value>0</value>
                                </PolicyMetadata>
                                #>
                                $property.DefaultValue = $additionalData.Value
                                $property.PolicyType = $additionalData.PolicyType
                                $property.RegKey = $additionalData.RegKeyPathRedirect
                                $property.RegValueName = $additionalData.RegValueNameRedirect
                            } else {
                                # no additional data was found in policyAreaNameMetadata
                                # trying to get them from admxPolicyAreaNameMetadata

                                <#
                                <IngestedADMXPolicyMetaData>
                                    <EnrollmentId>11120759-7CE3-4683-AB59-46C27FF40D35</EnrollmentId>
                                    <AreaName>
                                        <ADMXIngestedAreaName>OneDriveNGSCv2~Policy~OneDriveNGSC</ADMXIngestedAreaName>
                                        <PolicyMetadata>
                                            <PolicyName>BlockExternalSync</PolicyName>
                                            <SourceAdmxFile>OneDriveNGSCv2</SourceAdmxFile>
                                            <Behavior>224</Behavior>
                                            <MergeAlgorithm>3</MergeAlgorithm>
                                            <RegKeyPathRedirect>SOFTWARE\Policies\Microsoft\OneDrive</RegKeyPathRedirect>
                                            <RegValueNameRedirect>BlockExternalSync</RegValueNameRedirect>
                                            <PolicyType>1</PolicyType>
                                            <AdmxMetadataDevice>30313D0100000000323D000000000000</AdmxMetadataDevice>
                                        </PolicyMetadata>
                                #>
                                $additionalData = ($admxPolicyAreaNameMetadata.AreaName | ? { $_.ADMXIngestedAreaName -eq $policyAreaName }).PolicyMetadata | ? { $_.PolicyName -EQ $settingName } | select -First 1 # sometimes there are duplicities in results

                                if ($additionalData) {
                                    Write-Verbose "Additional data for '$settingName' was found in admxPolicyAreaNameMetadata"
                                    $property.PolicyType = $additionalData.PolicyType
                                    $property.RegKey = $additionalData.RegKeyPathRedirect
                                    $property.RegValueName = $additionalData.RegValueNameRedirect
                                    $property.SourceAdmxFile = $additionalData.SourceAdmxFile
                                } else {
                                    Write-Verbose "No additional data found for $settingName"
                                }
                            }

                            $winningProvider = $winningProviderPolicyAreaNameMetadata | ? Name -EQ "$settingName`_WinningProvider" | Select-Object -ExpandProperty Value
                            if ($winningProvider) {
                                if ($winningProvider -eq $userEnrollmentID) {
                                    $winningProvider = 'Intune'
                                }

                                $property.WinningProvider = $winningProvider
                            }

                            $settingDetails += New-Object -TypeName PSObject -Property $property
                        }
                    } else {
                        Write-Verbose "`tIt doesn't contain any settings"
                    }
                    #endregion get policy settings details

                    # get CSP policy URL if available
                    if ($showURLs) {
                        if ($policyAreaName -match "/") {
                            $pName = ($policyAreaName -split "/")[-2]
                        } else {
                            $pName = $policyAreaName
                        }
                        $policyURL = "https://docs.microsoft.com/en-us/windows/client-management/mdm/$pName-csp"
                        # check that URL exists
                        if ($clientIsOnline) {
                            if (!(Test-URLStatus $policyURL)) {
                                # URL doesn't exist
                                if ($policyAreaName -match "/") {
                                    # sometimes name of the CSP is not second from the end but third
                                    $pName = ($policyAreaName -split "/")[-3]
                                    $policyURL = "https://docs.microsoft.com/en-us/windows/client-management/mdm/$pName-csp"
                                    if (!(Test-URLStatus $policyURL)) {
                                        $policyURL = $null
                                    }
                                } else {
                                    $policyURL = "https://docs.microsoft.com/en-us/windows/client-management/mdm/policy-csp-$pName"
                                    if (!(Test-URLStatus $policyURL)) {
                                        $policyURL = $null
                                    }
                                }
                            }
                        }
                    }

                    #region return retrieved data
                    $property = [ordered] @{
                        Scope          = $scope
                        PolicyName     = $policyAreaName
                        SettingName    = $policyAreaSettingName
                        SettingDetails = $settingDetails
                    }
                    if ($showEnrollmentIDs) { $property.EnrollmentId = $enrollmentId }
                    if ($showURLs) { $property.PolicyURL = $policyURL }
                    $result = New-Object -TypeName PSObject -Property $property

                    if ($asHTML) {
                        $results += $result
                    } else {
                        $result
                    }
                    #endregion return retrieved data
                }
            }
        }
    }
    #endregion policies

    #region installations
    Write-Verbose "Getting MSI installations (MDMEnterpriseDiagnosticsReport.EnterpriseDesktopAppManagementinfo.MsiInstallations)"
    $installation = $xml.MDMEnterpriseDiagnosticsReport.EnterpriseDesktopAppManagementinfo.MsiInstallations | % { ConvertFrom-XML $_ }
    if ($installation) {
        Write-Verbose "Processing MSI installations"

        $settingDetails = @()

        $installation.TargetedUser | % {
            <#
            <MsiInstallations>
                <TargetedUser>
                <UserSid>S-0-0-00-0000000000-0000000000-000000000-000</UserSid>
                <Package>
                    <Type>MSI</Type>
                    <Details>
                    <PackageId>{23170F69-40C1-2702-1900-000001000000}</PackageId>
                    <DownloadInstall>Ready</DownloadInstall>
                    <ProductCode>{23170F69-40C1-2702-1900-000001000000}</ProductCode>
                    <ProductVersion>19.00.00.0</ProductVersion>
                    <ActionType>1</ActionType>
                    <Status>70</Status>
                    <JobStatusReport>1</JobStatusReport>
                    <LastError>0</LastError>
                    <BITSJobId></BITSJobId>
                    <DownloadLocation></DownloadLocation>
                    <CurrentDownloadUrlIndex>0</CurrentDownloadUrlIndex>
                    <CurrentDownloadUrl></CurrentDownloadUrl>
                    <FileHash>A7803233EEDB6A4B59B3024CCF9292A6FFFB94507DC998AA67C5B745D197A5DC</FileHash>
                    <CommandLine>ALLUSERS=1</CommandLine>
                    <AssignmentType>1</AssignmentType>
                    <EnforcementTimeout>30</EnforcementTimeout>
                    <EnforcementRetryIndex>0</EnforcementRetryIndex>
                    <EnforcementRetryCount>5</EnforcementRetryCount>
                    <EnforcementRetryInterval>3</EnforcementRetryInterval>
                    <LocURI>./Device/Vendor/MSFT/EnterpriseDesktopAppManagement/MSI/{23170F69-40C1-2702-1900-000001000000}/DownloadInstall</LocURI>
                    <ServerAccountID>11120759-7CE3-4683-FB59-46C27FF40D35</ServerAccountID>
                    </Details>
            #>

            $userSID = $_.UserSid
            $type = $_.Package.Type
            $details = $_.Package.details

            $details | % {
                Write-Verbose "`t$($_.PackageId) of type $type"

                # define base object
                $property = [ordered]@{
                    "Scope"          = _getTargetName $userSID
                    "Type"           = $type
                    "Status"         = _translateStatus $_.Status
                    "LastError"      = $_.LastError
                    "ProductVersion" = $_.ProductVersion
                    "CommandLine"    = $_.CommandLine
                    "RetryIndex"     = $_.EnforcementRetryIndex
                    "MaxRetryCount"  = $_.EnforcementRetryCount
                    "PackageId"      = $_.PackageId -replace "{" -replace "}"
                }
                $settingDetails += New-Object -TypeName PSObject -Property $property
            }
        }

        #region return retrieved data
        $property = [ordered] @{
            Scope          = $null
            PolicyName     = "SoftwareInstallation" # made up!
            SettingName    = $null
            SettingDetails = $settingDetails
        }
        if ($showEnrollmentIDs) { $property.EnrollmentId = $null }
        if ($showURLs) { $property.PolicyURL = $null } # this property only to have same properties for all returned objects
        $result = New-Object -TypeName PSObject -Property $property

        if ($asHTML) {
            $results += $result
        } else {
            $result
        }
        #endregion return retrieved data
    }
    #endregion installations

    #region convert results to HTML and output
    if ($asHTML -and $results) {
        Write-Verbose "Converting to HTML"

        # split the results
        $resultsWithSettings = @()
        $resultsWithoutSettings = @()
        $results | % {
            if ($_.settingDetails) {
                $resultsWithSettings += $_
            } else {
                $resultsWithoutSettings += $_
            }
        }

        New-HTML -TitleText "Intune Report" -Online -FilePath $HTMLReportPath -ShowHTML {
            # it looks better to have headers and content in center
            New-HTMLTableStyle -TextAlign center

            New-HTMLSection -HeaderText 'Intune Report' -Direction row -HeaderBackGroundColor Black -HeaderTextColor White -HeaderTextSize 20 {
                if ($resultsWithoutSettings) {
                    New-HTMLSection -HeaderText "Policies without settings details" -HeaderTextAlignment left -CanCollapse -BackgroundColor DeepSkyBlue -HeaderBackGroundColor DeepSkyBlue -HeaderTextSize 10 -HeaderTextColor EgyptianBlue -Direction row {
                        #region prepare data
                        # exclude some not significant or needed properties
                        # SettingName is empty (or same as PolicyName)
                        # settingDetails is empty
                        $excludeProperty = @('SettingName', 'SettingDetails')
                        if (!$showEnrollmentIDs) { $excludeProperty += 'EnrollmentId' }
                        if (!$showURLs) { $excludeProperty += 'PolicyURL' }
                        $resultsWithoutSettings = $resultsWithoutSettings | Select-Object -Property * -exclude $excludeProperty
                        # sort
                        $resultsWithoutSettings = $resultsWithoutSettings | Sort-Object -Property Scope, PolicyName
                        #endregion prepare data

                        # render policies
                        New-HTMLSection -HeaderText 'Policy' -HeaderBackGroundColor Wedgewood -BackgroundColor White {
                            New-HTMLTable -DataTable $resultsWithoutSettings -WordBreak 'break-all' -DisableInfo -HideButtons -DisablePaging -FixedHeader -FixedFooter
                        }
                    }
                }

                if ($resultsWithSettings) {
                    New-HTMLSection -HeaderText "Policies with settings details" -HeaderTextAlignment left -CanCollapse -BackgroundColor DeepSkyBlue -HeaderBackGroundColor DeepSkyBlue -HeaderTextSize 10 -HeaderTextColor EgyptianBlue -Direction row {
                        # sort
                        $resultsWithSettings = $resultsWithSettings | Sort-Object -Property Scope, PolicyName

                        $resultsWithSettings | % {
                            $policy = $_
                            $policySetting = $_.settingDetails

                            #region prepare data
                            # exclude some not significant or needed properties
                            # SettingName is useless in HTML report from my point of view
                            # settingDetails will be shown in separate table, omit here
                            if ($showEnrollmentIDs) {
                                $excludeProperty = 'SettingName', 'SettingDetails'
                            } else {
                                $excludeProperty = 'SettingName', 'SettingDetails', 'EnrollmentId'
                            }

                            $policy = $policy | Select-Object -Property * -ExcludeProperty $excludeProperty
                            #endregion prepare data

                            New-HTMLSection -HeaderText $policy.PolicyName -HeaderTextAlignment left -CanCollapse -BackgroundColor White -HeaderBackGroundColor White -HeaderTextSize 12 -HeaderTextColor EgyptianBlue {
                                # render main policy
                                New-HTMLSection -HeaderText 'Policy' -HeaderBackGroundColor Wedgewood -BackgroundColor White {
                                    New-HTMLTable -DataTable $policy -WordBreak 'break-all' -HideFooter -DisableInfo -HideButtons -DisablePaging -DisableSearch -DisableOrdering
                                }

                                # render policy settings details
                                if ($policySetting) {
                                    if (@($policySetting).count -eq 1) {
                                        $detailsHTMLTableParam = @{
                                            DisableSearch   = $true
                                            DisableOrdering = $true
                                        }
                                    } else {
                                        $detailsHTMLTableParam = @{}
                                    }
                                    New-HTMLSection -HeaderText 'Policy settings' -HeaderBackGroundColor PictonBlue -BackgroundColor White {
                                        New-HTMLTable @detailsHTMLTableParam -DataTable $policySetting -WordBreak 'break-all' -AllProperties -FixedHeader -HideFooter -DisableInfo -HideButtons -DisablePaging -WarningAction SilentlyContinue {
                                            New-HTMLTableCondition -Name 'WinningProvider' -ComparisonType string -Operator 'ne' -Value 'Intune' -BackgroundColor Red -Color White #-Row
                                            New-HTMLTableCondition -Name 'LastError' -ComparisonType number -Operator 'ne' -Value 0 -BackgroundColor Red -Color White # -Row
                                            New-HTMLTableCondition -Name 'Error' -ComparisonType number -Operator 'ne' -Value 0 -BackgroundColor Red -Color White # -Row
                                        }
                                    }
                                }
                            }

                            # hack for getting new line between sections
                            New-HTMLText -Text '.' -Color DeepSkyBlue
                        }
                    }
                }
            } # end of main HTML section
        }
    }
    #endregion convert results to HTML and output

    if ($computerName) {
        Remove-PSSession $session
    }
}

function Get-ClientIntunePolicyResult {
    <#
        .SYNOPSIS
        Function for getting gpresult/rsop like report but for local client Intune policies.
        Result can be PowerShell object or HTML report.

        .DESCRIPTION
        Function for getting gpresult/rsop like report but for local client Intune policies.
        Result can be PowerShell object or HTML report.

        .PARAMETER computerName
        (optional) Computer name from which you want to get data from.

        .PARAMETER intuneXMLReport
        (optional) PowerShell object returned by ConvertFrom-MDMDiagReportXML function.

        .PARAMETER asHTML
        Switch for returning HTML report instead of PowerShell object.
        PSWriteHTML module is needed!

        .PARAMETER HTMLReportPath
        (optional) Where the HTML report should be stored.

        Default is "IntunePolicyReport.html" in user profile.

        .PARAMETER getDataFromIntune
        Switch for getting additional data (policy names and account names instead of IDs) from Intune itself.
        Microsoft.Graph.Intune module is required!

        Account with READ permission for: Applications, Scripts, RemediationScripts, Users will be needed i.e.:
        - DeviceManagementApps.Read.All
        - DeviceManagementManagedDevices.Read.All
        - DeviceManagementConfiguration.Read.All
        - User.Read.All

        .PARAMETER credential
        Credentials for connecting to Intune.
        Account that has at least READ permissions has to be used.

        .PARAMETER tenantId
        String with your TenantID.
        Use only if you want use application authentication (instead of user authentication).
        You can get your TenantID at https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/Overview.

        .PARAMETER showEnrollmentIDs
        Switch for showing EnrollmentIDs in the result.

        .PARAMETER showURLs
        Switch for showing policy/setting URLs in the result.
        Makes this function a little slower, because every URL is tested that it exists.

        .PARAMETER showConnectionData
        Switch for showing data related to client's connection to the Intune.

        .EXAMPLE
        Get-ClientIntunePolicyResult

        Will return PowerShell object containing Intune policy processing report data.

        .EXAMPLE
        Get-ClientIntunePolicyResult -showURLs -asHTML

        Will return HTML page containing Intune policy processing report data.
        URLs to policies/settings will be included.

        .EXAMPLE
        $intuneREADCred = Get-Credential
        Get-ClientIntunePolicyResult -showURLs -asHTML -getDataFromIntune -showConnectionData -credential $intuneREADCred

        Will return HTML page containing Intune policy processing report data and connection data.
        URLs to policies/settings and Intune policies names (if available) will be included.

        .EXAMPLE
        $intuneREADAppCred = Get-Credential
        Get-ClientIntunePolicyResult -showURLs -asHTML -getDataFromIntune -credential $intuneREADAppCred -tenantId 123456789

        Will return HTML page containing Intune policy processing report data.
        URLs to policies/settings will be included same as Intune policies names (if available).
        For authentication to Intune registered application secret will be used (AppID and secret stored in credentials object).
        #>

    [Alias("ipresult", "Get-IntunePolicyResult")]
    [CmdletBinding()]
    param (
        [string] $computerName,

        [ValidateScript( { $_.GetType().Name -eq 'Object[]' } )]
        $intuneXMLReport,

        [switch] $asHTML,

        [string] $HTMLReportPath = (Join-Path $env:USERPROFILE "IntunePolicyReport.html"),

        [switch] $getDataFromIntune,

        [System.Management.Automation.PSCredential] $credential,

        [string] $tenantId,

        [switch] $showEnrollmentIDs,

        [switch] $showURLs,

        [switch] $showConnectionData
    )

    # remove property validation
    (Get-Variable intuneXMLReport).Attributes.Clear()

    #region prepare
    if ($computerName) {
        $session = New-PSSession -ComputerName $computerName -ErrorAction Stop
    }

    if ($asHTML) {
        if (!(Get-Module 'PSWriteHtml') -and (!(Get-Module 'PSWriteHtml' -ListAvailable))) {
            throw "Module PSWriteHtml is missing. To get it use command: Install-Module PSWriteHtml -Scope CurrentUser"
        }
        [Void][System.IO.Directory]::CreateDirectory((Split-Path $HTMLReportPath -Parent))
    }

    if ($getDataFromIntune) {
        if (!(Get-Module 'Microsoft.Graph.Intune') -and !(Get-Module 'Microsoft.Graph.Intune' -ListAvailable)) {
            throw "Module 'Microsoft.Graph.Intune' is required. To install it call: Install-Module 'Microsoft.Graph.Intune' -Scope CurrentUser"
        }

        if ($tenantId) {
            # app logon
            if (!$credential) {
                $credential = Get-Credential -Message "Enter AppID and AppSecret for connecting to Intune tenant" -ErrorAction Stop
            }
            Update-MSGraphEnvironment -AppId $credential.UserName -Quiet
            Update-MSGraphEnvironment -AuthUrl "https://login.windows.net/$tenantId" -Quiet
            $null = Connect-MSGraph -ClientSecret $credential.GetNetworkCredential().Password -ErrorAction Stop
        } else {
            # user logon
            if ($credential) {
                $null = Connect-MSGraph -Credential $credential -ErrorAction Stop
                # $header = New-GraphAPIAuthHeader -credential $credential -ErrorAction Stop
            } else {
                $null = Connect-MSGraph -ErrorAction Stop
                # $header = New-GraphAPIAuthHeader -ErrorAction Stop
            }
        }

        Write-Verbose "Getting Intune data"
        # filtering by ID is as slow as getting all data
        # Invoke-MSGraphRequest -Url 'https://graph.microsoft.com/beta/deviceAppManagement/mobileApps?$filter=(id%20eq%20%2756695a77-925a-4df0-be79-24ed039afa86%27)'
        $intuneRemediationScript = Invoke-MSGraphRequest -Url "https://graph.microsoft.com/beta/deviceManagement/deviceHealthScripts?select=id,displayname" | Get-MSGraphAllPages
        $intuneScript = Invoke-MSGraphRequest -Url "https://graph.microsoft.com/beta/deviceManagement/deviceManagementScripts?select=id,displayname" | Get-MSGraphAllPages
        $intuneApp = Invoke-MSGraphRequest -Url "https://graph.microsoft.com/beta/deviceAppManagement/mobileApps?select=id,displayname" | Get-MSGraphAllPages
        $intuneUser = Invoke-MSGraphRequest -Url 'https://graph.microsoft.com/beta/users?select=id,userPrincipalName' | Get-MSGraphAllPages
    }

    # get the core Intune data
    if (!$intuneXMLReport) {
        $param = @{}
        if ($showEnrollmentIDs) { $param.showEnrollmentIDs = $true }
        if ($showURLs) { $param.showURLs = $true }
        if ($showConnectionData) { $param.showConnectionData = $true }
        if ($computerName) { $param.computerName = $computerName }

        Write-Verbose "Getting client Intune data via ConvertFrom-MDMDiagReportXML"
        $intuneXMLReport = ConvertFrom-MDMDiagReportXML @param
    }
    #endregion prepare

    #region helper functions
    function _getTargetName {
        param ([string] $id)

        Write-Verbose "Translating $id"

        if (!$id) {
            Write-Verbose "id was null"
            return
        } elseif ($id -eq 'device') {
            # xml nodes contains 'device' instead of 'Device'
            return 'Device'
        }

        $errPref = $ErrorActionPreference
        $ErrorActionPreference = "Stop"
        try {
            if ($id -eq '00000000-0000-0000-0000-000000000000' -or $id -eq 'S-0-0-00-0000000000-0000000000-000000000-000') {
                return 'Device'
            } elseif ($id -match "^S-1-5-21") {
                # it is local account
                return ((New-Object System.Security.Principal.SecurityIdentifier($id)).Translate([System.Security.Principal.NTAccount])).Value
            } else {
                # it is AzureAD account
                if ($getDataFromIntune) {
                    return ($intuneUser | ? id -EQ $id).userPrincipalName
                } else {
                    # unable to translate ID to name because there is no connection to the Intune Graph API
                    return $id
                }
            }
        } catch {
            Write-Warning "Unable to translate $id to account name ($_)"
            $ErrorActionPreference = $errPref
            return $id
        }
    }
    function _getIntuneScript {
        param ([string] $scriptID)

        $intuneScript | ? id -EQ $scriptID
    }

    function _getIntuneApp {
        param ([string] $appID)

        $intuneApp | ? id -EQ $appID
    }

    function _getRemediationScript {
        param ([string] $scriptID)
        $intuneRemediationScript | ? id -EQ $scriptID
    }

    # create helper functions text definition for usage in remote sessions
    if ($computerName) {
        $allFunctionDefs = "function _getTargetName { ${function:_getTargetName} }; function _getIntuneScript { ${function:_getIntuneScript} }; function _getIntuneApp { ${function:_getIntuneApp} }; ; function _getRemediationScript { ${function:_getRemediationScript} }; function Get-IntuneWin32App { ${function:Get-IntuneWin32App} }"
    }
    #endregion helper functions

    #region enrich SoftwareInstallation section
    if ($intuneXMLReport | ? PolicyName -EQ 'SoftwareInstallation') {
        Write-Verbose "Modifying 'SoftwareInstallation' section"
        # list of installed MSI applications
        $scriptBlock = {
            Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\', 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\' -ErrorAction SilentlyContinue -Recurse | % {
                Get-ItemProperty -Path $_.PSPath | select -Property DisplayName, DisplayVersion, UninstallString
            }
        }

        $param = @{
            scriptBlock  = $scriptBlock
            argumentList = ($VerbosePreference, $allFunctionDefs)
        }
        if ($computerName) {
            $param.session = $session
        }

        $installedMSI = Invoke-Command @param

        if ($installedMSI) {
            $intuneXMLReport = $intuneXMLReport | % {
                if ($_.PolicyName -EQ 'SoftwareInstallation') {
                    $softwareInstallation = $_

                    $softwareInstallationSettingDetails = $softwareInstallation.SettingDetails | ? { $_ } | % {
                        $item = $_
                        $packageId = $item.PackageId

                        Write-Verbose "`tPackageId $packageId"

                        Add-Member -InputObject $item -MemberType NoteProperty -Force -Name DisplayName -Value ($installedMSI | ? UninstallString -Match ([regex]::Escape($packageId)) | select -Last 1 -ExpandProperty DisplayName)

                        #return modified MSI object (put Displayname as a second property)
                        $item | select -Property Scope, DisplayName, Type, Status, LastError, ProductVersion, CommandLine, RetryIndex, MaxRetryCount, PackageId
                    }

                    # save results back to original object
                    $softwareInstallation.SettingDetails = $softwareInstallationSettingDetails

                    # return modified object
                    $softwareInstallation
                } else {
                    # no change necessary
                    $_
                }
            }
        }
    }
    #endregion enrich SoftwareInstallation section

    #region Win32App
    Write-Verbose "Processing 'Win32App' section"
    #region get data
    $scriptBlock = {
        param($verbosePref, $getDataFromIntune, $intuneApp, $intuneUser, $allFunctionDefs)

        # inherit verbose settings from host session
        $VerbosePreference = $verbosePref

        # recreate functions from their text definitions
        . ([ScriptBlock]::Create($allFunctionDefs))

        $win32App = Get-IntuneWin32App

        if ($showURLs) {
            $win32App | % {
                $_ | Add-Member -MemberType NoteProperty -Name "IntuneWin32AppURL" -Value "https://endpoint.microsoft.com/#blade/Microsoft_Intune_Apps/SettingsMenu/0/appId/$($_.id)"
            }
        } else {
            $win32App
        }
    }

    $param = @{
        scriptBlock  = $scriptBlock
        argumentList = ($VerbosePreference, $getDataFromIntune, $intuneApp, $intuneUser, $allFunctionDefs)
    }
    if ($computerName) {
        $param.session = $session
    }

    $settingDetails = Invoke-Command @param
    #endregion get data

    if ($settingDetails) {
        $property = [ordered]@{
            "Scope"          = $null # scope is specified at the particular items level
            "PolicyName"     = 'SoftwareInstallation Win32App' # my custom made
            # SettingName    = 'Win32App' # my custom made
            "SettingDetails" = $settingDetails
        }

        if ($showURLs) {
            $property.PolicyURL = "https://endpoint.microsoft.com/#blade/Microsoft_Intune_DeviceSettings/AppsWindowsMenu/windowsApps"
        }

        $intuneXMLReport += New-Object -TypeName PSObject -Property $property
    }
    #endregion Win32App

    #region add Scripts section
    # https://oliverkieselbach.com/2018/02/12/part-2-deep-dive-microsoft-intune-management-extension-powershell-scripts/
    Write-Verbose "Processing 'Script' section"
    $scriptBlock = {
        param($verbosePref, $getDataFromIntune, $intuneScript, $intuneUser, $allFunctionDefs)

        # inherit verbose settings from host session
        $VerbosePreference = $verbosePref

        # recreate functions from their text definitions
        . ([ScriptBlock]::Create($allFunctionDefs))

        Get-ChildItem "HKLM:\SOFTWARE\Microsoft\IntuneManagementExtension\Policies" -ErrorAction SilentlyContinue | % {
            $userAzureObjectID = Split-Path $_.Name -Leaf

            Get-ChildItem $_.PSPath | % {
                $scriptRegPath = $_.PSPath
                $scriptID = Split-Path $_.Name -Leaf

                Write-Verbose "`tID $scriptID"

                $scriptRegData = Get-ItemProperty $scriptRegPath

                # get output of the invoked script
                if ($scriptRegData.ResultDetails) {
                    try {
                        $resultDetails = $scriptRegData.ResultDetails | ConvertFrom-Json -ErrorAction Stop | select -ExpandProperty ExecutionMsg
                    } catch {
                        Write-Verbose "`tUnable to get Script Output data"
                    }
                } else {
                    $resultDetails = $null
                }

                if ($getDataFromIntune) {
                    $property = [ordered]@{
                        "Scope"                   = _getTargetName $userAzureObjectID
                        "DisplayName"             = (_getIntuneScript $scriptID).DisplayName
                        "Id"                      = $scriptID
                        "Result"                  = $scriptRegData.Result
                        "ErrorCode"               = $scriptRegData.ErrorCode
                        "DownloadAndExecuteCount" = $scriptRegData.DownloadCount
                        "LastUpdatedTimeUtc"      = $scriptRegData.LastUpdatedTimeUtc
                        "RunAsAccount"            = $scriptRegData.RunAsAccount
                        "ResultDetails"           = $resultDetails
                    }
                } else {
                    # no 'DisplayName' property
                    $property = [ordered]@{
                        "Scope"                   = _getTargetName $userAzureObjectID
                        "Id"                      = $scriptID
                        "Result"                  = $scriptRegData.Result
                        "ErrorCode"               = $scriptRegData.ErrorCode
                        "DownloadAndExecuteCount" = $scriptRegData.DownloadCount
                        "LastUpdatedTimeUtc"      = $scriptRegData.LastUpdatedTimeUtc
                        "RunAsAccount"            = $scriptRegData.RunAsAccount
                        "ResultDetails"           = $resultDetails
                    }
                }

                if ($showURLs) {
                    $property.IntuneScriptURL = "https://endpoint.microsoft.com/#blade/Microsoft_Intune_DeviceSettings/ConfigureWMPolicyMenuBlade/properties/policyId/$scriptID/policyType/0"
                }

                New-Object -TypeName PSObject -Property $property
            }
        }
    }

    $param = @{
        scriptBlock  = $scriptBlock
        argumentList = ($VerbosePreference, $getDataFromIntune, $intuneScript, $intuneUser, $allFunctionDefs)
    }
    if ($computerName) {
        $param.session = $session
    }

    $settingDetails = Invoke-Command @param

    if ($settingDetails) {
        $property = [ordered]@{
            "Scope"          = $null # scope is specified at the particular items level
            "PolicyName"     = 'Script' # my custom made
            "SettingName"    = $null
            "SettingDetails" = $settingDetails
        }

        if ($showURLs) {
            $property.PolicyURL = "https://endpoint.microsoft.com/#blade/Microsoft_Intune_DeviceSettings/DevicesMenu/powershell"
        }

        $intuneXMLReport += New-Object -TypeName PSObject -Property $property
    }
    #endregion add Scripts section

    #region remediation script
    Write-Verbose "Processing 'Remediation Script' section"
    $scriptBlock = {
        param($verbosePref, $getDataFromIntune, $intuneRemediationScript, $intuneUser, $allFunctionDefs)

        # inherit verbose settings from host session
        $VerbosePreference = $verbosePref

        # recreate functions from their text definitions
        . ([ScriptBlock]::Create($allFunctionDefs))

        Get-ChildItem "HKLM:\SOFTWARE\Microsoft\IntuneManagementExtension\SideCarPolicies\Scripts\Reports" -ErrorAction SilentlyContinue | % {
            $userAzureObjectID = Split-Path $_.Name -Leaf
            $userRemScriptRoot = $_.PSPath

            # $lastFullReportTimeUTC = Get-ItemPropertyValue $userRemScriptRoot -Name LastFullReportTimeUTC
            $remScriptIDList = Get-ChildItem $userRemScriptRoot | select -ExpandProperty PSChildName | % { $_ -replace "_\d+$" } | select -Unique

            $remScriptIDList | % {
                $remScriptID = $_

                Write-Verbose "`tID $remScriptID"

                $newestRemScriptRecord = Get-ChildItem $userRemScriptRoot | ? PSChildName -Match ([regex]::escape($remScriptID)) | Sort-Object -Descending -Property PSChildName | select -First 1

                try {
                    $result = Get-ItemPropertyValue "$($newestRemScriptRecord.PSPath)\Result" -Name Result | ConvertFrom-Json
                } catch {
                    Write-Verbose "`tUnable to get Remediation Script Result data"
                }

                $lastExecution = Get-ItemPropertyValue "HKLM:\SOFTWARE\Microsoft\IntuneManagementExtension\SideCarPolicies\Scripts\Execution\$userAzureObjectID\$($newestRemScriptRecord.PSChildName)" -Name LastExecution

                if ($getDataFromIntune) {
                    $property = [ordered]@{
                        "Scope"                             = _getTargetName $userAzureObjectID
                        "DisplayName"                       = (_getRemediationScript $remScriptID).DisplayName
                        "Id"                                = $remScriptID
                        "LastError"                         = $result.ErrorCode
                        "LastExecution"                     = $lastExecution
                        # LastFullReportTimeUTC               = $lastFullReportTimeUTC
                        "InternalVersion"                   = $result.InternalVersion
                        "PreRemediationDetectScriptOutput"  = $result.PreRemediationDetectScriptOutput
                        "PreRemediationDetectScriptError"   = $result.PreRemediationDetectScriptError
                        "RemediationScriptErrorDetails"     = $result.RemediationScriptErrorDetails
                        "PostRemediationDetectScriptOutput" = $result.PostRemediationDetectScriptOutput
                        "PostRemediationDetectScriptError"  = $result.PostRemediationDetectScriptError
                        "RemediationExitCode"               = $result.Info.RemediationExitCode
                        "FirstDetectExitCode"               = $result.Info.FirstDetectExitCode
                        "LastDetectExitCode"                = $result.Info.LastDetectExitCode
                        "ErrorDetails"                      = $result.Info.ErrorDetails
                    }
                } else {
                    # no 'DisplayName' property
                    $property = [ordered]@{
                        "Scope"                             = _getTargetName $userAzureObjectID
                        "Id"                                = $remScriptID
                        "LastError"                         = $result.ErrorCode
                        "LastExecution"                     = $lastExecution
                        # LastFullReportTimeUTC               = $lastFullReportTimeUTC
                        "InternalVersion"                   = $result.InternalVersion
                        "PreRemediationDetectScriptOutput"  = $result.PreRemediationDetectScriptOutput
                        "PreRemediationDetectScriptError"   = $result.PreRemediationDetectScriptError
                        "RemediationScriptErrorDetails"     = $result.RemediationScriptErrorDetails
                        "PostRemediationDetectScriptOutput" = $result.PostRemediationDetectScriptOutput
                        "PostRemediationDetectScriptError"  = $result.PostRemediationDetectScriptError
                        "RemediationExitCode"               = $result.Info.RemediationExitCode
                        "FirstDetectExitCode"               = $result.Info.FirstDetectExitCode
                        "LastDetectExitCode"                = $result.Info.LastDetectExitCode
                        "ErrorDetails"                      = $result.Info.ErrorDetails
                    }
                }

                New-Object -TypeName PSObject -Property $property
            }
        }
    }

    $param = @{
        scriptBlock  = $scriptBlock
        argumentList = ($VerbosePreference, $getDataFromIntune, $intuneRemediationScript, $intuneUser, $allFunctionDefs)
    }
    if ($computerName) {
        $param.session = $session
    }

    $settingDetails = Invoke-Command @param

    if ($settingDetails) {
        $property = [ordered]@{
            "Scope"          = $null # scope is specified at the particular items level
            "PolicyName"     = 'RemediationScript' # my custom made
            "SettingName"    = $null # my custom made
            "SettingDetails" = $settingDetails
        }

        if ($showURLs) {
            $property.PolicyURL = "https://endpoint.microsoft.com/#blade/Microsoft_Intune_Enrollment/UXAnalyticsMenu/proactiveRemediations"
        }

        $intuneXMLReport += New-Object -TypeName PSObject -Property $property
    }
    #endregion remediation script

    if ($computerName) {
        Remove-PSSession $session
    }

    #region output the results (as object or HTML report)
    if ($asHTML -and $intuneXMLReport) {
        Write-Verbose "Converting to '$HTMLReportPath'"

        # split the results
        $resultsWithSettings = @()
        $resultsWithoutSettings = @()
        $resultsConnectionData = $null
        $intuneXMLReport | % {
            if ($_.settingDetails) {
                $resultsWithSettings += $_
            } elseif ($_.MDMServerName) {
                # MDMServerName property is only in object representing connection data
                $resultsConnectionData = $_
            } else {
                $resultsWithoutSettings += $_
            }
        }

        if ($computerName) { $title = "Intune Report - $($computerName.toupper())" }
        else { $title = "Intune Report - $($env:COMPUTERNAME.toupper())" }

        New-HTML -TitleText $title -Online -FilePath $HTMLReportPath -ShowHTML {
            # it looks better to have headers and content in center
            New-HTMLTableStyle -TextAlign center

            New-HTMLSection -HeaderText $title -Direction row -HeaderBackGroundColor Black -HeaderTextColor White -HeaderTextSize 20 {
                if ($resultsConnectionData) {
                    New-HTMLSection -HeaderText "Intune connection information" -HeaderTextAlignment left -CanCollapse -BackgroundColor DeepSkyBlue -HeaderBackGroundColor DeepSkyBlue -HeaderTextSize 10 -HeaderTextColor EgyptianBlue -Direction row {
                        # render policies
                        New-HTMLSection -BackgroundColor White {
                            New-HTMLTable -DataTable $resultsConnectionData -WordBreak 'break-all' -DisableInfo -HideButtons -DisablePaging -HideFooter -DisableSearch -DisableOrdering
                        }
                    }
                }

                if ($resultsWithoutSettings) {
                    New-HTMLSection -HeaderText "Policies without settings details" -HeaderTextAlignment left -CanCollapse -BackgroundColor DeepSkyBlue -HeaderBackGroundColor DeepSkyBlue -HeaderTextSize 10 -HeaderTextColor EgyptianBlue -Direction row {
                        #region prepare data
                        # exclude some not significant or needed properties
                        # SettingName is empty (or same as PolicyName)
                        # settingDetails is empty
                        $excludeProperty = @('SettingName', 'SettingDetails')
                        if (!$showEnrollmentIDs) { $excludeProperty += 'EnrollmentId' }
                        if (!$showURLs) { $excludeProperty += 'PolicyURL' }
                        $resultsWithoutSettings = $resultsWithoutSettings | Select-Object -Property * -exclude $excludeProperty
                        # sort
                        $resultsWithoutSettings = $resultsWithoutSettings | Sort-Object -Property Scope, PolicyName
                        #endregion prepare data

                        # render policies
                        New-HTMLSection -HeaderText 'Policy' -HeaderBackGroundColor Wedgewood -BackgroundColor White {
                            New-HTMLTable -DataTable $resultsWithoutSettings -WordBreak 'break-all' -DisableInfo -HideButtons -DisablePaging -FixedHeader -FixedFooter
                        }
                    }
                }

                if ($resultsWithSettings) {
                    # sort
                    $resultsWithSettings = $resultsWithSettings | Sort-Object -Property Scope, PolicyName

                    # modify inner sections margins
                    $innerSectionStyle = New-HTMLSectionStyle -RequestConfiguration
                    Add-HTMLStyle -Css @{
                        "$($innerSectionStyle.Section)" = @{
                            'margin-bottom' = '20px'
                        }
                    } -SkipTags

                    New-HTMLSection -HeaderText "Policies with settings details" -HeaderTextAlignment left -CanCollapse -BackgroundColor DeepSkyBlue -HeaderBackGroundColor DeepSkyBlue -HeaderTextSize 10 -HeaderTextColor EgyptianBlue -Direction row {
                        $resultsWithSettings | % {
                            $policy = $_
                            $policySetting = $_.settingDetails

                            #region prepare data
                            # exclude some not significant or needed properties
                            # SettingName is useless in HTML report from my point of view
                            # settingDetails will be shown in separate table, omit here
                            $excludeProperty = @('SettingName', 'SettingDetails')
                            if (!$showEnrollmentIDs) { $excludeProperty += 'EnrollmentId' }
                            if (!$showURLs) { $excludeProperty += 'PolicyURL' }

                            $policy = $policy | Select-Object -Property * -ExcludeProperty $excludeProperty
                            #endregion prepare data

                            New-HTMLSection -HeaderText $policy.PolicyName -HeaderTextAlignment left -CanCollapse -BackgroundColor White -HeaderBackGroundColor White -HeaderTextSize 12 -HeaderTextColor EgyptianBlue -StyleSheetsConfiguration $innerSectionStyle {
                                # render main policy
                                New-HTMLSection -HeaderText 'Policy' -HeaderBackGroundColor Wedgewood -BackgroundColor White {
                                    New-HTMLTable -DataTable $policy -WordBreak 'break-all' -HideFooter -DisableInfo -HideButtons -DisablePaging -DisableSearch -DisableOrdering
                                }

                                # render policy settings details
                                if ($policySetting) {
                                    if (@($policySetting).count -eq 1) {
                                        $detailsHTMLTableParam = @{
                                            DisableSearch   = $true
                                            DisableOrdering = $true
                                        }
                                    } else {
                                        $detailsHTMLTableParam = @{}
                                    }
                                    New-HTMLSection -HeaderText 'Policy settings' -HeaderBackGroundColor PictonBlue -BackgroundColor White {
                                        New-HTMLTable @detailsHTMLTableParam -DataTable $policySetting -WordBreak 'break-all' -AllProperties -FixedHeader -HideFooter -DisableInfo -HideButtons -DisablePaging -WarningAction SilentlyContinue {
                                            New-HTMLTableCondition -Name 'WinningProvider' -ComparisonType string -Operator 'ne' -Value 'Intune' -BackgroundColor Red -Color White #-Row
                                            New-HTMLTableCondition -Name 'LastError' -ComparisonType number -Operator 'ne' -Value 0 -BackgroundColor Red -Color White # -Row
                                            New-HTMLTableCondition -Name 'Error' -ComparisonType number -Operator 'ne' -Value 0 -BackgroundColor Red -Color White # -Row
                                            New-HTMLTableCondition -Name 'ErrorCode' -ComparisonType number -Operator 'ne' -Value 0 -BackgroundColor Red -Color White # -Row
                                            New-HTMLTableCondition -Name 'RemediationScriptErrorDetails' -ComparisonType string -Operator 'ne' -Value '' -BackgroundColor Red -Color White # -Row
                                            New-HTMLTableCondition -Name 'RemediationScriptErrorDetails' -ComparisonType string -Operator 'ne' -Value '' -BackgroundColor Red -Color White # -Row
                                            New-HTMLTableCondition -Name 'PreRemediationDetectScriptError' -ComparisonType string -Operator 'ne' -Value '' -BackgroundColor Red -Color White # -Row
                                            New-HTMLTableCondition -Name 'PostRemediationDetectScriptError' -ComparisonType string -Operator 'ne' -Value '' -BackgroundColor Red -Color White # -Row
                                            New-HTMLTableCondition -Name 'RemediationExitCode' -ComparisonType number -Operator 'ne' -Value 0 -BackgroundColor Red -Color White # -Row
                                            New-HTMLTableCondition -Name 'FirstDetectExitCode' -ComparisonType number -Operator 'ne' -Value 0 -BackgroundColor Red -Color White # -Row
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } # end of main HTML section
        }
    } else {
        Write-Verbose "Returning PowerShell object"
        return $intuneXMLReport
    }
    #endregion output the results (as object or HTML report)
}

If(-not(Get-InstalledModule CommonStuff -ErrorAction silentlycontinue)){
    Install-Module CommonStuff -Scope CurrentUser -force -Confirm:$False
}

Get-ClientIntunePolicyResult -showURLs -asHTML