function Invoke-Exe {
    <#
    .SYNOPSIS
    Runs an external command.

    .DESCRIPTION
    Calls an external command outside of the PowerShell script and logs the output.

    .PARAMETER Executable
    Executable that needs to be run.

    .PARAMETER Arguments
    Arguments for the executable. Default is NULL.

    .EXAMPLE
    Invoke-Exe dir c:\

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-13 - Improved readability and completed help metadata without changing behavior
    #>

    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$Executable,

        [Parameter(ValueFromRemainingArguments = $true, ValueFromPipelineByPropertyName = $true)]
        $Arguments = $null
    )

    Write-Host -ForegroundColor DarkGray "Invoke-Exe '$Executable' Arguments '$Arguments'"
    $commandOutput = &$Executable $Arguments 2>&1 | Out-String
    $trimmedOutput = $commandOutput.Trim()

    if ($trimmedOutput) {
        $trimmedOutput.Split("`n") | ForEach-Object {
            Write-Host -ForegroundColor DarkGray "$_"
        }
    }
}
