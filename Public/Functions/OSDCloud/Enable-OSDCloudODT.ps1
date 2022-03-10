function Enable-OSDCloudODT {
    <#
    .SYNOPSIS
    Enables ODT Support in an OSDCloud Workspace

    .DESCRIPTION
    Enables ODT Support in an OSDCloud Workspace

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    
    [CmdletBinding()]
    param ()
    #=================================================
    #	Start the Clock
    #=================================================
    $ODTStartTime = Get-Date
    #=================================================
    #	Blocks
    #=================================================
    Block-WinPE
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    Block-NoCurl
    #=================================================
    #	Get-OSDCloudTemplate
    #=================================================
    if (-NOT (Get-OSDCloudTemplate)) {
        Write-Warning "Setting up a new OSDCloudTemplate"
        New-OSDCloudTemplate -Verbose
    }

    $OSDCloudTemplate = Get-OSDCloudTemplate
    if (-NOT ($OSDCloudTemplate)) {
        Write-Warning "Something bad happened.  I have to go"
        Break
    }
    #=================================================
    #	Set WorkspacePath
    #=================================================
    $WorkspacePath = Get-OSDCloudWorkspace -ErrorAction Stop
    #=================================================
    #	Setup Workspace
    #=================================================
    if (-NOT ($WorkspacePath)) {
        Write-Warning "You need to provide a path to your Workspace with one of the following examples"
        Write-Warning "Set-OSDCloudWorkspace -WorkspacePath C:\OSDCloud"
        Break
    }

    if (-NOT (Test-Path $WorkspacePath)) {
        New-OSDCloudWorkspace -WorkspacePath $WorkspacePath -Verbose -ErrorAction Stop
    }

    if (-NOT (Test-Path "$WorkspacePath\Media")) {
        New-OSDCloudWorkspace -WorkspacePath $WorkspacePath -Verbose -ErrorAction Stop
    }

    if (-NOT (Test-Path "$WorkspacePath\Media\sources\boot.wim")) {
        Write-Warning "Nothing is going well for you today my friend"
        Break
    }
#=================================================
#	O365ProPlusRetail Configurations
#=================================================
$O365ProPlusRetailCurrent = @'
<Configuration ID="4d85475a-3aea-4fcb-877a-85841651fb69">
  <Add OfficeClientEdition="64" Channel="Current">
    <Product ID="O365ProPlusRetail">
      <Language ID="MatchOS" />
      <ExcludeApp ID="Groove" />
    </Product>
  </Add>
  <Property Name="SharedComputerLicensing" Value="0" />
  <Property Name="SCLCacheOverride" Value="0" />
  <Property Name="AUTOACTIVATE" Value="0" />
  <Property Name="FORCEAPPSHUTDOWN" Value="FALSE" />
  <Property Name="DeviceBasedLicensing" Value="0" />
  <Updates Enabled="TRUE" />
  <RemoveMSI />
  <Display Level="Full" AcceptEULA="TRUE" />
</Configuration>
'@
$O365ProPlusRetailMonthlyEnterprise = @'
<Configuration ID="002634c3-bedd-416a-82ea-764d564ec07a">
  <Add OfficeClientEdition="64" Channel="MonthlyEnterprise">
    <Product ID="O365ProPlusRetail">
      <Language ID="MatchOS" />
      <ExcludeApp ID="Groove" />
    </Product>
  </Add>
  <Property Name="SharedComputerLicensing" Value="0" />
  <Property Name="SCLCacheOverride" Value="0" />
  <Property Name="AUTOACTIVATE" Value="0" />
  <Property Name="FORCEAPPSHUTDOWN" Value="FALSE" />
  <Property Name="DeviceBasedLicensing" Value="0" />
  <Updates Enabled="TRUE" />
  <RemoveMSI />
  <Display Level="Full" AcceptEULA="TRUE" />
</Configuration>
'@
$O365ProPlusRetailSemiAnnual = @'
<Configuration ID="4c075323-cc94-4689-85d1-43719cc99f01">
  <Add OfficeClientEdition="64" Channel="SemiAnnual">
    <Product ID="O365ProPlusRetail">
      <Language ID="MatchOS" />
      <ExcludeApp ID="Groove" />
    </Product>
  </Add>
  <Property Name="SharedComputerLicensing" Value="0" />
  <Property Name="SCLCacheOverride" Value="0" />
  <Property Name="AUTOACTIVATE" Value="0" />
  <Property Name="FORCEAPPSHUTDOWN" Value="FALSE" />
  <Property Name="DeviceBasedLicensing" Value="0" />
  <Updates Enabled="TRUE" />
  <RemoveMSI />
  <Display Level="Full" AcceptEULA="TRUE" />
</Configuration>
'@
$O365ProPlusRetailSemiAnnualPreview = @'
<Configuration ID="3d9984f2-c89e-4b93-93c4-4415f960cbe0">
  <Add OfficeClientEdition="64" Channel="SemiAnnualPreview">
    <Product ID="O365ProPlusRetail">
      <Language ID="MatchOS" />
      <ExcludeApp ID="Groove" />
    </Product>
  </Add>
  <Property Name="SharedComputerLicensing" Value="0" />
  <Property Name="SCLCacheOverride" Value="0" />
  <Property Name="AUTOACTIVATE" Value="0" />
  <Property Name="FORCEAPPSHUTDOWN" Value="FALSE" />
  <Property Name="DeviceBasedLicensing" Value="0" />
  <Updates Enabled="TRUE" />
  <RemoveMSI />
  <Display Level="Full" AcceptEULA="TRUE" />
</Configuration>
'@
$ProPlus2019Volume = @'
<Configuration ID="fbce83bd-7a92-4627-84e5-c08baf3dc13d">
  <Add OfficeClientEdition="64" Channel="PerpetualVL2019">
    <Product ID="ProPlus2019Volume" PIDKEY="NMMKJ-6RK4F-KMJVX-8D9MJ-6MWKP">
      <Language ID="MatchOS" />
      <ExcludeApp ID="Groove" />
    </Product>
  </Add>
  <Property Name="SharedComputerLicensing" Value="0" />
  <Property Name="SCLCacheOverride" Value="0" />
  <Property Name="AUTOACTIVATE" Value="0" />
  <Property Name="FORCEAPPSHUTDOWN" Value="FALSE" />
  <Property Name="DeviceBasedLicensing" Value="0" />
  <Updates Enabled="TRUE" />
  <RemoveMSI />
  <Display Level="Full" AcceptEULA="TRUE" />
</Configuration>
'@
    #=================================================
    #	Enable OSDCloud ODT
    #=================================================
    if (Test-WebConnection -Uri 'https://www.microsoft.com/en-us/download') {
        $ODTPageLinks = (Invoke-WebRequest -Uri 'https://www.microsoft.com/en-us/download/confirmation.aspx?id=49117' -UseBasicParsing).Links
        $ODTDownload = ($ODTPageLinks | Where-Object {$_.outerHTML -like "*click here to download manually*"}).href

        Write-Verbose "Downloading $ODTDownload"
        $ODTFile = Save-WebFile -SourceUrl $ODTDownload -DestinationDirectory "$WorkspacePath\ODT" -Overwrite

        #Create Paths
        if (!(Test-Path "$WorkspacePath\ODT\O365ProPlusRetail\Current")) {New-Item -Path "$WorkspacePath\ODT\O365ProPlusRetail\Current" -ItemType Directory -Force | Out-Null}
        if (!(Test-Path "$WorkspacePath\ODT\O365ProPlusRetail\MonthlyEnterprise")) {New-Item -Path "$WorkspacePath\ODT\O365ProPlusRetail\MonthlyEnterprise" -ItemType Directory -Force | Out-Null}
        if (!(Test-Path "$WorkspacePath\ODT\O365ProPlusRetail\SemiAnnual")) {New-Item -Path "$WorkspacePath\ODT\O365ProPlusRetail\SemiAnnual" -ItemType Directory -Force | Out-Null}
        if (!(Test-Path "$WorkspacePath\ODT\O365ProPlusRetail\SemiAnnualPreview")) {New-Item -Path "$WorkspacePath\ODT\O365ProPlusRetail\SemiAnnualPreview" -ItemType Directory -Force | Out-Null}
        if (!(Test-Path "$WorkspacePath\ODT\ProPlus2019Volume\PerpetualVL2019")) {New-Item -Path "$WorkspacePath\ODT\ProPlus2019Volume\PerpetualVL2019" -ItemType Directory -Force | Out-Null}

        $O365ProPlusRetailCurrent | Out-File -FilePath "$WorkspacePath\ODT\O365ProPlusRetail\Current\OSD M365 Current.xml" -Encoding utf8
        $O365ProPlusRetailMonthlyEnterprise | Out-File -FilePath "$WorkspacePath\ODT\O365ProPlusRetail\MonthlyEnterprise\OSD M365 Monthly Enterprise.xml" -Encoding utf8
        $O365ProPlusRetailSemiAnnual | Out-File -FilePath "$WorkspacePath\ODT\O365ProPlusRetail\SemiAnnual\OSD M365 Semi-Annual.xml" -Encoding utf8
        $O365ProPlusRetailSemiAnnualPreview | Out-File -FilePath "$WorkspacePath\ODT\O365ProPlusRetail\SemiAnnualPreview\OSD M365 Semi-Annual Preview.xml" -Encoding utf8
        $ProPlus2019Volume | Out-File -FilePath "$WorkspacePath\ODT\ProPlus2019Volume\PerpetualVL2019\OSD Office Professional Plus 2019.xml" -Encoding utf8

        if (Test-Path $ODTFile.FullName) {
            Write-Verbose "Expanding $($ODTFile.FullName) to $WorkspacePath\ODT\O365ProPlusRetail\Current"
            & $ODTFile.FullName /quiet /extract:"$WorkspacePath\ODT\O365ProPlusRetail\Current"

            Write-Verbose "Expanding $($ODTFile.FullName) to $WorkspacePath\ODT\O365ProPlusRetail\MonthlyEnterprise"
            & $ODTFile.FullName /quiet /extract:"$WorkspacePath\ODT\O365ProPlusRetail\MonthlyEnterprise"

            Write-Verbose "Expanding $($ODTFile.FullName) to $WorkspacePath\ODT\O365ProPlusRetail\SemiAnnual"
            & $ODTFile.FullName /quiet /extract:"$WorkspacePath\ODT\O365ProPlusRetail\SemiAnnual"

            Write-Verbose "Expanding $($ODTFile.FullName) to $WorkspacePath\ODT\O365ProPlusRetail\SemiAnnualPreview"
            & $ODTFile.FullName /quiet /extract:"$WorkspacePath\ODT\O365ProPlusRetail\SemiAnnualPreview"

            Write-Verbose "Expanding $($ODTFile.FullName) to $WorkspacePath\ODT\ProPlus2019Volume\PerpetualVL2019"
            & $ODTFile.FullName /quiet /extract:"$WorkspacePath\ODT\ProPlus2019Volume\PerpetualVL2019"
        }

        Start-Sleep -Seconds 3

        Get-ChildItem -Path "$WorkspacePath\ODT\" -Include 'configuration-Office365-x64.xml' -Recurse | Remove-Item
        Get-ChildItem -Path "$WorkspacePath\ODT\" -Include 'configuration-Office365-x86.xml' -Recurse | Remove-Item
        Get-ChildItem -Path "$WorkspacePath\ODT\" -Include 'configuration-Office2019Enterprise.xml' -Recurse | Remove-Item

    }
    #=================================================
    #	Complete
    #=================================================
    $ODTEndTime = Get-Date
    $ODTTimeSpan = New-TimeSpan -Start $ODTStartTime -End $ODTEndTime
    Write-Host -ForegroundColor DarkGray    "================================================"
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Completed in $($ODTTimeSpan.ToString("mm' minutes 'ss' seconds'"))"
    #=================================================
}