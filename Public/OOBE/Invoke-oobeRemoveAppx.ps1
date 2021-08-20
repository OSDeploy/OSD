function Invoke-oobeRemoveAppx {
    [CmdletBinding()]
    param (
        [string[]]$RemoveAppx
    )
    #================================================
    #   Initialize
    #================================================
    $Title = 'Invoke-oobeRemoveAppx'
    $host.ui.RawUI.WindowTitle = "Running $Title"
    $host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.size(2000,2000)
    #================================================
    #   Temp
    #================================================
    if (!(Test-Path "$env:SystemRoot\Temp")) {
        New-Item -Path "$env:SystemRoot\Temp" -ItemType Directory -Force
    }
    #================================================
    #   Transcript
    #================================================
    $Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-$Title.log"
    Start-Transcript -Path (Join-Path "$env:SystemRoot\Temp" $Transcript) -ErrorAction Ignore
    $host.ui.RawUI.WindowTitle = "Running $Title $env:SystemRoot\Temp\$Transcript"
    #================================================
    #   Main
    #================================================
    if ($env:UserName -eq 'defaultuser0') {
        foreach ($Item in $RemoveAppx) {
            Remove-AppxOnline -Name $Item
        }
    }
    else {
        Write-Warning "OOBE defaultuser0 is required to run $Title"
        Start-Sleep -Seconds 5
    }

    #================================================
    #   Complete
    #================================================
    if ($Global:OOBEDeployWindowTitle) {
        $host.ui.RawUI.WindowTitle = $Global:OOBEDeployWindowTitle
    }
    else {
        $host.ui.RawUI.WindowTitle = "$Title $env:SystemRoot\Temp\$Transcript"
    }
    Stop-Transcript
    #================================================
}