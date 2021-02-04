$WinUserLanguageList = Get-WinUserLanguageList

$LanguageList = foreach ($Item in $WinUserLanguageList) {
    [PSCustomObject] @{
        Culture         = $Item.LanguageTag
        Language        = ($Item.LanguageTag -split "-")[0]
        Localization    = ($Item.LanguageTag -split "-")[1]
    }
}


Write-Host "Installed Cultures:" -ForegroundColor Cyan
foreach ($item in $LanguageList) {
    Write-Host "$($Item.Culture)"
}
Write-Host "Installed Languages:" -ForegroundColor Cyan
foreach ($item in $LanguageList) {
    Write-Host "$($Item.Language)"
}
Write-Host "Installed Localizations:" -ForegroundColor Cyan
foreach ($item in $LanguageList) {
    Write-Host "$($Item.Localization)"
}
pause