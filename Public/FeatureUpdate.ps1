function Get-FeatureUpdate {
    [CmdletBinding()]
    param (
        [ValidateSet('Windows 10','Windows 11')]
        [string]$OSVersion = 'Windows 10',

        [ValidateSet('Retail','Volume')]
        [Alias('License')]
        [string]$OSLicense = 'Volume',

        [ValidateSet('21H2','21H1','20H2','2004','1909','1903','1809')]
        [Alias('Build')]
        [string]$OSBuild = '21H2',

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
        [string]$OSLanguage = 'en-us'
    )
    #=================================================
    #   Import Local FeatureUpdates
    #=================================================
    $GetFeatureUpdate = Get-WSUSXML -Catalog FeatureUpdate
    #=================================================
    #   Filter Compatible
    #=================================================
    $GetFeatureUpdate = $GetFeatureUpdate | `
        Where-Object {$_.UpdateBuild -eq $OSBuild} | `
        Where-Object {$_.UpdateArch -eq 'x64'} | `
        Where-Object {$_.Title -match $OSLanguage}
    #=================================================
    #   $OSVersion
    #=================================================
    if ($OSVersion -eq 'Windows 10') {
        $GetFeatureUpdate = $GetFeatureUpdate | Where-Object {$_.UpdateOS -eq 'Windows 10'}
    }
    else {
        $GetFeatureUpdate = $GetFeatureUpdate | Where-Object {$_.UpdateOS -eq 'Windows 11'}
    }
    #=================================================
    #   $OSLicense
    #=================================================
    if ($OSLicense -eq 'Retail') {
        $GetFeatureUpdate = $GetFeatureUpdate | Where-Object {$_.Title -match 'consumer'}
    }
    else {
        $GetFeatureUpdate = $GetFeatureUpdate | Where-Object {$_.Title -match 'business'}
    }
    #=================================================
    #   Pick and Sort
    #=================================================
    $GetFeatureUpdate = $GetFeatureUpdate | Sort-Object CreationDate -Descending | Select-Object -First 1
    #=================================================
    #   Return
    #=================================================
    Return $GetFeatureUpdate
    #=================================================
}
function Save-FeatureUpdate {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [Alias ('DownloadFolder','Path')]
        [string]$DownloadPath = 'C:\OSDCloud\OS',

        [ValidateSet('Retail','Volume')]
        [Alias('License')]
        [string]$OSLicense = 'Volume',

        [ValidateSet('21H2','21H1','20H2','2004','1909','1903','1809')]
        [Alias('Build')]
        [string]$OSBuild = '21H1',

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
        [string]$OSLanguage = 'en-us'
    )
    #=================================================
    #   Get-FeatureUpdate
    #=================================================
    $GetFeatureUpdate = Get-FeatureUpdate -OSLicense $OSLicense -OSBuild $OSBuild -OSLanguage $OSLanguage
    #=================================================
    #   SaveWebFile
    #=================================================
    if ($GetFeatureUpdate) {
        if (Test-Path "$DownloadPath\$($GetFeatureUpdate.FileName)") {
            Get-Item "$DownloadPath\$($GetFeatureUpdate.FileName)"
        }
        elseif (Test-WebConnection -Uri "$($GetFeatureUpdate.FileUri)") {
            $SaveWebFile = Save-WebFile -SourceUrl $GetFeatureUpdate.FileUri -DestinationDirectory "$DownloadPath" -DestinationName $GetFeatureUpdate.FileName

            if (Test-Path $SaveWebFile.FullName) {
                Get-Item $SaveWebFile.FullName
            }
            else {
                Write-Warning "Could not download the Feature Update"
            }
        }
        else {
            Write-Warning "Could not verify an Internet connection for the Feature Update"
        }
    }
    else {
        Write-Warning "Unable to determine a suitable Feature Update"
    }
}