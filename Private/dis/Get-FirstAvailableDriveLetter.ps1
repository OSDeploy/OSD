function Get-FirstAvailableDriveLetter {
    param()
      
    $GetVolume = Get-Volume
    # Get all available drive letters, and store in a temporary variable.
    $UsedDriveLetters = @($GetVolume | % { "$([char]$_.DriveLetter)"}) + @(Get-WmiObject -Class Win32_MappedLogicalDisk | %{$([char]$_.DeviceID.Trim(':'))})
    $TempDriveLetters = @(Compare-Object -DifferenceObject $UsedDriveLetters -ReferenceObject $( 67..90 | % { "$([char]$_)" } ) | ? { $_.SideIndicator -eq '<=' } | % { $_.InputObject })
    
    # For completeness, sort the output alphabetically
    $AvailableDriveLetter = ($TempDriveLetters | Sort-Object)
    $AvailableDriveLetter[0]
}