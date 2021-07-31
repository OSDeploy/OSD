function Start-ScriptPad {
    [CmdletBinding()]
    param (
        [string]$JsonUri
    )
    #=======================================================================
    #   PreFlight
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    $Global:ScriptPad = $null

    if ($JsonUri) {
        Write-Host -ForegroundColor Cyan "JsonUri: $JsonUri"
        if (Test-WebConnection -Uri $JsonUri) {
            $Global:ScriptPad = Invoke-RestMethod -Uri $JsonUri
        }
        else {
            Write-Warning "Unable to connect to ScriptPad JsonUri"
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
    #   Flight
    #=======================================================================
    & "$($MyInvocation.MyCommand.Module.ModuleBase)\GUI\ScriptPad.ps1"
    #=======================================================================
}
function Start-OSDCloudScriptPad {
    [CmdletBinding()]
    param ()

    Start-ScriptPad -JsonUri 'https://raw.githubusercontent.com/OSDeploy/OSDCloud/main/ScriptPad/ScriptPad.json'
}