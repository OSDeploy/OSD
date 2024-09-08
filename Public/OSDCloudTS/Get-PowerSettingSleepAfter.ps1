Function Get-PowerSettingSleepAfter {
# Get active plan
    # Get-CimInstance won't work due to Get-CimInstance -Namespace root\cimv2\power -ClassName Win32_PowerPlan doesn't have the "Activate" trigger as Get-WmiObject does
    $CurrentPlan = Get-WmiObject -Namespace root\cimv2\power -ClassName Win32_PowerPlan | Where-Object -FilterScript {$_.IsActive}

    # Get "Lid closed" setting
    $SleepAfterSetting = Get-CimInstance -Namespace root\cimv2\power -ClassName Win32_Powersetting | Where-Object -FilterScript {$_.ElementName -eq "Sleep after"}

    # Get GUIDs
    $CurrentPlanGUID = [Regex]::Matches($CurrentPlan.InstanceId, "{.*}" ).Value
    $SleepAfterGUID = [Regex]::Matches($SleepAfterSetting.InstanceID, "{.*}" ).Value

    # Get "Plugged in lid" setting (DC)

    $DC = Get-CimInstance -Namespace root\cimv2\power -ClassName Win32_PowerSettingDataIndex | Where-Object -FilterScript {
        ($_.InstanceID -eq "Microsoft:PowerSettingDataIndex\$CurrentPlanGUID\DC\$SleepAfterGUID")
        }
    # Get "Plugged in lid" setting (AC)

	    $AC = Get-CimInstance -Namespace root\cimv2\power -ClassName Win32_PowerSettingDataIndex | Where-Object -FilterScript {
	    ($_.InstanceID -eq "Microsoft:PowerSettingDataIndex\$CurrentPlanGUID\AC\$SleepAfterGUID")
        }
    [int]$ACMinutes = $AC.SettingIndexValue / 60
    [int]$DCMinutes = $DC.SettingIndexValue / 60
    $ReturnResults = New-Object System.Object
    $ReturnResults | Add-Member -MemberType NoteProperty -Name "AC" -Value $ACMinutes -Force
    $ReturnResults | Add-Member -MemberType NoteProperty -Name "DC" -Value $DCMinutes -Force
    return $ReturnResults
}
