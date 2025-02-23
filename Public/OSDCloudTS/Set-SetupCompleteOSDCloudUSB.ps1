Function Get-SetupCompleteOSDCloudUSB {
    <#
    .SYNOPSIS
    This function checks for the presence of an OSDCloud SetupComplete Folder on any drive other than 'C'.

    .DESCRIPTION
    This function checks for the presence of an OSDCloud SetupComplete Folder on any drive other than 'C'.
    Sorts the drives in Descending order and returns $true if the SetupComplete Folder with files inside is found.

    .NOTES
    Sorting in descending order is done to try and have the USB Drive take precedence over any other drives.
    #>

    # Get all available Drives that aren't 'C'
    $Drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -match '[a-bd-zA-BD-Z]:\\' } | Sort-Object -Property Name -Descending

    $SetupCompleteFound = $false
    # Check if any drives were found
    if ($Drives) {
        # Loop through the Drives
        foreach ($Drive in $Drives) {
            # Set the Path to the OSDCloud SetupComplete Folder
            $SetupCompletePath = $null
            $SetupCompletePath = "$($Drive.Name):\OSDCloud\Config\Scripts\SetupComplete"
            # Check if the Path exists
            $SetupComplete = $null
            if (Test-Path $SetupCompletePath) {
                $SetupComplete = Get-ChildItem $SetupCompletePath
                # Check if the Folder has any files
                if ($SetupComplete) {
                    $SetupCompleteFound = $true
                }
            }
        }
    }
    return $SetupCompleteFound
}

function Set-SetupCompleteOSDCloudUSB {
    <#
    .SYNOPSIS
    This function copies SetupComplete Files to the Local OSDCloud SetupComplete Folder
    Then onfigures the System SetupComplete.ps1 File to run the Custom Scripts from the OSDCloud SetupComplete Folder.

    .DESCRIPTION
    This function checks for the presence of an OSDCLoud SetupComplete Folder on any drive other than 'C'.
    Sorts the drives in Descending order and returns $true if the SetupComplete Folder with files inside is found.
    Copies the SetupComplete Files to the Local OSDCloud SetupComplete Folder.
    Then onfigures the System SetupComplete.ps1 File to run the Custom Scripts from the OSDCloud SetupComplete Folder.

    .NOTES
    Sorting in descending order is done to try and have the USB Drive take precedence over any other drives.
    #>
    
    # Get all available Drives that aren't 'C'
    $Drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -match '[a-bd-zA-BD-Z]:\\' } | Sort-Object -Property Name -Descending
    # Check if any drives were found
    if ($Drives) {
        # Loop through the Drives
        $ConfigureSetupCompleteCustom = $false
        foreach ($Drive in $Drives) {
            # Set the Path to the OSDCloud SetupComplete Folder
            $SetupCompletePath = $null
            $SetupCompletePath = "$($Drive.Name):\OSDCloud\Config\Scripts\SetupComplete"
            # Check if the Path exists
            $SetupComplete = $null
            if (Test-Path $SetupCompletePath) {
                $SetupComplete = Get-ChildItem $SetupCompletePath
            }
            # Check if the Folder has any files
            if ($SetupComplete) {
                # Create the Local SetupComplete Folder
                try {
                    [void][System.IO.Directory]::CreateDirectory("C:\OSDCloud\Scripts")
                    [void][System.IO.Directory]::CreateDirectory("C:\OSDCloud\Scripts\SetupComplete")
                }
                catch { throw }
                # Copy the SetupComplete Files to the Local SetupComplete Folder
                Write-Host -ForegroundColor DarkGray "Found SetupComplete Files in [$($SetupCompletePath)], Copying to 'C'"
                Copy-Item -Path $SetupCompletePath\* -Destination "C:\OSDCloud\Scripts\SetupComplete" -Recurse -Force
                $ConfigureSetupCompleteCustom = $true
  
            }
        }
        # If Custom SetupComplete Files were Copied, Configure to run them
        if ($ConfigureSetupCompleteCustom) {
            # Define the Local SetupComplete Scripts Path
            $ScriptsPath = "C:\Windows\Setup\scripts"
            # Define the SetupComplete Scripts
            $RunScript = @(@{ Script = "SetupComplete"; BatFile = 'SetupComplete.cmd'; ps1file = 'SetupComplete.ps1'; Type = 'Setup'; Path = "$ScriptsPath" })
            # Build the Path to the SetupComplete.ps1 File
            $PSFilePath = "$($RunScript.Path)\$($RunScript.ps1File)"
            # Check if the SetupComplete.ps1 File exists
            if (Test-Path -Path $PSFilePath) {
                # Add the SetupComplete Script to the SetupComplete.ps1 File
                Add-Content -Path $PSFilePath "Write-OutPut 'Running Scripts in Custom OSDCloud SetupComplete Folder'"
                Add-Content -Path $PSFilePath '$SetupCompletePath = "C:\OSDCloud\Scripts\SetupComplete\SetupComplete.cmd"'
                Add-Content -Path $PSFilePath 'if (Test-Path $SetupCompletePath) { $SetupComplete = Get-ChildItem $SetupCompletePath -Filter SetupComplete.cmd }'
                Add-Content -Path $PSFilePath 'if ($SetupComplete){ cmd.exe /start /wait /c $SetupComplete.FullName }'
                Add-Content -Path $PSFilePath "Write-Output '-------------------------------------------------------------'"
            }
            else {
                Write-Output "$PSFilePath - Not Found"
            }
        }
    }
}

function Set-SetupCompleteOSDCloudCustom {
    $OSDCloudSetupCompletePath = "C:\OSDCloud\Scripts\SetupComplete"
    try {
        [void][System.IO.Directory]::CreateDirectory("C:\OSDCloud\Scripts")
        [void][System.IO.Directory]::CreateDirectory("$OSDCloudSetupCompletePath")
    }
    catch { throw }

    $ScriptsPath = "C:\Windows\Setup\scripts"
    $RunScript = @(@{ Script = "SetupComplete"; BatFile = 'SetupComplete.cmd'; ps1file = 'SetupComplete.ps1'; Type = 'Setup'; Path = "$ScriptsPath" })
    $PSFilePath = "$($RunScript.Path)\$($RunScript.ps1File)"

    if (Test-Path -Path $PSFilePath) {
        Add-Content -Path $PSFilePath "Write-OutPut 'Running Scripts in Custom OSDCloud SetupComplete Folder'"
        Add-Content -Path $PSFilePath '$SetupCompletePath = "C:\OSDCloud\Scripts\SetupComplete\SetupComplete.cmd"'
        Add-Content -Path $PSFilePath 'if (Test-Path $SetupCompletePath){$SetupComplete = Get-ChildItem $SetupCompletePath -Filter SetupComplete.cmd}'
        Add-Content -Path $PSFilePath 'if ($SetupComplete){cmd.exe /start /wait /c $SetupComplete.FullName}'
        Add-Content -Path $PSFilePath "Write-Output '-------------------------------------------------------------'"
    }
    else {
        Write-Output "$PSFilePath - Not Found"
    }
}