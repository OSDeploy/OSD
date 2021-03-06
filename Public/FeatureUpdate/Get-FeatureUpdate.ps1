
function Get-FeatureUpdate {
    [CmdletBinding()]
    param (
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
    #   Import Local FeatureUpdates
    #===================================================================================================
    $GetFeatureUpdate = Import-Clixml "$($MyInvocation.MyCommand.Module.ModuleBase)\Files\Catalogs\OSDCloud-FeatureUpdates.xml"
    #===================================================================================================
    #   Filter Compatible
    #===================================================================================================
    $GetFeatureUpdate = $GetFeatureUpdate | `
        Where-Object {$_.UpdateOS -eq 'Windows 10'} | `
        Where-Object {$_.UpdateBuild -eq $OSBuild} | `
        Where-Object {$_.UpdateArch -eq 'x64'} | `
        Where-Object {$_.Title -match 'business'} | `
        Where-Object {$_.Title -match $OSCulture}
    #===================================================================================================
    #   Pick and Sort
    #===================================================================================================
    $GetFeatureUpdate = $GetFeatureUpdate | Sort-Object CreationDate -Descending | Select-Object -First 1
    #===================================================================================================
    #   Return
    #===================================================================================================
    Return $GetFeatureUpdate
    #===================================================================================================
}