<#
.SYNOPSIS
Starts the OSDCloud Windows 10 Build Process from the OSD Module or a GitHub Repository

.DESCRIPTION
Starts the OSDCloud Windows 10 Build Process from the OSD Module or a GitHub Repository

.PARAMETER OSEdition
Edition of the Windows installation

.PARAMETER OSCulture
Language of the Windows installation
Alias = Culture, Language

.PARAMETER Screenshot
Captures screenshots during OSDCloud

.PARAMETER GitHub
Starts OSDCloud from GitHub
GitHub Variable Url: $GitHubBaseUrl/$GitHubUser/$GitHubRepository/$GitHubBranch/$GitHubScript
GitHub Resolved Url: https://raw.githubusercontent.com/OSDeploy/OSDCloud/main/Start-OSDCloud.ps1

.PARAMETER GitHubBaseUrl
The GitHub Base URL

.PARAMETER GitHubUser
GitHub Repository User

.PARAMETER GitHubRepository
OSDCloud Repository

.PARAMETER GitHubBranch
Branch of the Repository

.PARAMETER GitHubScript
Script to execute

.PARAMETER GitHubToken
Used to access a GitHub Private Repository

.LINK
https://osdcloud.osdeploy.com/

.NOTES
21.3.12 Module vs GitHub options added
21.3.10 Added additional parameters
21.3.9  Initial Release
#>
function Start-OSDCloud {
    [CmdletBinding(DefaultParameterSetName = 'Module')]
    param (
        [ValidateSet('2009','2004','1909','1903','1809')]
        [Alias('Build')]
        [string]$OSBuild = '2009',

        [ValidateSet('Education','Enterprise','Pro')]
        [Alias('Edition')]
        [string]$OSEdition = 'Enterprise',

        [ValidateSet (
            'ar-sa','bg-bg','cs-cz','da-dk','de-de','el-gr',
            'en-gb','en-us','es-es','es-mx','et-ee','fi-fi',
            'fr-ca','fr-fr','he-il','hr-hr','hu-hu','it-it',
            'ja-jp','ko-kr','lt-lt','lv-lv','nb-no','nl-nl',
            'pl-pl','pt-br','pt-pt','ro-ro','ru-ru','sk-sk',
            'sl-si','sr-latn-rs','sv-se','th-th','tr-tr',
            'uk-ua','zh-cn','zh-tw'
        )]
        [Alias('Culture','Language')]
        [string]$OSCulture = 'en-us',

        [switch]$Screenshot,

        [Parameter(ParameterSetName = 'GitHub')]
        [switch]$GitHub,

        [Parameter(ParameterSetName = 'GitHub')]
        [string]$GitHubBaseUrl = 'https://raw.githubusercontent.com',
        
        [Parameter(ParameterSetName = 'GitHub')]
        [Alias('U','User')]
        [string]$GitHubUser = 'OSDeploy',

        [Parameter(ParameterSetName = 'GitHub')]
        [Alias('R','Repository')]
        [string]$GitHubRepository = 'OSDCloud',

        [Parameter(ParameterSetName = 'GitHub')]
        [Alias('B','Branch')]
        [string]$GitHubBranch = 'main',

        [Parameter(ParameterSetName = 'GitHub')]
        [Alias('S','Script')]
        [string]$GitHubScript = 'Deploy-OSDCloud.ps1',

        [Parameter(ParameterSetName = 'GitHub')]
        [Alias('T','Token')]
        [string]$GitHubToken = '',

        [string]$Manufacturer = (Get-MyComputerManufacturer -Brief),
        [string]$Product = (Get-MyComputerProduct)
    )
    #=======================================================================
    #	Start the Clock
    #=======================================================================
    $Global:OSDCloudStartTime = Get-Date
    #=======================================================================
    #   Screenshot
    #=======================================================================
    if ($PSBoundParameters.ContainsKey('Screenshot')) {
        $Global:OSDCloudScreenshot = "$env:TEMP\ScreenPNG"
        Start-ScreenPNGProcess -Directory "$env:TEMP\ScreenPNG"
    }
    #=======================================================================
    #	Global Variables
    #=======================================================================
    $Global:OSDCloudOSEdition = $OSEdition
    $Global:OSDCloudOSCulture = $OSCulture
    $Global:OSDCloudManufacturer = $Manufacturer
    $Global:OSDCloudProduct = $Product
    #=======================================================================
    #	Block
    #=======================================================================
    Block-PowerShellVersionLt5
    Block-NoCurl
    #=======================================================================
    #   Header
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name)"
    Write-Warning "OSDCLOUD IS CURRENTLY IN DEVELOPMENT FOR TESTING ONLY"
    #=======================================================================
    #	Test PowerShell Gallery Connectivity
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "Test-WebConnection"
    Write-Host -ForegroundColor DarkGray "powershellgallery.com"

    if (Test-WebConnection -Uri "powershellgallery.com") {
        Write-Host -ForegroundColor Green "OK"
    }
    else {
        Write-Host -ForegroundColor Red " FAILED"
        Write-Warning "Could not validate an Internet connection to the PowerShell Gallery"
        Write-Warning "OSDCloud will continue, but there may be issues if this can't be resolved"
    }
    #=======================================================================
    #	Get-FeatureUpdate
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "Get-FeatureUpdate"
    Write-Host -ForegroundColor DarkGray "Windows 10 x64 | OSBuild: $OSBuild | OSEdition: $Global:OSDCloudOSEdition | OSCulture: $OSCulture"

    $GetFeatureUpdate = Get-FeatureUpdate -OSBuild $OSBuild -OSCulture $OSCulture

    if ($GetFeatureUpdate) {
        $GetFeatureUpdate = $GetFeatureUpdate | Select-Object -Property CreationDate,KBNumber,Title,UpdateOS,UpdateBuild,UpdateArch,FileName, @{Name='SizeMB';Expression={[int]($_.Size /1024/1024)}},FileUri,Hash,AdditionalHash
    }
    else {
        Write-Warning "Unable to locate a Windows 10 Feature Update"
        Write-Warning "OSDCloud cannot continue"
        Break
    }
    #=======================================================================
    #	Get-FeatureUpdate Source
    #=======================================================================
    $OSDCloudOfflineOS = Get-OSDCloud.offline.file -Name $GetFeatureUpdate.FileName | Select-Object -First 1

    if ($OSDCloudOfflineOS) {
        $OSDCloudOfflineOSFullName = $OSDCloudOfflineOS.FullName
        Write-Host -ForegroundColor Green "OK"
        Write-Host -ForegroundColor DarkGray "$($GetFeatureUpdate.Title)"
        Write-Host -ForegroundColor DarkGray "$OSDCloudOfflineOSFullName"
    }
    elseif (Test-WebConnection -Uri $GetFeatureUpdate.FileUri) {
        Write-Host -ForegroundColor Yellow "Download"
        Write-Host -ForegroundColor Yellow "$($GetFeatureUpdate.Title)"
        Write-Host -ForegroundColor Yellow "$($GetFeatureUpdate.FileUri)"
    }
    else {
        Write-Warning "Could not verify an Internet connection for Windows 10 Feature Update"
        Write-Warning "OSDCloud cannot continue"
        Break
    }
    #=======================================================================
    #	Start-OSDCloud Get-MyDriverPack
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "Get-MyDriverPack"
    
    if ($PSBoundParameters.ContainsKey('Manufacturer')) {
        $GetMyDriverPack = Get-MyDriverPack -Manufacturer $Global:OSDCloudManufacturer -Product $Global:OSDCloudProduct
    }
    else {
        $GetMyDriverPack = Get-MyDriverPack -Product $Global:OSDCloudProduct
    }

    if ($GetMyDriverPack) {
        Write-Host -ForegroundColor DarkGray "Name: $($GetMyDriverPack.Name)"
        Write-Host -ForegroundColor DarkGray "Product: $($GetMyDriverPack.Product)"

        $GetOSDCloudOfflineFile = Get-OSDCloud.offline.file -Name $GetMyDriverPack.FileName | Select-Object -First 1
        if ($GetOSDCloudOfflineFile) {
            Write-Host -ForegroundColor Green "OK"
            Write-Host -ForegroundColor DarkGray "$($GetOSDCloudOfflineFile.FullName)"
        }
        elseif (Test-WebConnection -Uri $GetMyDriverPack.DriverPackUrl) {
            Write-Host -ForegroundColor Yellow "Download"
            Write-Host -ForegroundColor Yellow "$($GetMyDriverPack.DriverPackUrl)"
        }
        else {
            Write-Warning "Could not verify an Internet connection for the Dell Driver Pack"
            Write-Warning "OSDCloud will continue, but there may be issues"
        }
    }
    else {
        Write-Warning "Unable to determine a suitable Driver Pack for this Computer Model"
    }
    #=======================================================================
    #	Get-MyDellBios
    #=======================================================================
    if ($Global:OSDCloudManufacturer -eq 'Dell') {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "Get-MyDellBios"

        $GetMyDellBios = Get-MyDellBios
        if ($GetMyDellBios) {
            Write-Host -ForegroundColor DarkGray "$($GetMyDellBios.Name)"
            Write-Host -ForegroundColor DarkGray "$($GetMyDellBios.ReleaseDate)"

            $GetOSDCloudOfflineFile = Get-OSDCloud.offline.file -Name $GetMyDellBios.FileName | Select-Object -First 1

            if ($OSDCloudOfflineBios) {
                Write-Host -ForegroundColor Green "OK"
                Write-Host -ForegroundColor DarkGray "$($OSDCloudOfflineBios.FullName)"
            }
            elseif (Test-MyDellBiosWebConnection) {
                Write-Host -ForegroundColor Yellow "Download"
                Write-Host -ForegroundColor Yellow "$($GetMyDellBios.Url)"
            }
            else {
                Write-Warning "Could not verify an Internet connection for the Dell Bios Update"
                Write-Warning "OSDCloud will continue, but there may be issues"
            }

            $OSDCloudOfflineFlash64W = Get-OSDCloud.offline.file -Name 'Flash64W.exe' | Select-Object -First 1
            if ($OSDCloudOfflineFlash64W) {
                Write-Host -ForegroundColor DarkGray "$($OSDCloudOfflineFlash64W.FullName)"
            }
            elseif (Test-MyDellBiosWebConnection) {
                Write-Host -ForegroundColor Yellow "$($GetMyDellBios.Flash64W)"
            }
            else {
                Write-Warning "Could not verify an Internet connection for the Dell Flash64W"
                Write-Warning "OSDCloud will continue, but there may be issues"
            }
        }
        else {
            Write-Warning "Unable to determine a suitable BIOS update for this Computer Model"
            Write-Warning "OSDCloud will continue, but there may be issues"
        }
    }
    #=======================================================================
    #	AutoPilot Profiles
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "Get-OSDCloud.autopilotprofiles"

    $GetOSDCloudautopilotprofiles = Get-OSDCloud.autopilotprofiles

    if ($GetOSDCloudautopilotprofiles) {
        Write-Host -ForegroundColor Green "OK"

        foreach ($Item in $GetOSDCloudautopilotprofiles) {
            Write-Host -ForegroundColor DarkGray "$($Item.FullName)"
        }
    } else {
        Write-Warning "No AutoPilot Profiles were found in any PSDrive"
        Write-Warning "AutoPilot Profiles must be located in a <PSDrive>:\OSDCloud\AutoPilot\Profiles directory"
    }
    #=======================================================================
    #   Module
    #=======================================================================
    if ($PSCmdlet.ParameterSetName -eq 'Module') {
        $GetDeployOSDCloud = Get-OSDCloud.offline.file -Name 'Deploy-MyOSDCloud.ps1' | Select-Object -First 1
        if ($GetDeployOSDCloud) {
            & "$($GetDeployOSDCloud.FullName)"
        }
        else {
            & "$($MyInvocation.MyCommand.Module.ModuleBase)\OSDCloud\Deploy-OSDCloud.ps1"
        }
    }
    #=======================================================================
    #   GitHub
    #=======================================================================
    if ($PSCmdlet.ParameterSetName -eq 'GitHub') {
        if (-NOT (Test-WebConnection -Uri $GitHubBaseUrl)) {
            Write-Warning "Could not verify an Internet connection to $Global:GitHubUrl"
            Write-Warning "OSDCloud -GitHub cannot continue"
            Write-Warning "Verify you have an Internet connection or remove the -GitHub parameter"
            Break
        }

        if ($PSBoundParameters['Token']) {
            $Global:GitHubUrl = "$GitHubBaseUrl/$GitHubUser/$GitHubRepository/$GitHubBranch/$GitHubScript`?token=$GitHubToken"
        } else {
            $Global:GitHubUrl = "$GitHubBaseUrl/$GitHubUser/$GitHubRepository/$GitHubBranch/$GitHubScript"
        }

        if (-NOT (Test-WebConnection -Uri $Global:GitHubUrl)) {
            Write-Warning "Could not verify an Internet connection to $Global:GitHubUrl"
            Write-Warning "OSDCloud -GitHub cannot continue"
            Write-Warning "Verify you have an Internet connection or remove the -GitHub parameter"
            Break
        }

        $Global:GitHubBaseUrl = $GitHubBaseUrl
        $Global:GitHubUser = $GitHubUser
        $Global:GitHubRepository = $GitHubRepository
        $Global:GitHubBranch = $GitHubBranch
        $Global:GitHubScript = $GitHubScript
        $Global:GitHubToken = $GitHubToken

        Write-Host -ForegroundColor Cyan "Starting $($Global:GitHubUrl)"
        Start-Sleep -Seconds 5
        Invoke-WebPSScript -WebPSScript $Global:GitHubUrl
    }
    #=======================================================================
}