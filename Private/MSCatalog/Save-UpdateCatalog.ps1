function Save-UpdateCatalog {
    <#
        .SYNOPSIS
        Download an update file from catalog.update.micrsosoft.com.

        .PARAMETER Update
        Specify the update to be downloaded.
        The update object is retrieved using the Get-MSCatalogUpdate function.

        .PARAMETER Guid
        Specify the Guid for the update to be downloaded.
        The Guid is retrieved using the Get-MSCatalogUpdate function.

        .PARAMETER Destination
        Specify the destination directory to download the update to.

        .PARAMETER Language
        Some updates are available in multiple languages. By default this function will list all available
        files for a specific update and prompt you to select the one to download. If you wish to remove
        this prompt you can specify a language-country code combination e.g. "en-us".

        .PARAMETER UseBits
        If using a Windows system you can use this parameter to download the update using BITS.

        .EXAMPLE
        $Update = Get-MSCatalogUpdate -Search "KB4515384"
        Save-MSCatalogUpdate -Update $Update -Destination C:\Windows\Temp\

        .EXAMPLE
        Save-MSCatalogUpdate -Guid "5570183b-a0b7-4478-b0af-47a6e65417ca" -Destination C:\Windows\Temp\

        .EXAMPLE
        $Update = Get-MSCatalogUpdate -Search "KB4515384"
        Save-MSCatalogUpdate -Update $Update -Destination C:\Windows\Temp\ -Language "en-us"

        .EXAMPLE
        $Update = Get-MSCatalogUpdate -Search "KB4515384"
        Save-MSCatalogUpdate -Update $Update -Destination C:\Windows\Temp\ -UseBits
    #>
    
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = "Guid"
        )]
        [String] $Guid,

        [String] $DestinationDirectory = $env:TEMP
    )

    if ($Update) {
        $Guid = $Update.Guid
    }
    $Links = Get-UpdateLinks -Guid $Guid
    if ($Links.Matches.Count -eq 1) {
        $Link = $Links.Matches[0]

        Write-Host -ForegroundColor DarkGray "DownloadUrl: $($Link.Value)"

        $SaveWebFile = Save-WebFile -SourceUrl $Link.Value -DestinationDirectory "$DestinationDirectory" -DestinationName $Link.Value.Split('/')[-1]
        $SaveWebFile
    }
    else {
        Write-Host "Id  FileName`r"
        Write-Host "--  --------"
        foreach ($Link in $Links.Matches) {
            $Id = $Links.Matches.IndexOf($Link)
            $FileName = $Link.Value.Split('/')[-1]
            if ($Id -lt 10) {
                Write-Host " $Id  $FileName`r"
            }
            else {
                Write-Host "$Id  $FileName`r"
            }
        }
        $SelectedId = Read-Host "Multiple files exist for this update. Enter the Id of the file to download or 'A' to download all files."
        $ToDownload = @()
        if ($SelectedId -like "A") {
            foreach ($Link in $Links.Matches) {
                $ToDownload += $Link.Value
            }
        }
        else {
            $ToDownload += $Links.Matches[$SelectedId].Value
        }

        foreach ($Item in $ToDownload) {
            $SaveWebFile = Save-WebFile -SourceUrl $Item -DestinationDirectory "$DestinationDirectory" -DestinationName $Item.Split('/')[-1]
        }
    }
}