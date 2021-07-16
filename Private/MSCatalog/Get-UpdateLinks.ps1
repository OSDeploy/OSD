function Get-UpdateLinks {
    [CmdLetBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0
        )]
        [String] $Guid
    )

    $Post = @{size = 0; updateID = $Guid; uidInfo = $Guid} | ConvertTo-Json -Compress
    $Body = @{updateIDs = "[$Post]"}

    $Params = @{
        Uri = "https://www.catalog.update.microsoft.com/DownloadDialog.aspx"
        Method = "Post"
        Body = $Body
        ContentType = "application/x-www-form-urlencoded"
        UseBasicParsing = $true
    }
    $DownloadDialog = Invoke-WebRequest @Params
    $Links = $DownloadDialog.Content.Replace("www.download.windowsupdate", "download.windowsupdate")
    $Regex = "(http[s]?\://dl\.delivery\.mp\.microsoft\.com\/[^\'\""]*)|(http[s]?\://download\.windowsupdate\.com\/[^\'\""]*)"
    $Links = $Links | Select-String -AllMatches -Pattern $Regex
    $Links
}