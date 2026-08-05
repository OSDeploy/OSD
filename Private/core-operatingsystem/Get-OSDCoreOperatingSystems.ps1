function Get-OSDCoreOperatingSystems {
    <#
    .SYNOPSIS
    Gets parsed OSD core operating system catalog entries.

    .DESCRIPTION
    Imports normalized raw catalog records from Get-ModuleCoreOperatingSystems and
    transforms them into OSD core operating system objects used by selection and
    deployment workflows. The function derives build identity, Windows family and
    release, normalized architecture, activation channel, and compatibility flags,
    then returns unique sorted records.

    .EXAMPLE
    Get-OSDCoreOperatingSystems

    Returns all available parsed core operating system records.

    .EXAMPLE
    Get-OSDCoreOperatingSystems | Where-Object Version -eq 'Windows 11'

    Returns only Windows 11 operating system records.

    .EXAMPLE
    Get-OSDCoreOperatingSystems | Where-Object { $_.Architecture -eq 'arm64' }

    Returns only arm64 operating system records.

    .INPUTS
    None
    You cannot pipe input to this function.

    .OUTPUTS
    PSCustomObject[]
    Parsed operating system records with OSD-specific properties.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-22 - Initial help block created
    2026-08-05 - Expanded help content and examples
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject[]])]
    param ()

    $ErrorActionPreference = 'Stop'
    $records = @()
    $mctRecords = @()

    $mctRecords = Get-ModuleCoreOperatingSystems

    if (-not $mctRecords) {
        return $records
    }

    foreach ($node in ($mctRecords | Sort-Object FileName, LanguageCode, Architecture)) {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Processing $($node.FileName)"

        if ([string]::IsNullOrWhiteSpace($node.FileName) -or $node.FileName.Length -lt 5) {
            continue
        }
            #=================================================
            #   OSBuild
            #   Get the OSBuild from the FileName
            $OSBuild = $node.FileName.Substring(0, 5)
            #=================================================
            #   OperatingSystem / OSName / OSVersion
            #   19045 = Windows 10 22H2
            #   22000 = Windows 11 21H2
            #   22621 = Windows 11 22H2
            #   22631 = Windows 11 23H2
            #   26100 = Windows 11 24H2
            #   26200 = Windows 11 25H2
            #   28000 = Windows 11 26H1
            switch ($OSBuild) {
                '19045' { $OSName = 'Windows 10'; $OSVersion = '22H2' }
                '22000' { $OSName = 'Windows 11'; $OSVersion = '21H2' }
                '22621' { $OSName = 'Windows 11'; $OSVersion = '22H2' }
                '22631' { $OSName = 'Windows 11'; $OSVersion = '23H2' }
                '26100' { $OSName = 'Windows 11'; $OSVersion = '24H2' }
                '26200' { $OSName = 'Windows 11'; $OSVersion = '25H2' }
                '28000' { $OSName = 'Windows 11'; $OSVersion = '26H1' }
                default { continue }
            }
            #=================================================
            #   OSBuildVersion
            #   Combination of <OSBuild>.<Sub>
            #   Extract from FileName
            #=================================================
            $fileNameParts = $node.FileName -split '\.'
            if ($fileNameParts.Count -lt 2) {
                continue
            }
            $OSBuildVersion = "$($fileNameParts[0]).$($fileNameParts[1])"
            #=================================================
            #   OSArchitecture
            #   Avoids confusion between x64 releases (amd64/arm64)
            #=================================================
            if ($node.Architecture -match 'x64') {
                $OSArchitecture = 'amd64'
            } elseif ($node.Architecture -match 'arm64') {
                $OSArchitecture = 'arm64'
            } else {
                $OSArchitecture = 'x86'
                continue
            }
            #=================================================
            #   OSActivation
            #=================================================
            if ($node.FileName -match 'clientconsumer_ret') {
                $OSActivation = 'Retail'
            }
            elseif ($node.FileName -match 'CLIENTBUSINESS_VOL') {
                $OSActivation = 'Volume'
            }
            else {
                $OSActivation = 'Unknown'
                continue
            }
            #=================================================
            #   Win10 / Win11
            #=================================================
            if ($OSName -eq 'Windows 10') {
                $Win10 = $true
                $Win11 = $false
            }
            elseif ($OSName -eq 'Windows 11') {
                $Win10 = $false
                $Win11 = $true
            }
            else {
                $Win10 = $false
                $Win11 = $false
            }
            #=================================================
            #   OSD Module Properties
            #=================================================
            # DisplayName should be in the format "Win11-25H2-amd64"
            $DisplayName = "$OSName $OSVersion $OSArchitecture $($node.LanguageCode) $OSActivation $OSBuildVersion"
            #=================================================
            #   ObjectProperties
            #=================================================
            <#
            Status       :
            ReleaseDate  : 2023-12-04
            Name         : Windows 10 22H2 x64 ar-sa Retail 19045.3803
            Version      : Windows 10
            ReleaseID    : 22H2
            Architecture : x64
            Language     : ar-sa
            Activation   : Retail
            Build        : 19045.3803
            FileName     : 19045.3803.231204-0204.22h2_release_svc_refresh_CLIENTCONSUMER_RET_x64FRE_ar-sa.esd
            ImageIndex   :
            ImageName    :
            Url          : http://dl.delivery.mp.microsoft.com/filestreamingservice/files/39d366c6-bb66-4938-9a78-0670eda8304d/19045.3803.231204-0204.22h2_release_svc_refresh_CLIENTCONSUMER_RET_x64FRE_ar-sa.esd
            SHA1         : 2119ef0efd432f98cdccdf525cd17fcceacef111
            UpdateID     :
            Win10        : True
            Win11        : False
            #>

        $records += [pscustomobject]@{
            Status          = $null
            ReleaseDate     = $null
            Name            = $DisplayName
            Version         = $OSName
            ReleaseID       = $OSVersion
            Architecture    = $OSArchitecture
            Language        = $node.LanguageCode
            Activation      = $OSActivation
            Build           = $OSBuildVersion
            FileName        = $node.FileName
            ImageIndex      = $node.ImageIndex
            ImageName       = $node.ImageName
            Url             = $node.FilePath
            SHA1            = $node.Sha1
            SHA256          = $node.Sha256
            UpdateID        = $node.UpdateID
            Win10           = $Win10
            Win11           = $Win11
        }
    }

    $records = $records | Sort-Object -Property Url -Unique
    $records = $records | Sort-Object -Property Name
    return $records
}
