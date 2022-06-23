function get-AzOSDCloud {
    [CmdletBinding()]
    param (
        
    )
    $Folders = @('bicep', 'terraform')
    $BaseNamefolder = Get-CurrentModuleBase
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

   code C:\OSDcloud

}