<#
.SYNOPSIS
Gets a list of links to download
.DESCRIPTION
Gets a list of links to download
.LINK
https://osd.osdeploy.com
#>
function Get-DownLinks
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position=0,Mandatory)]
        # Uri to get download to download
        [System.String]
        $Url,

        [Parameter(Position=1)]
        # File extension of the links to get
        [System.String]
        $Extension
    )

    $DownLinks = @()
    $DownLinks = (Invoke-WebRequest -Uri "$URL").Links | Select-Object -Property *
    if ($Extension)
    {
        $DownLinks = $DownLinks | Where-Object {$_.href -like "*$Extension"}
    }
    
    #$Downlinks = $Downlinks | Select-Object -Property href
    foreach ($DownLink in $DownLinks)
    {
        if ($DownLink.href -like "/*")
        {
            $DownLink.href = "http://downloads.dell.com$($DownLink.href)"
        }
    }

    $Downlinks = $Downlinks | Out-GridView -PassThru -Title 'Select Download Links'
    $Downlinks
}