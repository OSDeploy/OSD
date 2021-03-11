function Select-AutoPilotJson {
    [CmdletBinding()]
    param ()
    $AutoPilotConfiguration = $null
    $AutoPilotJsons = @()
    $AutoPilotJsons = Get-PSDrive -PSProvider FileSystem | % {Get-ChildItem "$($_.Name):\*" -Include AutoPilot*.json -File -ErrorAction Ignore} | % {Get-Content $_ | ConvertFrom-Json} | Sort-Object Comment_File

    if ($AutoPilotJsons) {
        foreach ($Item in $AutoPilotJsons) {
            $i++
            $Item | Add-Member -NotePropertyName "Number" -NotePropertyValue "$i"
            Write-Host "[$i]" -ForegroundColor Green -NoNewline
            Write-Host " $($Item.Comment_File)"
            Write-Host "$($Item.CloudAssignedTenantDomain) ZtdCorrelationId: $($Item.ZtdCorrelationId)"
            Write-Host ""
        }
            #Write-Host "[S]" -ForegroundColor Green -BackgroundColor Black  -NoNewline
            #Write-Host "Skip AutoPilotConfigurationFile.json"

        do {
            $AutoPilotJson = Read-Host -Prompt "Type the Number to select an AutoPilot Profile to apply (AutoPilotConfigurationFile.json), or S to Skip"
        }
        until (
            ((($AutoPilotJson -ge 0) -and ($AutoPilotJson -in $AutoPilotJsons.Number)) -or ($AutoPilotJson -eq 'S')) 
        )
        if ($AutoPilotJson -ne 'S') {
           $AutoPilotConfiguration = $AutoPilotJsons | Where-Object {$_.Number -eq $AutoPilotJson}
           $AutoPilotConfiguration = $AutoPilotConfiguration | Select-Object -Property * -ExcludeProperty Number
        }
        Return $AutoPilotConfiguration
    }
}