#Get ESD files from the Microsoft Creation Tool's list
#This file needs to be updated for each release of Windows
#This will create a table of all of the ESD files from MS, then create a "database" for OSDCloud
#Gary Blok's attempt to help David


$StagingFolder = "$env:TEMP\OSDStaging"
if (!(Test-Path -Path $StagingFolder)){
    new-item -Path $StagingFolder -ItemType Directory | Out-Null
}

$WindowsTable = @(
@{ Version = 'Win1022H2';LocalCab = "Win1022H2.Cab"; URL = "https://download.microsoft.com/download/3/c/9/3c959fca-d288-46aa-b578-2a6c6c33137a/products_win10_20230510.cab.cab"}
@{ Version = 'Win1121H2';LocalCab = "Win1121H2.Cab"; URL = "https://download.microsoft.com/download/1/b/4/1b4e06e2-767a-4c9a-9899-230fe94ba530/products_Win11_20211115.cab"}
@{ Version = 'Win1121H2';LocalCab = "Win1122H2.Cab"; URL = "https://download.microsoft.com/download/b/1/9/b19bd7fd-78c4-4f88-8c40-3e52aee143c2/products_win11_20230510.cab.cab"}
)


#region functions borrowed from HPCMSL
function Invoke-HPPrivateExpandCAB {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)] $cab,
    [Parameter(Mandatory = $true)] $expectedFile
  )
  Write-Verbose "Expanding CAB $cab to $cab.dir"

  $target = "$cab.dir"
  Invoke-HPPrivateSafeRemove -Path $target -Recurse
  Write-Verbose "Expanding $cab to $target"
  $result = New-Item -Force $target -ItemType Directory
  Write-Verbose "Created folder $result"

  $shell = New-Object -ComObject "Shell.Application"
  $exception = $null
  try {
    if (!$?) { $(throw "unable to create $comObject object") }
    $sourceCab = $shell.Namespace($cab).items()
    $DestinationFolder = $shell.Namespace($target)
    $DestinationFolder.CopyHere($sourceCab)
  }
  catch {
    $exception = $_.Exception
  }
  finally {
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject([System.__ComObject]$shell) | Out-Null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
  }

  if ($exception) {
    throw "Failed to decompress $cab. $($exception.Message)."
  }

  $downloadedOk = Test-Path $expectedFile
  if ($downloadedOk -eq $false) {
    throw "Invalid cab file, did not find $expectedFile in contents"
  }
  return $expectedFile
}

function Invoke-HPPrivateSafeRemove {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)] [string[]]$path,
    [Parameter(Mandatory = $false)] [switch]$recurse
  )
  foreach ($p in $path) {
    if (Test-Path $p) {
      Write-Verbose "Removing $p"
      Remove-Item $p -Recurse:$recurse
    }
  }
}
#endregion

#region functions
function Test-WebConnection{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline)]
        # Uri to test
        [System.Uri]
        $Uri = 'google.com'
    )
    $Params = @{
        Method = 'Head'
        Uri = $Uri
        UseBasicParsing = $true
        Headers = @{'Cache-Control'='no-cache'}
    }

    try {
        Write-Verbose "Test-WebConnection OK: $Uri"
        Invoke-WebRequest @Params | Out-Null
        $true
    }
    catch {
        Write-Verbose "Test-WebConnection FAIL: $Uri"
        $false
    }
    finally {
        $Error.Clear()
    }
}

#endregion

$ESDInfo  = @()
ForEach ($Option in $WindowsTable){
    Invoke-WebRequest -Uri $Option.URL -UseBasicParsing -OutFile "$StagingFolder\$($Option.LocalCab)" -ErrorAction SilentlyContinue -Verbose
    $file = Invoke-HPPrivateExpandCAB -cab "$StagingFolder\$($Option.LocalCab)" -expectedFile "$StagingFolder\$($Option.LocalCab).dir\products.xml" -Verbose
    [XML]$XML = Get-Content -Raw -Path "$StagingFolder\$($Option.LocalCab).dir\products.xml"
    $ESDInfo += $XML.MCT.Catalogs.Catalog.PublishedMedia.Files.File
    }

#Clean Up Results
$x64ESDInfo = $ESDInfo | Where-Object {$_.Architecture -eq "x64"}
$x64ESDInfo = $x64ESDInfo | Where-Object {$_.Edition -eq "Professional" -or $_.Edition -eq "Education" -or $_.Edition -eq "Enterprise" -or $_.Edition -eq "Professional" -or $_.Edition -eq "HomePremium"}



Import-Module -Name OSD -Force
#=================================================
#   FeatureUpdates
#=================================================

$Results = $x64ESDInfo
$Results = $Results | Select-Object `
@{Name='Status';Expression={($null)}}, `
@{Name='ReleaseDate';Expression={($null)}}, `
@{Name='Name';Expression={($_.Title)}}, `
@{Name='Version';Expression={($null)}}, `
@{Name='ReleaseID';Expression={($_.null)}}, `
@{Name='Architecture';Expression={($_.Architecture)}}, `
@{Name='Language';Expression={($_.LanguageCode)}}, `
@{Name='Activation';Expression={($null)}}, `
@{Name='Build';Expression={($null)}}, `
@{Name='FileName';Expression={($_.FileName)}}, `
@{Name='ImageIndex';Expression={($null)}}, `
@{Name='ImageName';Expression={($null)}}, `
@{Name='Url';Expression={($_.FilePath)}}, `
@{Name='SHA1';Expression={($_.Sha1)}}, `
@{Name='UpdateID';Expression={($_.UpdateID)}}

foreach ($Result in $Results) {
    #=================================================
    #   
    #=================================================
    if ($Result.FileName -match 'Windows 10') {
        $Result.Version = 'Windows 10'
    }
    if ($Result.Name -match 'Windows 11') {
        $Result.Version = 'Windows 11'
    }
    #=================================================
    #   Language
    #=================================================
    #if ($Result.FileName -match 'sr-latn-rs') {
    #    $Result.Language = 'sr-latn-rs'
    #}
    #else {
    #    $Regex = "[a-zA-Z]+-[a-zA-Z]+"
    #    $Result.Language = ($Result.FileName | Select-String -AllMatches -Pattern $Regex).Matches[0].Value
    #}
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
    #   OS Version
    #=================================================
    if ($Result.Build -lt 22000) {
        $Result.Version = 'Windows 10'
    }
    if ($Result.Name -ge 22000) {
        $Result.Version = 'Windows 11'
    }
    #=================================================
    #   Build
    #=================================================
    $Regex = "[0-9]*\.[0-9]+"
    $Result.Build = ($Result.FileName | Select-String -AllMatches -Pattern $Regex).Matches[0].Value
    #=================================================
    #   ReleaseID
    #=================================================
    if ($Result.Build -match "19045"){$Result.ReleaseID = "22H2"}
    if ($Result.Build -match "22000"){$Result.ReleaseID = "21H2"}
    if ($Result.Build -match "22621"){$Result.ReleaseID = "22H2"}
    if ($Result.Build -match "22631"){$Result.ReleaseID = "23H2"}
    
    #$Result.ReleaseID = (($Result.FileName).Split(".")[3]).Split("_")[0] #worked on some, not others

    #=================================================
    #   Date
    #=================================================
    $DateString = (($Result.FileName).Split(".")[2]).Split("-")[0]
    $Date = [datetime]::parseexact($DateString, 'yyMMdd', $null)
    $Result.ReleaseDate = (Get-Date $Date -Format "yyyy-MM-dd")
    #=================================================
    #   SHA1
    #=================================================
    #$Regex = "[0-9a-f]{40}"
    #$Result.SHA1 = ($Result.FileName | Select-String -AllMatches -Pattern $Regex).Matches[0].Value
    #$Result.SHA1 = ((Split-Path -Leaf $Result.Url) | Select-String -AllMatches -Pattern $Regex).Matches[0].Value
    #=================================================
    #   Name
    #=================================================
    if ($Result.Activation -eq 'Volume') {
        $Result.Name = $Result.Version + ' ' + $Result.ReleaseID + ' x64 ' + $Result.Language + ' Volume ' + $Result.Build
    }
    else {
        $Result.Name = $Result.Version + ' ' + $Result.ReleaseID + ' x64 ' + $Result.Language + ' Retail ' + $Result.Build
    }
    #=================================================
}
$Results = $Results | Sort-Object -Property Name
$Results | Export-Clixml -Path (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\CloudOperatingSystemsMCT.xml") -Force
Import-Clixml -Path (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\CloudOperatingSystemsMCT.xml") | ConvertTo-Json | Out-File (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\CloudOperatingSystemsMCT.json") -Encoding ascii -Width 2000 -Force
#================================================