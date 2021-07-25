function Get-DownLinks {
    [CmdletBinding()]
    PARAM (
        [Parameter(Position=0,Mandatory=$true)]
        [string]$URL,
        [Parameter(Position=1)]
        [string]$Extension
    )

    Write-Verbose "Validating $URL" -Verbose
    Write-Host ""
    $DownLinks = @()
    $DownLinks = (Invoke-WebRequest -Uri "$URL").Links | Select-Object -Property *
    if ($Extension) {$DownLinks = $DownLinks | Where-Object {$_.href -like "*$Extension"}}
    #$Downlinks = $Downlinks | Select-Object -Property href
    foreach ($DownLink in $DownLinks) {
        if ($DownLink.href -like "/*") {
            $DownLink.href = "http://downloads.dell.com$($DownLink.href)"
        }
    }

    $Downlinks = $Downlinks | Out-GridView -PassThru -Title 'Select Download Links'
    $Downlinks
}