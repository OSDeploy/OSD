<#
.SYNOPSIS
Returns True if ImagePath is a Windows Image

.DESCRIPTION
Returns True if ImagePath is a Windows Image

.PARAMETER ImagePath
Specifies the full path to the Windows Image

.PARAMETER Index
Index of the Windows Image

.PARAMETER Extension
Test if the File Extension is .esd or .wim

.LINK
https://osd.osdeploy.com/module/functions/windowsimage

.NOTES
#>
function Test-WindowsImage {
    [CmdletBinding()]
    param (
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('FullName')]
        [string]$ImagePath,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [Alias('ImageIndex')]
        [UInt32]$Index = $null,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [ValidateSet('.esd','.wim')]
        [string]$Extension = $null
    )
    #=================================================
    #   Test-Path
    #=================================================
    if (! (Test-Path $ImagePath)) {
        Write-Warning "Test-WindowsImage: Test-Path failed $ImagePath"
        Return $false
    }
    #=================================================
    #   Get-Item
    #=================================================
    try {
        $GetItem = Get-Item -Path $ImagePath -ErrorAction Stop
    }
    catch {
        Write-Warning "Test-WindowsImage: Get-Item failed $ImagePath"
        Return $false
    }
    #=================================================
    #   Get-Item Extension
    #=================================================
    if ($Extension) {
        if (($Extension -eq '.esd') -and ($GetItem.Extension -ne '.esd')) {
            Write-Warning "Test-WindowsImage: Get-Item Extension is not $Extension"
            Return $false
        }
        if (($Extension -eq '.wim') -and ($GetItem.Extension -ne '.wim')) {
            Write-Warning "Test-WindowsImage: Get-Item Extension is not $Extension"
            Return $false
        }
    }
    else {
        if (($GetItem.Extension -ne '.esd') -and ($GetItem.Extension -ne '.wim')) {
            Write-Warning "Test-WindowsImage: Get-Item Extension failed. File must be .esd or .wim"
            Return $false
        }
    }
    #=================================================
    #   Get-WindowsImage
    #=================================================
    if ($Index) {
        try {
            $GetWindowsImage = Get-WindowsImage -ImagePath $GetItem.FullName -Index $Index -ErrorAction Stop | Out-Null
            Return $true
        }
        catch {
            Write-Warning "Test-WindowsImage: Get-WindowsImage failed $ImagePath"
            Return $false
        }
        finally {
            $Error.Clear()
        }
    }
    else {
        try {
            $GetWindowsImage = Get-WindowsImage -ImagePath $GetItem.FullName -ErrorAction Stop | Out-Null
            Return $true
        }
        catch {
            Write-Warning "Test-WindowsImage: Get-WindowsImage failed $ImagePath"
            Return $false
        }
        finally {
            $Error.Clear()
        }
    }
    #=================================================
    #   Something didn't work right if this is run
    #=================================================
    Return $false
    #=================================================
}