function Get-AzOSDCloud {
    <#
    .SYNOPSIS
    Initialize the local OSDCloud Azure workspace.

    .DESCRIPTION
    Creates the local OSDCloud folder structure under C:\OSDCloud, copies the repository's Bicep
    and Terraform templates into place, and optionally opens the workspace in Visual Studio Code.

    .PARAMETER edit
    Open the C:\OSDCloud workspace in Visual Studio Code after the files are copied.

    .EXAMPLE
    Get-AzOSDCloud
    Creates the local workspace and copies the Azure IaC templates.

    .EXAMPLE
    Get-AzOSDCloud -edit
    Creates the local workspace and opens it in Visual Studio Code.

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Updated help to repo standard

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .LINK
    https://github.com/OSDeploy/OSD/blob/master/docs/Get-AzOSDCloud.md
    #>
    [CmdletBinding()]
    param (
        [switch]$edit
    )
    Write-Host "============================================================" -ForegroundColor Gray
    Write-Host "Initialize OSDCLOUD system $env:COMPUTERNAME" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Gray
    write-host ""
    Write-Host "This function create this folder structure" -ForegroundColor Green
    write-host ""
    write-host "├───bicep" -ForegroundColor Cyan
    write-host "    └───azosdbicep.bicep" -ForegroundColor Cyan
    write-host "└───terraform" -ForegroundColor Cyan
    write-host "    └───maint.tf" -ForegroundColor Cyan
    write-host "    └───provider.tf" -ForegroundColor Cyan
    write-host "    └───terraform.tfvars" -ForegroundColor Cyan
    write-host "    └───variables.tf" -ForegroundColor Cyan
    if ($edit.IsPresent){

        Write-Host "The Folder OSDCloud will be open with Visual Code" -ForegroundColor Green
   }


    Start-Sleep -Seconds 5


    $Folders = @('bicep', 'terraform')
    $BaseNamefolder = $MyInvocation.MyCommand.Module.ModuleBase
    if (!(Test-Path c:\OSDcloud)){
        Write-Host "Creating Folder OSDCLOUD on disk C:"
        foreach ($item in $Folders) {
            New-Item -Name $item -ItemType Directory -Path c:\OSDCloud | Out-Null
            Write-Host "Creating $item folder in OSDCLOUD folder on disk C:"
        }
    }

   $Bicep= Get-ChildItem -Path $BaseNamefolder\cloud\Iac\bicep
   $terraform = Get-ChildItem -Path $BaseNamefolder\cloud\Iac\terraform

   foreach ($item in $terraform.Name) {

    Copy-Item -LiteralPath "$BaseNamefolder\cloud\Iac\terraform\$item" -Destination C:\OSDcloud\terraform\$item -force

   }
   foreach ($item in $Bicep.Name) {

    Copy-Item -LiteralPath "$BaseNamefolder\cloud\Iac\bicep\$item" -Destination C:\OSDcloud\bicep\$item -force

   }
   if ($edit.IsPresent){

    try {
        code C:\OSDCloud

    }
    catch {
        Write-Warning "the Program Visual Code isn't available"
    }

   }

}
