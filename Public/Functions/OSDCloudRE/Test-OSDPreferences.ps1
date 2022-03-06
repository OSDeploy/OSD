function Test-OSDPreferences {
    [CmdletBinding()]
    param (
        [ValidateSet({[string]$Global:ValidateOSName})]
        #Operating System Name. Default is 'Windows 11 21H2'
        [System.String]
        $OSName
    )

    $OSName
}