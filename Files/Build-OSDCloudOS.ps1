Import-Module -Name OSD -Force
#=================================================
#   Get-FeatureUpdates
#=================================================
$Results = Get-WSUSXML -Catalog FeatureUpdate -Silent
$Results = $Results | Where-Object {$_.UpdateArch -eq 'x64'}
$Results = $Results | Select-Object @{Name='CatalogVersion';Expression={(Get-Date -Format "yy.MM.dd")}}, `
@{Name='Status';Expression={($_.OSDStatus)}}, `
@{Name='ReleaseDate';Expression={(Get-Date $_.CreationDate -Format "yy.MM.dd")}}, `
@{Name='Title';Expression={($_.Title)}}, `
@{Name='OSName';Expression={($null)}}, `
@{Name='OSVersion';Expression={($_.UpdateOS)}}, `
@{Name='OSArchitecture';Expression={($_.UpdateArch)}}, `
@{Name='OSBuild';Expression={($_.UpdateBuild)}}, `
@{Name='OSLanguage';Expression={($null)}}, `
@{Name='OSLicense';Expression={($null)}}, `
@{Name='FileName';Expression={((Split-Path -Leaf $_.FileUri))}}, `
@{Name='Url';Expression={($_.FileUri)}}, `
@{Name='HashSHA1';Expression={($null)}}

foreach ($Result in $Results) {
    $Result.OSName = $Result.OSVersion + ' ' + $Result.OSBuild

    if ($Result.FileName -match 'sr-latn-rs') {
        $Result.OSLanguage = 'sr-latn-rs'
    }
    else {
        $Regex = "[a-zA-Z]+-[a-zA-Z]+"
        $Result.OSLanguage = ($Result.FileName | Select-String -AllMatches -Pattern $Regex).Matches[0].Value
    }

    if ($Result.Title -match 'business') {
        $Result.OSLicense = 'Volume'
    }
    else {
        $Result.OSLicense = 'Retail'
    }

    $Regex = "[0-9a-f]{40}"
    $Result.HashSHA1 = ($Result.FileName | Select-String -AllMatches -Pattern $Regex).Matches[0].Value

    $Result.Title = $Result.OSName + ' ' + $Result.OSLicense + ' ' + $Result.OSLanguage
}

$Results | Export-Clixml -Path (Join-Path (Get-Module OSD).ModuleBase "OSDCloud\os.xml") -Force
Import-Clixml -Path (Join-Path (Get-Module OSD).ModuleBase "OSDCloud\os.xml") | ConvertTo-Json | Out-File (Join-Path (Get-Module OSD).ModuleBase "OSDCloud\os.json") -Force -Encoding ascii
#================================================