<#
.SYNOPSIS
Break the running script if run as an Administrator

.DESCRIPTION
Break the running script if run as an Administrator

.PARAMETER Warn
Warning Message without a Break

.PARAMETER Pause
Adds a 'Press Enter to Continue'

.LINK
https://osd.osdeploy.com/module/functions/block
#>
function Block-AdminUser {
    [CmdletBinding()]
    param (
        [switch]$Warn,
        [switch]$Pause
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
<#
.SYNOPSIS
Break the running script if the computer is not a Lenovo

.DESCRIPTION
Break the running script if the computer is not a Lenovo

.PARAMETER Warn
Warning Message without a Break

.PARAMETER Pause
Adds a 'Press Enter to Continue'

.LINK
https://osd.osdeploy.com/module/functions/block
#>
function Block-ManufacturerNeLenovo {
    [CmdletBinding()]
    param (
        [switch]$Warn,
        [switch]$Pause
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
<#
.SYNOPSIS
Break the running script if Curl.exe is not present on the system

.DESCRIPTION
Break the running script if Curl.exe is not present on the system

.PARAMETER Warn
Warning Message without a Break

.PARAMETER Pause
Adds a 'Press Enter to Continue'

.LINK
https://osd.osdeploy.com/module/functions/block
#>
function Block-NoCurl {
    [CmdletBinding()]
    param (
        [switch]$Warn,
        [switch]$Pause
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
<#
.SYNOPSIS
Break the running script if PowerShell Version is less than 5

.DESCRIPTION
Break the running script if PowerShell Version is less than 5

.PARAMETER Warn
Warning Message without a Break

.PARAMETER Pause
Adds a 'Press Enter to Continue'

.LINK
https://osd.osdeploy.com/module/functions/block
#>
function Block-PowerShellVersionLt5 {
    [CmdletBinding()]
    param (
        [switch]$Warn,
        [switch]$Pause
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
<#
.SYNOPSIS
Break the running script if run as a Standard User

.DESCRIPTION
Break the running script if run as a Standard User

.PARAMETER Warn
Warning Message without a Break

.PARAMETER Pause
Adds a 'Press Enter to Continue'

.LINK
https://osd.osdeploy.com/module/functions/block
#>
function Block-StandardUser {
    [CmdletBinding()]
    param (
        [switch]$Warn,
        [switch]$Pause
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
<#
.SYNOPSIS
Break the running script if the Windows 10 ReleaseID is less than 1703

.DESCRIPTION
Break the running script if the Windows 10 ReleaseID is less than 1703

.PARAMETER Warn
Warning Message without a Break

.PARAMETER Pause
Adds a 'Press Enter to Continue'

.LINK
https://osd.osdeploy.com/module/functions/block
#>
function Block-WindowsReleaseIdLt1703 {
    [CmdletBinding()]
    param (
        [switch]$Warn,
        [switch]$Pause
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
<#
.SYNOPSIS
Break the running script if the Windows Version is not equal to 10

.DESCRIPTION
Break the running script if the Windows Version is not equal to 10

.PARAMETER Warn
Warning Message without a Break

.PARAMETER Pause
Adds a 'Press Enter to Continue'

.LINK
https://osd.osdeploy.com/module/functions/block
#>
function Block-WindowsVersionNe10 {
    [CmdletBinding()]
    param (
        [switch]$Warn,
        [switch]$Pause
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
<#
.SYNOPSIS
Break the running script if running in Windows (not WinPE)

.DESCRIPTION
Break the running script if running in Windows (not WinPE)

.PARAMETER Warn
Warning Message without a Break

.PARAMETER Pause
Adds a 'Press Enter to Continue'

.LINK
https://osd.osdeploy.com/module/functions/block
#>
function Block-WinOS {
    [CmdletBinding()]
    param (
        [switch]$Warn,
        [switch]$Pause
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
<#
.SYNOPSIS
Break the running script if run in WinPE (not Windows)

.DESCRIPTION
Break the running script if run in WinPE (not Windows)

.PARAMETER Warn
Warning Message without a Break

.PARAMETER Pause
Adds a 'Press Enter to Continue'

.LINK
https://osd.osdeploy.com/module/functions/block
#>
function Block-WinPE {
    [CmdletBinding()]
    param (
        [switch]$Warn,
        [switch]$Pause
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
<#
.SYNOPSIS
Break the running script if PowerShell Module is not installed

.DESCRIPTION
Break the running script if PowerShell Module is not installed

.PARAMETER Warn
Warning Message without a Break

.PARAMETER Pause
Adds a 'Press Enter to Continue'

.LINK
https://osd.osdeploy.com/module/functions/block
#>
function Block-PSModuleNotInstalled {
    [CmdletBinding()]
    param (
        [string]$ModuleName = 'OSD',
        [switch]$Warn,
        [switch]$Pause
    )
    $CallingFunction = (Get-PSCallStack)[1].InvocationInfo.Line
    $Message = "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))] $CallingFunction requires PowerShell Modukle $ModuleName to be installed"
        
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