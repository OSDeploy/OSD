function Start-OSDCloudToolbox {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]$RepoFolder,

        [Alias('OAuthToken')]
        [string]$OAuth
    )
    #region Initialize

    #Start the Transcript
    $Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Toolbox.log"
    $null = Start-Transcript -Path (Join-Path "$env:SystemRoot\Temp" $Transcript) -ErrorAction Ignore

    #Determine the proper Windows environment
    if ($env:SystemDrive -eq 'X:') {$WindowsPhase = 'WinPE'}
    else {
        $ImageState = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State' -ErrorAction Ignore).ImageState
        if ($env:UserName -eq 'defaultuser0') {$WindowsPhase = 'OOBE'}
        elseif ($ImageState -eq 'IMAGE_STATE_SPECIALIZE_RESEAL_TO_OOBE') {$WindowsPhase = 'Specialize'}
        elseif ($ImageState -eq 'IMAGE_STATE_SPECIALIZE_RESEAL_TO_AUDIT') {$WindowsPhase = 'AuditMode'}
        else {$WindowsPhase = 'Windows'}
    }

    #Finish initialization
    Write-Host -ForegroundColor DarkGray "WindowsPhase: $WindowsPhase"
    if (-not ($RepoFolder)) {
        $RepoFolder = $WindowsPhase
    }

    #Load OSDCloud Functions
    #Invoke-Expression -Command (Invoke-RestMethod -Uri functions.osdcloud.com)

    #endregion
    
    #region Run Command
    if ($OAuth) {
        $OSDPadParams = @{
            Brand           = "OSDCloud Toolbox - $RepoFolder"
            RepoOwner       = 'OSDeploy'
            RepoName        = 'OSDCloudToolbox'
            RepoFolder      = $RepoFolder
            OAuth           = $OAuth
        }
    }
    else {
        $OSDPadParams = @{
            Brand           = "OSDCloud Toolbox - $RepoFolder"
            RepoOwner       = 'OSDeploy'
            RepoName        = 'OSDCloudToolbox'
            RepoFolder      = $RepoFolder
        }
    }
    Start-OSDPad @OSDPadParams
    #endregion
}