function Get-OSDCloudDriverPack {
    <#
    .SYNOPSIS
    Gets the OSDCloud DriverPack for the current or specified computer model

    .DESCRIPTION
    Gets the OSDCloud DriverPack for the current or specified computer model

    .EXAMPLE
    Get-OSDCloudDriverPack
    Returns the most recent matching OSDCloud driver pack for the current device model.

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added NOTES and EXAMPLE to align with OSD help standards.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding()]
    param (
        [System.String]
        #Product is determined automatically by Get-MyComputerProduct
        $Product = (Get-MyComputerProduct),

        [System.String]
        [ValidateSet('Windows 11','Windows 10')]
        $OSVersion,

        [System.String]
        $OSReleaseID
    )
    $ProductDriverPacks = Get-OSDCloudDriverPacks | Where-Object {($_.Product -contains $Product)}
    #=================================================
    #   Results
    #=================================================
    if ($ProductDriverPacks) {
        if ($OSVersion) {
            $OSVersionDriverPacks = $ProductDriverPacks | Where-Object { $_.OS -match $OSVersion}
            if (-NOT $OSVersionDriverPacks) {
                $OSVersionDriverPacks = $ProductDriverPacks
            }
        }
        else {
            $OSVersionDriverPacks = $ProductDriverPacks
        }

        if ($OSReleaseID) {
            $OSReleaseIDDriverPacks = $OSVersionDriverPacks | Where-Object { $_.Name -match $OSReleaseID}
            if (-NOT $OSReleaseIDDriverPacks) {
                $OSReleaseIDDriverPacks = $OSVersionDriverPacks
            }
        }
        else {
            $OSReleaseIDDriverPacks = $OSVersionDriverPacks
        }
        $Results = $OSReleaseIDDriverPacks | Sort-Object -Property Name -Descending
        $Results[0]
    }
    else {
        Write-Verbose "Product $Product is not supported"
    }
    #=================================================
}
function Get-OSDCloudDriverPacks {
    <#
    .SYNOPSIS
    Returns the DriverPacks used by OSDCloud

    .DESCRIPTION
    Returns the DriverPacks used by OSDCloud

    .EXAMPLE
    Get-OSDCloudDriverPacks
    Returns all OSDCloud driver packs from the module catalog.

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added NOTES and EXAMPLE to align with OSD help standards.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding()]
    param ()
    $Results = Import-Clixml -Path "$(Get-OSDModulePath)\cache\driverpack-catalogs\build-driverpacks.xml"
    $Results
}
function Save-OSDCloudDriverPack {
    <#
    .SYNOPSIS
    Gets the OSDCloud DriverPack for the current or specified computer model

    .DESCRIPTION
    Gets the OSDCloud DriverPack for the current or specified computer model

    .EXAMPLE
    Save-OSDCloudDriverPack -Guid '00000000-0000-0000-0000-000000000000' -DownloadPath 'C:\Drivers'
    Downloads the specified OSDCloud driver pack to C:\Drivers.

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added NOTES and EXAMPLE to align with OSD help standards.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String[]]
        $Guid,

        [System.String]
        $DownloadPath = 'C:\Drivers',

        [System.Management.Automation.SwitchParameter]
        $Expand
    )
    begin {
        #=================================================
        #   Block
        #=================================================
        if ($Expand) {
            $CurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
            $CurrentPrincipal = [Security.Principal.WindowsPrincipal]::new($CurrentIdentity)
            if (-not $CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
                Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Administrative rights are required"
                return
            }
        }
        Block-WindowsVersionNe10
        #=================================================
        #   Create Directory
        #=================================================
        if (-NOT (Test-Path "$DownloadPath")) {
            New-Item $DownloadPath -ItemType Directory -Force -ErrorAction Stop | Out-Null
        }
        $DriverPackList = Get-OSDCloudDriverPacks
        #=================================================
    }
    process {
        foreach($Item in $Guid) {
            $DriverPack = $DriverPackList | Where-Object { $_.Guid -eq $Item }

            if ($DriverPack) {
                $OutFile = Join-Path $DownloadPath $DriverPack.FileName

                Write-Verbose -Message "ReleaseDate: $($DriverPack.ReleaseDate)"
                Write-Verbose -Message "Name: $($DriverPack.Name)"
                Write-Verbose -Message "Product: $($DriverPack.Product)"
                Write-Verbose -Message "Url: $($DriverPack.Url)"
                if ($DriverPack.HashMD5) {
                    Write-Verbose -Message "HashMD5: $($DriverPack.HashMD5)"
                }
                Write-Verbose -Message "OutFile: $OutFile"

                Save-WebFile -SourceUrl $DriverPack.Url -DestinationDirectory $DownloadPath -DestinationName $DriverPack.FileName

                if (! (Test-Path $OutFile)) {
                    Write-Warning "[$(Get-Date -format s)] Driver Pack failed to download"
                }
                else {
                    $GetItemOutFile = Get-Item $OutFile
                }
                $DriverPack | ConvertTo-Json | Out-File "$OutFile.json" -Encoding ascii -Width 2000 -Force
            }
        }
    }
    end {}
}
