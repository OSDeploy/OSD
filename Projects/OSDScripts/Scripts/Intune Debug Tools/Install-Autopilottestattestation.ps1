If(-not(Get-InstalledModule autopilottestattestation -ErrorAction silentlycontinue)){
    Install-Module -name autopilottestattestation -scope CurrentUser -force -Confirm:$False
}
import-module autopilottestattestation
test-AutopilotAttestation

 if (!($host.name -match "ISE")) {
    Write-Host ""
    Write-Host "Script Finalized"
    
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}