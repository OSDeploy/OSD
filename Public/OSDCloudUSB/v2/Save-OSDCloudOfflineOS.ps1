<#
.SYNOPSIS
Downloads a Manufacturer Driver Pack by selection using Out-Gridview to an OSDCloud USB

.DESCRIPTION
Downloads a Manufacturer Driver Pack by selection using Out-Gridview to an OSDCloud USB

.PARAMETER Manufacturer
Computer Manufacturer of the Driver Pack

.LINK
https://www.osdcloud.com
#>
function Add-OSDCloudUSB {
    [CmdletBinding()]
    param (
        [ValidateSet('*','ThisPC','Dell','HP','Lenovo','Microsoft')]
        [System.String[]]$DriverPack,

        [ValidateSet(
            'Windows 11 21H2',
            'Windows 10 21H2',
            'Windows 10 21H1',
            'Windows 10 20H2',
            'Windows 10 2004',
            'Windows 10 1909',
            'Windows 10 1903',
            'Windows 10 1809'
            )]
        [System.String]$OS,

        [ValidateSet('Retail','Volume')]
        [System.String]$OSLicense,

        [ValidateSet (
            'ar-sa','bg-bg','cs-cz','da-dk','de-de','el-gr',
            'en-gb','en-us','es-es','es-mx','et-ee','fi-fi',
            'fr-ca','fr-fr','he-il','hr-hr','hu-hu','it-it',
            'ja-jp','ko-kr','lt-lt','lv-lv','nb-no','nl-nl',
            'pl-pl','pt-br','pt-pt','ro-ro','ru-ru','sk-sk',
            'sl-si','sr-latn-rs','sv-se','th-th','tr-tr',
            'uk-ua','zh-cn','zh-tw'
        )]
        [System.String]$OSLanguage
    )
    #=================================================
    #	Block
    #=================================================
    Block-PowerShellVersionLt5
    Block-NoCurl
    Block-WinPE
    #=================================================
    #	Initialize
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor DarkGray "Examples:"
    Write-Host -ForegroundColor DarkGray "Add-OSDCloudUSB -DriverPack *"
    Write-Host -ForegroundColor DarkGray "Add-OSDCloudUSB -DriverPack ThisPC"
    Write-Host -ForegroundColor DarkGray "Add-OSDCloudUSB -DriverPack Dell"
    Write-Host -ForegroundColor DarkGray "Add-OSDCloudUSB -DriverPack HP,Lenovo,Microsoft"
    Write-Host -ForegroundColor DarkGray "Add-OSDCloudUSB -OS 'Windows 11 21H2"
    Write-Host -ForegroundColor DarkGray "Add-OSDCloudUSB -OS 'Windows 10 21H2 -OSLicense Retail"
    Write-Host -ForegroundColor DarkGray "Add-OSDCloudUSB -OS 'Windows 10 21H1 -OSLicense Volume -OSLanguage en-us"
    Write-Host -ForegroundColor DarkGray "========================================================================="
    $UsbVolumes = Get-Volume.usb
    $WorkspacePath = Get-OSDCloud.workspace
    $IsAdmin = Get-OSDGather -Property IsAdmin
    #=================================================
    #	USB Volumes
    #=================================================
    if ($UsbVolumes) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) USB volumes found"
    }
    else {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find any USB volumes"
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) You may need to run New-OSDCloudUSB first"
        Get-Help New-OSDCloudUSB -Examples
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Break
    }
    #=================================================
    #   Header
    #=================================================
    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud content can be saved to an 8GB+ NTFS USB Volume"
    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) DriverPacks will require up to 2GB each"
    #=================================================
    #   OSDCloudVolumes
    #=================================================
    $OSDCloudVolumes = Get-Volume.usb | Where-Object {$_.FileSystem -eq 'NTFS'} | Where-Object {$_.SizeGB -ge 8} | Sort-Object DriveLetter -Descending
    
    if (-NOT ($OSDCloudVolumes)) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unfortunately, I don't see any USB volumes that will work"
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Failed!"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Break
    }
    
    if (($OSDCloudVolumes).Count -gt 1) {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Select one or more USB Drives to update in the PowerShell GridView window"
        $OSDCloudVolumes = $OSDCloudVolumes | Out-GridView -Title 'Select one or more USB volumes and press OK' -PassThru -OutputMode Single
    }
    #=================================================
    #   DriverPack
    #=================================================
    if ($OSDCloudVolumes) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) USB Free Space is not verified before downloading yet, so this is on you!"
        $OSDCloudOfflineUSB = "$($OSDCloudVolumes.DriveLetter):\OSDCloud"

        if ($DriverPack -contains 'ThisPC') {
            $Manufacturer = Get-MyComputerManufacturer -Brief
            Save-MyDriverPack -DownloadPath "$OSDCloudOfflineUSB\DriverPacks\$Manufacturer"
        }
    
        if ($DriverPack -contains 'Dell') {
            Get-DellDriverPack -DownloadPath "$OSDCloudOfflineUSB\DriverPacks\Dell"
        }
        if ($DriverPack -contains 'HP') {
            Get-HPDriverPack -DownloadPath "$OSDCloudOfflineUSB\DriverPacks\HP"
        }
        if ($DriverPack -contains 'Lenovo') {
            Get-LenovoDriverPack -DownloadPath "$OSDCloudOfflineUSB\DriverPacks\Lenovo"
        }
        if ($DriverPack -contains 'Microsoft') {
            Get-MicrosoftDriverPack -DownloadPath "$OSDCloudOfflineUSB\DriverPacks\Microsoft"
        }
    }
    #=================================================
    #   GetFeatureUpdates
    #=================================================
    if ($OS -or $OSLicense -or $OSLanguage) {
        $GetFeatureUpdates = Get-WSUSXML -Catalog FeatureUpdate

        if ($OS) {
            $GetFeatureUpdates = $GetFeatureUpdates | Where-Object {$_.Catalog -cmatch $OS}
        }
        if ($OSLicense -eq 'Retail') {
            $GetFeatureUpdates = $GetFeatureUpdates | Where-Object {$_.Title -match 'consumer'}
        }
        if ($OSLicense -eq 'Volume') {
            $GetFeatureUpdates = $GetFeatureUpdates | Where-Object {$_.Title -match 'business'}
        }
        if ($OSLanguage){
            $GetFeatureUpdates = $GetFeatureUpdates | Where-Object {$_.Title -match $OSLanguage}
        }
    }
    #=================================================
    #   SaveWebFile
    #=================================================
    if ($GetFeatureUpdates) {
        $GetFeatureUpdates = $GetFeatureUpdates | Sort-Object Title

        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Select one or more Feature Updates to download in the PowerShell GridView"
        $GetFeatureUpdates = $GetFeatureUpdates | Out-GridView -Title 'Select one or more Feature Updates to download and press OK' -PassThru
        
        $DownloadPath = "$OSDCloudOfflineUSB\OS"

        foreach ($FeatureUpdate in $GetFeatureUpdates) {
            if (Get-ChildItem -Path $DownloadPath -Recurse -Include $FeatureUpdate.FileName) {
                Get-ChildItem -Path $DownloadPath -Recurse -Include $FeatureUpdate.FileName
            }
            elseif (Test-WebConnection -Uri "$($FeatureUpdate.FileUri)") {
                $SaveWebFile = Save-WebFile -SourceUrl $FeatureUpdate.FileUri -DestinationDirectory "$DownloadPath" -DestinationName $FeatureUpdate.FileName
                if (Test-Path $SaveWebFile.FullName) {
                    Get-Item $SaveWebFile.FullName
                }
                else {
                    Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Could not download the Feature Update"
                }
            }
            else {
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Could not verify an Internet connection for the Feature Update"
            }
        }
    }
    else {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to determine a suitable Feature Update"
    }
    #=================================================
    #   Complete
    #=================================================
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Add-OSDCloudUSB is complete"
    Write-Host -ForegroundColor DarkGray "========================================================================="
    #=================================================
}