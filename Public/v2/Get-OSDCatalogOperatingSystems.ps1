function Get-OSDCatalogOperatingSystems {
    [CmdletBinding()]
    param ()
    #=================================================
    #   Paths
    #=================================================
    $PathMicrosoftCatalogs = "$(Get-OSDCatalogsPath)\winos-mct"
    $PathOutoutXml = "$(Get-OSDCatalogsPath)\winos-mct\20241004.xml"
    $PathOutputJson = "$(Get-OSDCatalogsPath)\winos-mct\20241004.json"
    #=================================================
    #   Microsoft Catalogs
    #=================================================
    $MicrosoftCatalogs = Get-ChildItem -Path $PathMicrosoftCatalogs -Recurse -File

    $Results = foreach ($MicrosoftCatalog in $MicrosoftCatalogs) {
        [xml]$XmlCatalogContent = Get-Content $($MicrosoftCatalog.FullName) -ErrorAction Stop
        $XmlFiles = $XmlCatalogContent.MCT.Catalogs.Catalog.PublishedMedia.Files.File

        $ParentDirectory = Split-Path $MicrosoftCatalog.Directory -Leaf
        #=================================================
        #   OperatingSystem
        #=================================================
        if ($ParentDirectory -match 'win11') {
            $OperatingSystem = 'Windows 11'
        } elseif ($ParentDirectory -match 'win10') {
            $OperatingSystem = 'Windows 10'
        } else {
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Skipping OperatingSystem $ParentDirectory"
            Continue
        }
        #=================================================
        #   OSReleaseId
        #=================================================
        $OSReleaseId = ($ParentDirectory -split '-')[1]
        $OSReleaseId = $OSReleaseId.ToUpper()
        #=================================================
        #   OSBuild
        #=================================================
        $OSBuild = ($ParentDirectory -split '-')[2]
        #=================================================
        #   Create Object
        #=================================================
        foreach ($Item in $XmlFiles) {
            #=================================================
            #   OSArchitecture
            #=================================================
            if ($Item.Architecture -match 'x64') {
                $OSArchitecture = 'amd64'
            } elseif ($Item.Architecture -match 'arm64') {
                $OSArchitecture = 'arm64'
            } else {
                Continue
            }
            #=================================================
            #   License
            #=================================================
            if ($Item.FilePath -match 'consumer') {
                $License = 'Retail'
            } elseif ($Item.FilePath -match 'business') {
                $License = 'Volume'
            } else {
                $License = 'Unknown'
                Continue
            }
            #=================================================
            #   ObjectProperties
            #=================================================
            $ObjectProperties = [Ordered]@{
                Name            = "$OperatingSystem $OSReleaseId $OSArchitecture"
                OperatingSystem = $OperatingSystem
                ReleaseId       = $OSReleaseId
                Build           = $OSBuild
                Architecture    = $OSArchitecture
                LanguageCode    = $Item.LanguageCode
                License         = $License
                SizeGB          = $Item.Size / 1GB
                Sha1            = $Item.Sha1
                Url             = $Item.FilePath
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
        }
    }
    #=================================================
    #   Results
    #=================================================
    $Results = $Results | Sort-Object -Property Url -Unique
    $Results = $Results | Sort-Object -Property @{Expression={$_.Build}; Descending=$true}, Architecture, Language
    return $Results
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}