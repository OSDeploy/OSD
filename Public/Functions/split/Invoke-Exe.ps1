function Invoke-Exe {
    <#
    .SYNOPSIS
    Run External Command.

    .DESCRIPTION
    This function calls an external command outside of the powershell script and logs the output.

    .PARAMETER Executable
    Executable that needs to be run.

    .PARAMETER Arguments
    Arguments for the executable. Default is NULL.

    .EXAMPLE
    Invoke-Exe dir c:\
    
    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$Executable,

        [Parameter(ValueFromRemainingArguments = $true, ValueFromPipelineByPropertyName = $true)]
        $Arguments = $null
    )
    Write-Host -ForegroundColor DarkGray "Invoke-Exe '$Executable' Arguments '$Arguments'"
    $Out = &$Executable $Arguments 2>&1 | Out-String
    if ($Out.Trim()) {
        $Out.Trim().Split("`n") | ForEach-Object {
            Write-Host -ForegroundColor DarkGray "$_"
        }
    }
}