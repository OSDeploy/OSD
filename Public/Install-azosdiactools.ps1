function Install-azOSDIacTools {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        Block-StandardUser
        Write-Host "============================================================" -ForegroundColor Gray
        Write-Host "Searching for #Iac Tools on your system $env:COMPUTERNAME" -ForegroundColor Green
        Write-Host "============================================================" -ForegroundColor Gray
        write-host ""

        try {
            Write-Host "Searching for Terraform on your system $env:COMPUTERNAME" -ForegroundColor Green
            $resultterraform = Terraform --version
            Write-Host "Found Terraform on your system $env:COMPUTERNAME with the version $($resultterraform[0].split(" ")[1])" -ForegroundColor Cyan
            write-host ""

        }
        catch {
            Write-Warning "Terraform is not installed on your system $env:COMPUTERNAME"
            $Needinstallterraform = $true
        }
        try {
            Write-Host "Searching for bicep on your system $env:COMPUTERNAME" -ForegroundColor Green
            $resultbicep =  bicep --version
            Write-Host "Found bicep on your system $env:COMPUTERNAME with the version $($resultbicep)" -ForegroundColor Cyan
            write-host ""

        }
        catch {
            Write-Warning "Bicep is not installed on your system $env:COMPUTERNAME"
            $Needinstallbicep = $true
        }
        try {
            Write-Host "Searching for Azure Cli on your system $env:COMPUTERNAME" -ForegroundColor Green
            $resultazcli =  az --version
            Write-Host "Found Azure Cli on your system $env:COMPUTERNAME with the version $($resultazcli[0].Split(" ")[$resultazcli[0].Split(" ").count -1])" -ForegroundColor Cyan
            write-host ""
        }
        catch {
            Write-Warning "Azure Cli is not installed on your system $env:COMPUTERNAME"
            Write-Host ""
            $Needinstallazcli = $true
        }
    
    }
    
    process {
       
        if ($Needinstallbicep -eq $true ) {
            
            Write-Host "Installing bicep on your system $env:COMPUTERNAME" -ForegroundColor Green
            $installPath = "$env:USERPROFILE\.bicep"
            $installDir = New-Item -ItemType Directory -Path $installPath -Force
            $installDir.Attributes += 'Hidden'
            # Fetch the latest Bicep CLI binary
            (New-Object Net.WebClient).DownloadFile("https://github.com/Azure/bicep/releases/latest/download/bicep-win-x64.exe", "$installPath\bicep.exe")
            # Add bicep to your PATH
            $currentPath = (Get-Item -path "HKCU:\Environment" ).GetValue('Path', '', 'DoNotExpandEnvironmentNames')
            if (-not $currentPath.Contains("%USERPROFILE%\.bicep")) { setx PATH ($currentPath + ";%USERPROFILE%\.bicep") }
            if (-not $env:path.Contains($installPath)) { $env:path += ";$installPath" }
            $resultbicep =  bicep --version
            Write-Host "Found bicep on your system $env:COMPUTERNAME with the version $($resultbicep)" -ForegroundColor Cyan
            write-host ""

        }

        if ($Needinstallazcli -eq $true) {
            Write-Host "Installing Azure CLI on your system $env:COMPUTERNAME" -ForegroundColor Green
            Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi
            Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
            rm .\AzureCLI.msi 
            # Add Terraform to your PATH
            $currentPath = (Get-Item -path "HKCU:\Environment" ).GetValue('Path', '', 'DoNotExpandEnvironmentNames')
            if (-not $currentPath.Contains("C:\Program Files (x86)\Microsoft SDKs\Azure\CLI2\wbin")) { setx PATH ($currentPath + "; 'C:\Program Files (x86)\Microsoft SDKs\Azure\CLI2\wbin'") }
            if (-not $env:path.Contains( "C:\Program Files (x86)\Microsoft SDKs\Azure\CLI2\wbin")) { $env:path += "; 'C:\Program Files (x86)\Microsoft SDKs\Azure\CLI2\wbin'" }
            write-host ""
            Write-Warning "You need to restart Powershell session."

        }

        if ($Needinstallterraform -eq $true) {
            Write-Host "Installing Terraform on your system $env:COMPUTERNAME" -ForegroundColor Green
            $installPath = "$env:USERPROFILE\.terraform"
            $installDir = New-Item -ItemType Directory -Path $installPath -Force
            $installDir.Attributes += 'Hidden'
            # Fetch the Terraform CLI binary
            (New-Object Net.WebClient).DownloadFile("https://releases.hashicorp.com/terraform/1.2.3/terraform_1.2.3_windows_amd64.zip", "$installPath\terraform_1.2.3_windows_amd64.zip")
            Expand-Archive "$installPath\terraform_1.2.3_windows_amd64.zip" -DestinationPath "$installPath" -Force
            Remove-Item -Path "$installPath\terraform_1.2.3_windows_amd64.zip" -Force
            # Add Terraform to your PATH
            $currentPath = (Get-Item -path "HKCU:\Environment" ).GetValue('Path', '', 'DoNotExpandEnvironmentNames')
            if (-not $currentPath.Contains("%USERPROFILE%\.terraform")) { setx PATH ($currentPath + ";%USERPROFILE%\.terraform") }
            if (-not $env:path.Contains($installPath)) { $env:path += ";$installPath" }
            $resultterraform = Terraform --version
            Write-Host "Found Terraform on your system $env:COMPUTERNAME with the version $($resultterraform[0].split(" ")[1])" -ForegroundColor Cyan
            write-host ""

        }

    }
    
    end {
        Write-Host "============================================================" -ForegroundColor Gray
        Write-Host "Searching PowerShellModule  for #Iac on your system $env:COMPUTERNAME" -ForegroundColor Green
        Write-Host "============================================================" -ForegroundColor Gray
        write-host ""
        Get-AzOSDModules
        Write-Host "============================================================" -ForegroundColor Gray
        Write-Host "End all #Iac Tools are present on your system $env:COMPUTERNAME" -ForegroundColor Green
        Write-Host "============================================================" -ForegroundColor Gray
        write-host ""

    }
}

