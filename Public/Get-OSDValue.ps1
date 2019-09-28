function Get-OSDValue {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet(`
            'IsAdmin',`
            'IsWinOS',`
            'IsWinPE','IsWinSE',`
            'IsDesktop','IsLaptop','IsServer','IsSFF','IsTablet',`
            'IsUEFI','IsServerOS','IsServerCoreOS'
        )]
        [string]$Property
    )
    #======================================================================================================
    #   IsAdmin
    #======================================================================================================
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')
    if ($Property -eq 'IsAdmin') {Return $IsAdmin}
    #======================================================================================================
    #   IsWinPE IsWinSE
    #======================================================================================================
    $IsWinPE = $env:SystemDrive -eq 'X:'
    $IsWinSE = ($IsWinPE -and (Test-Path 'X:\Setup.exe'))

    if ($Property -eq 'IsWinPE') {Return $IsWinPE}
    if ($Property -eq 'IsWinSE') {Return $IsWinSE}
    #======================================================================================================
    #   IsUEFI
    #======================================================================================================
    if ($Property -eq 'IsUEFI') {
        if ($IsWinPE) {
            if ((Get-ItemProperty -Path HKLM:\System\CurrentControlSet\Control).PEFirmwareType -eq 2) {
                $IsUEFI = $true
            } else {
                $IsUEFI = $false
            }
        } else {
            if ((Get-ItemProperty HKLM:\System\CurrentControlSet\control\SecureBoot\State -ErrorAction SilentlyContinue) -eq $null ) {
                $IsUEFI = $false
            } else {
                $IsUEFI = $true
            }
        }
        Return $IsUEFI
    }
    #======================================================================================================
    #   IsServerCoreOS
    #======================================================================================================
    if ($Property -eq 'IsWinOS' -or$Property -eq 'IsServerOS' -or $Property -eq 'IsServerCoreOS') {
        $IsWinOS = $true
        $IsServerOS = $false
        $IsServerCoreOS = $false

        if (!($env:SystemDrive -ne 'X:')) {
            if (!(Test-Path "$env:windir\explorer.exe")) {
                $IsWinOS = $false
                $IsServerCoreOS = $true
            }

            if (Test-Path HKLM:\System\CurrentControlSet\Control\ProductOptions\ProductType) {
                $productType = Get-Item HKLM:System\CurrentControlSet\Control\ProductOptions\ProductType
                if ($productType -eq "ServerNT" -or $productType -eq "LanmanNT") {
                    $IsWinOS = $false
                    $IsServerOS = $true
                }
            }
        }
        if ($Property -eq 'IsWinOS') {Return $IsWinOS}
        if ($Property -eq 'IsServerOS') {Return $IsServerOS}
        if ($Property -eq 'IsServerCoreOS') {Return $IsServerCoreOS}
    }
    #======================================================================================================
    #   Win32_SystemEnclosure
    #   Credit FriendsOfMDT         https://github.com/FriendsOfMDT/PSD
    #   Credit Johan Schrewelius    https://gallery.technet.microsoft.com/PowerShell-script-that-a8a7bdd8
    #======================================================================================================
    $IsDesktop = $false
    $IsLaptop = $false
    $IsServer = $false
    $IsSFF = $false
    $IsTablet = $false
    Get-CimInstance -ClassName Win32_SystemEnclosure | ForEach-Object {
        $AssetTag = $_.SMBIOSAssetTag.Trim()
        if ($_.ChassisTypes[0] -in "8", "9", "10", "11", "12", "14", "18", "21") { $IsLaptop = $true }
        if ($_.ChassisTypes[0] -in "3", "4", "5", "6", "7", "15", "16") { $IsDesktop = $true }
        if ($_.ChassisTypes[0] -in "23") { $IsServer = $true }
        if ($_.ChassisTypes[0] -in "34", "35", "36") { $IsSFF = $true }
        if ($_.ChassisTypes[0] -in "13", "31", "32", "30") { $IsTablet = $true } 
    }
    if ($Property -eq 'AssetTag') {Return $AssetTag}
    if ($Property -eq 'IsDesktop') {Return $IsDesktop}
    if ($Property -eq 'IsLaptop') {Return $IsLaptop}
    if ($Property -eq 'IsServer') {Return $IsServer}
    if ($Property -eq 'IsSFF') {Return $IsSFF}
    if ($Property -eq 'IsTablet') {Return $IsTablet}



    















        # Look up OS details
        
        
    
        Get-CimInstance -ClassName Win32_OperatingSystem | ForEach-Object { $OSCurrentVersion = $_.Version; $OSCurrentBuild = $_.BuildNumber }

<#         if (Test-Path HKLM:System\CurrentControlSet\Control\MiniNT) {
            $OSVersion = "WinPE"
          }
          else
          {
            $OSVersion = "Other"
            if (Test-Path "$env:WINDIR\Explorer.exe") {
              $IsServerCoreOS = $true
            }
            if (Test-Path HKLM:\System\CurrentControlSet\Control\ProductOptions\ProductType)
            {
              $productType = Get-Item HKLM:System\CurrentControlSet\Control\ProductOptions\ProductType
              if ($productType -eq "ServerNT" -or $productType -eq "LanmanNT") {
                $IsServerOS = $true
              }
            }
          } #>



    #======================================================================================================
    #   Defaults
    #======================================================================================================
    $Value = $false
    #======================================================================================================
    #   Win32_SystemEnclosure
    #   Credit Johan Schrewelius
    #======================================================================================================
    if (($Property -eq 'IsDesktop') -or ($Property -eq 'IsLaptop') -or ($Property -eq 'IsServer') -or ($Property -eq 'ChassisType') -or ($Property -eq 'ChassisTypeName')) {

        $ChassisType = (Get-CimInstance -ClassName Win32_SystemEnclosure).ChassisTypes[0]
        if ($Property -eq 'ChassisType') {Return $ChassisType}

        $ChassisTypeName = switch ( $ChassisType ) {
            3 { 'Desktop' }
            4 { 'Desktop' }
            5 { 'Desktop' }
            6 { 'Desktop' }
            7 { 'Desktop' }
            13 { 'Desktop' }
            15 { 'Desktop' }
            16 { 'Desktop' }
            35 { 'Desktop' }
            36 { 'Desktop' }

            8 { 'Laptop' }
            9 { 'Laptop' }
            10 { 'Laptop' }
            11 { 'Laptop' }
            12 { 'Laptop' }
            14 { 'Laptop' }
            18 { 'Laptop' }
            21 { 'Laptop' }
            30 { 'Laptop' }
            31 { 'Laptop' }
            32 { 'Laptop' }

            23 { 'Server' }
            28 { 'Server' }

            default { 'Unknown' }
        }

        if ($Property -eq 'ChassisTypeName') {Return $ChassisTypeName}

        if ($ChassisTypeName -eq 'Laptop') {
            $IsLaptop = $true
            $IsDesktop = $false
            $IsServer = $false
        }
        if ($ChassisTypeName -eq 'Desktop') {
            $IsLaptop = $false
            $IsDesktop = $true
            $IsServer = $false
        }
        if ($ChassisTypeName -eq 'Server') {
            $IsLaptop = $false
            $IsDesktop = $false
            $IsServer = $true
        }
        if ($ChassisTypeName -eq 'Unknown') {
            $IsLaptop = $false
            $IsDesktop = $false
            $IsServer = $false
        }

        if ($Property -eq 'IsLaptop') {Return $IsLaptop}
        if ($Property -eq 'IsDesktop') {Return $IsDesktop}
        if ($Property -eq 'IsServer') {Return $IsServer}
    }
    #======================================================================================================
    #	IsUEFI
    #======================================================================================================
    if ($Property -eq 'IsUEFI') {
        if ($IsWinPE) {
            $Value = (Get-ItemProperty -Path HKLM:\System\CurrentControlSet\Control).PEFirmwareType -eq 2
            $Global:IsUEFI = $PSDefaultParameterValues
            Return $Value
        } else {
            Write-Warning 'IsUEFI must be run in WinPE'
        }
    }
}