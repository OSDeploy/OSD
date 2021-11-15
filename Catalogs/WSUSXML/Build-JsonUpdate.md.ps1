$AllUpdates = @()
$AllCatalogs = Get-ChildItem -Path "$PSScriptRoot\*" -Include '*.json' -Recurse
foreach ($CatalogFile in $AllCatalogs) {
    $AllUpdates += Get-Content $CatalogFile.FullName | ConvertFrom-Json
}

$AllUpdates = $AllUpdates | Select-Object -Property * | Sort-Object -Property Title -Unique | Sort-Object CreationDate -Descending
Write-Host ""
$AllUpdates | Select-Object -Property CreationDate, KBNumber, Title | Sort @{Expression = {$_.CreationDate}; Ascending = $false}, KBNumber, Title | Out-File D:\GitHub\Modules\OSD\UPDATES.md
