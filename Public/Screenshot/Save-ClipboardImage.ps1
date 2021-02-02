<#
.SYNOPSIS
Saves the Clipboard Image as a file.  PNG extension is recommended

.DESCRIPTION
Saves the Clipboard Image as a file.  PNG extension is recommended

.LINK
https://osd.osdeploy.com/module/functions/general/save-clipboardimage

.NOTES
21.2.1  Initial Release
#>
function Save-ClipboardImage {
    [CmdletBinding()]
    param(
        #Path and Name of the file to save
        #PNG extension is recommend
        [Parameter(Mandatory = $true)]
        $SaveAs
    )

    #Test if the Clipboard contains an Image
    if (!(Get-Clipboard -Format Image)) {
        Write-Warning "Clipboard Image does not exist"
        Break
    }

    #Test if existing file is present
    if (Test-Path $SaveAs) {
        Write-Warning "Existing file '$SaveAs' will be overwritten"
    }

    Try {
        (Get-Clipboard -Format Image).Save($SaveAs)
    }
    Catch{
        Write-Warning "Clipboard Image does not exist"
        Break
    }

    #Make sure that a file was written
    if (!(Test-Path $SaveAs)) {
        Write-Warning "Clipboard Image could not be saved to '$SaveAs'"
    }

    #Return Get-Item Object
    Return Get-Item -Path $SaveAs
}