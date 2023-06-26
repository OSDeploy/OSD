###################################################################################################################
# Name: Invoke-AutopilotPrereqCheck.ps1
# Author: Thomas Marcussen, Thomas@ThomasMarcussen.com
# Date: March,2023
# Version: 1.0.1
# https://github.com/ThomasMarcussen/assortedScripts/blob/master/Invoke-AutopilotPrereqChecks.ps1
###################################################################################################################
<#
	.SYNOPSIS
	Script to check for Intune Autopilot prerequisites.
	.DESCRIPTION
	Script to check for Intune Autopilot prerequisites.
	
	* Tenant checks 
		-- Check license requirements 
		-- Automatic Windows enrollment (MDM authority is set) 
		-- DNS records 
		-- Check user can join device to Azure AD 
		-- Check Enrollment Status Page 
		-- Check Windows Autopilot Deployment Profile 
		-- Check company branding 

	* Device checks 
		-- Windows OS version 
		-- TPM checks (IS NOT AN INTUNE PREREQUISITE)
		-- Hardware hash uploaded to Intune 
		-- Check Windows Autopilot Deployment Profile assignment status 

	* User checks 
		-- User is licensed correctly 

	* Network checks 
		-- Required communication for Intune Autopilot is allowed
                -- Updated with multiple URLs
	
	Script prerequisites:
	1. A minimum Windows PowerShell version of '7.2' is required to run this script. The script automatically checks for and installs module if needed.
	
	2. Microsoft Graph PowerShell Module must be installed on local machine. The script automatically checks for and installs module if needed.

	3. An Azure AD user that has an admin consent permission, if needed, to approve the following permissions in Microsoft Graph application in Azure AD apps:
	CloudPC.ReadWrite.All, DeviceManagementConfiguration.ReadWrite.All, DeviceManagementManagedDevices.ReadWrite.All, Directory.Read.All
	.PARAMETER DomainName
	Specifies the public DNS name to check for Autopilot DNS records. If blank, then "Check Autopilot DNS Records: (TEST #3)" will be skipped.
	.PARAMETER UserName
	Specifies the username to check for Intune licensing. If blank, then "Check user is licensed correctly : (TEST #11)" will be skipped.
	.PARAMETER DeviceGroup
	Specifies the device group to check for Autopilot deployment profile assignment. If blank, then "Check Windows Autopilot Deployment Profile assignment status: (TEST #10)" will be skipped.
	.PARAMETER LogPath
	Specifies path to save script output to.
	.EXAMPLE
	.\Invoke-AutopilotPrereqChecks.ps1 -DomainName xyz.com -Username user123@xyz.com -DeviceGroup APComputers -LogPath .\

#>

param (
	[Parameter(mandatory = $false)][string] $DomainName,
	[Parameter(mandatory = $false)][string] $UserName,
	[Parameter(mandatory = $false)][string] $DeviceGroup,
	[Parameter(mandatory = $false)][string] $LogPath
)

if ($LogPath) {
	$ErrorActionPreference="SilentlyContinue"
	Stop-Transcript | out-null
	$ErrorActionPreference = "Continue"
	$log_file = $LogPath + "\" + (Get-Date -f yyyy-MM-dd_HH-mm-ss) + "_Invoke-AutopilotPrereqChecks_Output.log"
	Start-Transcript -path $log_file -append
}

#443 Ports to check
$connections443 = @(
    [pscustomobject]@{uri='www.msftconnecttest.com';Area='Internet connection test'},
    [pscustomobject]@{uri='ztd.dds.microsoft.com';Area='Autopilot Service'},
    [pscustomobject]@{uri='cs.dds.microsoft.com';Area='Autopilot Service'},
    [pscustomobject]@{uri='login.live.com';Area='Autopilot Service'},

    [pscustomobject]@{uri='login.microsoftonline.com';Area='Microsoft authentication'},
    [pscustomobject]@{uri='aadcdn.msauth.net';Area='Microsoft authentication'},

    [pscustomobject]@{uri='enterpriseregistration.windows.net';Area='Intune'},
    [pscustomobject]@{uri='enterpriseenrollment-s.manage.microsoft.com';Area='Intune'},
    [pscustomobject]@{uri='enterpriseEnrollment.manage.microsoft.com';Area='Intune'},
    [pscustomobject]@{uri='enrollment.manage.microsoft.com';Area='Intune'},
    [pscustomobject]@{uri='portal.manage.microsoft.com';Area='Intune'},
    [pscustomobject]@{uri='config.office.com';Area='Intune'},
    [pscustomobject]@{uri='graph.windows.net';Area='Intune'},
    [pscustomobject]@{uri='m.manage.microsoft.com';Area='Intune'},
    [pscustomobject]@{uri='fef.msuc03.manage.microsoft.com';Area='Intune'},
    [pscustomobject]@{uri='mam.manage.microsoft.com';Area='Intune'},
    [pscustomobject]@{uri='manage.microsoft.com';Area='Intune'},

    [pscustomobject]@{uri='activation.sls.microsoft.com';Area='License activation'},
    [pscustomobject]@{uri='licensing.mp.microsoft.com';Area='License activation'},
    [pscustomobject]@{uri='validation-v2.sls.microsoft.com';Area='License activation'},
    [pscustomobject]@{uri='validation.sls.microsoft.com';Area='License activation'},
    [pscustomobject]@{uri='purchase.mp.microsoft.com';Area='License activation'},
    [pscustomobject]@{uri='purchase.md.mp.microsoft.com';Area='License activation'},
    [pscustomobject]@{uri='licensing.md.mp.microsoft.com';Area='License activation'},
    [pscustomobject]@{uri='go.microsoft.com';Area='License activation'},
    [pscustomobject]@{uri='displaycatalog.md.mp.microsoft.com';Area='License activation'},
    [pscustomobject]@{uri='displaycatalog.mp.microsoft.com';Area='License activation'},
    [pscustomobject]@{uri='activation-v2.sls.microsoft.com';Area='License activation'},
    [pscustomobject]@{uri='activation.sls.microsoft.com';Area='License activation'},

    [pscustomobject]@{uri='emdl.ws.microsoft.com';Area='Windows Update'},
    [pscustomobject]@{uri='dl.delivery.mp.microsoft.com';Area='Windows Update'},
    [pscustomobject]@{uri='update.microsoft.com';Area='Windows Update'},
    [pscustomobject]@{uri='fe2cr.update.microsoft.com';Area='Windows Update'},

    [pscustomobject]@{uri='autologon.microsoftazuread-sso.com';Area='Single sign-on'},

    [pscustomobject]@{uri='powershellgallery.com';Area='Powershell gallery'},

    [pscustomobject]@{uri='ekop.intel.com';Area='TPM check'},
    [pscustomobject]@{uri='ekcert.spserv.microsoft.com';Area='TPM check'},
    [pscustomobject]@{uri='ftpm.amd.com';Area='TPM check'},

    [pscustomobject]@{uri='naprodimedatapri.azureedge.net';Area='Powershell and Win32'},
    [pscustomobject]@{uri='naprodimedatasec.azureedge.net';Area='Powershell and Win32'},
    [pscustomobject]@{uri='naprodimedatahotfix.azureedge.net';Area='Powershell and Win32'},
    [pscustomobject]@{uri='euprodimedatapri.azureedge.net';Area='Powershell and Win32'},
    [pscustomobject]@{uri='euprodimedatasec.azureedge.net';Area='Powershell and Win32'},
    [pscustomobject]@{uri='euprodimedatahotfix.azureedge.net';Area='Powershell and Win32'},
    [pscustomobject]@{uri='approdimedatapri.azureedge.net';Area='Powershell and Win32'},
    [pscustomobject]@{uri='approdimedatasec.azureedge.net';Area='Powershell and Win32'},
    [pscustomobject]@{uri='approdimedatahotfix.azureedge.net';Area='Powershell and Win32'},

    [pscustomobject]@{uri='v10c.events.data.microsoft.com';Area='Update Compliance'},
    [pscustomobject]@{uri='v10.vortex-win.data.microsoft.com';Area='Update Compliance'},
    [pscustomobject]@{uri='settings-win.data.microsoft.com';Area='Update Compliance'},
    [pscustomobject]@{uri='adl.windows.com';Area='Update Compliance'},
    [pscustomobject]@{uri='watson.telemetry.microsoft.com';Area='Update Compliance'},
    [pscustomobject]@{uri='oca.telemetry.microsoft.com';Area='Update Compliance'}       
)

#80 Ports to check
$connections80 = @(
    [pscustomobject]@{uri='emdl.ws.microsoft.com';Area='Windows Update'},
    [pscustomobject]@{uri='dl.delivery.mp.microsoft.com';Area='Windows Update'}
)

function Get-ConnectionTest {
    param(
		[Parameter(Mandatory)] $connections,
		[Parameter(Mandatory)] [int]$port
	)

    write-host -ForegroundColor yellow "Testing port $port :"

    $connections | ForEach-Object {
        $result = (Test-NetConnection -Port $port -ComputerName $_.uri)    
        if ($_.Area -eq 'Autopilot Service' -or $_.Area -eq 'Internet connection test') {
			write-host -ForegroundColor yellow -NoNewline " **AUTOPILOT MANDATORY** $($_.area): $($result.ComputerName) ($($result.RemoteAddress)): "
		} else {
			write-host -ForegroundColor yellow -NoNewline " **Autopilot Optional** $($_.area): $($result.ComputerName) ($($result.RemoteAddress)): "
		}
        if ($result.TcpTestSucceeded) {
            write-host -ForegroundColor Green $result.TcpTestSucceeded
        } else {
            write-host -ForegroundColor Red $result.TcpTestSucceeded
        }
    }
    Write-Host
}

function Get-OtherConnectionsTested {
    param(
		[Parameter(Mandatory)]
		$connections
	)

    $msEndpoints = @()
    (invoke-restmethod -Uri ("https://endpoints.office.com/endpoints/WorldWide?ServiceAreas=MEM`&clientrequestid=" + ([GUID]::NewGuid()).Guid)) | ?{$_.ServiceArea -eq "MEM" -and $_.urls} | select -ExpandProperty urls | ForEach-Object {
        #$msEndpoints += $_.Replace("*.", "")
        $msEndpoints += $_
    }
    $msEndpoints = $msEndpoints | Where-Object {$_ -notmatch "\*." -and $_ -notin $connections}    
    Write-Host -ForegroundColor yellow "Checking other endpoints (not all are necessary for enrollment) (443):"

    $msEndpoints | ForEach-Object {
        $result = (Test-NetConnection -Port 443 -ComputerName $_)    
        Write-Host -NoNewline "  Other Connections: $($result.ComputerName) ($($result.RemoteAddress)): "
        if($result.TcpTestSucceeded) {
            Write-Host -ForegroundColor Green $result.TcpTestSucceeded
        }else{
            Write-Host -ForegroundColor Red $result.TcpTestSucceeded
        }
    }
    Write-Host
}

function Get-NtpTime ( [String]$NTPServer )
# credits to https://madwithpowershell.blogspot.com/2016/06/getting-current-time-from-ntp-service.html
{
	# Build NTP request packet. We'll reuse this variable for the response packet
	$NTPData    = New-Object byte[] 48  # Array of 48 bytes set to zero
	$NTPData[0] = 27                    # Request header: 00 = No Leap Warning; 011 = Version 3; 011 = Client Mode; 00011011 = 27

	try {
		# Open a connection to the NTP service
		$Socket = New-Object Net.Sockets.Socket ( 'InterNetwork', 'Dgram', 'Udp' )
		$Socket.SendTimeOut    = 2000  # ms
		$Socket.ReceiveTimeOut = 2000  # ms
		$Socket.Connect( $NTPServer, 123 )

		# Make the request
		$Null = $Socket.Send(    $NTPData )
		$Null = $Socket.Receive( $NTPData )

		# Clean up the connection
		$Socket.Shutdown( 'Both' )
		$Socket.Close()
	}

	catch {
		return $null
	}

	# Extract relevant portion of first date in result (Number of seconds since "Start of Epoch")
	$Seconds = [BitConverter]::ToUInt32( $NTPData[43..40], 0 )

	# Add them to the "Start of Epoch", convert to local time zone, and return
	( [datetime]'1/1/1900' ).AddSeconds( $Seconds ).ToLocalTime()
}

function Get-NtpTimeTested{
    Write-Host -ForegroundColor blue "Test NTP:"
    $timeserver = "time.windows.com"
    Write-Host -NoNewline "  Time Server: $timeserver "
    $timeserverip = (Resolve-DnsName -Name $timeserver -ErrorAction SilentlyContinue).IP4Address
    if( $null -eq $timeserverip ) {
        Write-Host -ForegroundColor Red ": False (not resolved)"
    } else {
        Write-Host -NoNewline "($timeserverip): "
        $time = Get-NtpTime($timeserver)
        if($null -ne $time){
            Write-Host -ForegroundColor Green "True ($time)"
        }else{
            Write-Host -ForegroundColor Red ": False (Not Time response)"
        }
    }
}


if (-not(Get-InstalledModule -Name Microsoft.graph -MinimumVersion 1.9.6)) {
	Write-host -ForegroundColor green "`nMicrosoft Grapgh PS module was not found. Installing ..."
	Install-Module microsoft.graph -scope CurrentUser -Force -AllowClobber -verbose
	}

Write-host -ForegroundColor green "`nConnecting to Microsoft Graph API. If not authenticated already in this PowerShell session, you will be prompted for your Azure AD credentials. `n`nPlease use an account that can grant consent on the following permissions: 
`nOrganization.Read.All `nPolicy.Read.All `nDeviceManagementServiceConfig.Read.All `nDirectory.Read.All`n"

try { Connect-MgGraph -Scopes "Organization.Read.All", "Policy.Read.All", "DeviceManagementServiceConfig.Read.All", "Directory.Read.All"
}
catch [System.Exception] {
	throw "$($MyInvocation.MyCommand): failed to connect to Microsoft Graph API with the follwing error: $($_.Exception.Message)"
}

Write-host -ForegroundColor green "`nConnected Successfully to Microsoft Graph API."

Select-MgProfile beta

write-host -ForegroundColor white "************************************************************"

#*Tenant checks 
#	-- Check license requirements
write-host -ForegroundColor green "`nTenant checks`n	-- Check license requirements: (TEST #1)"
[System.Boolean]$IntuneLicense = $False
$SKUs = Get-MgSubscribedSku
foreach ($SKU in  $SKUs) {
	$SKUPlans = $SKU.serviceplans.ServicePlanName | Select-String -Pattern 'intune' -SimpleMatch
	if (![string]::IsNullOrWhiteSpace($SKUPlans)) {
		$IntuneLicense = $true
	}
}

if (!($IntuneLicense)) {
	write-host -ForegroundColor red "`nFAILED - None of tenant licenses contain Intune features."
}
else {
	write-host -ForegroundColor green "`nPASSED - One or more of your tenant licenses contain Intune features"
}

write-host -ForegroundColor white "************************************************************"

#* Tenant checks 
#	-- Automatic Windows enrollment (MDM authority is set)
write-host -ForegroundColor green "`nTenant checks`n	-- Automatic Windows enrollment (MDM authority is set): (TEST #2)"
$MDMSettings = Get-MgPolicyMobileDeviceManagementPolicy -MobilityManagementPolicyId 0000000a-0000-0000-c000-000000000000 -ExpandProperty includedGroups

#MDM user scope
if ($MDMSettings.AppliesTo -eq 'none') {
	write-host -ForegroundColor red "`nFAILED - MDM Policy scope is set to None."
} elseif ($MDMSettings.AppliesTo -eq 'all') {
	write-host -ForegroundColor green "`nPASSED - MDM Policy scope is set to all users."
} elseif ($MDMSettings.AppliesTo -eq 'selected') {
	write-host -ForegroundColor green "`nPASSED - MDM Policy scope is set to the following group(s) of users."
	$MDMSettings.IncludedGroups.displayname
}


#MDM terms of use URL
if ($MDMSettings.TermsOfUseUrl -ne 'https://portal.manage.microsoft.com/TermsofUse.aspx') {
	write-host -ForegroundColor red "`nFAILED - MDM terms of use URL does not match the default value."
} else {
	write-host -ForegroundColor green "`nPASSED - MDM terms of use URL matches the default value."
}

#MDM discovery URL
if ($MDMSettings.DiscoveryUrl -ne 'https://enrollment.manage.microsoft.com/enrollmentserver/discovery.svc') {
	write-host -ForegroundColor red "`nFAILED - MDM discovery URL does not match the default value."
} else {
	write-host -ForegroundColor green "`nPASSED - MDM discovery URL matches the default value."
}

#MDM compliance URL
if ($MDMSettings.ComplianceUrl -ne 'https://portal.manage.microsoft.com/?portalAction=Compliance') {
	write-host -ForegroundColor red "`nFAILED - MDM compliance URL does not match the default value."
} else {
	write-host -ForegroundColor green "`nPASSED - MDM compliance URL matches the default value."
}

write-host -ForegroundColor white "************************************************************"

#*Tenant checks 
#	-- DNS Records
write-host -ForegroundColor green "`nTenant checks`n	-- Check Autopilot DNS Records: (TEST #3)"
if (![string]::IsNullOrWhiteSpace($DomainName)) {
	if ((Resolve-DnsName -Name EnterpriseEnrollment.$DomainName -Type CNAME).namehost -ne 'EnterpriseEnrollment-s.manage.microsoft.com') {
		write-host -ForegroundColor red "`nFAILED - EnterpriseEnrollment CNAME DNS record does not match the required value."
	} else {
		write-host -ForegroundColor green "`nPASSED - EnterpriseEnrollment CNAME DNS record matches the required value."
	}
	
	if ((Resolve-DnsName -Name EnterpriseRegistration.$DomainName -Type CNAME).namehost -ne 'EnterpriseRegistration.windows.net') {
		write-host -ForegroundColor red "`nFAILED - EnterpriseRegistration CNAME DNS record does not match the required value."
	} else {
		write-host -ForegroundColor green "`nPASSED - EnterpriseRegistration CNAME DNS record matches the required value."
	}

} else {
	write-host -ForegroundColor yellow "`nSKIPPED - Autopilot DNS Records check was skipped."
}

write-host -ForegroundColor white "************************************************************"

#*Tenant checks 
#	-- Check user can join device to Azure AD 
write-host -ForegroundColor green "`nTenant checks`n	-- Check user can join device to Azure AD: (TEST #4)"
$DeviceRegPolicy = (Get-MgPolicyDeviceRegistrationPolicy -Property AzureAdJoin).azureadjoin
switch ($DeviceRegPolicy.AppliesTo) {
	0 {write-host -ForegroundColor red "`nFAILED - No users can join device to Azure AD."}
	1 {write-host -ForegroundColor green "`nPASSED - All users can join device to Azure AD."}
	2 {write-host -ForegroundColor yellow "`nPASSED - Some users/groups can join device to Azure AD."}
	}

write-host -ForegroundColor white "************************************************************"

#*Tenant checks 
#	-- Check Enrollment Status Page
write-host -ForegroundColor green "`nTenant checks`n	-- Check Enrollment Status Page: (TEST #5)"
$ESPConfig = Get-MgDeviceManagementDeviceEnrollmentConfiguration  -ExpandProperty "assignments" -Filter "DeviceEnrollmentConfigurationType eq 'windows10EnrollmentCompletionPageConfiguration'"
#######

write-host -ForegroundColor white "************************************************************"

#*Tenant checks 
#	-- Check Windows Autopilot Deployment Profile
write-host -ForegroundColor green "`nTenant checks`n	-- Check Windows Autopilot deployment profile: (TEST #6)"
$APDeploymentProfiles = Get-MgDeviceManagementWindowAutopilotDeploymentProfile -ExpandProperty "assignments" -Top 50
if ($APDeploymentProfiles -eq $null) {
	write-host -ForegroundColor red "`nFAILED - No Windows Autopilot deployment profile was found."
} else {
	write-host -ForegroundColor green "`nPASSED - At least one Windows Autopilot deployment profile was found."
}

write-host -ForegroundColor white "************************************************************"

#*Tenant checks 
#	-- Check company branding
write-host -ForegroundColor green "`nTenant checks`n	-- Check company branding: (TEST #7)"
$OrgBrandingLoc = Get-MgOrganizationBrandingLocalization -OrganizationId ((Get-MgOrganization).id)
switch ($OrgBrandingLoc) {
	{$_.BackgroundImageRelativeUrl -eq $null} {write-host -ForegroundColor red "`nFAILED - Sign-in page background image is empty."}
	{$_.BannerLogoRelativeUrl -eq $null} {write-host -ForegroundColor red "`nFAILED - Banner logo is empty."}
	{$_.UsernameHintText -eq $null} {write-host -ForegroundColor red "`nFAILED - Username hint is empty."}
	{$_.SignInPageText -eq $null} {write-host -ForegroundColor red "`nFAILED - Sign-in page text is empty."}
	{$_.SquareLogoDarkRelativeUrl -eq $null} {write-host -ForegroundColor red "`nFAILED - Square logo dark theme is empty."}
	{$_.SquareLogoRelativeUrl -eq $null} {write-host -ForegroundColor red "`nFAILED - Square logo light theme image is empty."}
	default {write-host -ForegroundColor green "`nPASSED - Company branding following attributes were populated: Sign-in page background image, Banner logo, Square logo image, Username hint, and Sign-in page text."}
	}

write-host -ForegroundColor white "************************************************************"

#* Device checks 
#	-- Windows OS edition 
write-host -ForegroundColor green "`nDevice checks `n	-- Windows OS version and edition: (TEST #8)"
$ComputerInfo = Get-ComputerInfo
switch ($ComputerInfo.WindowsEditionId) {
	{$_ -like '*enterprise*'} {write-host -ForegroundColor green "`nPASSED - Windows OS edition is Enterprise."}
	{$_ -like '*pro*'} {write-host -ForegroundColor green "`nPASSED - Windows OS edition is Pro."}
	{$_ -like '*education*'} {write-host -ForegroundColor green "`nPASSED - Windows OS edition is Education."}
	{$_ -like '*home*'} {write-host -ForegroundColor red "`nFAILED - Windows OS edition is Home."}
	}
if ($ComputerInfo.OsVersion -ge 10) {
	write-host -ForegroundColor green "`nPASSED - Windows OS version is 10/11."
} else {
	write-host -ForegroundColor red "`nFAILED - Windows OS version is older than Windows 10."
}
	Write-Host
    Write-Host -ForegroundColor yellow "OS Install Date: $($computerInfo.OsInstallDate)"
    Write-Host -ForegroundColor yellow "OS Serial Number:     $($computerInfo.OsSerialNumber)"
    Write-Host -ForegroundColor yellow "Computer Name:            $($computerInfo.CsName)"
    Write-Host -ForegroundColor yellow "KB Layout:      $($computerInfo.KeyboardLayout)"
    Write-Host -ForegroundColor yellow "Time Zone:            $($computerInfo.TimeZone)"
	Write-Host -ForegroundColor yellow "BIOS Version:        $($computerInfo.BiosBIOSVersion)"
    Write-Host -ForegroundColor yellow "BIOS Status:         $($computerInfo.BiosStatus)"
    Write-Host -ForegroundColor yellow "BIOS Serial Number:   $($computerInfo.BiosSeralNumber)"

write-host -ForegroundColor white "************************************************************"

#* Device checks 
#	-- TPM checks (IS NOT AN INTUNE PREREQUISITE)
write-host -ForegroundColor green "`nTPM checks `n	-- Requires the script to run as admin (IS NOT AN INTUNE PREREQUISITE): (TEST #9)"

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) -eq $True){
	write-host -ForegroundColor green "`nScript is running as admin. Proceeding TPM with checks..."
	$TPMInfo = Get-TPM
	Write-Host "TPM Is Present? $($TPMInfo.TpmPresent)"
    Write-Host "TPM Is Ready? $($TPMInfo.TpmReady)"
    Write-Host "TPM Is Enabled? $($TPMInfo.TpmEnabled)"
} else {
	write-host -ForegroundColor yellow "`nScript is NOT running as admin. Skipping TPM checks."
}

write-host -ForegroundColor white "************************************************************"

#* Device checks 
#	-- Hardware hash uploaded to Intune 
write-host -ForegroundColor green "`nDevice checks `n	-- Hardware hash uploaded to Intune: (TEST #10)"
$APDevices = Get-MgDeviceManagementWindowAutopilotDeviceIdentity -Top 5
if ([string]::IsNullOrWhiteSpace($APDevices)) {
	write-host -ForegroundColor red "`nFAILED - No hardware hash were uploaded to Intune."
} else {
	write-host -ForegroundColor green "`nPASSED - Hardware hashes were found uploaded in Intune."
}

write-host -ForegroundColor white "************************************************************"

#* Device checks 
#	-- Check Windows Autopilot Deployment Profile assignment status 
write-host -ForegroundColor green "`nDevice checks `n	-- Check Windows Autopilot Deployment Profile assignment status: (TEST #11)"
if ($APDeploymentProfiles -eq $null) {
	write-host -ForegroundColor yellow "`nSKIPPED - No Windows Autopilot deployment profile was found."
} else {
	if (![string]::IsNullOrWhiteSpace($DeviceGroup)) {
		$DeviceGroupID = (Get-MgGroup  -Filter "DisplayName eq '$DeviceGroup'").id
		if ($DeviceGroupID -ne $null) {
			$Count = 0
			foreach ($Profile in $APDeploymentProfiles) {
				foreach ($Assignment in $Profile.Assignments) {
					$GroupID = $Assignment.Id.Remove(0,37)
					$GroupID = $GroupID.Remove(36,2)
					if ($DeviceGroupID -match $GroupID) {
						$Count++
						write-host -ForegroundColor green "`nGroup assignment for group ""$DeviceGroup"" was found in Windows Autopilot deployment profile" (-join('"', $Profile.DisplayName, '"'))
					}
				}
			}
		} else {
			write-host -ForegroundColor yellow "`nSKIPPED - Device group ""$DeviceGroup"" was not found."
		}
		if ($Count -gt 0) {
			write-host -ForegroundColor green "`nPASSED - At least one Windows Autopilot deployment profile group assignment was found."
		} else {
			write-host -ForegroundColor red "`nFAILED - No Windows Autopilot deployment profile group assignment was found."
		}
	} else {
		write-host -ForegroundColor yellow "`nSKIPPED - No device group was specified."
	}
}

write-host -ForegroundColor white "************************************************************"

#* User checks 
#	-- User is licensed correctly 
write-host -ForegroundColor green "`nUser checks `n	-- Check user is licensed correctly : (TEST #12)"
if (![string]::IsNullOrWhiteSpace($Username)) {
	$MGUserID = (Get-MgUser  -Filter "UserPrincipalName eq '$Username'").id
	$licenses = Get-MgUserLicenseDetail -UserId $MGUserID
	foreach ($license in  $licenses) {
		$licensePlans = $license.serviceplans.ServicePlanName | Select-String -Pattern 'intune' -SimpleMatch
		if (![string]::IsNullOrWhiteSpace($SKUPlans)) {
			$UserIntuneLicense = $true
		}
	}
	if (!($UserIntuneLicense)) {
		write-host -ForegroundColor red "`nFAILED - User ""$Username"" assigned licenses does NOT contain Intune features."
	}
	else {
		write-host -ForegroundColor green "`nPASSED - User ""$Username"" assigned licenses contain Intune features."
	}
} else {
	write-host -ForegroundColor yellow "`nSKIPPED - No username was specified."
}

write-host -ForegroundColor white "************************************************************"

#* Network checks 
#	-- required communication for Intune Autopilot is allowed
write-host -ForegroundColor green "`nNetwork checks `n	-- Check required communication for Intune Autopilot is allowed: (TEST #13)"

Get-ConnectionTest -connections $connections443 -port 443
Get-ConnectionTest -connections $connections80 -port 80
Get-OtherConnectionsTested -connections ($connections80 + $connections443).uri
Get-NtpTimeTested

write-host -ForegroundColor white "************************************************************"
write-host -ForegroundColor yellow "`nFINISHED `n	-- All checks completed"
write-host -ForegroundColor white "************************************************************"

if ($LogPath) {
	Stop-Transcript
}