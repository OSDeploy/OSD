#======================================================================================
#   Installed Languages
#======================================================================================
Write-Host "======================================================================================"
$OSMUILanguages = $((Get-WmiObject -Class Win32_OperatingSystem).MUILanguages)

$InstalledLanguagePacks = foreach ($Item in $OSMUILanguages) {
    [PSCustomObject] @{
        LanguagePack    = $Item
        Language        = ($Item -split "-")[0]
        Localization    = ($Item -split "-")[1]
    }
}

$InstalledLanguagePacks | Out-GridView

pause

Write-Host "Installed Language Packs:" -ForegroundColor Cyan
foreach ($item in $InstalledLanguagePacks) {
    Write-Host "$($Item.LanguagePack)"
}
Write-Host "Installed Languages:" -ForegroundColor Cyan
foreach ($item in $InstalledLanguagePacks) {
    Write-Host "$($Item.Language)"
}
Write-Host "Installed Localizations:" -ForegroundColor Cyan
foreach ($item in $InstalledLanguagePacks) {
    Write-Host "$($Item.Localization)"
}
pause