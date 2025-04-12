$DriverPacks = Get-ChildItem -Path 'C:\Windows\Temp\osdcloud\driverpacks' -File

foreach ($Item in $DriverPacks) {
    $ExpandFile = $Item.FullName
    Write-Verbose -Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Reviewing $ExpandFile"
    $DestinationPath = Join-Path $Item.Directory $Item.BaseName
    #=================================================
    #   PPKG
    #=================================================
    if ($Item.Extension -eq '.ppkg') {
        Write-Host "Applying Provisioning Package at $($Item.FullName)"
        #$ArgumentList = "/Online /Add-ProvisioningPackage /PackagePath:`"$($Item.FullName)`""
        #Start-Process -FilePath 'dism.exe' -ArgumentList $ArgumentList -Wait -NoNewWindow
        dism.exe /Online /Add-ProvisioningPackage /PackagePath:"$($Item.FullName)"
        schtasks /Change /TN "Microsoft\Windows\Management\Provisioning\Retry" /Enable
        schtasks /Query
        Continue
    }
    #=================================================
    #   MSI
    #=================================================
    if ($Item.Extension -eq '.msi') {
        Write-Verbose -Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Processing actions for MSI file"

        $DateStamp = Get-Date -Format yyyyMMddTHHmmss
        $logFile = '{0}-{1}.log' -f $ExpandFile,$DateStamp
        $MSIArguments = @(
            "/i"
            ('"{0}"' -f $ExpandFile)
            "/qb"
            "/norestart"
            "/L*v"
            $logFile
        )
        Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow
        Continue
    }
}