function Get-OSDGather {
    [CmdletBinding()]
    Param ()

    if ($VerbosePreference -eq 'Continue') {$VerboseParam = $true}
    #==================================================
    #	OSDPhase
    #==================================================
    if (Test-Path 'HKLM:\SYSTEM\Setup') {
        Write-Verbose "=================================================="
        $HKLMSystemSetup = Get-ItemProperty -Path 'HKLM:\SYSTEM\Setup'

        [int]$Global:SetupPhase = $HKLMSystemSetup.SetupPhase
        if ($null -eq $Global:SetupPhase) {$Global:SetupPhase = 0}
        Write-Verbose "Property SetupPhase: $Global:SetupPhase"

        [int]$Global:SetupType = $HKLMSystemSetup.SetupType
        if ($null -eq $Global:SetupType) {$Global:SetupType = 0}
        Write-Verbose "Property SetupType: $Global:SetupType"

        [int]$Global:SystemSetupInProgress = $HKLMSystemSetup.SystemSetupInProgress
        if ($null -eq $Global:SetupPhase) {$Global:SetupPhase = 0}
        Write-Verbose "Property SystemSetupInProgress: $Global:SystemSetupInProgress"

        [int]$Global:FactoryPreInstallInProgress = $HKLMSystemSetup.FactoryPreInstallInProgress
        if ($null -eq $Global:FactoryPreInstallInProgress) {$Global:FactoryPreInstallInProgress = 0}
        Write-Verbose "Property FactoryPreInstallInProgress: $Global:FactoryPreInstallInProgress"

        [int]$Global:OOBEInProgress = $HKLMSystemSetup.OOBEInProgress
        if ($null -eq $Global:OOBEInProgress) {$Global:OOBEInProgress = 0}
        Write-Verbose "Property OOBEInProgress: $Global:OOBEInProgress"

        #$Global:WorkingDirectory = $HKLMSystemSetup.WorkingDirectory
        #Write-Verbose "Property WorkingDirectory: $Global:WorkingDirectory"

        if ($Global:SystemSetupInProgress -eq 0) {$Global:OSDPhase = 'Windows'}
        if ($Global:FactoryPreInstallInProgress -eq 1) {$Global:OSDPhase = 'WinXE'}
        if ($Global:SetupPhase -eq 4) {$Global:OSDPhase = 'Specialize'}
        if ($Global:OOBEInProgress -eq 1) {$Global:OSDPhase = 'OOBE'}
        Write-Verbose "Property OSDPhase: $Global:OSDPhase"
    }
    #==================================================
    #   IsAdmin
    #==================================================
    Write-Verbose "=================================================="
    $Global:IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')
    Write-Verbose "Property IsAdmin: $Global:IsAdmin"
    #==================================================
    #   IsWinPE
    #==================================================
    $Global:IsWinPE = $env:SystemDrive -eq 'X:'
    Write-Verbose "Property IsWinPE: $Global:IsWinPE"
    #==================================================
    #   IsWinSE
    #==================================================
    if (($Global:IsWinPE -eq $true) -and (Test-Path 'X:\Setup.exe')) {
        $Global:IsWinSE = $true
    } else {
        $Global:IsWinSE = $false
    }
    Write-Verbose "Property IsWinSE: $Global:IsWinSE"
    #==================================================
    #   IsWinOS
    #==================================================
    if ($Global:IsWinPE -eq $true) {
        $Global:IsWinOS = $false
    } else {
        $Global:IsWinOS = $true
    }
    Write-Verbose "Property IsWinOS: $Global:IsWinOS"
    #==================================================
    #	IsUEFI
    #==================================================
    if ($Global:IsWinPE) {
        $Global:IsUEFI = (Get-ItemProperty -Path HKLM:\System\CurrentControlSet\Control).PEFirmwareType -eq 2
        Write-Verbose "Property IsUEFI: $Global:IsUEFI"
    } else {
        $Global:IsUEFI = $false
        Write-Verbose "Property IsUEFI: $Global:IsUEFI"
    }
    #==================================================
    #   IsLaptop IsDesktop
    #==================================================
    Write-Verbose "=================================================="
    $VerbosePreference = 'SilentlyContinue'
    $ChassisTypes = (Get-CimInstance -ClassName Win32_SystemEnclosure).ChassisTypes
    if ($VerboseParam -eq $true) {$VerbosePreference = 'Continue'}

    if ($ChassisTypes -match 9 -or $ChassisTypes -match 10 -or $ChassisTypes -match 14) {
        $Global:IsDesktop = $false
        Write-Verbose "Property IsDesktop: $Global:IsDesktop"
        $Global:IsLaptop = $true
        Write-Verbose "Property IsLaptop: $Global:IsLaptop"
    } else {
        $Global:IsDesktop = $true
        Write-Verbose "Property IsDesktop: $Global:IsDesktop"
        $Global:IsLaptop = $false
        Write-Verbose "Property IsLaptop: $Global:IsLaptop"
    }
    #==================================================
    #	Customize: Increase the Console Screen Buffer size
    #==================================================
    if (!(Test-Path "HKCU:\Console")) {
        #Write-Host "Increase Console Screen Buffer" -ForegroundColor Gray
        New-Item -Path "HKCU:\Console" -Force | Out-Null
        New-ItemProperty -Path HKCU:\Console ScreenBufferSize -Value 589889656 -PropertyType DWORD -Force | Out-Null
    }
}