function Save-MyDellBios {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [Alias ('DownloadFolder','Path')]
        [string]$DownloadPath = $env:TEMP
    )

    if ((Get-MyComputerManufacturer -Brief) -eq 'Dell') {
        $GetMyDellBios = Get-MyDellBios
        if ($GetMyDellBios) {
            if (Test-MyDellBiosWebConnection) {
                $SaveMyDellBios = Save-OSDDownload -SourceUrl $GetMyDellBios.Url -DownloadFolder "$DownloadPath"
                if (Test-Path $SaveMyDellBios.FullName) {
                    Get-Item $SaveMyDellBios.FullName
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