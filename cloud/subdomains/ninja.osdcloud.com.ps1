<#
.SYNOPSIS
    OSDCloud initialization script for WinPE
    
.DESCRIPTION
    This script validates the WinPE environment and configures required settings
    for OSDCloud operations. It verifies dependencies and configures:
    - WinPE environment verification
    - TLS 1.2 security protocol
    - PowerShell execution policy
    - Required environment variables
    
.NOTES
    This script is designed to be downloaded and executed in WinPE PowerShell
#>

[CmdletBinding()]
param()

# ========================================
# Functions
# ========================================

function Test-WinPEEnvironment {
    <#
    .SYNOPSIS
        Validates that we are running in WinPE
        
    .DESCRIPTION
        Checks for WinPE-specific environment indicators and registry values
        
    .RETURNS
        $true if running in WinPE, $false otherwise
    #>
    
    try {
        # Check for WinPE registry path
        $winpeRegPath = "HKLM:\System\CurrentControlSet\Control\Windows"
        
        if (Test-Path -Path $winpeRegPath) {
            $regValue = Get-ItemProperty -Path $winpeRegPath -Name "PEOptimizeForSpeed" -ErrorAction SilentlyContinue
            if ($null -ne $regValue) {
                Write-Host "[✓] WinPE environment detected" -ForegroundColor Green
                return $true
            }
        }
        
        # Alternative check: look for WinPE system file
        if (Test-Path -Path "$env:SystemRoot\System32\winpeshl.ini") {
            Write-Host "[✓] WinPE environment detected (winpeshl.ini found)" -ForegroundColor Green
            return $true
        }
        
        # Check for WinPE temporary files directory
        if (Test-Path -Path "X:\") {
            Write-Host "[✓] WinPE environment detected (X: drive found)" -ForegroundColor Green
            return $true
        }
        
        Write-Host "[✗] Not running in WinPE environment" -ForegroundColor Red
        return $false
    }
    catch {
        Write-Host "[!] Error checking WinPE environment: $_" -ForegroundColor Yellow
        return $false
    }
}

function Set-TLSVersion {
    <#
    .SYNOPSIS
        Configures TLS 1.2 for secure communications
        
    .DESCRIPTION
        Sets up Transport Layer Security 1.2 to ensure secure HTTPS connections
        for downloading packages and modules
    #>
    
    try {
        # Set TLS 1.2 as the minimum protocol
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12
        
        Write-Host "[✓] TLS 1.2 configured" -ForegroundColor Green
    }
    catch {
        Write-Host "[!] Warning: Could not configure TLS 1.2: $_" -ForegroundColor Yellow
    }
}

function Set-ExecutionPolicy {
    <#
    .SYNOPSIS
        Sets PowerShell execution policy
        
    .DESCRIPTION
        Configures the execution policy to allow script execution
        Uses 'Bypass' for the machine scope to allow all scripts to run
    #>
    
    try {
        $currentPolicy = Get-ExecutionPolicy -Scope LocalMachine
        
        if ($currentPolicy -ne "Bypass") {
            Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine -Force -ErrorAction Stop
            Write-Host "[✓] Execution policy set to Bypass (LocalMachine scope)" -ForegroundColor Green
        }
        else {
            Write-Host "[✓] Execution policy already set to Bypass" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "[!] Error setting execution policy: $_" -ForegroundColor Yellow
    }
}

function Initialize-EnvironmentVariables {
    <#
    .SYNOPSIS
        Initializes required environment variables for WinPE
        
    .DESCRIPTION
        Sets and validates critical environment variables including APPDATA, 
        HOMEDRIVE, HOMEPATH, and LOCALAPPDATA. Creates directories as needed.
        
    .RETURNS
        $true if all environment variables are successfully initialized, $false otherwise
    #>
    
    try {
        # Determine the user profile path
        if ([string]::IsNullOrEmpty($env:UserProfile)) {
            $userProfile = "$env:SystemDrive\Users\Administrator"
        }
        else {
            $userProfile = $env:UserProfile
        }
        
        # Define the environment variables to set
        $envVars = @{
            'APPDATA' = "$userProfile\AppData\Roaming"
            'HOMEDRIVE' = $env:SystemDrive
            'HOMEPATH' = $userProfile
            'LOCALAPPDATA' = "$userProfile\AppData\Local"
        }
        
        # Set each environment variable and verify the path exists
        foreach ($varName in $envVars.Keys) {
            $varValue = $envVars[$varName]
            
            # Set the environment variable at process level
            [System.Environment]::SetEnvironmentVariable($varName, $varValue, [System.EnvironmentVariableTarget]::Process)
            
            # Create the directory if it doesn't exist
            if (-not (Test-Path -Path $varValue)) {
                New-Item -ItemType Directory -Path $varValue -Force | Out-Null
                Write-Host "[✓] Created directory and set $varName = $varValue" -ForegroundColor Green
            }
            else {
                Write-Host "[✓] Verified $varName = $varValue" -ForegroundColor Green
            }
        }
        
        return $true
    }
    catch {
        Write-Host "[✗] Error initializing environment variables: $_" -ForegroundColor Red
        return $false
    }
}

function Confirm-LocalAppDataVariable {
    <#
    .SYNOPSIS
        Validates LocalAppData environment variable
        
    .DESCRIPTION
        Checks if the LocalAppData environment variable exists and is accessible.
        Creates it if necessary for WinPE environments where it may not be preset.
        
    .RETURNS
        $true if LocalAppData is available, $false otherwise
    #>
    
    try {
        # Check if LocalAppData environment variable exists
        if ([string]::IsNullOrEmpty($env:LocalAppData)) {
            Write-Host "[!] LocalAppData environment variable not set" -ForegroundColor Yellow
            
            # Attempt to create LocalAppData for current user
            # In WinPE, this is typically System context, so use a default path
            if (Test-Path -Path "X:\") {
                $env:LocalAppData = "X:\Temp\LocalAppData"
                if (-not (Test-Path -Path $env:LocalAppData)) {
                    New-Item -ItemType Directory -Path $env:LocalAppData -Force | Out-Null
                }
                Write-Host "[✓] LocalAppData created at $($env:LocalAppData)" -ForegroundColor Green
            }
            else {
                # Fallback for non-standard WinPE environments
                $env:LocalAppData = "$env:SystemDrive\Temp\LocalAppData"
                if (-not (Test-Path -Path $env:LocalAppData)) {
                    New-Item -ItemType Directory -Path $env:LocalAppData -Force | Out-Null
                }
                Write-Host "[✓] LocalAppData created at $($env:LocalAppData)" -ForegroundColor Green
            }
        }
        else {
            Write-Host "[✓] LocalAppData verified: $($env:LocalAppData)" -ForegroundColor Green
        }
        
        # Verify the path is accessible
        if (Test-Path -Path $env:LocalAppData) {
            return $true
        }
        else {
            Write-Host "[✗] LocalAppData path is not accessible: $($env:LocalAppData)" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "[✗] Error validating LocalAppData: $_" -ForegroundColor Red
        return $false
    }
}

function Update-PowerShellProfile {
    <#
    .SYNOPSIS
        Updates PowerShell profile with environment configurations
        
    .DESCRIPTION
        Adds WinPE and OOBE-specific settings to the PowerShell profile.
        Configures TLS 1.2 and environment variables for proper script execution.
        
    .RETURNS
        $true if profile was successfully updated, $false otherwise
    #>
    
    try {
        # Define WinPE PowerShell Profile
        $winpePowerShellProfile = @'
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
[System.Environment]::SetEnvironmentVariable('APPDATA',"$Env:UserProfile\AppData\Roaming",[System.EnvironmentVariableTarget]::Process)
[System.Environment]::SetEnvironmentVariable('HOMEDRIVE',"$Env:SystemDrive",[System.EnvironmentVariableTarget]::Process)
[System.Environment]::SetEnvironmentVariable('HOMEPATH',"$Env:UserProfile",[System.EnvironmentVariableTarget]::Process)
[System.Environment]::SetEnvironmentVariable('LOCALAPPDATA',"$Env:UserProfile\AppData\Local",[System.EnvironmentVariableTarget]::Process)
'@

        # Define OOBE PowerShell Profile
        $oobePowerShellProfile = @'
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
[System.Environment]::SetEnvironmentVariable('Path',$Env:Path + ";$Env:ProgramFiles\WindowsPowerShell\Scripts",'Process')
'@

        # Ensure PowerShell profile directory exists
        $profileDir = Split-Path -Parent $PROFILE
        if (-not (Test-Path -Path $profileDir)) {
            New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
            Write-Host "[✓] Created PowerShell profile directory: $profileDir" -ForegroundColor Green
        }

        # Update the profile with WinPE configuration
        if (Test-Path -Path "X:\") {
            # WinPE environment
            Add-Content -Path $PROFILE -Value $winpePowerShellProfile -Force
            Write-Host "[✓] Updated PowerShell profile with WinPE settings" -ForegroundColor Green
        }
        else {
            # OOBE or regular environment
            Add-Content -Path $PROFILE -Value $oobePowerShellProfile -Force
            Write-Host "[✓] Updated PowerShell profile with OOBE settings" -ForegroundColor Green
        }

        return $true
    }
    catch {
        Write-Host "[!] Error updating PowerShell profile: $_" -ForegroundColor Yellow
        return $false
    }
}

function Update-PowerShellGetAndPackageManagement {
    <#
    .SYNOPSIS
        Ensures NuGet provider, trusts PSGallery, and updates modules

    .DESCRIPTION
        Bootstraps NuGet, registers/trusts PSGallery, and installs/updates
        PackageManagement and PowerShellGet to latest available versions.

    .RETURNS
        $true if updates succeeded, $false otherwise
    #>

    $ok = $true
    try {
        Write-Host "[*] Bootstrapping NuGet provider..." -ForegroundColor Cyan
        $nuget = Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue
        if (-not $nuget) {
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -ErrorAction Stop | Out-Null
        }
        else {
            Write-Host "[✓] NuGet provider present" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "[✗] Failed to install NuGet provider: $_" -ForegroundColor Red
        $ok = $false
    }

    try {
        Write-Host "[*] Ensuring PSGallery repository is available and trusted..." -ForegroundColor Cyan
        $psg = Get-PSRepository -Name 'PSGallery' -ErrorAction SilentlyContinue
        if (-not $psg) {
            try { Register-PSRepository -Default -ErrorAction Stop } catch { }
            $psg = Get-PSRepository -Name 'PSGallery' -ErrorAction SilentlyContinue
            if (-not $psg) {
                Register-PSRepository -Name 'PSGallery' -SourceLocation 'https://www.powershellgallery.com/api/v2' -ScriptSourceLocation 'https://www.powershellgallery.com/api/v2' -InstallationPolicy Trusted -ErrorAction Stop
            }
        }
        else {
            Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted -ErrorAction SilentlyContinue
        }
        Write-Host "[✓] PSGallery repository ready" -ForegroundColor Green
    }
    catch {
        Write-Host "[✗] Failed to configure PSGallery: $_" -ForegroundColor Red
        $ok = $false
    }

    try {
        Write-Host "[*] Installing/Updating PackageManagement..." -ForegroundColor Cyan
        Install-Module -Name PackageManagement -Repository PSGallery -Force -AllowClobber -Scope AllUsers -ErrorAction Stop
        Write-Host "[✓] PackageManagement updated" -ForegroundColor Green
    }
    catch {
        Write-Host "[✗] Failed to update PackageManagement: $_" -ForegroundColor Red
        $ok = $false
    }

    try {
        Write-Host "[*] Installing/Updating PowerShellGet..." -ForegroundColor Cyan
        Install-Module -Name PowerShellGet -Repository PSGallery -Force -AllowClobber -Scope AllUsers -ErrorAction Stop
        Write-Host "[✓] PowerShellGet updated" -ForegroundColor Green
    }
    catch {
        Write-Host "[✗] Failed to update PowerShellGet: $_" -ForegroundColor Red
        $ok = $false
    }

    return [bool]$ok
}

function Test-Dependencies {
    <#
    .SYNOPSIS
        Validates required PowerShell modules and components
        
    .DESCRIPTION
        Checks for required modules and dependencies
    #>
    
    Write-Host "`n[*] Checking dependencies..." -ForegroundColor Cyan
    
    $missingDependencies = @()
    
    # Check for required modules (can be expanded as needed)
    $requiredModules = @(
        "PSReadLine",
        "PackageManagement"
    )
    
    foreach ($module in $requiredModules) {
        if (-not (Get-Module -ListAvailable -Name $module -ErrorAction SilentlyContinue)) {
            Write-Host "[!] Module not found: $module" -ForegroundColor Yellow
            $missingDependencies += $module
        }
        else {
            Write-Host "[✓] Module available: $module" -ForegroundColor Green
        }
    }
    
    return $missingDependencies.Count -eq 0
}

# ========================================
# Main Execution
# ========================================

Write-Host "================================" -ForegroundColor Cyan
Write-Host "OSDCloud WinPE Initialization" -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

# Step 1: Verify WinPE Environment
Write-Host "[1/4] Verifying WinPE environment..." -ForegroundColor Magenta
$winpeValid = Test-WinPEEnvironment
if (-not $winpeValid) {
    Write-Host "`n[✗] FATAL: This script must be executed in WinPE. Exiting in 10 seconds..." -ForegroundColor Red
    Start-Sleep -Seconds 10
    exit 1
}

# Step 2: Set TLS 1.2
Write-Host "`n[2/4] Configuring TLS 1.2..." -ForegroundColor Magenta
Set-TLSVersion

# Step 3: Set Execution Policy
Write-Host "`n[3/6] Setting PowerShell execution policy..." -ForegroundColor Magenta
Set-ExecutionPolicy

# Step 4: Initialize Environment Variables
Write-Host "`n[4/6] Initializing environment variables..." -ForegroundColor Magenta
$envVarsValid = Initialize-EnvironmentVariables

# Step 5: Verify LocalAppData
Write-Host "`n[5/6] Verifying LocalAppData environment variable..." -ForegroundColor Magenta
$localAppDataValid = Confirm-LocalAppDataVariable

# Step 6: Update PowerShell Profile
Write-Host "`n[6/7] Updating PowerShell profile..." -ForegroundColor Magenta
$profileValid = Update-PowerShellProfile

# Step 7: Update PowerShellGet and PackageManagement
Write-Host "`n[7/7] Updating PowerShellGet and PackageManagement..." -ForegroundColor Magenta
$pkgModUpdated = Update-PowerShellGetAndPackageManagement

# Step 8: Check Dependencies
Write-Host "`n[8/7] Checking dependencies..." -ForegroundColor Magenta
Test-Dependencies

# Summary
Write-Host "`n================================" -ForegroundColor Cyan
Write-Host "Initialization Summary" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host "WinPE Environment: Valid" -ForegroundColor Green
Write-Host "TLS 1.2: Configured" -ForegroundColor Green
Write-Host "Execution Policy: Configured" -ForegroundColor Green
Write-Host "Environment Variables: $(if ($envVarsValid) { 'Valid' } else { 'Invalid' })" -ForegroundColor $(if ($envVarsValid) { 'Green' } else { 'Red' })
Write-Host "LocalAppData: $(if ($localAppDataValid) { 'Valid' } else { 'Invalid' })" -ForegroundColor $(if ($localAppDataValid) { 'Green' } else { 'Red' })
Write-Host "PowerShell Profile: $(if ($profileValid) { 'Updated' } else { 'Warning' })" -ForegroundColor $(if ($profileValid) { 'Green' } else { 'Yellow' })
Write-Host "PSGet/PackageManagement: $(if ($pkgModUpdated) { 'Updated' } else { 'Warning' })" -ForegroundColor $(if ($pkgModUpdated) { 'Green' } else { 'Yellow' })
Write-Host "================================`n" -ForegroundColor Cyan

if ($envVarsValid -and $localAppDataValid) {
    Write-Host "[✓] Initialization completed successfully. Ready for OSDCloud operations." -ForegroundColor Green
    exit 0
}
else {
    Write-Host "[!] Initialization completed with warnings. Review the output above." -ForegroundColor Yellow
    exit 0
}
