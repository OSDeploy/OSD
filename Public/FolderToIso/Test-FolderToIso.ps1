function Test-FolderToIso {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName')]
        [string]$folderFullName,

        [string]$isoFullName = (Join-Path $env:TEMP $([string]$(Get-Random) + '.iso')),

        [ValidateLength(1,16)]
        [string]$isoLabel = 'FolderToIso'
    )
    #=================================================
    #   Make sure the folder we are iso'ing exists
    #=================================================
    if (! (Test-Path $folderFullName)) {
        Write-Warning "Test-FolderToIso: folderFullName does not exist at $folderFullName"
        Return $false
    }
    #=================================================
    #   Make sure folder is a folder
    #=================================================
    if ((Get-Item $folderFullName) -isnot [System.IO.DirectoryInfo]) {
        Write-Warning "Test-FolderToIso: folderFullName is not a folder"
        Return $false
    }
    #=================================================
    #   isoFullName
    #=================================================
    $GetItem = Get-Item -Path $folderFullName
    if (! ($isoFullName)) {
        $isoFullName = Join-Path (get-item -Path "T:\DevBox\Win11_22000.318").Parent.FullName ($GetItem.BaseName + '.iso')
    }
    #=================================================
    #   Test if existing file exists and writable
    #=================================================
    if (Test-Path $isoFullName) {
        Write-Warning "Test-FolderToIso: Delete exiting file at $isoFullName"
        Return $false
    }
    else {
        try {
            New-Item -Path $isoFullName -Force -ErrorAction Stop | Out-Null
        }
        catch {
            Write-Warning "Test-FolderToIso: isoFullName is not writable at $isoFullName"
            Return $false
        }
        finally {
            if (Test-Path $isoFullName) {
                Remove-Item -Path $isoFullName -Force | Out-Null
            }
        }
    }
    #=================================================
    #   Get Adk Paths
    #=================================================
    $AdkPaths = Get-AdkPaths

    if ($null -eq $AdkPaths) {
        Write-Warning "Test-FolderToIso: Could not locate the ADK to create the ISO"
        Return $false
    }
    #=================================================
    #   Return results
    #=================================================
    Return $true
    #=================================================
}