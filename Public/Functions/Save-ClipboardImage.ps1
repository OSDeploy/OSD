function Save-ClipboardImage {
<#
.SYNOPSIS
Saves ClipboardImage content.

.DESCRIPTION
Writes ClipboardImage output to disk or another target defined by parameters.

.PARAMETER SaveAs
Specifies the SaveAs to use when running Save-ClipboardImage.

.EXAMPLE
Save-ClipboardImage -S <value>
Demonstrates a common way to run Save-ClipboardImage.

.LINK
https://github.com/OSDeploy/OSD/tree/master/docs

.NOTES
Author: David Segura - Recast Software
2026-07-13 - Initial help block created
2026-07-13 - Refined generated help text
#>
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
