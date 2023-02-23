Import-Module -Name OSD -Force
#=================================================
#   Get-FeatureUpdates
#=================================================
$Results = Get-WSUSXML -Catalog FeatureUpdate -Silent
$Results = $Results | Where-Object {$_.UpdateArch -eq 'x64'}
$Results = $Results | Select-Object `
@{Name='Status';Expression={($null)}}, `
@{Name='ReleaseDate';Expression={(Get-Date $_.CreationDate -Format "yyyy-MM-dd")}}, `
@{Name='Name';Expression={($_.Title)}}, `
@{Name='OS';Expression={($null)}}, `
@{Name='Version';Expression={($_.UpdateBuild)}}, `
@{Name='Arch';Expression={($_.UpdateArch)}}, `
@{Name='Language';Expression={($null)}}, `
@{Name='Activation';Expression={($null)}}, `
@{Name='Build';Expression={($null)}}, `
@{Name='FileName';Expression={((Split-Path -Leaf $_.FileUri))}}, `
@{Name='ImageIndex';Expression={($null)}}, `
@{Name='ImageName';Expression={($null)}}, `
@{Name='Url';Expression={($_.FileUri)}}, `
@{Name='SHA1';Expression={($null)}}, `
@{Name='UpdateID';Expression={($_.UpdateID)}}

foreach ($Result in $Results) {
    #=================================================
    #   Language
    #=================================================
    if ($Result.FileName -match 'sr-latn-rs') {
        $Result.Language = 'sr-latn-rs'
    }
    else {
        $Regex = "[a-zA-Z]+-[a-zA-Z]+"
        $Result.Language = ($Result.FileName | Select-String -AllMatches -Pattern $Regex).Matches[0].Value
    }
    #=================================================
    #   Activation
    #=================================================
    if ($Result.Url -match 'business') {
        $Result.Activation = 'Volume'
    }
    else {
        $Result.Activation = 'Retail'
    }
    #=================================================
    #   OS
    #=================================================
    if ($Result.Name -match 'Windows 10') {
        $Result.OS = 'Windows 10'
    }
    if ($Result.Name -match 'Windows 11') {
        $Result.OS = 'Windows 11'
    }
    #=================================================
    #   Build
    #=================================================
    $Regex = "[0-9]*\.[0-9]+"
    $Result.Build = ($Result.FileName | Select-String -AllMatches -Pattern $Regex).Matches[0].Value
    #=================================================
    #   SHA1
    #=================================================
    $Regex = "[0-9a-f]{40}"
    $Result.SHA1 = ($Result.FileName | Select-String -AllMatches -Pattern $Regex).Matches[0].Value
    #=================================================
    #   Name
    #=================================================
    if ($Result.Activation -eq 'Volume') {
        $Result.Name = $Result.OS + ' ' + $Result.Version + ' x64 ' + $Result.Language + ' Volume ' + $Result.Build
    }
    else {
        $Result.Name = $Result.OS + ' ' + $Result.Version + ' x64 ' + $Result.Language + ' Retail ' + $Result.Build
    }
    #=================================================
}
$Results = $Results | Sort-Object -Property Name
$Results | Export-Clixml -Path (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\operatingsystemsv2.xml") -Force
Import-Clixml -Path (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\operatingsystemsv2.xml") | ConvertTo-Json | Out-File (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\operatingsystemsv2.json") -Encoding ascii -Width 2000 -Force
#================================================