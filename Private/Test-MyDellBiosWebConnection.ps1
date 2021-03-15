function Test-MyDellBiosWebConnection {
    [CmdletBinding()]
    param ()
    
    $GetMyDellBios = Get-MyDellBios
    if ($GetMyDellBios) {
        Test-WebConnection -Uri $GetMyDellBios.Url
    } else {
        Return $false
    }
}