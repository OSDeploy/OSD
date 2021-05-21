#=======================================================================
#   PowershellWindow Functions
#=======================================================================
$Script:showWindowAsync = Add-Type -MemberDefinition @"
[DllImport("user32.dll")]
public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
"@ -Name "Win32ShowWindowAsync" -Namespace Win32Functions -PassThru
function Show-PowershellWindow() {
    $null = $showWindowAsync::ShowWindowAsync((Get-Process -Id $pid).MainWindowHandle, 10)
}
function Hide-PowershellWindow() {
    $null = $showWindowAsync::ShowWindowAsync((Get-Process -Id $pid).MainWindowHandle, 2)
}

Hide-PowershellWindow
#=======================================================================
#   MahApps.Metro
#=======================================================================
# Assign current script directory to a global variable
$Global:MyScriptDir = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)

# Load presentationframework and Dlls for the MahApps.Metro theme
[System.Reflection.Assembly]::LoadWithPartialName("presentationframework") | Out-Null
[System.Reflection.Assembly]::LoadFrom("$Global:MyScriptDir\assembly\System.Windows.Interactivity.dll") | Out-Null
[System.Reflection.Assembly]::LoadFrom("$Global:MyScriptDir\assembly\MahApps.Metro.dll") | Out-Null

# Set console size and title
$host.ui.RawUI.WindowTitle = "OSDeploy"
#=======================================================================
#   Test-InWinPE
#=======================================================================
function Test-InWinPE {
    return Test-Path -Path Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlset\Control\MiniNT
}
#=======================================================================
#   LoadForm
#=======================================================================
function LoadForm {
    [CmdletBinding()]
    param (
     [Parameter(Mandatory=$False,Position=1)]
     [string]$XamlPath
    )
    
    # Import the XAML code
    #[xml]$Global:xmlWPF = Get-Content -Path $XamlPath

    [xml]$Global:xmlWPF = @"
    <Controls:MetroWindow
        xmlns:Controls = "clr-namespace:MahApps.Metro.Controls;assembly=MahApps.Metro"
        xmlns = "http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x = "http://schemas.microsoft.com/winfx/2006/xaml"
        Title = "Start-AutopilotGUI" Height="240" Width="565"
        BorderBrush = "{DynamicResource AccentColorBrush}"
        BorderThickness = "1"
        WindowStartupLocation = "CenterScreen">

        <Window.Resources>
            <ResourceDictionary>
                <ResourceDictionary.MergedDictionaries>
                    <!-- MahApps.Metro resource dictionaries. Make sure that all file names are Case Sensitive! -->
                    <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Controls.xaml" />
                    <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Fonts.xaml" />
                    <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Colors.xaml" />
                    <!-- Accent and AppTheme setting -->
                    <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Accents/Blue.xaml" />
                    <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Accents/BaseLight.xaml" />
                </ResourceDictionary.MergedDictionaries>
            </ResourceDictionary>
        </Window.Resources>

        <Grid>
            <StackPanel>
                <Label Name="Title"
                Content="OSDeploy Autopilot"
                HorizontalAlignment="Left" Margin="10,5,0,0" VerticalAlignment="Top" Width="500" FontSize="30"/>
            </StackPanel>
            <StackPanel>
                <Label Name="LabelOperatingSystem"
                Content="Select an Operating System"
                HorizontalAlignment="Left" Margin="10,50,0,0" VerticalAlignment="Top" Width="390" FontSize="14"/>
            </StackPanel>
            <StackPanel>
                <ComboBox Name="ListBoxOperatingSystems"
                SelectedIndex="0" HorizontalAlignment="Left" Height="30" Margin="29,80,0,0" VerticalAlignment="Top" Width="399" FontSize="14"/>
            </StackPanel>

            <StackPanel>
                <Label Name="LabelMethod"
                Content="Select an Autopilot Registration Method"
                HorizontalAlignment="Left" Margin="10,110,0,0" VerticalAlignment="Top" Width="390" FontSize="14"/>
            </StackPanel>
            <StackPanel>    
                <ComboBox Name="ListBoxAutopilotMethod"
                SelectedIndex="0" HorizontalAlignment="Left" Height="30" Margin="29,140,0,0" VerticalAlignment="Top" Width="399" FontSize="14"/>
            </StackPanel>

            <StackPanel Orientation="Horizontal">
                <Button Name="GoButton"
                Content="GO"
                HorizontalAlignment="Right" Margin="437,80,0,0" VerticalAlignment="Top" Width="116" Height="90" FontSize="16"/>
            </StackPanel>
        </Grid>
    </Controls:MetroWindow>
"@

    # Add WPF and Windows Forms assemblies
    try {
        Add-Type -AssemblyName PresentationCore,PresentationFramework,WindowsBase,system.windows.forms
    } 
    catch {
        throw "Failed to load Windows Presentation Framework assemblies."
    }

    #Create the XAML reader using a new XML node reader
    $Global:xamGUI = [Windows.Markup.XamlReader]::Load((new-object System.Xml.XmlNodeReader $xmlWPF))

    #Create hooks to each named object in the XAML
    $xmlWPF.SelectNodes("//*[@Name]") | ForEach {
        Set-Variable -Name ($_.Name) -Value $xamGUI.FindName($_.Name) -Scope Global
    }
}
#=======================================================================
#   LoadForm
#=======================================================================
# Load the XAML form and create the PowerShell Variables
LoadForm


#Get the DeployRoot
$DeployRoot = (Get-Item $PSScriptRoot).parent.FullName

#Find available Operating Systems
$OperatingSystemsPath = Join-Path $DeployRoot "Operating Systems"
$OperatingSystems = Get-ChildItem $OperatingSystemsPath -Directory | Where-Object {$_.Name -match 'Win10' -and $_.Name -match 'x64'} | Sort-Object -Property Name -Descending | ForEach-Object {
    $ListBoxOperatingSystems.Items.Add($_) | Out-Null
}

#Select a Deployment Method
$AutopilotMethods = @('OOBE','Audit Mode','Production JSON','Development JSON')
$AutopilotMethods | ForEach-Object {$ListBoxAutopilotMethod.Items.Add($_) | Out-Null}

# EVENT Handlers 
$GoButton.add_Click({
    if (-not ($ListBoxOperatingSystems.SelectedItem)) {
        # Do nothing 
    }
    if(-not ($ListBoxAutopilotMethod.SelectedItem)) {
        # Do nothing 
    }
    else {
        $OperatingSystemName = $ListBoxOperatingSystems.SelectedItem
        Write-Host "Operating System: $($OperatingSystemName.FullName)"

        $AutopilotMethod = $ListBoxAutopilotMethod.SelectedItem
        Write-Host "Autopilot Registration Method: $AutopilotMethod"

        # Close the WPF GUI
        $xamGUI.Close()
        Show-PowershellWindow

        #===================================================================================================
        #   Define Build Process
        #===================================================================================================
        $ApplyDrivers           = $true
        $BuildName              = 'OSDeploy Autopilot'
        $SetAuditMode           = $false
        $SetDevelopment         = $false
        $SetProduction          = $false
        $RequiresUEFI           = $true
        $RequiresWinPE          = $true

        if ($AutopilotMethod -eq 'Audit Mode') {
            $SetAuditMode       = $true
        }

        if ($AutopilotMethod -eq 'Development JSON') {
            $SetDevelopment     = $true
        }
        
        if ($AutopilotMethod -eq 'Production JSON') {
            $SetProduction      = $true
        }

        Write-Host -ForegroundColor DarkCyan "================================================================="
        #===================================================================================================
        #   Warning
        #===================================================================================================
        Write-Warning "This computer will be prepared for $BuildName"
        Write-Warning "All Local Hard Drives will be wiped and all data will be lost"
        Write-Host ""
        Write-Warning "When you press any key to continue, this process will get started"
        PAUSE
        #===================================================================================================
        #   Require UEFI for AutoPilot
        #===================================================================================================
        if ((Get-OSDGather -Property IsUEFI) -eq $false) {
            Write-Warning "$BuildName requires UEFI"
            PAUSE
            Break
        }
        #===================================================================================================
        #   Verify WinPE
        #===================================================================================================
        if (-NOT (Test-InWinPE)) {
            Write-Warning "Running in Full Windows - $BuildName will not continue!"
            PAUSE
            Break
        }
        #===================================================================================================
        #   Enable High Performance Power Plan
        #===================================================================================================
        Get-OSDPower -Property High
        #===================================================================================================
        #   Remove USB Drives
        #===================================================================================================
        if (Get-USBDisk) {
            do {
                Write-Warning "Remove all attached USB Drives at this time ..."
                $RemoveUSB = $true
                pause
            }
            while (Get-USBDisk)
        }
        #===================================================================================================
        #   Clear Local Disks
        #===================================================================================================
        Clear-LocalDisk -Force
        #===================================================================================================
        #   Create OSDisk
        #===================================================================================================
        New-OSDisk -Force
        Start-Sleep -Seconds 3
        #===================================================================================================
        #   Attach USB Drives
        #===================================================================================================
        if ($GetUSBDisk) {
            do {
                Write-Warning "Attach the USB Drive $($GetUSBDisk.FriendlyName) to continue ..."
                pause
            }
            until (Get-USBDisk | Where-Object {$_.ObjectId -eq $GetUSBDisk.ObjectId})
        
            $GetUSBPartition | Select-Object *
        
            $NewDriveLetter = Get-Partition | `
                Where-Object {$_.ObjectId -eq $GetUSBPartition.ObjectId} | `
                Where-Object {$_.PartitionNumber -eq $GetUSBPartition.PartitionNumber} | `
                Select-Object -ExpandProperty DriveLetter
            #Write-Host "NewDriveLetter = $NewDriveLetter"
            #Write-Host "DeployPath = $DeployPath"
            $DeployRoot = "$($NewDriveLetter):$($DeployPath)"
            Write-Host "DeployRoot = $DeployRoot"
            #Pause
        }
        #===================================================================================================
        #   DeployRoot
        #===================================================================================================
        if (($null -eq $DeployRoot) -or (-NOT (Test-Path "$DeployRoot"))) {
            Write-Warning "An error has occurred getting the DeployRoot"
            Write-Warning "$BuildName will exit"
            Break
        }
        #===================================================================================================
        #   OperatingSystems
        #===================================================================================================
        $OperatingSystems = Join-Path $DeployRoot "Operating Systems"
        if ($null -eq $DeployRoot) {
            Write-Warning "An error has occurred getting the Operating Systems"
            Write-Warning "$BuildName will exit"
            Break
        }
        #===================================================================================================
        #   Operating System
        #===================================================================================================
        $OperatingSystem = Get-ChildItem $OperatingSystems -Directory -Recurse | `
            Where-Object {($_.Name -match 'Win10') -and ($_.Name -match 'x64') -and ($_.Name -match $OperatingSystemName)} | `
            Select-Object -First 1 | `
            Select-Object -ExpandProperty FullName
        if ($null -eq $OperatingSystem) {
            Write-Warning "An error has occurred getting the AutoPilotOS"
            Write-Warning "$BuildName will exit"
            Break
        }
        #===================================================================================================
        #   Drivers
        #===================================================================================================
        if ($ApplyDrivers) {
            $Drivers = Join-Path $DeployRoot "OSDeploy\OSDDrivers"
            if ($null -eq $Drivers) {
                Write-Warning "An error has occurred getting the Drivers"
                Write-Warning "$BuildName will exit"
                Break
            }
        }
        #===================================================================================================
        #   Go
        #===================================================================================================
        Clear-Host
        Write-Host -ForegroundColor Cyan "================================================================="
        Write-Host -ForegroundColor Cyan "Preparing $BuildName"
        Write-Host -ForegroundColor Cyan "DeployRoot:   $DeployRoot"
        Write-Host -ForegroundColor Cyan "Windows OS:   $OperatingSystem"
        Write-Host -ForegroundColor Cyan "Drivers:      $Drivers"
        Write-Host -ForegroundColor Cyan "================================================================="
        #===================================================================================================
        #   Apply OS
        #===================================================================================================
        <# try {Expand-WindowsImage -ImagePath $OperatingSystem -ApplyPath "C:\" -Index 1 -ErrorAction Ignore}
        catch {Write-Host "Writing Image"} #>
        
        #dism /apply-image /imagefile:"$OperatingSystem\OS\Sources\install.wim" /index:1 /applydir:c:\
        dism /apply-image /imagefile:"$OperatingSystem\OS\Sources\install.swm" /SWMFile:"$OperatingSystem\OS\Sources\install*.swm" /index:1 /applydir:c:\
        
        <# $SystemDrive = Get-Partition | Where-Object {$_.Type -eq 'System'} | Select-Object -First 1
        $SystemDrive | Set-Partition -NewDriveLetter 'S' #>
        bcdboot C:\Windows /s S: /f ALL
        #$SystemDrive | Remove-PartitionAccessPath -AccessPath "S:\"
        #===================================================================================================
        #   AutoPilotConfigurationFile.json
        #===================================================================================================
$AutoPilotJsonProd = @'
{
    "CloudAssignedDomainJoinMethod":  1,
    "CloudAssignedAutopilotUpdateTimeout":  1800000,
    "CloudAssignedForcedEnrollment":  1,
    "Version":  2049,
    "CloudAssignedTenantId":  "d584a4b7-b1f2-4714-a578-fd4d43c146a6",
    "CloudAssignedAutopilotUpdateDisabled":  1,
    "ZtdCorrelationId":  "15047571-d833-4bec-8515-3f2eafa3710e",
    "Comment_File":  "Profile Windows 10 Autopilot Prod User Driven",
    "HybridJoinSkipDCConnectivityCheck":  1,
    "CloudAssignedAadServerData":  "{\"ZeroTouchConfig\":{\"CloudAssignedTenantUpn\":\"\",\"ForcedEnrollment\":1,\"CloudAssignedTenantDomain\":\"bakerhughes.onmicrosoft.com\"}}",
    "CloudAssignedOobeConfig":  1310,
    "CloudAssignedTenantDomain":  "bakerhughes.onmicrosoft.com",
    "CloudAssignedLanguage":  "os-default"
}
'@
$AutoPilotJsonDev = @'
{
    "CloudAssignedDomainJoinMethod":  1,
    "CloudAssignedAutopilotUpdateTimeout":  1800000,
    "CloudAssignedForcedEnrollment":  1,
    "Version":  2049,
    "CloudAssignedTenantId":  "d584a4b7-b1f2-4714-a578-fd4d43c146a6",
    "CloudAssignedAutopilotUpdateDisabled":  1,
    "ZtdCorrelationId":  "35818010-f424-409f-a04e-82e6d9cd43e6",
    "Comment_File":  "Profile Windows 10 Autopilot Dev User Driven",
    "HybridJoinSkipDCConnectivityCheck":  1,
    "CloudAssignedAadServerData":  "{\"ZeroTouchConfig\":{\"CloudAssignedTenantUpn\":\"\",\"ForcedEnrollment\":1,\"CloudAssignedTenantDomain\":\"bakerhughes.onmicrosoft.com\"}}",
    "CloudAssignedOobeConfig":  1310,
    "CloudAssignedTenantDomain":  "bakerhughes.onmicrosoft.com",
    "CloudAssignedLanguage":  "os-default"
}
'@
        #===================================================================================================
        #   Create Directories
        #===================================================================================================
        $PathAutoPilot = 'C:\Windows\Provisioning\AutoPilot'
        if (-NOT (Test-Path $PathAutoPilot)) {
            Write-Warning "An error has occurred finding $PathAutoPilot"
            Write-Warning "AutoPilot will exit"
            Break
        }
        $PathPanther = 'C:\Windows\Panther'
        if (-NOT (Test-Path $PathPanther)) {
            New-Item -Path $PathPanther -ItemType Directory -Force | Out-Null
        }

        $AutoPilotConfigurationFile = Join-Path $PathAutoPilot 'AutoPilotConfigurationFile.json'
        $UnattendPath = Join-Path $PathPanther 'Unattend.xml'
        #===================================================================================================
        #   Apply AutoPilot
        #===================================================================================================
        if ($SetProduction -or $SetDevelopment) {
            Write-Verbose -Verbose "Setting $AutoPilotConfigurationFile"
            if ($SetProduction) {
                $AutoPilotJsonProd | Out-File -FilePath $AutoPilotConfigurationFile -Encoding ASCII
            }
            if ($SetDevelopment) {
                $AutoPilotJsonDev | Out-File -FilePath $AutoPilotConfigurationFile -Encoding ASCII
            }
        }
        #===================================================================================================
        #   Apply Drivers
        #===================================================================================================
$UnattendDrivers = @'
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="offlineServicing">
        <component name="Microsoft-Windows-PnpCustomizationsNonWinPE" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <DriverPaths>
                <PathAndCredentials wcm:keyValue="1" wcm:action="add">
                    <Path>C:\Drivers</Path>
                </PathAndCredentials>
            </DriverPaths>
        </component>
    </settings>
</unattend>
'@
        if ($ApplyDrivers) {
            Write-Verbose -Verbose "Preparing Drivers ... this may take a while ..."
            & $Drivers\Deploy-OSDDrivers.ps1
            
            Write-Verbose -Verbose "Setting Driver Unattend.xml at $UnattendPath"
            $UnattendDrivers | Out-File -FilePath $UnattendPath -Encoding utf8
        
            Write-Verbose -Verbose "Applying Unattend ... this may take a while ..."
            Use-WindowsUnattend -Path 'C:\' -UnattendPath $UnattendPath -Verbose
        }
        #===================================================================================================
        #   Apply ApplyUnattendAE
        #===================================================================================================
$UnattendAuditMode = @'
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <Reseal>
                <Mode>Audit</Mode>
            </Reseal>
        </component>
    </settings>
    <settings pass="auditUser">
        <component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <RunSynchronous>
            <RunSynchronousCommand wcm:action="add">
            <Order>1</Order>
            <Description>Setting PowerShell ExecutionPolicy</Description>
            <Path>PowerShell -WindowStyle Hidden -Command "Set-ExecutionPolicy RemoteSigned -Force"</Path>
            </RunSynchronousCommand>

            <RunSynchronousCommand wcm:action="add">
            <Order>2</Order>
            <Description>Installing AutoPilot Scripts and Modules</Description>
            <Path>PowerShell -Command "Install-Script -Name Get-WindowsAutoPilotInfo -Verbose -Force"</Path>
            </RunSynchronousCommand>

            <RunSynchronousCommand wcm:action="add">
            <Order>3</Order>
            <Description>Configure AutoPilot</Description>
            <Path>PowerShell.exe -File "C:\Program Files\WindowsPowerShell\Scripts\Get-WindowsAutoPilotInfo.ps1" -Online -GroupTag Enterprise</Path>
            </RunSynchronousCommand>

            <RunSynchronousCommand wcm:action="add">
            <Order>4</Order>
            <Description>AutoPilot Registration</Description>
            <Path>PowerShell.exe -WindowStyle Minimized -Command Write-Host "Please wait 20 minutes ...";Start-Sleep -Seconds 1200</Path>
            </RunSynchronousCommand>

            <RunSynchronousCommand wcm:action="add">
            <Order>5</Order>
            <Description>Restart to OOBE</Description>
            <Path>%SystemRoot%\System32\Sysprep\Sysprep.exe /OOBE /Reboot</Path>
            </RunSynchronousCommand>

            </RunSynchronous>
        </component>
    </settings>
</unattend>
'@
        if ($SetAuditMode) {
            Write-Verbose -Verbose "Setting AutoPilot Unattend.xml at $UnattendPath"
            $UnattendAuditMode | Out-File -FilePath $UnattendPath -Encoding utf8
            Write-Verbose -Verbose "Applying Unattend"
            Use-WindowsUnattend -Path 'C:\' -UnattendPath $UnattendPath -Verbose
        }
        #===================================================================================================
        #   Copying Resources
        #===================================================================================================
        Write-Verbose -Verbose "Copying Resources"
        robocopy "$GetConnect\Resources" "C:\Program Files" *.* /s /ndl /xj /nfl /njh /r:0 /w:0
        #===================================================================================================
        #   Create Autopilot.cmd
        #===================================================================================================
        Write-Verbose "Creating C:\Windows\AutopilotEnterprise.cmd for Enterprise" -Verbose
$AutopilotCmd = @'
PowerShell -NoL -Com Set-ExecutionPolicy RemoteSigned -Force
start PowerShell -Nol -W Mi
start /wait PowerShell -NoL -C Install-Script Get-WindowsAutoPilotInfo -Verbose -Force
set path=%path%;C:\Program Files\WindowsPowerShell\Scripts
start /wait PowerShell -NoL -C Write-Host "Enter your Baker Hughes email address at the Microsoft Sign in screen";Get-WindowsAutoPilotInfo -Online -GroupTag Enterprise;Start-Sleep -Seconds 20
start /wait PowerShell -NoL -C Write-Host "Waiting 20 minutes for Intune profile assignment ...";Start-Sleep -Seconds 1200
%SystemRoot%\System32\Sysprep\Sysprep.exe /OOBE /Reboot
'@
        $AutopilotCmd | Out-File -FilePath "C:\Windows\AutopilotEnterprise.cmd" -Force -Encoding ascii
        
        Write-Verbose "Creating C:\Windows\AutopilotDevelopment.cmd for Development" -Verbose
$AutopilotCmd = @'
PowerShell -NoL -Com Set-ExecutionPolicy RemoteSigned -Force
start PowerShell -Nol -W Mi
start /wait PowerShell -NoL -C Install-Script Get-WindowsAutoPilotInfo -Verbose -Force
set path=%path%;C:\Program Files\WindowsPowerShell\Scripts
start /wait PowerShell -NoL -C Write-Host "Enter your Baker Hughes email address at the Microsoft Sign in screen";Get-WindowsAutoPilotInfo -Online -GroupTag Development;Start-Sleep -Seconds 20
start /wait PowerShell -NoL -C Write-Host "Waiting 20 minutes for Intune profile assignment ...";Start-Sleep -Seconds 1200
%SystemRoot%\System32\Sysprep\Sysprep.exe /OOBE /Reboot
'@
        $AutopilotCmd | Out-File -FilePath "C:\Windows\AutopilotDevelopment.cmd" -Force -Encoding ascii
        #===================================================================================================
        #   Complete
        #===================================================================================================
        if (Get-USBDisk) {
            Write-Warning "It is time to restart, so remove your USB Drives ..."
            pause
        }
        if ($BuildImage -eq '1') {
            Write-Host -ForegroundColor DarkCyan "================================================================="
            Write-Host -ForegroundColor Cyan "After your computer restarts to OOBE (Out of Box Experience)"
            Write-Host -ForegroundColor Cyan "Press Shift + F10 to open a Command Prompt and run the following command"
            Write-Host -ForegroundColor Cyan "AutopilotEnterprise"
        }
        Write-Host -ForegroundColor Cyan "This computer will restart in 30 seconds"
        Start-Sleep -Seconds 30
        Get-OSDWinPE -Reboot
        Start-Sleep -Seconds 10
        Exit 0
    }
})

# Launch the window
$xamGUI.ShowDialog() | Out-Null