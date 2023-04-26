function Get-FeatureUpdate {
    <#
    .SYNOPSIS
    Returns a Windows Client Feature Update

    .DESCRIPTION
    Returns a Windows Client Feature Update

    .EXAMPLE
    Get-FeatureUpdate

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>

    [CmdletBinding(DefaultParameterSetName = 'ByOSName')]
    param (
        #Operating System Name
        #Default = Windows 11 22H2 x64
        [Parameter(ParameterSetName = 'ByOSName')]
        [ValidateSet(
            'Windows 11 22H2 x64',
            'Windows 11 21H2 x64',
            'Windows 10 22H2 x64',
            'Windows 10 21H2 x64',
            'Windows 10 21H1 x64',
            'Windows 10 20H2 x64',
            'Windows 10 2004 x64',
            'Windows 10 1909 x64',
            'Windows 10 1903 x64',
            'Windows 10 1809 x64')]
        [Alias('Name')]
        [System.String]
        $OSName = 'Windows 11 22H2 x64',

        #Operating System Version
        #Default = Windows 11
        [Parameter(ParameterSetName = 'v1')]
        [ValidateSet('Windows 11','Windows 10')]
        [Alias('Version')]
        [System.String]
        $OSVersion = 'Windows 11',

        #Operating System ReleaseID
        #Default = 22H2
        [Parameter(ParameterSetName = 'v1')]
        [ValidateSet('22H2','21H2','21H1','20H2','2004','1909','1903','1809')]
        [Alias('Build','OSBuild','ReleaseID')]
        [System.String]
        $OSReleaseID = '22H2',

        #Operating System Architecture
        #Default = x64
        [ValidateSet('x64','x86')]
        [Alias('Arch','OSArch','Architecture')]
        [System.String]
        $OSArchitecture = 'x64',

        #Operating System Activation
        #Default = Volume
        [ValidateSet('Retail','Volume')]
        [Alias('License','OSLicense','Activation')]
        [System.String]
        $OSActivation = 'Volume',

        #Operating System Language
        #Default = en-us
        [ValidateSet (
            'ar-sa','bg-bg','cs-cz','da-dk','de-de','el-gr',
            'en-gb','en-us','es-es','es-mx','et-ee','fi-fi',
            'fr-ca','fr-fr','he-il','hr-hr','hu-hu','it-it',
            'ja-jp','ko-kr','lt-lt','lv-lv','nb-no','nl-nl',
            'pl-pl','pt-br','pt-pt','ro-ro','ru-ru','sk-sk',
            'sl-si','sr-latn-rs','sv-se','th-th','tr-tr',
            'uk-ua','zh-cn','zh-tw')]
        [Alias('Culture','OSCulture','Language')]
        [System.String]
        $OSLanguage = 'en-us'
    )
    #=================================================
    #   Import Local FeatureUpdates
    #=================================================
    $Results = Get-WSUSXML -Catalog FeatureUpdate -Silent
    #=================================================
    #   OSLanguage
    #=================================================
    $Results = $Results | Where-Object {$_.Title -match $OSLanguage}
    #=================================================
    #   OSActivation
    #=================================================
    switch ($OSActivation) {
        Retail  {$Results = $Results | Where-Object {$_.Title -match 'consumer'}}
        Volume  {$Results = $Results | Where-Object {$_.Title -match 'business'}}
    }
    #=================================================
    #   v1
    #=================================================
    if ($PSCmdlet.ParameterSetName -eq 'v1') {
        Write-Verbose -Message 'v1'
        $Results = $Results | Where-Object {$_.UpdateArch -eq $OSArchitecture}
        $Results = $Results | Where-Object {$_.UpdateOS -match $OSVersion}
        $Results = $Results | Where-Object {$_.UpdateBuild -eq $OSReleaseID}
    }
    else {
        $Results = $Results | Where-Object {$_.UpdateArch -eq $OSArchitecture}
    }
    #=================================================
    #   ByOSName
    #=================================================
    if ($PSCmdlet.ParameterSetName -eq 'ByOSName') {
        switch ($OSName) {
            'Windows 11 22H2'   {$Results = $Results | Where-Object {$_.UpdateOS -match 'Windows 11'} | Where-Object {$_.UpdateBuild -eq '22H2'}}
            'Windows 11 21H2'   {$Results = $Results | Where-Object {$_.UpdateOS -match 'Windows 11'} | Where-Object {$_.UpdateBuild -eq '21H2'}}
            'Windows 10 22H2'   {$Results = $Results | Where-Object {$_.UpdateOS -match 'Windows 10'} | Where-Object {$_.UpdateBuild -eq '22H2'}}
            'Windows 10 21H2'   {$Results = $Results | Where-Object {$_.UpdateOS -match 'Windows 10'} | Where-Object {$_.UpdateBuild -eq '21H2'}}
            'Windows 10 21H1'   {$Results = $Results | Where-Object {$_.UpdateOS -match 'Windows 10'} | Where-Object {$_.UpdateBuild -eq '21H1'}}
            'Windows 10 20H2'   {$Results = $Results | Where-Object {$_.UpdateOS -match 'Windows 10'} | Where-Object {$_.UpdateBuild -eq '20H2'}}
            'Windows 10 2004'   {$Results = $Results | Where-Object {$_.UpdateOS -match 'Windows 10'} | Where-Object {$_.UpdateBuild -eq '2004'}}
            'Windows 10 1909'   {$Results = $Results | Where-Object {$_.UpdateOS -match 'Windows 10'} | Where-Object {$_.UpdateBuild -eq '1909'}}
            'Windows 10 1903'   {$Results = $Results | Where-Object {$_.UpdateOS -match 'Windows 10'} | Where-Object {$_.UpdateBuild -eq '1903'}}
            'Windows 10 1809'   {$Results = $Results | Where-Object {$_.UpdateOS -match 'Windows 10'} | Where-Object {$_.UpdateBuild -eq '1809'}}
        }
    }
    #=================================================
    #   Results
    #=================================================
    $Results | Sort-Object CreationDate -Descending | Select-Object -First 1
    #=================================================
}