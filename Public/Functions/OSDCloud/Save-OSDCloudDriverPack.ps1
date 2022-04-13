function Save-OSDCloudDriverPack {
    <#
    .SYNOPSIS`
    Gets the OSDCloud DriverPack for the current or specified computer model

    .DESCRIPTION
    Gets the OSDCloud DriverPack for the current or specified computer model

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
            Block-StandardUser
        }
        Block-WindowsVersionNe10
        #=================================================
        #   Create Directory
        #=================================================
        if (-NOT (Test-Path "$DownloadPath")) {
            New-Item $DownloadPath -ItemType Directory -Force -ErrorAction Stop | Out-Null
        }
        $DriverPackList = Get-OSDCloudDriverPackList
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
                Write-Verbose -Message "Url: $($DriverPack.DriverPackUrl)"
                if ($DriverPack.HashMD5) {
                    Write-Verbose -Message "HashMD5: $($DriverPack.HashMD5)"
                }
                Write-Verbose -Message "OutFile: $OutFile"
        
                Save-WebFile -SourceUrl $DriverPack.DriverPackUrl -DestinationDirectory $DownloadPath -DestinationName $DriverPack.FileName
        
                if (! (Test-Path $OutFile)) {
                    Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Driver Pack failed to download"
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