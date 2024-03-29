function Get-HPDeviceFamilyPlatformDetails {
    [CmdletBinding(DefaultParameterSetName='Family')]
    param (
        [parameter(Mandatory=$false,
        ParameterSetName="Family")]
        [String]
        $biosFamily,

        [parameter(Mandatory=$false,
        ParameterSetName="SystemID")]
        [String]
        $platform    

    )
    #$PSCmdlet.ParameterSetName
    $ConnectPlatformsURL = 'https://hpconnectformem-prod.hpbp.io/platforms'
    if (Test-WebConnection){
        $content = (invoke-webrequest -Uri $ConnectPlatformsURL).content | Convertfrom-Json

        if ($biosFamily){
            
            $Content | Where-Object {$_.biosFamily -eq $biosFamily}
        }
        elseif ($platform){
            $Content | Where-Object {$_.systemId -eq $platform}
        }
        else{
            $content
        }
    }
    else {
        Write-Output "This function requires internet connection"
    }
}
