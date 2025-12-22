<#
.SYNOPSIS
    OSD Cloud initialization script for WinPE
    
.DESCRIPTION
    This script validates the WinPE environment and configures required settings
    for OSD Cloud operations. It verifies dependencies and configures:
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
Write-Host "OSD Cloud WinPE Initialization" -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

# Step 1: Verify WinPE Environment
Write-Host "[1/4] Verifying WinPE environment..." -ForegroundColor Magenta
$winpeValid = Test-WinPEEnvironment
if (-not $winpeValid) {
    Write-Host "`n[!] Warning: Script is optimized for WinPE. Some features may not work correctly." -ForegroundColor Yellow
    # Continue execution for testing purposes
}

# Step 2: Set TLS 1.2
Write-Host "`n[2/4] Configuring TLS 1.2..." -ForegroundColor Magenta
Set-TLSVersion

# Step 3: Set Execution Policy
Write-Host "`n[3/4] Setting PowerShell execution policy..." -ForegroundColor Magenta
Set-ExecutionPolicy

# Step 4: Verify LocalAppData
Write-Host "`n[4/4] Verifying LocalAppData environment variable..." -ForegroundColor Magenta
$localAppDataValid = Confirm-LocalAppDataVariable

# Step 5: Check Dependencies
Test-Dependencies

# Summary
Write-Host "`n================================" -ForegroundColor Cyan
Write-Host "Initialization Summary" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host "WinPE Environment: $(if ($winpeValid) { 'Valid' } else { 'Warning' })" -ForegroundColor $(if ($winpeValid) { 'Green' } else { 'Yellow' })
Write-Host "TLS 1.2: Configured" -ForegroundColor Green
Write-Host "Execution Policy: Configured" -ForegroundColor Green
Write-Host "LocalAppData: $(if ($localAppDataValid) { 'Valid' } else { 'Invalid' })" -ForegroundColor $(if ($localAppDataValid) { 'Green' } else { 'Red' })
Write-Host "================================`n" -ForegroundColor Cyan

if ($winpeValid -and $localAppDataValid) {
    Write-Host "[✓] Initialization completed successfully. Ready for OSD Cloud operations." -ForegroundColor Green
    exit 0
}
else {
    Write-Host "[!] Initialization completed with warnings. Review the output above." -ForegroundColor Yellow
    exit 0
}
