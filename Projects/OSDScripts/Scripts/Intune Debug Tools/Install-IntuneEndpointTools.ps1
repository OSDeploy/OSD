If(-not(Get-InstalledModule IntuneEndpointTools -ErrorAction silentlycontinue)){
    Install-Module -name IntuneEndpointTools -scope CurrentUser -force -Confirm:$False
}
import-module IntuneEndpointTools
Get-IntuneMDMDiagReport -OutputFolder $env:temp
Export-IntuneDiagnosticPackage -OutputFolder $env:temp

 if (!($host.name -match "ISE")) {
    	Write-Host "* DIAGNOSTICS CREATED *" -ForegroundColor Yellow
	Write-Host "Diagnostic report created here: " -NoNewline
	Write-Host "$env:temp" -ForegroundColor Green
	Write-Host "Diagnostic export package created here: " -NoNewline
	Write-Host "$env:temp\IntuneDiagnostics.zip" -ForegroundColor Green
    	
	Write-Host "Script Finalized" -ForegroundColor Green
    
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}