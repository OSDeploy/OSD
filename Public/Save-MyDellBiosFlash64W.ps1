function Save-MyDellBiosFlash64W {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [Alias ('DownloadFolder','Path')]
        [string]$DownloadPath = $env:TEMP
    )

    if ((Get-MyComputerManufacturer -Brief) -eq 'Dell') {
        $GetMyDellBios = Get-MyDellBios
        if ($GetMyDellBios) {
            if (Test-WebConnection -Uri $GetMyDellBios.Flash64W) {
                $SaveMyDellBiosFlash64W = Save-OSDDownload -SourceUrl $GetMyDellBios.Flash64W -DownloadFolder "$DownloadPath"
                Expand -R "$($SaveMyDellBiosFlash64W.FullName)" -F:* "$DownloadPath" | Out-Null
                if (Test-Path (Join-Path $DownloadPath 'Flash64W.exe')) {
                    Get-Item (Join-Path $DownloadPath 'Flash64W.exe')
                }
            }
            else {
                Write-Warning "Could not verify an Internet connection for the Dell Bios"
            }
        }
        else {
            Write-Warning "Unable to determine a suitable Bios update for this Computer Model"
        }
    }
}