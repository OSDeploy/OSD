function Get-IntuneLogWin32AppData {
    <#
    .SYNOPSIS
    Function for getting Intune Win32Apps information from clients log files ($env:ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension*.log).

    .DESCRIPTION
    Function for getting Intune Win32Apps information from clients log files ($env:ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension*.log).

    Finds data about processing of Win32Apps and outputs them into console as an PowerShell object.

    Returns various information like app requirements, install/uninstall command, detection and requirement scripts etc.

    .PARAMETER allOccurrences
    Switch for getting all Win32App processings.
    By default just newest processing is returned from the newest Intune log.

    .PARAMETER excludeProperty
    List of properties to exclude.

    By default: 'Intent', 'TargetType', 'ToastState', 'Targeted', 'MetadataVersion', 'RelationVersion', 'DOPriority', 'SupportState', 'InstallContext', 'InstallerData'

    Reason for exclude is readability and the fact that I didn't find any documentation that would help me interpret their values.

    .EXAMPLE
    $win32AppData = Get-IntuneLogWin32AppData

    $myApp = ($win32AppData | ? Name -eq 'MyApp')

    "Output complete object"
    $myApp

    "Detection script content for application 'MyApp'"
    $myApp.DetectionRule.DetectionText.ScriptBody

    "Requirement script content for application 'MyApp'"
    $myApp.RequirementRulesExtended.RequirementText.ScriptBody

    "Installation script content for application 'MyApp'"
    $myApp.InstallCommandLine

    Show various interesting information for MyApp application deployment.

    .NOTES
    Run on Windows client managed using Intune MDM.
    #>

    [CmdletBinding()]
    param (
        [switch] $allOccurrences,

        [string[]] $excludeProperty = ('Intent', 'TargetType', 'ToastState', 'Targeted', 'MetadataVersion', 'RelationVersion', 'DOPriority', 'SupportState', 'InstallContext', 'InstallerData')
    )

    #region helper functions
    function ConvertFrom-Base64 {
        param ($encodedString)
        [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($encodedString))
    }

    # transforms default JSON object into more readable one
    function _enhanceObject {
        param ($object, $excludeProperty)

        #region helper functions
        function _ruleSubType {
            param ($type, $subType, $value)

            switch ($type) {
                'File' {
                    switch ($subType) {
                        1 { "File or folder exist" }
                        2 { "Date Modified" }
                        3 { "Date Created" }
                        4 { "File version" }
                        5 { "Size in MB" }
                        6 { "File or folder does not exist" }
                        default { $subType }
                    }
                }

                'Registry' {
                    switch ($subType) {
                        1 { if ($value) { "Value exists" } else { "Key exists" } }
                        2 { if ($value) { "Value does not exist" } else { "Key does not exist" } }
                        3 { "String comparison" }
                        4 { "Integer comparison" }
                        5 { "Version comparison" }
                        default { $subType }
                    }
                }

                'Script' {
                    switch ($subType) {
                        1 { "String" }
                        2 { "Date and Time" }
                        3 { "Integer" }
                        4 { "Floating Point" }
                        5 { "Version" }
                        6 { "Boolean" }
                        default { $subType }
                    }
                }

                default {
                    Write-Warning "Undefined operator type $type"
                    $subType
                }
            }
        }

        function _operator {
            param ($operator)

            switch ($operator) {
                0 { "Does not exist" }
                1 { "Equals" }
                2 { "Not equal to" }
                4 { "Greater than" }
                5 { "Greater than or equal" }
                8 { "Less than" }
                9 { "Less than or equal" }
                default { $operator }
            }
        }

        function _detectionRule {
            param ($detectionRules)

            function _detectionType {
                param ($detectionType)

                switch ($detectionType) {
                    0 { "Registry" }
                    1 { "MSI" }
                    2 { "File" }
                    3 { "Script" }
                    default { $detectionType }
                }
            }

            $detectionRules = $detectionRules | ConvertFrom-Json

            # enhance the object properties
            $detectionRules | % {
                $detectionRule = $_

                $type = _detectionType $detectionRule.DetectionType

                $property = [ordered]@{
                    Type = $type
                }

                $detectionText = $_.DetectionText | ConvertFrom-Json # convert from JSON and select-object in two lines otherwise it behaves strangely
                if ($detectionText.ScriptBody) {
                    # it is a script detection check
                    $detectionText = $detectionText | select -Property `
                    @{n = 'EnforceSignatureCheck'; e = { if ($_.EnforceSignatureCheck -ne 0) { $true } else { $false } } },
                    @{n = 'RunAs32Bit'; e = { if ($_.RunAs32Bit -ne 0) { $true } else { $false } } },
                    @{n = 'ScriptBody'; e = { ConvertFrom-Base64 ($_.ScriptBody -replace "^77u/") } } `
                        -ExcludeProperty 'ScriptBody', 'RunAs32Bit', 'EnforceSignatureCheck'
                } elseif ($detectionText.ProductCode) {
                    # it is a MSI detection check
                    $detectionText = $detectionText | select -Property @{n = 'ProductVersionOperator'; e = { _operator $_.ProductVersionOperator } }, '*' -ExcludeProperty 'ProductVersionOperator'
                } else {
                    # it is a file or registry detection check
                    $detectionText = $detectionText | select -Property `
                    @{n = 'DetectionType'; e = { _ruleSubType -type $type -subtype $_.detectionType -value $_.KeyName } },
                    @{n = 'Operator'; e = { _operator -operator $_.operator -type $type } },
                    '*',
                    @{n = 'Check32BitOn64System'; e = { if ($_.Check32BitOn64System -ne 0) { $true } else { $false } } }`
                        -ExcludeProperty 'DetectionType', 'Operator', 'Check32BitOn64System'

                    if ($detectionText.DetectionType -in "File or folder exist", "File or folder does not exist", "Value exists", "Value does not exist") {
                        # Operator and DetectionValue properties are not used for these types, remove them
                        $detectionText = $detectionText | select -Property * -ExcludeProperty Operator, DetectionValue
                    }

                    if ($detectionText.DetectionType -in "Key exists", "Key does not exist") {
                        # Operator, DetectionValue and KeyName properties are not used for these types, remove them
                        $detectionText = $detectionText | select -Property * -ExcludeProperty Operator, DetectionValue, KeyName
                    }
                }

                # add object ($detectionText) properties to the parent object ($detectionRule) a.k.a flatten object structure
                $newProperty = $detectionText.psobject.properties | select name

                $newProperty | % {
                    $propertyName = $_.Name
                    $propertyValue = $detectionText.$propertyName

                    $property.$propertyName = $propertyValue
                }

                New-Object -TypeName PSObject -Property $property
            }
        }

        function _extendedRequirementRules {
            param ($extendedRequirementRules)

            function _requirementType {
                param ($type)

                switch ($type) {
                    0 { "Registry" }
                    2 { "File" }
                    3 { "Script" }
                    default { $type }
                }
            }

            $extendedRequirementRules = $extendedRequirementRules | ConvertFrom-Json

            # enhance the object properties
            $extendedRequirementRules | % {
                $extendedRequirementRule = $_

                $type = _requirementType $extendedRequirementRule.Type

                $property = [ordered]@{
                    Type = $type
                }

                $requirementText = $extendedRequirementRule.RequirementText | ConvertFrom-Json # convert from JSON and select-object in two lines otherwise it behaves strangely

                if ($requirementText.ScriptBody) {
                    # it is a script requirement check
                    $requirementText = $requirementText | select -Property `
                    @{n = 'ReqType'; e = { _ruleSubType -type $type -subtype $_.type -value $_.value } },
                    @{n = 'Operator'; e = { _operator $_.operator } },
                    '*',
                    @{n = 'RunAsLoggedUser'; e = { if ($_.RunAsAccount -ne 0) { $true } else { $false } } },
                    @{n = 'RunAs32Bit'; e = { if ($_.RunAs32Bit -ne 0) { $true } else { $false } } },
                    @{n = 'EnforceSignatureCheck'; e = { if ($_.EnforceSignatureCheck -ne 0) { $true } else { $false } } },
                    @{n = 'ScriptBody'; e = { ConvertFrom-Base64 $_.ScriptBody } } `
                        -ExcludeProperty 'Type', 'Operator', 'ScriptBody', 'RunAs32Bit', 'EnforceSignatureCheck', 'RunAsAccount'
                } else {
                    # it is a file or registry requirement check
                    $requirementText = $requirementText | select -Property `
                    @{n = 'ReqType'; e = { _ruleSubType -type $type -subtype $_.type -value $(if ($_.value) { $_.value } else { $_.keyname }) } },
                    @{n = 'Operator'; e = { _operator $_.operator } },
                    '*',
                    @{n = 'Check32BitOn64System'; e = { if ($_.Check32BitOn64System -ne 0) { $true } else { $false } } }`
                        -ExcludeProperty 'Type', 'Operator', 'Check32BitOn64System'

                    if ($requirementText.ReqType -in "File or folder exist", "File or folder does not exist", "Value exists", "Value does not exist") {
                        # operator and value properties are not used for these types, remove them
                        $requirementText = $requirementText | select -Property * -ExcludeProperty Operator, Value
                    }

                    if ($requirementText.ReqType -in "Key exists", "Key does not exist") {
                        # operator, value and keyname properties are not used for these types, remove them
                        $requirementText = $requirementText | select -Property * -ExcludeProperty Operator, Value, KeyName
                    }
                }

                # add object ($requirementText) properties to the parent object ($extendedRequirementRule) a.k.a flatten object structure
                $newProperty = $requirementText.psobject.properties | select name
                $newProperty | % {
                    $propertyName = $_.Name
                    $propertyValue = $requirementText.$propertyName

                    $property.$propertyName = $propertyValue
                }

                New-Object -TypeName PSObject -Property $property
            }
        }

        function _returnCodes {
            param ($returnCodes)

            function _type {
                param ($type)

                switch ($type) {
                    0 { "Failed" }
                    1 { "Success" }
                    2 { "SoftReboot" }
                    3 { "HardReboot" }
                    4 { "Retry" }
                    default { $type }
                }
            }

            $returnCodes = $returnCodes | ConvertFrom-Json # convert from JSON and select-object in two lines otherwise it behaves strangely

            $returnCodes | select 'ReturnCode', @{n = 'Type'; e = { _type $_.Type } }
        }

        function _installEx {
            param ($installEx)

            function _deviceRestartBehavior {
                param ($deviceRestartBehavior)

                switch ($deviceRestartBehavior) {
                    0 { 'Determine behavior based on return codes' }
                    1 { "App install may force a device restart" }
                    2 { 'No specific action' }
                    3 { 'Intune will force a mandatory device restart' }
                    default { $deviceRestartBehavior }
                }
            }

            $installEx = $installEx | ConvertFrom-Json # convert from JSON and select-object in two lines otherwise it behaves strangely

            $installEx | select -Property `
            @{n = 'RunAs'; e = { if ($_.RunAs -eq 1) { 'System' } else { 'User' } } },
            '*',
            @{n = 'DeviceRestartBehavior'; e = { _deviceRestartBehavior $_.DeviceRestartBehavior } }`
                -ExcludeProperty RunAs, DeviceRestartBehavior
        }

        function _requirementRules {
            param ($requirementRules)

            $requirementRules = $requirementRules | ConvertFrom-Json # convert from JSON and select-object in two lines otherwise it behaves strangely

            $requirementRules | select -Property `
            @{n = 'RequiredOSArchitecture'; e = { if ($_.RequiredOSArchitecture -eq 1) { 'x86' } else { 'x64' } } },
            '*'`
                -ExcludeProperty RequiredOSArchitecture
        }

        function _flatDependencies {
            param ($flatDependencies)

            $flatDependencies | select @{n = 'AutoInstall'; e = { if ($_.Action -eq 10) { $true } else { $false } } }, @{n = 'AppId'; e = { $_.ChildId } }
        }
        #endregion helper functions

        # add properties that gets customized/replaced
        $excludeProperty += 'DetectionRule', 'RequirementRules', 'ExtendedRequirementRules', 'InstallEx', 'ReturnCodes', 'FlatDependencies', 'RebootEx', 'StartDeadlineEx'

        $object | select -Property '*',
        @{n = 'DetectionRule'; e = { _detectionRule $_.DetectionRule } },
        @{n = 'RequirementRules'; e = { _requirementRules $_.RequirementRules } },
        @{n = 'RequirementRulesExtended'; e = { _extendedRequirementRules $_.ExtendedRequirementRules } },
        @{n = 'InstallExtended'; e = { _installEx $_.InstallEx } },
        @{n = 'FlatDependencies'; e = { _flatDependencies $_.FlatDependencies } },
        @{n = 'RebootExtended'; e = { $_.RebootEx } },
        @{n = 'ReturnCodes'; e = { _returnCodes $_.ReturnCodes } },
        @{n = 'StartDeadlineExtended'; e = { $_.StartDeadlineEx } }`
            -ExcludeProperty $excludeProperty
    }
    #endregion helper functions

    # get list of available Intune logs
    $intuneLogList = Get-ChildItem -Path "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs" -Filter "IntuneManagementExtension*.log" -File | sort LastWriteTime -Descending | select -ExpandProperty FullName

    if (!$intuneLogList) {
        Write-Error "Unable to find any Intune log files. Unable to get script content."
        return
    }

    :outerForeach foreach ($intuneLog in $intuneLogList) {
        # how content of the log can looks like
        # <![LOG[Get policies = [{"Id":"56695a77-925a-4....

        Write-Verbose "Searching for Win32Apps processing in '$intuneLog'"

        # get line text where win32apps processing is mentioned
        $param = @{
            Path       = $intuneLog
            Pattern    = ("^" + [regex]::escape('<![LOG[Get policies = [{"Id":'))
            AllMatches = $true
        }

        $matchList = Select-String @param | select -ExpandProperty Line

        if ($matchList.count -gt 1) {
            # get the newest events first
            [array]::Reverse($matchList)
        }

        if ($matchList) {
            foreach ($match in $matchList) {
                # get rid of non-JSON prefix/suffix
                $jsonList = $match -replace [regex]::Escape("<![LOG[Get policies = [") -replace ([regex]::Escape("]]LOG]!>") + ".*")
                # ugly but working solution :D
                $i = 0
                $jsonListSplitted = $jsonList -split '},{"Id":'
                if ($jsonListSplitted.count -gt 1) {
                    # there are multiple JSONs divided by comma, I have to process them one by one
                    $jsonListSplitted | % {
                        # split replaces text that was used to split, I have to recreate it
                        $json = ""
                        if ($i -eq 0) {
                            # first item
                            $json = $_ + '}'
                        } elseif ($i -ne ($jsonListSplitted.count - 1)) {
                            $json = '{"Id":' + $_ + '}'
                        } else {
                            # last item
                            $json = '{"Id":' + $_
                        }

                        ++$i

                        Write-Verbose "Processing:`n$json"

                        # customize converted object (convert base64 to text and JSON to object)
                        _enhanceObject -object ($json | ConvertFrom-Json) -excludeProperty $excludeProperty
                    }
                } else {
                    # there is just one JSON, I can directly convert it to an object
                    # customize converted object (convert base64 to text and JSON to object)

                    Write-Verbose "Processing:`n$jsonList"

                    _enhanceObject -object ($jsonList | ConvertFrom-Json) -excludeProperty $excludeProperty
                }

                if (!$allOccurrences) {
                    # don't continue the search when you already have match
                    break outerForeach
                }
            }
        } else {
            Write-Verbose "There is no data related processing of Win32App. Trying next log."
        }
    }
}

function Get-IntuneLogWin32AppReportingResultData {
    <#
    .SYNOPSIS
    Function for getting Intune Win32Apps reporting data from clients log files ($env:ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension*.log).

    .DESCRIPTION
    Function for getting Intune Win32Apps reporting data from clients log files ($env:ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension*.log).

    Finds data about results reporting of Win32Apps and outputs them into console as an PowerShell object.

    Shows data about application that won't be installed on the client because requirements are not met (such app won't be seen in registry, only in log file).

    .PARAMETER allOccurrences
    Switch for getting all Win32App reportings.
    By default just newest report is returned from the newest Intune log.

    .PARAMETER excludeProperty
    List of properties to exclude.

    .EXAMPLE
    Get-IntuneLogWin32AppReportingResultData

    Get newest reporting data for Win32Apps.

    .NOTES
    Run on Windows client managed using Intune MDM.
    #>

    [CmdletBinding()]
    param (
        [switch] $allOccurrences,

        [string[]] $excludeProperty = ('')
    )

    #region helper functions
    function _enhanceObject {
        param ($object, $excludeProperty)

        #region helper functions
        function _complianceStateMessage {
            param ($complianceStateMessage)

            function _complianceState {
                param ($complianceState)

                switch ($complianceState) {
                    0 { "Unknown" }
                    1 { "Compliant" }
                    2 { "Not compliant" }
                    3 { "Conflict (Not applicable for app deployment)" }
                    4 { "Error" }
                    default { $complianceState }
                }
            }

            function _desiredState {
                param ($desiredState)

                switch ($desiredState) {
                    0	{ "None" }
                    1	{ "NotPresent" }
                    2	{ "Present" }
                    3	{ "Unknown" }
                    4	{ "Available" }
                    default { $desiredState }
                }
            }

            $complianceStateMessage | select Applicability, @{n = 'ComplianceState'; e = { _complianceState $_.ComplianceState } }, @{n = 'DesiredState'; e = { _desiredState $_.DesiredState } }, @{n = 'ErrorCode'; e = { _translateErrorCode  $_.ErrorCode } }, TargetingMethod, InstallContext, TargetType, ProductVersion, AssignmentFilterIds
        }

        function _enforcementStateMessage {
            param ($enforcementStateMessage)

            function _enforcementState {
                param ($enforcementState)

                switch ($enforcementState) {
                    1000	{ "Succeeded" }
                    1003	{ "Received command to install" }
                    2000	{ "Enforcement action is in progress" }
                    2007	{ "App enforcement will be attempted once all dependent apps have been installed" }
                    2008	{ "App has been installed but is not usable until device has rebooted" }
                    2009	{ "App has been downloaded but no installation has been attempted" }
                    3000	{ "Enforcement action aborted due to requirements not being met" }
                    4000	{ "Enforcement action could not be completed due to unknown reason" }
                    5000	{ "Enforcement action failed due to error.  Error code needs to be checked to determine detailed status" }
                    5003	{ "Client was unable to download app content." }
                    5999	{ "Enforcement action failed due to error, will retry immediately." }
                    6000	{ "Enforcement action has not been attempted.  No reason given." }
                    6001	{ "App install is blocked because one or more of the app's dependencies failed to install." }
                    6002	{ "App install is blocked on the machine due to a pending hard reboot." }
                    6003	{ "App install is blocked because one or more of the app's dependencies have requirements which are not met." }
                    6004	{ "App is a dependency of another application and is configured to not automatically install." }
                    6005	{ "App install is blocked because one or more of the app's dependencies are configured to not automatically install." }
                    default { $enforcementState }
                }
            }

            $enforcementStateMessage | select @{n = 'EnforcementState'; e = { _enforcementState $_.EnforcementState } }, @{n = 'ErrorCode'; e = { _translateErrorCode  $_.ErrorCode } }, TargetingMethod
        }

        function _translateErrorCode {
            param ($errorCode)

            if (!$errorCode) { return }

            $errMsg = [ComponentModel.Win32Exception]$errorCode
            if ($errMsg -match "^Unknown error") {
                $errorCode
            } else {
                $errMsg.Message + " ($errorCode)"
            }
        }
        #endregion helper functions

        # add properties that gets customized/replaced
        $excludeProperty += 'ApplicationName', 'AppId', 'ComplianceStateMessage', 'EnforcementStateMessage'

        $object | select -Property @{n = 'Name'; e = { $_.ApplicationName } }, @{n = 'Id'; e = { $_.AppId } }, @{n = 'ComplianceStateMessage'; e = { _complianceStateMessage $_.ComplianceStateMessage } }, @{n = 'EnforcementStateMessage'; e = { _enforcementStateMessage $_.EnforcementStateMessage } }, '*'`
            -ExcludeProperty $excludeProperty
    }
    #endregion helper functions

    # get list of available Intune logs
    $intuneLogList = Get-ChildItem -Path "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs" -Filter "IntuneManagementExtension*.log" -File | sort LastWriteTime -Descending | select -ExpandProperty FullName

    if (!$intuneLogList) {
        Write-Error "Unable to find any Intune log files. Unable to get script content."
        return
    }

    :outerForeach foreach ($intuneLog in $intuneLogList) {
        # how content of the log looks like
        # [Win32App] Sending results to service. session RequestPayload: [{.....

        Write-Verbose "Searching for Win32Apps results in '$intuneLog'"

        # get line text where win32apps results send is mentioned
        $param = @{
            Path       = $intuneLog
            Pattern    = ("^" + [regex]::escape('<![LOG[[Win32App] Sending results to service. session RequestPayload:'))
            AllMatches = $true

        }

        $matchList = Select-String @param | select -ExpandProperty Line
        if ($matchList.count -gt 1) {
            # get the newest events first
            [array]::Reverse($matchList)
        }

        if ($matchList) {
            foreach ($match in $matchList) {
                # get rid of non-JSON prefix/suffix
                $jsonList = $match -replace [regex]::Escape("<![LOG[[Win32App] Sending results to service. session RequestPayload: [") -replace ([regex]::Escape("]]LOG]!>") + ".*")
                # ugly but working solution :D
                $i = 0
                $jsonListSplitted = $jsonList -split '},{"AppId":'
                if ($jsonListSplitted.count -gt 1) {
                    # there are multiple JSONs divided by comma, I have to process them one by one
                    $jsonListSplitted | % {
                        # split replaces text that was used to split, I have to recreate it
                        $json = ""
                        if ($i -eq 0) {
                            # first item
                            $json = $_ + '}'
                        } elseif ($i -ne ($jsonListSplitted.count - 1)) {
                            $json = '{"AppId":' + $_ + '}'
                        } else {
                            # last item
                            $json = '{"AppId":' + $_
                        }

                        ++$i

                        Write-Verbose "Processing:`n$json"

                        # customize converted object (convert base64 to text and JSON to object)
                        _enhanceObject -object ($json | ConvertFrom-Json) -excludeProperty $excludeProperty
                    }
                } else {
                    # there is just one JSON, I can directly convert it to an object
                    # customize converted object (convert base64 to text and JSON to object)

                    Write-Verbose "Processing:`n$jsonList"

                    _enhanceObject -object ($jsonList | ConvertFrom-Json) -excludeProperty $excludeProperty
                }

                if (!$allOccurrences) {
                    # don't continue the search when you already have match
                    break outerForeach
                }
            }
        } else {
            Write-Verbose "There is no data related processing of Win32App. Trying next log."
        }
    }
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

function Invoke-IntuneWin32AppRedeploy {
    <#
    .SYNOPSIS
    Function for forcing redeploy of selected Win32App deployed from Intune.

    .DESCRIPTION
    Function for forcing redeploy of selected Win32App deployed from Intune.

    OutGridView is used to output discovered Apps.

    Redeploy means that corresponding registry keys will be deleted from registry and service IntuneManagementExtension will be restarted.

    .PARAMETER computerName
    Name of remote computer where you want to force the redeploy.

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
    Invoke-IntuneWin32AppRedeploy

    Get and show Win32App(s) deployed from Intune to this computer. Selected ones will be then redeployed.
    IDs of targeted users and apps will be translated using information from local Intune log files.

    .EXAMPLE
    Invoke-IntuneWin32AppRedeploy -computerName PC-01 -getDataFromIntune credential $creds

    Get and show Win32App(s) deployed from Intune to computer PC-01. IDs of apps and targeted users will be translated to corresponding names. Selected ones will be then redeployed.
    #>

    [CmdletBinding()]
    param (
        [string] $computerName,

        [switch] $getDataFromIntune,

        [System.Management.Automation.PSCredential] $credential,

        [string] $tenantId
    )

    if (!(Get-Command Get-IntuneWin32App)) {
        throw "Command Get-IntuneWin32App is missing"
    }

    if (! ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        throw "Run as admin"
         if (!($host.name -match "ISE")) {
         Write-Host ""    
        $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
    }

    #region helper function
    # function gets app GRS hash from Intune log files
    function Get-Win32AppGRSHash {
        param (
            [Parameter(Mandatory = $true)]
            [string] $appId
        )

        $intuneLogList = Get-ChildItem -Path "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs" -Filter "IntuneManagementExtension*.log" -File | sort LastWriteTime -Descending | select -ExpandProperty FullName

        if (!$intuneLogList) {
            Write-Error "Unable to find any Intune log files. Redeploy will probably not work as expected."
            return
        }

        foreach ($intuneLog in $intuneLogList) {
            $appMatch = Select-String -Path $intuneLog -Pattern "\[Win32App\] ExecManager: processing targeted app .+ id='$appId'" -Context 0, 2
            if ($appMatch) {
                foreach ($match in $appMatch) {
                    $hash = ([regex]"\d+:Hash = ([^]]+)\]").Matches($match).captures.groups[1].value
                    if ($hash) {
                        return $hash
                    }
                }
            }
        }

        Write-Verbose "Unable to find App '$appId' GRS hash in any of the Intune log files. Redeploy will probably not work as expected"
    }
    # create helper functions text definition for usage in remote sessions
    $allFunctionDefs = "function Get-Win32AppGRSHash { ${function:Get-Win32AppGRSHash} };"
    #endregion helper function

    #region get deployed Win32Apps
    $param = @{}
    if ($computerName) { $param.computerName = $computerName }
    if ($getDataFromIntune) { $param.getDataFromIntune = $true }
    if ($credential) { $param.credential = $credential }
    if ($tenantId) { $param.tenantId = $tenantId }

    Write-Verbose "Getting deployed Win32Apps"
    $win32App = Get-IntuneWin32App @param
    #endregion get deployed Win32Apps

    if ($win32App) {
        $appToRedeploy = $win32App | Out-GridView -PassThru -Title "Pick app(s) for redeploy"

        #region redeploy selected Win32Apps
        if ($appToRedeploy) {
            $scriptBlock = {
                param ($verbosePref, $allFunctionDefs, $appToRedeploy)

                # inherit verbose settings from host session
                $VerbosePreference = $verbosePref

                # recreate functions from their text definitions
                . ([ScriptBlock]::Create($allFunctionDefs))

                $win32AppKeys = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\IntuneManagementExtension\Win32Apps" -Recurse -Depth 2 | select PSChildName, PSPath, PSParentPath

                $appToRedeploy | % {
                    $appId = $_.id
                    $appName = $_.name
                    $scopeId = $_.scopeId
                    $scope = $_.scope
                    if ($scopeId -eq 'device') { $scopeId = "00000000-0000-0000-0000-000000000000" }
                    if (!$appId) { throw "ID property is missing. Problem is probably in function Get-IntuneWin32App." }
                    if (!$scopeId) { throw "ScopeId property is missing. Problem is probably in function Get-IntuneWin32App." }
                    $txt = $appName
                    if (!$txt) { $txt = $appId }
                    Write-Verbose "Redeploying app $txt (scope $scope)"

                    $win32AppKeyToDelete = $win32AppKeys | ? { $_.PSChildName -Match "^$appId`_\d+" -and $_.PSParentPath -Match "\\$scopeId$" }

                    if ($win32AppKeyToDelete) {
                        $win32AppKeyToDelete | % {
                            Write-Verbose "Deleting $($_.PSPath)"
                            Remove-Item $_.PSPath -Force -Recurse
                        }

                        # GRS key needs to be deleted too https://call4cloud.nl/2022/07/retry-lola-retry/#part1-4
                        $win32AppKeyGRSHash = Get-Win32AppGRSHash $appId
                        if ($win32AppKeyGRSHash) {
                            $win32AppGRSKeys = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\IntuneManagementExtension\Win32Apps\$scopeId\GRS"
                            $win32AppGRSKeyToDelete = $win32AppGRSKeys | ? { $_.PSChildName -eq $win32AppKeyGRSHash }
                            if ($win32AppGRSKeyToDelete) {
                                Write-Verbose "Deleting $($win32AppGRSKeyToDelete.PSPath)"
                                Remove-Item $win32AppGRSKeyToDelete.PSPath -Force -Recurse
                            }
                        }
                    } else {
                        throw "BUG??? App $appId with scope $scopeId wasn't found in the registry"
                    }
                }

                Write-Warning "Invoking redeploy (by removing registry key and restarting service IntuneManagementExtension). Redeploy can take several minutes!"
                Restart-Service IntuneManagementExtension -Force
            }

            $param = @{
                scriptBlock  = $scriptBlock
                argumentList = ($VerbosePreference, $allFunctionDefs, $appToRedeploy)
            }
            if ($computerName) {
                $param.computerName = $computerName
            }

            Invoke-Command @param
        }
        #endregion redeploy selected Win32Apps
    } else {
        Write-Warning "No deployed Win32App detected"
    }
}
Invoke-IntuneWin32AppRedeploy
