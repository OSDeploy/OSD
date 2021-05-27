$IMP = Import-Clixml "D:\GitHub\Modules\OSD\Catalogs\FeatureUpdate\Catalogq.xml"

$IMP = $IMP | Select-Object -Property CreationDate,KBNumber,Title,UpdateOS,UpdateBuild,UpdateArch,FileName,Size,FileUri,Hash,AdditionalHash
$IMP | Sort-Object -Property CreationDate -Descending | Export-Clixml "$PSScriptRoot\Catalogx.xml"