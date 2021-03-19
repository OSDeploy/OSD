function Block-Admin {
    [CmdletBinding()]
    param ()
    $FirstParty = (Get-PSCallStack)[1].InvocationInfo.Line
    $Message = "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))] $FirstParty requires non-Admin Rights"

    if ((Get-OSDGather -Property IsAdmin) -eq $true) {
        Write-Warning $Message; Break
    }
}
function Block-StandardUser {
    [CmdletBinding()]
    param ()
    $FirstParty = (Get-PSCallStack)[1].InvocationInfo.Line
    $Message = "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))] $FirstParty requires Admin Rights"

    if ((Get-OSDGather -Property IsAdmin) -eq $false) {
        Write-Warning $Message; Break
    }
}
function Block-WinOS {
    [CmdletBinding()]
    param ()
    $FirstParty = (Get-PSCallStack)[1].InvocationInfo.Line
    $Message = "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))] $FirstParty requires WinPE"
        
    if (-NOT (Get-OSDGather -Property IsWinPE)) {
        Write-Warning $Message; Break
    }
}
function Block-WinPE {
    [CmdletBinding()]
    param ()
    $FirstParty = (Get-PSCallStack)[1].InvocationInfo.Line
    $Message = "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))] $FirstParty cannot be run from WinPE"
        
    if ((Get-OSDGather -Property IsWinPE)) {
        Write-Warning $Message; Break
    }
}
function Block-WindowsMajorLt10 {
    [CmdletBinding()]
    param ()
    $FirstParty = (Get-PSCallStack)[1].InvocationInfo.Line
    $Message = "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))] $FirstParty requires Windows with a Major version 10 or greater"
        
    if ([System.Environment]::OSVersion.Version.Major -lt 10) {
        Write-Warning $Message; Break
    }
}
function Block-PowerShellVersionLt5 {
    [CmdletBinding()]
    param ()
    $FirstParty = (Get-PSCallStack)[1].InvocationInfo.Line
    $Message = "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))] $FirstParty requires PowerShell version 5 or greater"
        
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        Write-Warning $Message; Break
    }
}
function Block-WindowsReleaseIdLt1703 {
    [CmdletBinding()]
    param ()
    $FirstParty = (Get-PSCallStack)[1].InvocationInfo.Line
    $Message = "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))] $FirstParty requires Windows ReleaseId of 1703 or greater"
        
    if ((Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').ReleaseId -lt 1703) {
        Write-Warning $Message; Break
    }
}
function Block-NonCurl {
    [CmdletBinding()]
    param ()
    $FirstParty = (Get-PSCallStack)[1].InvocationInfo.Line
    $Message = "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))] $FirstParty requires curl.exe"
        
    if (-NOT (Test-Path "$env:SystemRoot\System32\curl.exe")) {
        Write-Warning $Message; Break
    }
}