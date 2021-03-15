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
    #   Get
    #===================================================================================================
    $GetFeatureUpdate = Get-FeatureUpdate -OSBuild $OSBuild -OSCulture $OSCulture
    #===================================================================================================
    #   Save
    #===================================================================================================
    if ($GetFeatureUpdate) {
        if (Test-Path "$DownloadPath\$($GetFeatureUpdate.FileName)") {
            Get-Item "$DownloadPath\$($GetFeatureUpdate.FileName)"
        }
        elseif (Test-WebConnection -Uri "$($GetFeatureUpdate.FileUri)") {
            $SaveFeatureUpdate = Save-OSDDownload -SourceUrl $GetFeatureUpdate.FileUri -DownloadFolder "$DownloadPath"
            if (Test-Path $SaveFeatureUpdate.FullName) {
                Rename-Item -Path $SaveFeatureUpdate.FullName -NewName $GetFeatureUpdate.FileName -Force
            }
            if (Test-Path "$DownloadPath\$($GetFeatureUpdate.FileName)") {
                Get-Item "$DownloadPath\$($GetFeatureUpdate.FileName)"
            }
            elseif (Test-Path "$($SaveFeatureUpdate.FullName)") {
                Get-Item "$($SaveFeatureUpdate.FullName)"
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