function Invoke-OSDCloudIPU {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (

        [Parameter(ParameterSetName = 'Default')]
        [ValidateSet(
            'Windows 11 23H2 x64',    
            'Windows 11 22H2 x64',
            'Windows 11 21H2 x64',
            'Windows 10 22H2 x64')]
        [System.String]
        $OSName,

        #Operating System Edition of the Windows installation
        #Alias = Edition
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Legacy')]
        [ValidateSet('Home','HomeN','Home Single Language','Education','EducationN','Enterprise','EnterpriseN','Professional','ProfessionalN')]
        [Alias('Edition')]
        [System.String]
        $OSEdition,

        #Operating System Language of the Windows installation
        #Alias = Culture, OSCulture
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Legacy')]
        [ValidateSet (
            'ar-sa','bg-bg','cs-cz','da-dk','de-de','el-gr',
            'en-gb','en-us','es-es','es-mx','et-ee','fi-fi',
            'fr-ca','fr-fr','he-il','hr-hr','hu-hu','it-it',
            'ja-jp','ko-kr','lt-lt','lv-lv','nb-no','nl-nl',
            'pl-pl','pt-br','pt-pt','ro-ro','ru-ru','sk-sk',
            'sl-si','sr-latn-rs','sv-se','th-th','tr-tr',
            'uk-ua','zh-cn','zh-tw'
        )]
        [Alias('Culture','OSCulture')]
        [System.String]
        $OSLanguage,

        #License of the Windows Operating System
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Legacy')]
        [ValidateSet('Retail','Volume')]
        [Alias('License','OSLicense','Activation')]
        [System.String]
        $OSActivation
    )
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Starting Invoke-WindowsUpgrade"
    Write-Host -ForegroundColor Gray "Looking of Details about this device...."
    if (!($OSEdition)){
        $OSEdition = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name "EditionID"
    }
    if (!($OSLanguage)){
        $OSLanguage = (Get-WinSystemLocale).Name
    }
    if (!($OSActivation)){
        $OSActivation = (Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%'" | Where-Object { $_.PartialProductKey }).ProductKeyChannel
    }
    #=================================================
    #	OSEditionId and OSActivation
    #=================================================
    if ($OSEdition -eq 'Home') {
        $OSEditionId = 'Core'
        $OSActivation = 'Retail'
        $OSImageIndex = 4
    }
    if ($OSEdition -eq 'Home N') {
        $OSEditionId = 'CoreN'
        $OSActivation = 'Retail'
        $OSImageIndex = 5
    }
    if ($OSEdition -eq 'Home Single Language') {
        $OSEditionId = 'CoreSingleLanguage'
        $OSActivation = 'Retail'
        $OSImageIndex = 6
    }
    if ($OSEdition -eq 'Enterprise') {
        $OSEditionId = 'Enterprise'
        $OSActivation = 'Volume'
        $OSImageIndex = 6
    }
    if (($OSEdition -eq 'Enterprise N') -or ($OSEdition -eq 'EnterpriseN')) {
        $OSEditionId = 'EnterpriseN'
        $OSActivation = 'Volume'
        $OSImageIndex = 7
    }
    if ($OSEdition -eq 'Education') {
        $OSEditionId = 'Education'
        if ($OSActivation -eq 'Retail') {$OSImageIndex = 7}
        if ($OSActivation -eq 'Volume') {$OSImageIndex = 4}
    }
    if (($OSEdition -eq 'Education N') -or ($OSEdition -eq 'EducationN')) {
        $OSEditionId = 'EducationN'
        if ($OSActivation -eq 'Retail') {$OSImageIndex = 8}
        if ($OSActivation -eq 'Volume') {$OSImageIndex = 5}
    }
    if (($OSEdition -eq 'Pro') -or ($OSEdition -eq 'Professional'))  {
        $OSEditionId = 'Professional'
        if ($OSActivation -eq 'Retail') {$OSImageIndex = 9}
        if ($OSActivation -eq 'Volume') {$OSImageIndex = 8}
    }
    if (($OSEdition -eq 'Pro N') -or ($OSEdition -eq 'ProfessionalN')) {
        $OSEditionId = 'ProfessionalN'
        if ($OSActivation -eq 'Retail') {$OSImageIndex = 10}
        if ($OSActivation -eq 'Volume') {$OSImageIndex = 9}
    }
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "OSEditionId: " -NoNewline
    Write-Host -ForegroundColor Green $OSEditionId
    Write-Host -ForegroundColor Cyan "OSImageIndex: " -NoNewline
    Write-Host -ForegroundColor Green $OSImageIndex
    Write-Host -ForegroundColor Cyan "OSLanguage: " -NoNewline
    Write-Host -ForegroundColor Green $OSLanguage
    Write-Host -ForegroundColor Cyan "OSActivation: " -NoNewline
    Write-Host -ForegroundColor Green $OSActivation
 
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Starting Feature Update lookup and Download"

    $ScratchLocation = 'c:\windows\temp\IPU'
    $MediaLocation = "$ScratchLocation\Media"
    if (!(Test-Path -Path $ScratchLocation)){New-Item -Path $ScratchLocation -ItemType Directory -Force | Out-Null}
    if (Test-Path -Path $MediaLocation){Remove-Item -Path $MediaLocation -Force -Recurse}
    New-Item -Path $MediaLocation -ItemType Directory -Force | Out-Null

    $ESD = Get-FeatureUpdate -OSName $OSName -OSActivation $OSActivation -OSLanguage $OSLanguage 
    Write-Host -ForegroundColor Cyan "Name: " -NoNewline
    Write-Host -ForegroundColor Green $ESD.Name
    Write-Host -ForegroundColor Cyan "Architecture: " -NoNewline
    Write-Host -ForegroundColor Green $ESD.Architecture
    Write-Host -ForegroundColor Cyan "Activation: " -NoNewline
    Write-Host -ForegroundColor Green $ESD.Activation
    Write-Host -ForegroundColor Cyan "Build: " -NoNewline
    Write-Host -ForegroundColor Green $ESD.Build    
    Write-Host -ForegroundColor Cyan "FileName: " -NoNewline
    Write-Host -ForegroundColor Green $ESD.FileName   
    Write-Host -ForegroundColor Cyan "Url: " -NoNewline
    Write-Host -ForegroundColor Green $ESD.Url   
    
    Write-Host -ForegroundColor Gray "Starting Download to $ScratchLocation, this takes awhile"
    Save-WebFile -SourceUrl $ESD.Url -DestinationDirectory $ScratchLocation -DestinationName $ESD.FileName


    #Grab ESD File and create bootable ISO
    $ImagePath = "$ScratchLocation\$($ESD.FileName)"
    if ((Test-Path -Path $ImagePath) -and (Test-Path -Path $MediaLocation)){
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Starting Extract of ESD file to create Setup Content"
        $ApplyPath = $MediaLocation
        Expand-WindowsImage -ImagePath $ImagePath -Index 1 -ApplyPath $ApplyPath
        #Export-WindowsImage -SourceImagePath $ImagePath -SourceIndex 2 -DestinationImagePath "$ApplyPath\Sources\boot.wim" -CompressionType max -CheckIntegrity
        #Export-WindowsImage -SourceImagePath $ImagePath -SourceIndex 3 -DestinationImagePath "$ApplyPath\Sources\boot.wim" -CompressionType max -CheckIntegrity -Setbootable
        Export-WindowsImage -SourceImagePath $ImagePath -SourceIndex $OSImageIndex -DestinationImagePath "$ApplyPath\Sources\install.wim" -CompressionType max -CheckIntegrity
        #Export-WindowsImage -SourceImagePath $ImagePath -SourceIndex 5 -DestinationImagePath "$ApplyPath\Sources\install.wim" -CompressionType max -CheckIntegrity
    }
    #>
}