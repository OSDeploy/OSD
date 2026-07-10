function Block-AdminUser {
    <#
    .SYNOPSIS
    Blocks execution if the current user has Administrator rights

    .DESCRIPTION
    Validates that the current user does not have Administrator rights. If admin rights are detected, writes a warning and breaks execution unless the -Warn parameter is specified.

    .PARAMETER Warn
    Shows a warning but continues execution instead of breaking

    .PARAMETER Pause
    Pauses and displays a message before continuing execution

    .EXAMPLE
    Block-AdminUser
    Halts execution if the user is running as Administrator

    .EXAMPLE
    Block-AdminUser -Warn
    Shows a warning but continues execution even if user is Administrator

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added comment-based help

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]$Warn,
        [System.Management.Automation.SwitchParameter]$Pause
    )
    $CallingFunction = (Get-PSCallStack)[1].InvocationInfo.Line
    $Message = "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))] $CallingFunction requires non-Admin Rights"

    if ((Get-OSDGather -Property IsAdmin) -eq $true) {
        Write-Warning $Message
        if ($PSBoundParameters.ContainsKey('Pause')) {
            [void]('Press Enter to Continue')
        }
        if (-NOT ($PSBoundParameters.ContainsKey('Warn'))) {
            Break
        }
    }
}
function Block-ManufacturerNeLenovo {
    <#
    .SYNOPSIS
    Blocks execution if the computer is not manufactured by Lenovo

    .DESCRIPTION
    Validates that the computer is manufactured by Lenovo. If the manufacturer is not Lenovo, writes a warning and breaks execution unless the -Warn parameter is specified.

    .PARAMETER Warn
    Shows a warning but continues execution instead of breaking

    .PARAMETER Pause
    Pauses and displays a message before continuing execution

    .EXAMPLE
    Block-ManufacturerNeLenovo
    Halts execution if the computer is not a Lenovo device

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added comment-based help

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]$Warn,
        [System.Management.Automation.SwitchParameter]$Pause
    )
    $CallingFunction = (Get-PSCallStack)[1].InvocationInfo.Line
    $Message = "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))] $CallingFunction requires a Lenovo computer"
        
    if ((Get-MyComputerManufacturer -Brief) -ne 'Lenovo') {
        Write-Warning $Message
        if ($PSBoundParameters.ContainsKey('Pause')) {
            [void]('Press Enter to Continue')
        }
        if (-NOT ($PSBoundParameters.ContainsKey('Warn'))) {
            Break
        }
    }
}
function Block-NoCurl {
    <#
    .SYNOPSIS
    Blocks execution if curl.exe is not available

    .DESCRIPTION
    Validates that curl.exe is available in the Windows System32 directory. If curl.exe is not found, writes a warning and breaks execution unless the -Warn parameter is specified.

    .PARAMETER Warn
    Shows a warning but continues execution instead of breaking

    .PARAMETER Pause
    Pauses and displays a message before continuing execution

    .EXAMPLE
    Block-NoCurl
    Halts execution if curl.exe is not available

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added comment-based help

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]$Warn,
        [System.Management.Automation.SwitchParameter]$Pause
    )
    $CallingFunction = (Get-PSCallStack)[1].InvocationInfo.Line
    $Message = "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))] $CallingFunction requires curl.exe"
        
    if (-NOT (Test-Path "$env:SystemRoot\System32\curl.exe")) {
        Write-Warning $Message
        if ($PSBoundParameters.ContainsKey('Pause')) {
            [void]('Press Enter to Continue')
        }
        if (-NOT ($PSBoundParameters.ContainsKey('Warn'))) {
            Break
        }
    }
}
function Block-NoInternet {
    <#
    .SYNOPSIS
    Blocks execution if internet connectivity is not available

    .DESCRIPTION
    Validates internet connectivity by testing connections to multiple well-known URLs. If connectivity cannot be established, writes a warning and breaks execution unless the -Warn parameter is specified.

    .PARAMETER Warn
    Shows a warning but continues execution instead of breaking

    .PARAMETER Pause
    Pauses and displays a message before continuing execution

    .EXAMPLE
    Block-NoInternet
    Halts execution if internet connectivity is not available

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added comment-based help

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]$Warn,
        [System.Management.Automation.SwitchParameter]$Pause
    )
    $CallingFunction = (Get-PSCallStack)[1].InvocationInfo.Line
    $Message = "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))] $CallingFunction requires Internet access"
    
    $TestURLs = @('google.com','github.com','nvidia.com','apple.com')
    
    foreach ($URL in $TestURLs){
        if (Test-WebConnection -Uri $URL){
            $Success = $true
            break
        }
        else {
            $Success = $false
        }
    }   
    if ($Success -eq $false) {
        Write-Warning $Message
        if ($PSBoundParameters.ContainsKey('Pause')) {
            [void]('Press Enter to Continue')
        }
        if (-NOT ($PSBoundParameters.ContainsKey('Warn'))) {
            Break
        }
    }
}
function Block-PowerShellVersionLt5 {
    <#
    .SYNOPSIS
    Blocks execution if PowerShell version is less than 5

    .DESCRIPTION
    Validates that PowerShell version 5 or greater is running. If the version is less than 5, writes a warning and breaks execution unless the -Warn parameter is specified.

    .PARAMETER Warn
    Shows a warning but continues execution instead of breaking

    .PARAMETER Pause
    Pauses and displays a message before continuing execution

    .EXAMPLE
    Block-PowerShellVersionLt5
    Halts execution if PowerShell version is less than 5

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added comment-based help

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]$Warn,
        [System.Management.Automation.SwitchParameter]$Pause
    )
    $CallingFunction = (Get-PSCallStack)[1].InvocationInfo.Line
    $Message = "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))] $CallingFunction requires PowerShell version 5 or greater"
        
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        Write-Warning $Message
        if ($PSBoundParameters.ContainsKey('Pause')) {
            [void]('Press Enter to Continue')
        }
        if (-NOT ($PSBoundParameters.ContainsKey('Warn'))) {
            Break
        }
    }
}
function Block-PSModuleNotInstalled {
    <#
    .SYNOPSIS
    Blocks execution if a specified PowerShell module is not installed

    .DESCRIPTION
    Validates that a specified PowerShell module is installed and available. If the module is not found, writes a warning and breaks execution unless the -Warn parameter is specified.

    .PARAMETER ModuleName
    Name of the PowerShell module to check. Default is 'OSD'

    .PARAMETER Warn
    Shows a warning but continues execution instead of breaking

    .PARAMETER Pause
    Pauses and displays a message before continuing execution

    .EXAMPLE
    Block-PSModuleNotInstalled
    Halts execution if the OSD module is not installed

    .EXAMPLE
    Block-PSModuleNotInstalled -ModuleName ActiveDirectory
    Halts execution if the ActiveDirectory module is not installed

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added comment-based help

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding()]
    param (
        [string]$ModuleName = 'OSD',
        [System.Management.Automation.SwitchParameter]$Warn,
        [System.Management.Automation.SwitchParameter]$Pause
    )
    $CallingFunction = (Get-PSCallStack)[1].InvocationInfo.Line
    $Message = "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))] $CallingFunction requires PowerShell Module $ModuleName to be installed"
        
    if (-not (Get-Module -ListAvailable -Name $ModuleName)) {
        Write-Warning $Message
        if ($PSBoundParameters.ContainsKey('Pause')) {
            [void]('Press Enter to Continue')
        }
        if (-NOT ($PSBoundParameters.ContainsKey('Warn'))) {
            Break
        }
    }
}
function Block-StandardUser {
    <#
    .SYNOPSIS
    Blocks execution if the current user does not have Administrator rights

    .DESCRIPTION
    Validates that the current user has Administrator rights. If standard user rights are detected, writes a warning and breaks execution unless the -Warn parameter is specified.

    .PARAMETER Warn
    Shows a warning but continues execution instead of breaking

    .PARAMETER Pause
    Pauses and displays a message before continuing execution

    .EXAMPLE
    Block-StandardUser
    Halts execution if the user is not running as Administrator

    .EXAMPLE
    Block-StandardUser -Warn
    Shows a warning but continues execution even if user is not Administrator

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added comment-based help

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]$Warn,
        [System.Management.Automation.SwitchParameter]$Pause
    )
    $CallingFunction = (Get-PSCallStack)[1].InvocationInfo.Line
    $Message = "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))] $CallingFunction requires Admin Rights"

    if ((Get-OSDGather -Property IsAdmin) -eq $false) {
        Write-Warning $Message
        if ($PSBoundParameters.ContainsKey('Pause')) {
            [void]('Press Enter to Continue')
        }
        if (-NOT ($PSBoundParameters.ContainsKey('Warn'))) {
            Break
        }
    }
}
function Block-WindowsReleaseIdLt1703 {
    <#
    .SYNOPSIS
    Blocks execution if Windows ReleaseId is less than 1703

    .DESCRIPTION
    Validates that Windows ReleaseId is 1703 or greater. If the ReleaseId is less than 1703, writes a warning and breaks execution unless the -Warn parameter is specified.

    .PARAMETER Warn
    Shows a warning but continues execution instead of breaking

    .PARAMETER Pause
    Pauses and displays a message before continuing execution

    .EXAMPLE
    Block-WindowsReleaseIdLt1703
    Halts execution if Windows ReleaseId is less than 1703

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added comment-based help

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]$Warn,
        [System.Management.Automation.SwitchParameter]$Pause
    )
    $CallingFunction = (Get-PSCallStack)[1].InvocationInfo.Line
    $Message = "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))] $CallingFunction requires Windows ReleaseId of 1703 or greater"
        
    if ((Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').ReleaseId -lt 1703) {
        Write-Warning $Message
        if ($PSBoundParameters.ContainsKey('Pause')) {
            [void]('Press Enter to Continue')
        }
        if (-NOT ($PSBoundParameters.ContainsKey('Warn'))) {
            Break
        }
    }
}
function Block-WindowsVersionNe10 {
    <#
    .SYNOPSIS
    Blocks execution if Windows major version is not 10

    .DESCRIPTION
    Validates that the operating system is Windows with major version 10 or greater. If the major version is not 10, writes a warning and breaks execution unless the -Warn parameter is specified.

    .PARAMETER Warn
    Shows a warning but continues execution instead of breaking

    .PARAMETER Pause
    Pauses and displays a message before continuing execution

    .EXAMPLE
    Block-WindowsVersionNe10
    Halts execution if Windows major version is not 10

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added comment-based help

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]$Warn,
        [System.Management.Automation.SwitchParameter]$Pause
    )
    $CallingFunction = (Get-PSCallStack)[1].InvocationInfo.Line
    $Message = "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))] $CallingFunction requires Windows with a Major version 10 or greater"
        
    if ([System.Environment]::OSVersion.Version.Major -ne 10) {
        Write-Warning $Message
        if ($PSBoundParameters.ContainsKey('Pause')) {
            [void]('Press Enter to Continue')
        }
        if (-NOT ($PSBoundParameters.ContainsKey('Warn'))) {
            Break
        }
    }
}
function Block-WinOS {
    <#
    .SYNOPSIS
    Blocks execution if the system is not running WinPE

    .DESCRIPTION
    Validates that the system is running in WinPE (Windows PE) environment. If not in WinPE, writes a warning and breaks execution unless the -Warn parameter is specified.

    .PARAMETER Warn
    Shows a warning but continues execution instead of breaking

    .PARAMETER Pause
    Pauses and displays a message before continuing execution

    .EXAMPLE
    Block-WinOS
    Halts execution if the system is not running WinPE

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added comment-based help

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]$Warn,
        [System.Management.Automation.SwitchParameter]$Pause
    )
    $CallingFunction = (Get-PSCallStack)[1].InvocationInfo.Line
    $Message = "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))] $CallingFunction requires WinPE"
        
    if (-NOT (Get-OSDGather -Property IsWinPE)) {
        Write-Warning $Message
        if ($PSBoundParameters.ContainsKey('Pause')) {
            [void]('Press Enter to Continue')
        }
        if (-NOT ($PSBoundParameters.ContainsKey('Warn'))) {
            Break
        }
    }
}
function Block-WinPE {
    <#
    .SYNOPSIS
    Blocks execution if the system is running WinPE

    .DESCRIPTION
    Validates that the system is not running in WinPE (Windows PE) environment. If running in WinPE, writes a warning and breaks execution unless the -Warn parameter is specified.

    .PARAMETER Warn
    Shows a warning but continues execution instead of breaking

    .PARAMETER Pause
    Pauses and displays a message before continuing execution

    .EXAMPLE
    Block-WinPE
    Halts execution if the system is running WinPE

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added comment-based help

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]$Warn,
        [System.Management.Automation.SwitchParameter]$Pause
    )
    $CallingFunction = (Get-PSCallStack)[1].InvocationInfo.Line
    $Message = "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))] $CallingFunction cannot be run from WinPE"
        
    if ((Get-OSDGather -Property IsWinPE)) {
        Write-Warning $Message
        if ($PSBoundParameters.ContainsKey('Pause')) {
            [void]('Press Enter to Continue')
        }
        if (-NOT ($PSBoundParameters.ContainsKey('Warn'))) {
            Break
        }
    }
}
