function Test-MyDellDriverCabWebConnection {
    [CmdletBinding()]
    param ()
    
    $GetMyDellDriverCab = Get-MyDellDriverCab
    if ($GetMyDellDriverCab) {
        Test-WebConnection -Uri $GetMyDellDriverCab.DriverUrl
    } else {
        Return $false
    }
}