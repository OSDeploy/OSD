$FeatureUpdates = Get-WSUSXML -Catalog FeatureUpdate
$FeatureUpdates = $FeatureUpdates | Select-Object -Property CreationDate,KBNumber,Title,UpdateOS,UpdateBuild,UpdateArch,FileName,Size,FileUri,Hash,AdditionalHash
$FeatureUpdates | Sort-Object -Property CreationDate -Descending | Export-Clixml "$PSScriptRoot\Catalog.xml"