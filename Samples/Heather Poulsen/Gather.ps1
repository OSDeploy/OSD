<#
Created:	 2013-01-08
Version:	 1.0
Author       Mikael Nystrom and Johan Arwidmark       
Homepage:    http://www.deploymentartist.com

Disclaimer:
This script is provided "AS IS" with no warranties, confers no rights and 
is not supported by the authors or DeploymentArtist.

Author - Mikael Nystrom
    Twitter: @mikael_nystrom
    Blog   : http://deploymentbunny.com

Author - Johan Arwidmark
    Twitter: @jarwidmark
    Blog   : http://deploymentresearch.com
#>


# Check for elevation
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Oupps, you need to run this script from an elevated PowerShell prompt!`nPlease start the PowerShell prompt as an Administrator and re-run the script."
    Write-Warning "Aborting script..."
    Break
}

cls
if (Test-Path -Path "C:\MININT") {Write-Host "C:\MININT exists, deleting...";Remove-Item C:\MININT -Recurse}
cscript.exe ZTIGather.wsf /debug:true
# C:\Tools\CMTrace C:\MININT\SMSOSD\OSDLOGS\ZTIGather.log