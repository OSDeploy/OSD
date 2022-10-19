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
        [System.String]
        $OSName = 'Windows 11 22H2 x64',

        #Operating System Version
        #Default = Windows 11
        [Parameter(ParameterSetName = 'v1')]
        [ValidateSet('Windows 11','Windows 10')]
        [System.String]
        $OSVersion = 'Windows 11',

        #Operating System Build
        #Default = 22H2
        [Parameter(ParameterSetName = 'v1')]
        [ValidateSet('22H2','21H2','21H1','20H2','2004','1909','1903','1809')]
        [Alias('Build')]
        [System.String]
        $OSBuild = '22H2',

        #Operating System Architecture
        #Default = x64
        [Parameter(ParameterSetName = 'v1')]
        [ValidateSet('x64','x86')]
        [System.String]
        $OSArch = 'x64',

        #Operating System Licensing
        #Default = Volume
        [ValidateSet('Retail','Volume')]
        [Alias('License')]
        [System.String]
        $OSLicense = 'Volume',

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
        [Alias('Culture','OSCulture')]
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
    #   OSLicense
    #=================================================
    switch ($OSLicense) {
        Retail  {$Results = $Results | Where-Object {$_.Title -match 'consumer'}}
        Volume  {$Results = $Results | Where-Object {$_.Title -match 'business'}}
    }
    #=================================================
    #   v1
    #=================================================
    if ($PSCmdlet.ParameterSetName -eq 'v1') {
        Write-Verbose -Message 'v1'
        $Results = $Results | Where-Object {$_.UpdateArch -eq $OSArch}
        $Results = $Results | Where-Object {$_.UpdateOS -match $OSVersion}
        $Results = $Results | Where-Object {$_.UpdateBuild -eq $OSBuild}
    }
    #=================================================
    #   ByOSName
    #=================================================
    if ($PSCmdlet.ParameterSetName -eq 'ByOSName') {
        $Results = $Results | Where-Object {$_.UpdateArch -eq 'x64'}

        if ($OSName -match 'Windows 10') {
            $Results = $Results | Where-Object {$_.UpdateOS -match 'Windows 10'}
        }
        if ($OSName -match 'Windows 11') {
            $Results = $Results | Where-Object {$_.UpdateOS -match 'Windows 11'}
        }
        if ($OSName -match '1809') {
            $Results = $Results | Where-Object {$_.UpdateBuild -eq '1809'}
        }
        if ($OSName -match '1903') {
            $Results = $Results | Where-Object {$_.UpdateBuild -eq '1903'}
        }
        if ($OSName -match '1909') {
            $Results = $Results | Where-Object {$_.UpdateBuild -eq '1909'}
        }
        if ($OSName -match '2004') {
            $Results = $Results | Where-Object {$_.UpdateBuild -eq '2004'}
        }
        if ($OSName -match '20H2') {
            $Results = $Results | Where-Object {$_.UpdateBuild -eq '20H2'}
        }
        if ($OSName -match '21H1') {
            $Results = $Results | Where-Object {$_.UpdateBuild -eq '21H1'}
        }
        if ($OSName -match '21H2') {
            $Results = $Results | Where-Object {$_.UpdateBuild -match '21H2'}
        }
        if ($OSName -match '22H2') {
            $Results = $Results | Where-Object {$_.UpdateBuild -match '22H2'}
        }
    }
    #=================================================
    #   Results
    #=================================================
    $Results | Sort-Object CreationDate -Descending | Select-Object -First 1
    #=================================================
}