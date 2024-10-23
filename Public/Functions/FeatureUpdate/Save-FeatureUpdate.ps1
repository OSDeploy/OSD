function Save-FeatureUpdate {
    <#
    .SYNOPSIS
    Downloads a Windows Client Feature Update

    .DESCRIPTION
    Downloads a Windows Client Feature Update

    .EXAMPLE
    Save-FeatureUpdate

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>

    [CmdletBinding(DefaultParameterSetName = 'ByOSName')]
    param (
        #Path to save the Feature Update
        #Default = C:\OSDCloud\OS
        [Parameter(ValueFromPipeline = $true)]
        [Alias ('DownloadFolder','Path')]
        [System.String]
        $DownloadPath = 'C:\OSDCloud\OS',

        #Operating System Name
        #Default = Windows 11 22H2 x64
        [Parameter(ParameterSetName = 'ByOSName')]
        [ValidateSet(
            'Windows 11 24H2 x64', 
            'Windows 11 23H2 x64',    
            'Windows 11 22H2 x64',
            'Windows 11 21H2 x64',
            'Windows 10 22H2 x64',
            'Windows 10 21H2 x64',
            'Windows 10 20H2 x64',
            'Windows 10 2004 x64',
            'Windows 10 1909 x64'
            )]
        [Alias('Name')]
        [System.String]
        $OSName = 'Windows 11 24H2 x64',

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
        [ValidateSet('24H2','23H2','22H2','21H2','20H2','2004','1909')]
        [Alias('Build','OSBuild','ReleaseID')]
        [System.String]
        $OSReleaseID = '24H2',

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
    #$Results = Get-WSUSXML -Catalog FeatureUpdate -Silent
    $Results = Get-OSDCloudOperatingSystems
    #=================================================
    #   OSLanguage
    #=================================================
    #$Results = $Results | Where-Object {$_.Title -match $OSLanguage}
    $Results = $Results | Where-Object {$_.Language -match $OSLanguage}
    #=================================================
    #   OSActivation
    #=================================================
    #switch ($OSActivation) {
    #    Retail  {$Results = $Results | Where-Object {$_.Title -match 'consumer'}}
    #    Volume  {$Results = $Results | Where-Object {$_.Title -match 'business'}}
    #}
    $Results = $Results | Where-Object {$_.Activation -match $OSActivation}
    #=================================================
    #   v1
    #=================================================
    if ($PSCmdlet.ParameterSetName -eq 'v1') {
        Write-Verbose -Message 'v1'
        #$Results = $Results | Where-Object {$_.UpdateArch -eq $OSArchitecture}
        $Results = $Results | Where-Object {$_.Architecture -eq $OSArchitecture}
        #$Results = $Results | Where-Object {$_.UpdateOS -match $OSVersion}
        $Results = $Results | Where-Object {$_.Version -match $OSVersion}
        #$Results = $Results | Where-Object {$_.UpdateBuild -eq $OSReleaseID}
        $Results = $Results | Where-Object {$_.ReleaseID -eq $OSReleaseID}
    }
    else {
        $Results = $Results | Where-Object {$_.Architecture -eq $OSArchitecture}
    }
    #=================================================
    #   ByOSName
    #=================================================
    if ($PSCmdlet.ParameterSetName -eq 'ByOSName') {
        switch ($OSName) {
            #'Windows 11 22H2 x64'   {$Results = $Results | Where-Object {$_.UpdateOS -match 'Windows 11'} | Where-Object {$_.UpdateBuild -eq '22H2'}}
            #'Windows 11 22H2 x64'   {$Results = $Results | Where-Object {$_.UpdateOS -match 'Windows 11'} | Where-Object {$_.UpdateBuild -eq '22H2'}}
            #'Windows 11 21H2 x64'   {$Results = $Results | Where-Object {$_.UpdateOS -match 'Windows 11'} | Where-Object {$_.UpdateBuild -eq '21H2'}}
            #'Windows 10 22H2 x64'   {$Results = $Results | Where-Object {$_.UpdateOS -match 'Windows 10'} | Where-Object {$_.UpdateBuild -eq '22H2'}}
            'Windows 11 24H2 x64' { $Results = $Results | Where-Object { $_.Version -match 'Windows 11' } | Where-Object { $_.ReleaseID -eq '24H2' } }
            'Windows 11 23H2 x64' { $Results = $Results | Where-Object { $_.Version -match 'Windows 11' } | Where-Object { $_.ReleaseID -eq '23H2' } }
            'Windows 11 22H2 x64' { $Results = $Results | Where-Object { $_.Version -match 'Windows 11' } | Where-Object { $_.ReleaseID -eq '22H2' } }
            'Windows 11 21H2 x64' { $Results = $Results | Where-Object { $_.Version -match 'Windows 11' } | Where-Object { $_.ReleaseID -eq '21H2' } }
            'Windows 10 22H2 x64' { $Results = $Results | Where-Object { $_.Version -match 'Windows 10' } | Where-Object { $_.ReleaseID -eq '22H2' } }
            'Windows 10 21H2 x64' { $Results = $Results | Where-Object { $_.Version -match 'Windows 10' } | Where-Object { $_.ReleaseID -eq '21H2' } }
            'Windows 10 20H2 x64' { $Results = $Results | Where-Object { $_.Version -match 'Windows 10' } | Where-Object { $_.ReleaseID -eq '20H2' } }
            'Windows 10 2004 x64' { $Results = $Results | Where-Object { $_.Version -match 'Windows 10' } | Where-Object { $_.ReleaseID -eq '2004' } }
            'Windows 10 1909 x64' { $Results = $Results | Where-Object { $_.Version -match 'Windows 10' } | Where-Object { $_.ReleaseID -eq '1909' } }
            'Windows 11 24H2 ARM64' { $Results = $Results | Where-Object { $_.Version -match 'Windows 11' } | Where-Object { $_.ReleaseID -eq '24H2' } | Where-Object { $_.Architecture -eq 'ARM64' } }
            'Windows 11 23H2 ARM64' { $Results = $Results | Where-Object { $_.Version -match 'Windows 11' } | Where-Object { $_.ReleaseID -eq '23H2' } | Where-Object { $_.Architecture -eq 'ARM64' } }
            'Windows 10 22H2 ARM64' { $Results = $Results | Where-Object { $_.Version -match 'Windows 10' } | Where-Object { $_.ReleaseID -eq '22H2' } | Where-Object { $_.Architecture -eq 'ARM64' } }
        }
    }

    #=================================================
    #   Results
    #=================================================
    $GetFeatureUpdate = $Results | Sort-Object CreationDate -Descending | Select-Object -First 1
    #=================================================
    #   SaveWebFile
    #=================================================
    if ($GetFeatureUpdate) {
        if (Test-Path "$DownloadPath\$($GetFeatureUpdate.FileName)") {
            Get-Item "$DownloadPath\$($GetFeatureUpdate.FileName)"
        }
        elseif (Test-WebConnection -Uri "$($GetFeatureUpdate.Url)") {
            $SaveWebFile = Save-WebFile -SourceUrl $GetFeatureUpdate.Url -DestinationDirectory "$DownloadPath" -DestinationName $GetFeatureUpdate.FileName

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