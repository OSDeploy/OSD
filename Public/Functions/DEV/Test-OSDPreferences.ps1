function Test-OSDPreferences {
    [CmdletBinding()]
    param (
        [ValidateSet({[string]$Global:ValidateOSName})]
        #Operating System Name. Default is 'Windows 11 22H2'
        [System.String]
        $OSName
    )

    $OSName
}