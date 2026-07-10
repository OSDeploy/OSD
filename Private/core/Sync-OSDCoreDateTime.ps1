function Sync-OSDCoreDateTime {
    <#
    .SYNOPSIS
        Synchronizes the system clock with internet time from Google.

    .DESCRIPTION
        Retrieves the current time from Google's HTTP Date header and compares it with the local system time.
        If the time difference exceeds the specified threshold and the system is running in WinPE (X: drive),
        the function will update the system clock to match the internet time.

        Note: Uses HTTP instead of HTTPS to avoid certificate validation issues that may occur when the
        system clock is significantly out of sync.

    .PARAMETER ThresholdMinutes
        The minimum time difference in minutes required to trigger a synchronization warning or action.
        Default is 5 minutes.

    .PARAMETER Force
        When specified, actually updates the system clock when the time difference exceeds the threshold.
        Without this parameter, the function only reports time differences without making changes.

    .PARAMETER PassThru
        Returns an object containing the synchronization results including local time, internet time,
        time difference, and whether the clock was updated.

    .EXAMPLE
        Sync-OSDCoreDateTime

        Checks the system time against internet time and reports any differences (in WinPE environment).

    .EXAMPLE
        Sync-OSDCoreDateTime -Force

        Checks and actually updates the system clock if the time difference exceeds the threshold.

    .EXAMPLE
        Sync-OSDCoreDateTime -ThresholdMinutes 30 -Force -PassThru

        Uses a 30-minute threshold, updates the clock if needed, and returns detailed synchronization results.

    .NOTES
        This function only modifies the system clock when running in Windows Preinstallation Environment (WinPE),
        detected by checking if the system drive is X:.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()]
        [ValidateRange(1, 1440)]
        [int]$ThresholdMinutes = 5,

        [Parameter()]
        [switch]$Force,

        [Parameter()]
        [switch]$PassThru
    )

    begin {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Starting internet time synchronization check"
    }

    process {
        $result = [PSCustomObject]@{
            LocalDateTime    = $null
            InternetDateTime = $null
            DifferenceMinutes = $null
            IsWinPE          = $env:SystemDrive -eq "X:"
            ClockUpdated     = $false
            Success          = $false
            ErrorMessage     = $null
        }

        try {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Retrieving time from Google"
            $googleResponse = Invoke-WebRequest -Uri "http://www.google.com" -UseBasicParsing -Method Head -ErrorAction Stop
            $googleDateHeaderRaw = $googleResponse.Headers["Date"]
            if ($googleDateHeaderRaw -is [System.Array]) {
                $googleDateHeader = $googleDateHeaderRaw | Select-Object -First 1
            }
            else {
                $googleDateHeader = $googleDateHeaderRaw
            }

            if ([string]::IsNullOrWhiteSpace($googleDateHeader)) {
                $result.ErrorMessage = "No Date header received from Google"
                Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] $($result.ErrorMessage)"
                if ($PassThru) { return $result }
                return
            }

            $internetDateTime = [System.DateTimeOffset]::MinValue
            $dateParseStyles = [System.Globalization.DateTimeStyles]::AllowWhiteSpaces -bor [System.Globalization.DateTimeStyles]::AssumeUniversal -bor [System.Globalization.DateTimeStyles]::AdjustToUniversal
            $parsedDate = [System.DateTimeOffset]::TryParse($googleDateHeader, [System.Globalization.CultureInfo]::InvariantCulture, $dateParseStyles, [ref]$internetDateTime)

            if ($parsedDate) {
                $result.LocalDateTime = Get-Date
                $result.InternetDateTime = $internetDateTime.LocalDateTime
                $result.Success = $true

                Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Local time: $($result.LocalDateTime)"
                Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Internet time: $($result.InternetDateTime)"
            }
            else {
                $result.ErrorMessage = "Unable to parse Date header from Google response: $googleDateHeader"
                Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] $($result.ErrorMessage)"
                if ($PassThru) { return $result }
                return
            }
        }
        catch {
            $result.ErrorMessage = $_.Exception.Message
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Failed to retrieve current time from Google. Error: $($result.ErrorMessage)"
            if ($PassThru) { return $result }
            return
        }

        if ($result.LocalDateTime -and $result.InternetDateTime) {
            $result.DifferenceMinutes = [math]::Round([math]::Abs(($result.InternetDateTime - $result.LocalDateTime).TotalMinutes))

            if ($result.DifferenceMinutes -gt $ThresholdMinutes) {
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Time difference of $($result.DifferenceMinutes) minutes exceeds threshold of $ThresholdMinutes minutes"

                if ($result.IsWinPE) {
                    if ($Force) {
                        if ($PSCmdlet.ShouldProcess("System Clock", "Set to $($result.InternetDateTime)")) {
                            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Setting system clock to internet time"
                            try {
                                $null = Set-Date -Date $result.InternetDateTime -ErrorAction Stop
                                $result.ClockUpdated = $true
                                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] System clock successfully updated"
                            }
                            catch {
                                $result.ErrorMessage = "Failed to set system clock: $($_.Exception.Message)"
                                Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] $($result.ErrorMessage)"
                            }
                        }
                    }
                    else {
                        Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] System clock is $($result.DifferenceMinutes) minutes out of sync with internet time"
                        Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Use -Force parameter to update the system clock"
                    }
                }
                else {
                    Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] System clock is $($result.DifferenceMinutes) minutes out of sync with internet time"
                    Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Please synchronize your system clock manually (not in WinPE environment)"
                }
            }
            else {
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] System clock is synchronized within threshold ($($result.DifferenceMinutes) minutes difference)"
            }
        }

        if ($PassThru) {
            return $result
        }
    }
}
