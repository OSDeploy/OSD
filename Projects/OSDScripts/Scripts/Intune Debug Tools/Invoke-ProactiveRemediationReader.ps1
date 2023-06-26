function Get-IntuneLogRemediationScriptData {
    <#
    .SYNOPSIS
    Function for getting Intune Remediation Scripts information from clients log files ($env:ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension*.log).

    .DESCRIPTION
    Function for getting Intune Remediation Scripts information from clients log files ($env:ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension*.log).

    Finds data about processing of Remediation Scripts and outputs them into console as an PowerShell object.

    .PARAMETER allOccurrences
    Switch for getting all Remediation Scripts processings.
    By default just newest processing is returned from the newest Intune log.

    .PARAMETER excludeProperty
    List of properties to exclude.

    By default: 'EncryptedPolicyBody', 'EncryptedRemediationScript', 'PolicyBodySize', 'PolicyHash', 'RemediateScriptHash', 'ContentSignature'

    Reason for exclude is readability and the fact that I didn't find any documentation that would help me interpret their values or are always empty.

    .EXAMPLE
    Get-IntuneLogRemediationScriptData

    Show various interesting information about Remediation scripts processing.

    .NOTES
    Run on Windows client managed using Intune MDM.
    #>

    [CmdletBinding()]
    param (
        [switch] $allOccurrences,

        [string[]] $excludeProperty = ('EncryptedPolicyBody', 'EncryptedRemediationScript', 'PolicyBodySize', 'PolicyHash', 'RemediateScriptHash', 'ContentSignature')
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
        function _lastPolicyRun {
            #TODO always returns newest run time a.k.a. will be confusing when allOccurrences will be used
            param ($policyId)

            # get line text where script run is mentioned
            # line can look like this
            # <![LOG[[HS] Daily handler: last execution time for 29455f83-3916-4069-88ba-a8e51633e34a is 21.09.2022 6:55:46]
            $param = @{
                Path       = $intuneLog
                Pattern    = ("^" + [regex]::escape('<![LOG[[HS] Daily handler: last execution time for ') + $policyId)
                AllMatches = $true
            }

            $match = Select-String @param | select -ExpandProperty Line -Last 1

            if ($match) {
                Get-Date (([regex]"$policyId is ([0-9.: ]+)").Match($match).groups[1].value)
            } else {
                Write-Verbose "No run of remediation policy $policyId was found"
            }
        }
        #endregion helper functions

        # add properties that gets customized/replaced
        $excludeProperty += 'PolicyBody', 'RemediationScript', 'ExecutionContext'

        $object | select -Property '*',
        @{n = 'LastPolicyRun'; e = { _lastPolicyRun $_.PolicyId } },
        @{n = 'RunAsLoggedUser'; e = { if ($_.ExecutionContext -eq 1) { $true } else { $false } } },
        @{n = 'DetectionScript'; e = { ConvertFrom-Base64 $_.PolicyBody } },
        @{n = 'RemediationScript'; e = { ConvertFrom-Base64 $_.RemediationScript } }`
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
        # <![LOG[[HS] Get policies = [{"AccountId":"db89...0e0ea", "PolicyId":"29455f80...51633e34a", "PolicyType":6, "DocumentSchemaVersion":"1.0", "PolicyHash":"46669E9D4716AD19626DAEECE85B05F1E1F2A7B8C0716109F9F8B10EFA3CF447", "PolicyBody":"PCMNCgkuTk9URV.........

        Write-Verbose "Searching for Script processing in '$intuneLog'"

        # get line text where win32apps processing is mentioned
        $param = @{
            Path       = $intuneLog
            Pattern    = ("^" + [regex]::escape('<![LOG[[HS] Get policies = [{"AccountId":'))
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
                $jsonList = $match -replace [regex]::Escape("<![LOG[[HS] Get policies = [") -replace ([regex]::Escape("]]LOG]!>") + ".*")
                # ugly but working solution :D
                $i = 0
                $jsonListSplitted = $jsonList -split '},{"AccountId":'
                if ($jsonListSplitted.count -gt 1) {
                    # there are multiple JSONs divided by comma, I have to process them one by one
                    $jsonListSplitted | % {
                        # split replaces text that was used to split, I have to recreate it
                        $json = ""
                        if ($i -eq 0) {
                            # first item
                            $json = $_ + '}'
                        } elseif ($i -ne ($jsonListSplitted.count - 1)) {
                            $json = '{"AccountId":' + $_ + '}'
                        } else {
                            # last item
                            $json = '{"AccountId":' + $_
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

Get-IntuneLogRemediationScriptData | Out-File $env:temp\LogRemediation.log

 if (!($host.name -match "ISE")) {
    	Write-Host "* PROACTIVE REMEDIATION LOG CREATED *" -ForegroundColor Yellow
	Write-Host "Log containing all scripts: " -NoNewline
	Write-Host "$env:temp\LogRemediation.log" -ForegroundColor Green
    	Write-Host "Press any key to continue, the log will open automatically"

    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

start "$env:temp\LogRemediation.log" -WindowStyle Maximized