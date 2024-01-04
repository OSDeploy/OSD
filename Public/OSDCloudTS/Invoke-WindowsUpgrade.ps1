function Invoke-WindowsUpgrade {
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

        #Operating System Version of the Windows installation
        [Parameter(ParameterSetName = 'Legacy')]
        [ValidateSet('Windows 11','Windows 10')]
        [System.String]
        $OSVersion,

        #Operating System Build of the Windows installation
        #Alias = Build
        [Parameter(ParameterSetName = 'Legacy')]
        [ValidateSet('23H2','22H2','21H2')]
        [Alias('Build')]
        [System.String]
        $OSBuild,

        #Operating System Edition of the Windows installation
        #Alias = Edition
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Legacy')]
        [ValidateSet('Home','Home N','Home Single Language','Education','Education N','Enterprise','Enterprise N','Pro','Pro N')]
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
    if ($OSEdition -eq 'Enterprise N') {
        $OSEditionId = 'EnterpriseN'
        $OSActivation = 'Volume'
        $OSImageIndex = 7
    }
    if ($OSEdition -eq 'Education') {
        $OSEditionId = 'Education'
        if ($OSActivation -eq 'Retail') {$OSImageIndex = 7}
        if ($OSActivation -eq 'Volume') {$OSImageIndex = 4}
    }
    if ($OSEdition -eq 'Education N') {
        $OSEditionId = 'EducationN'
        if ($OSActivation -eq 'Retail') {$OSImageIndex = 8}
        if ($OSActivation -eq 'Volume') {$OSImageIndex = 5}
    }
    if ($OSEdition -eq 'Pro') {
        $OSEditionId = 'Professional'
        if ($OSActivation -eq 'Retail') {$OSImageIndex = 9}
        if ($OSActivation -eq 'Volume') {$OSImageIndex = 8}
    }
    if ($OSEdition -eq 'Pro N') {
        $OSEditionId = 'ProfessionalN'
        if ($OSActivation -eq 'Retail') {$OSImageIndex = 10}
        if ($OSActivation -eq 'Volume') {$OSImageIndex = 9}
    }
    $ScratchLocation = 'c:\windows\temp\IPU'
    $MediaLocation = "$ScratchLocation\Media"
    if (!(Test-Path -Path $ScratchLocation)){New-Item -Path $ScratchLocation -ItemType Directory -Force | Out-Null}
    if (Test-Path -Path $MediaLocation){Remove-Item -Path $MediaLocation -Force -Recurse}
    New-Item -Path $MediaLocation -ItemType Directory -Force | Out-Null

    $ESD = Get-FeatureUpdate -OSName $OSName -OSActivation $OSActivation -OSLanguage $OSLanguage 
    Save-WebFile -SourceUrl $ESD.Url -DestinationDirectory $ScratchLocation -DestinationName $ESD.FileName


    #Grab ESD File and create bootable ISO
    $ImagePath = "$ScratchLocation\$($ESD.FileName)"
    if ((Test-Path -Path $ImagePath) -and (Test-Path -Path $MediaLocation)){
        $ApplyPath = $MediaLocation
        Expand-WindowsImage -ImagePath $ImagePath -Index 1 -ApplyPath $ApplyPath
        #Export-WindowsImage -SourceImagePath $ImagePath -SourceIndex 2 -DestinationImagePath "$ApplyPath\Sources\boot.wim" -CompressionType max -CheckIntegrity
        #Export-WindowsImage -SourceImagePath $ImagePath -SourceIndex 3 -DestinationImagePath "$ApplyPath\Sources\boot.wim" -CompressionType max -CheckIntegrity -Setbootable
        Export-WindowsImage -SourceImagePath $ImagePath -SourceIndex $OSImageIndex -DestinationImagePath "$ApplyPath\Sources\install.wim" -CompressionType max -CheckIntegrity
        #Export-WindowsImage -SourceImagePath $ImagePath -SourceIndex 5 -DestinationImagePath "$ApplyPath\Sources\install.wim" -CompressionType max -CheckIntegrity
    }
}
