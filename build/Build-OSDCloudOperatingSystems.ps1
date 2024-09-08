#Requires -RunAsAdministrator

# Import OSD Module
Import-Module OSD -Force -ErrorAction Stop

#=================================================
#   FeatureUpdates
#=================================================
$Results = Get-WSUSXML -Catalog FeatureUpdate -Silent
$Results = $Results | Where-Object {$_.UpdateArch -eq 'x64'}
$Results = $Results | Select-Object `
@{Name='Catalog';Expression={('OS')}}, `
@{Name='Updated';Expression={(Get-Date -Format "yyyy-MM-dd")}}, `
@{Name='Status';Expression={($_.OSDStatus)}}, `
@{Name='Released';Expression={(Get-Date $_.CreationDate -Format "yyyy-MM-dd")}}, `
@{Name='Name';Expression={($_.Title)}}, `
@{Name='OS';Expression={($null)}}, `
@{Name='Version';Expression={($_.UpdateBuild)}}, `
@{Name='Build';Expression={($null)}}, `
@{Name='Arch';Expression={($_.UpdateArch)}}, `
@{Name='Language';Expression={($null)}}, `
@{Name='Activation';Expression={($null)}}, `
@{Name='FileName';Expression={((Split-Path -Leaf $_.FileUri))}}, `
@{Name='ImageIndex';Expression={($null)}}, `
@{Name='ImageName';Expression={($null)}}, `
@{Name='Url';Expression={($_.FileUri)}}, `
@{Name='SHA1';Expression={($null)}}, `
@{Name='UpdateID';Expression={($_.UpdateID)}}, `
@{Name='Win10';Expression={($null)}}, `
@{Name='Win11';Expression={($null)}}

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
        $Result.Win10 = $true
        $Result.Win11 = $false
    }
    if ($Result.Name -match 'Windows 11') {
        $Result.OS = 'Windows 11'
        $Result.Win10 = $false
        $Result.Win11 = $true
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
        $Result.Name = $Result.OS + ' ' + $Result.Version + ' x64 ' + $Result.Language + ' business editions ' + $Result.Build
    }
    else {
        $Result.Name = $Result.OS + ' ' + $Result.Version + ' x64 ' + $Result.Language + ' consumer editions ' + $Result.Build
    }
    #=================================================
}
$Results = $Results | Sort-Object -Property Name
$Results | Export-Clixml -Path (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\CloudOperatingSystems.xml") -Force
Import-Clixml -Path (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\CloudOperatingSystems.xml") | ConvertTo-Json | Out-File (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\CloudOperatingSystems.json") -Encoding ascii -Width 2000 -Force
#================================================