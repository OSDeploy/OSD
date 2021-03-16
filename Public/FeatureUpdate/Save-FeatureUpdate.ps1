function Save-FeatureUpdate {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [Alias ('DownloadFolder','Path')]
        [string]$DownloadPath = 'C:\OSDCloud\OS',

        [ValidateSet('2009','2004','1909','1903','1809')]
        [Alias('Build')]
        [string]$OSBuild = '2009',

        [ValidateSet (
            'ar-sa','bg-bg','cs-cz','da-dk','de-de','el-gr',
            'en-gb','en-us','es-es','es-mx','et-ee','fi-fi',
            'fr-ca','fr-fr','he-il','hr-hr','hu-hu','it-it',
            'ja-jp','ko-kr','lt-lt','lv-lv','nb-no','nl-nl',
            'pl-pl','pt-br','pt-pt','ro-ro','ru-ru','sk-sk',
            'sl-si','sr-latn-rs','sv-se','th-th','tr-tr',
            'uk-ua','zh-cn','zh-tw'
        )]
        [Alias('Culture')]
        [string]$OSCulture = 'en-us'
    )
    #===================================================================================================
    #   Get-FeatureUpdate
    #===================================================================================================
    $GetFeatureUpdate = Get-FeatureUpdate -OSBuild $OSBuild -OSCulture $OSCulture
    #===================================================================================================
    #   SaveWebFile
    #===================================================================================================
    if ($GetFeatureUpdate) {
        if (Test-Path "$DownloadPath\$($GetFeatureUpdate.FileName)") {
            Get-Item "$DownloadPath\$($GetFeatureUpdate.FileName)"
        }
        elseif (Test-WebConnection -Uri "$($GetFeatureUpdate.FileUri)") {
            $SaveWebFile = Save-WebFile -SourceUrl $GetFeatureUpdate.FileUri -DestinationDirectory "$DownloadPath" -DestinationName $GetFeatureUpdate.FileName

            if (Test-Path $SaveWebFile.FullName) {
                Return Get-Item $SaveWebFile.FullName
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