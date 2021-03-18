function Start-Waiting {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true)]
        [int]$Seconds = 5,
    
        [string]$Activity = "Waiting",
    
        [string]$Status = "Time remaining ,,,,"
    )

    $FinishTime = (Get-Date).AddSeconds($Seconds)
    while ($FinishTime -gt (Get-Date)) {
        $SecondsLeft = $FinishTime.Subtract((Get-Date)).TotalSeconds
        $Percent = ($Seconds - $SecondsLeft) / $Seconds * 100
        Write-Progress -Activity $Activity -Status $Status -SecondsRemaining $SecondsLeft -PercentComplete $Percent
        [System.Threading.Thread]::Sleep(500)
    }
    Write-Progress -Activity $Activity -Status $Status -SecondsRemaining 0 -Completed
}