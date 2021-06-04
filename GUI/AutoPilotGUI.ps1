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

#Hide-PowershellWindow
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
$host.ui.RawUI.WindowTitle = "OSDeploy AutopilotGUI"
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
    Param(
     [Parameter(Mandatory=$False,Position=1)]
     [string]$XamlPath
    )
    
    # Import the XAML code
    #[xml]$Global:xmlWPF = Get-Content -Path $XamlPath

    [xml]$Global:xmlWPF = @"
    <Controls:MetroWindow
        xmlns = "http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x = "http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:Controls = "http://metro.mahapps.com/winfx/xaml/controls"

        Title = "AutopilotGUI"
        Width = "600"
        Height = "360"

        GlowBrush = "{DynamicResource MahApps.Brushes.Accent}"
        
        WindowStartupLocation = "CenterScreen"
    >

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
                <CheckBox Name = "OnlineCheckbox"
                    IsChecked = "True"
                    IsEnabled = "False"
                    HorizontalAlignment = "Left" Margin = "20,10,0,0" VerticalAlignment = "Top" Width = "500" FontSize = "14">
                    Online: Register this device to the Microsoft Graph authenticated Tenant 
                </CheckBox>
            </StackPanel>

            <StackPanel>
                <CheckBox Name = "AssignCheckbox"
                    HorizontalAlignment = "Left" Margin = "20,40,0,0" VerticalAlignment = "Top" Width = "500" FontSize = "14" Background = "LightBlue">
                    Assign: Wait for Intune to assign an Autopilot profile to the device
                </CheckBox>
            </StackPanel>

            <StackPanel>
                <Label
                    Name = "GroupTagLabel"
                    Content = "GroupTag:"
                    HorizontalAlignment = "Left" Margin = "20,70,0,0" VerticalAlignment = "Top" Width = "100" FontSize = "14"
                />
            </StackPanel>
            <StackPanel>    
                <TextBox
                    Name = "GroupTagTextBox"
                    HorizontalAlignment = "Left" Margin = "120,70,0,0" VerticalAlignment = "Top" Width = "320" FontSize = "14" Height = "30" Background = "LightBlue"
                />
            </StackPanel>

            <StackPanel>
                <Label
                    Name = "AddToGroupLabel"
                    Content = "AddToGroup:"
                    HorizontalAlignment = "Left" Margin = "20,110,0,0" VerticalAlignment = "Top" Width = "100" FontSize = "14"
                />
            </StackPanel>
            <StackPanel>    
                <TextBox
                    Name = "AddToGroupTextBox"
                    HorizontalAlignment = "Left" Margin = "120,110,0,0" VerticalAlignment = "Top" Width = "320" Height = "30" FontSize = "14"
                />
            </StackPanel>

            <StackPanel Orientation="Horizontal">
                <Button
                    Name = "GetWindowsAutopilotInfoButton"
                    Content = "Register"
                    HorizontalAlignment = "Right" Margin = "470,70,0,0" VerticalAlignment = "Top" Width = "100" Height = "70" FontSize = "14" Background = "LightBlue"
                />
            </StackPanel>

            <Separator/>

            <StackPanel Orientation="Horizontal">
                <Button
                    Name = "RunButton"
                    Content = "Run"
                    HorizontalAlignment = "Right" Margin = "20,190,0,0" VerticalAlignment = "Top" Width = "50" Height = "30" FontSize = "14"
                />
            </StackPanel>

            <StackPanel>    
                <TextBox
                    Name = "RunTextBox"
                    HorizontalAlignment = "Left" Margin = "75,190,0,0" VerticalAlignment = "Top" Width = "495" Height = "30" FontSize = "14"
                />
            </StackPanel>

            <StackPanel Orientation="Horizontal">
                <Button
                    Name = "PowerShellButton"
                    Content = "PowerShell"
                    HorizontalAlignment = "Right" Margin = "20,240,0,0" VerticalAlignment = "Top" Width = "150" Height = "30" FontSize = "14"
                />
            </StackPanel>

            <StackPanel Orientation="Horizontal">
                <Button
                    Name = "SettingsButton"
                    Content = "Settings"
                    HorizontalAlignment = "Right" Margin = "220,240,0,0" VerticalAlignment = "Top" Width = "150" Height = "30" FontSize = "14"
                />
            </StackPanel>

            <StackPanel Orientation="Horizontal">
                <Button
                    Name = "WirelessButton"
                    Content = "Wireless"
                    HorizontalAlignment = "Right" Margin = "420,240,0,0" VerticalAlignment = "Top" Width = "150" Height = "30" FontSize = "14"
                />
            </StackPanel>

            <StackPanel Orientation="Horizontal">
                <Button
                    Name = "SysprepButton"
                    Content = "Sysprep OOBE"
                    HorizontalAlignment = "Right" Margin = "20,280,0,0" VerticalAlignment = "Top" Width = "150" Height = "30" FontSize = "14" Background = "LightBlue"
                />
            </StackPanel>

            <StackPanel Orientation="Horizontal">
                <Button
                    Name = "RestartButton"
                    Content = "Restart"
                    HorizontalAlignment = "Right" Margin = "220,280,0,0" VerticalAlignment = "Top" Width = "150" Height = "30" FontSize = "14" Background = "LightBlue"
                />
            </StackPanel>

            <StackPanel Orientation="Horizontal">
                <Button
                    Name = "ShutdownButton"
                    Content = "Shutdown"
                    HorizontalAlignment = "Right" Margin = "420,280,0,0" VerticalAlignment = "Top" Width = "150" Height = "30" FontSize = "14"
                />
            </StackPanel>

        </Grid>
    </Controls:MetroWindow>
"@

    # Add WPF and Windows Forms assemblies
    Try {
        Add-Type -AssemblyName PresentationCore,PresentationFramework,WindowsBase,system.windows.forms
    } 
    Catch {
        Throw "Failed to load Windows Presentation Framework assemblies."
    }

    #Create the XAML reader using a new XML node reader
    $Global:xamGUI = [Windows.Markup.XamlReader]::Load((new-object System.Xml.XmlNodeReader $xmlWPF))

    #Create hooks to each named object in the XAML
    $xmlWPF.SelectNodes("//*[@Name]") | foreach {
        Set-Variable -Name ($_.Name) -Value $xamGUI.FindName($_.Name) -Scope Global
    }
}
#=======================================================================
#   LoadForm
#=======================================================================
LoadForm
#=======================================================================
#   Initialize
#=======================================================================
#$AddToGroupTextBox.Text = 'Enterprise'
#$GroupTagTextBox.Text = 'Enterprise'
$RunTextBox.Text = 'https://docs.microsoft.com/en-us/mem/autopilot/'
#=======================================================================
#   add_Click
#=======================================================================
$GetWindowsAutopilotInfoButton.add_Click({
    $xamGUI.Close()
    Show-PowershellWindow

    Write-Host -ForegroundColor Cyan "Online: $true"
    $Params = @{
        Online = $true
    }

    if ($AssignCheckbox.IsChecked) {
        Write-Host -ForegroundColor Cyan "Assign: $true" 
        $Params.Assign = $true
    }

    if ($GroupTagTextBox.Text -gt 0) {
        $Params.GroupTag = $GroupTagTextBox.Text
        Write-Host -ForegroundColor Cyan "GroupTag: $($Params.GroupTag)" 
    }

    if ($AddToGroupTextBox.Text -gt 0) {
        $Params.AddToGroup = $AddToGroupTextBox.Text
        Write-Host -ForegroundColor Cyan "AddToGroup: $($Params.AddToGroup)" 
    }

    Write-Host -ForegroundColor Cyan "Install-Script Get-WindowsAutoPilotInfo"
    Start-Sleep -Seconds 3
    Install-Script Get-WindowsAutoPilotInfo -Force

    Write-Host -ForegroundColor Cyan "Get-WindowsAutoPilotInfo"
    Start-Sleep -Seconds 3

    Get-WindowsAutoPilotInfo @Params
    Start-Sleep -Seconds 3
    Start-AutopilotGUI
})
#=======================================================================
#   RunButton
#=======================================================================
$RunButton.add_Click({
    Write-Host -ForegroundColor Cyan "Run: $($RunTextBox.Text)"
    try {
        Start-Process $RunTextBox.Text
    }
    catch {
        Write-Warning "Could not execute $($RunTextBox.Text)"
    }
})
#=======================================================================
#   SettingsButton
#=======================================================================
$SettingsButton.add_Click({
    Start-Process ms-settings:
})
#=======================================================================
#   WirelessButton
#=======================================================================
$WirelessButton.add_Click({
    Start-Process ms-availablenetworks:
})
#=======================================================================
#   PowerShellButton
#=======================================================================
$PowerShellButton.add_Click({
    Start-Process PowerShell.exe -ArgumentList "-Nologo"
})
#=======================================================================
#   SysprepButton
#=======================================================================
$SysprepButton.add_Click({
    Start-Process "$env:SystemRoot\System32\Sysprep\Sysprep.exe" -ArgumentList "/oobe","/quit"
})
#=======================================================================
#   RestartButton
#=======================================================================
$RestartButton.add_Click({
    Restart-Computer
})
#=======================================================================
#   ShutdownButton
#=======================================================================
$ShutdownButton.add_Click({
    Stop-Computer
})
#=======================================================================
#   ShowDialog
#=======================================================================
$xamGUI.ShowDialog() | Out-Null
#=======================================================================
