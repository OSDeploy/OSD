function Start-ScriptPad {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [string]$CustomProfile,

        [string]$IndexUri
    )
    #=======================================================================
    #   Initialize
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    $Global:ScriptPad = $null
    #=======================================================================
    #	Switch CustomProfile
    #=======================================================================
    switch ($CustomProfile)
    {
        Demo        {$IndexUri = 'https://raw.githubusercontent.com/OSDeploy/ScriptPadDemo/main/ScriptPad.json'}
        OSDCloud    {$IndexUri = 'https://raw.githubusercontent.com/OSDeploy/OSDCloud/main/ScriptPad/ScriptPad.json'}
        SeguraOSD   {$IndexUri = 'https://raw.githubusercontent.com/OSDeploy/MyScriptPad/main/Index/SeguraOSD.json'}
    }
    #=======================================================================
    #	IndexUri
    #=======================================================================
    if ($IndexUri) {
        Write-Host -ForegroundColor Cyan "IndexUri: $IndexUri"
        if (Test-WebConnection -Uri $IndexUri) {
            $Global:ScriptPad = Invoke-RestMethod -Uri $IndexUri
        }
        else {
            Write-Warning "Unable to connect to ScriptPad IndexUri"
            Write-Warning "Make sure you have an Internet connection and are not Firewall blocked"
            $Global:ScriptPad = $null
        }
    }

    if (-NOT ($Global:ScriptPad)) {
        $Global:ScriptPad = @{
            Settings = @{
                Title = 'ScriptPad'
            }
        }
    }
    #=======================================================================
    #   ScriptPad.ps1
    #=======================================================================
    & "$($MyInvocation.MyCommand.Module.ModuleBase)\GUI\ScriptPad.ps1"
    #=======================================================================
}
function Start-OSDCloudScriptPad {
    [CmdletBinding()]
    param ()

    Start-ScriptPad -CustomProfile OSDCloud
}