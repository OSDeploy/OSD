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
$host.ui.RawUI.WindowTitle = "Start-OSDCloudGUI"
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
        xmlns:Controls = "clr-namespace:MahApps.Metro.Controls;assembly=MahApps.Metro"
        xmlns = "http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x = "http://schemas.microsoft.com/winfx/2006/xaml"
        Title = "Start-OSDCloudGUI" Height="465" Width="705"
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
                Content = "OSDCloudGUI"
                HorizontalAlignment = "Left" Margin = "20,10,0,0" VerticalAlignment = "Top" Width = "500" FontSize = "30"/>
            </StackPanel>

            <StackPanel>
                <Label
                    Name = "OSBuildLabel"
                    Content = "OSBuild"
                    HorizontalAlignment = "Left" Margin = "20,70,0,0" VerticalAlignment = "Top" Width = "100" FontSize = "14"
                />
            </StackPanel>
            <StackPanel>
                <ComboBox
                    Name = "OSBuildComboBox"
                    HorizontalAlignment = "Left" Margin = "20,100,0,0" VerticalAlignment = "Top" Width = "100" FontSize = "14" Height = "30"
                />
            </StackPanel>
            
            <StackPanel>
                <Label
                    Name = "OSEditionLabel"
                    Content = "OSEdition"
                    HorizontalAlignment = "Left" Margin = "140,70,0,0" VerticalAlignment = "Top" Width = "200" FontSize = "14"
                />
            </StackPanel>
            <StackPanel>    
                <ComboBox
                    Name = "OSEditionComboBox"
                    HorizontalAlignment = "Left" Margin = "140,100,0,0" VerticalAlignment = "Top" Width = "200" FontSize = "14" Height = "30"
                />
            </StackPanel>

            <StackPanel>
                <Label
                    Name = "OSLanguageLabel"
                    Content = "OSLanguage"
                    HorizontalAlignment = "Left" Margin = "360,70,0,0" VerticalAlignment = "Top" Width = "100" FontSize = "14"
                />
            </StackPanel>
            <StackPanel>
                <ComboBox
                    Name = "OSLanguageComboBox"
                    HorizontalAlignment = "Left" Margin = "360,100,0,0" VerticalAlignment = "Top" Width = "100" FontSize = "14" Height = "30"
                />
            </StackPanel>
            
            <StackPanel>
                <Label
                    Name = "OSLicenseLabel"
                    Content = "OSLicense"
                    HorizontalAlignment = "Left" Margin = "480,70,0,0" VerticalAlignment = "Top" Width = "200" FontSize = "14"
                />
            </StackPanel>
            <StackPanel>    
                <ComboBox
                    Name = "OSLicenseComboBox"
                    HorizontalAlignment = "Left" Margin = "480,100,0,0" VerticalAlignment = "Top" Width = "200" FontSize = "14" Height = "30"
                />
            </StackPanel>

            <StackPanel>
                <Label
                    Name = "ImageIndexLabel"
                    Content = "ImageIndex"
                    HorizontalAlignment = "Left" Margin = "20,140,0,0" VerticalAlignment = "Top" Width = "250" FontSize = "14"
                />
            </StackPanel>
            <StackPanel>    
                <TextBox
                    Name = "ImageIndexTextBox"
                    HorizontalAlignment = "Left" Margin = "20,170,0,0" VerticalAlignment = "Top" Width = "100" FontSize = "14" Height = "30"
                />
            </StackPanel>

            <StackPanel>
                <Label
                    Name = "CustomImageLabel"
                    Content = "CustomImage"
                    HorizontalAlignment = "Left" Margin = "140,140,0,0" VerticalAlignment = "Top" Width = "250" FontSize = "14"
                />
            </StackPanel>
            <StackPanel>
                <ComboBox
                    Name = "CustomImageComboBox"
                    HorizontalAlignment = "Left" Margin = "140,170,0,0" VerticalAlignment = "Top" Width = "540" FontSize = "14" Height = "30"
                />
            </StackPanel>

            <StackPanel>
                <Label
                    Name = "ManufacturerLabel"
                    Content = "Manufacturer"
                    HorizontalAlignment = "Left" Margin = "20,210,0,0" VerticalAlignment = "Top" Width = "210" FontSize = "14"
                />
            </StackPanel>
            <StackPanel>    
                <TextBox
                    Name = "ManufacturerTextBox"
                    HorizontalAlignment = "Left" Margin = "20,240,0,0" VerticalAlignment = "Top" Width = "210" FontSize = "14" Height = "30"
                />
            </StackPanel>

            <StackPanel>
                <Label
                    Name = "ProductLabel"
                    Content = "Product"
                    HorizontalAlignment = "Left" Margin = "250,210,0,0" VerticalAlignment = "Top" Width = "200" FontSize = "14"
                />
            </StackPanel>
            <StackPanel>    
                <TextBox
                    Name = "ProductTextBox"
                    HorizontalAlignment = "Left" Margin = "250,240,0,0" VerticalAlignment = "Top" Width = "200" FontSize = "14" Height = "30"
                />
            </StackPanel>

            <StackPanel>
                <Label
                    Name = "ModelLabel"
                    Content = "Model"
                    HorizontalAlignment = "Left" Margin = "470,210,0,0" VerticalAlignment = "Top" Width = "210" FontSize = "14"
                />
            </StackPanel>
            <StackPanel>    
                <TextBox
                    Name = "ModelTextBox"
                    HorizontalAlignment = "Left" Margin = "470,240,0,0" VerticalAlignment = "Top" Width = "210" FontSize = "14" Height = "30"
                />
            </StackPanel>

            <StackPanel>
                <Label
                    Name = "PostConfigLabel"
                    Content = "OSDCloud Post Configuration and Autopilot"
                    HorizontalAlignment = "Left" Margin = "20,280,0,0" VerticalAlignment = "Top" Width = "540" FontSize = "14"
                />
            </StackPanel>
            <StackPanel>
                <ComboBox
                    Name = "PostConfigComboBox"
                    HorizontalAlignment = "Left" Margin = "20,310,0,0" VerticalAlignment = "Top" Width = "540" FontSize = "14" Height = "30"
                />
            </StackPanel>

            <StackPanel>
                <TextBox
                    Name = "NotesTextBox"
                    HorizontalAlignment = "Left" Margin = "20,350,0,0" VerticalAlignment = "Top" Width = "540" FontSize = "14" Height = "60"
                />
            </StackPanel>

            <StackPanel Orientation="Horizontal">
                <Button
                    Name = "OKButton"
                    Content = "GO"
                    HorizontalAlignment = "Right" Margin = "580,310,0,0" VerticalAlignment = "Top" Width = "100" Height = "100" FontSize = "16"
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
$OSDCloudParams = (Get-Command Start-OSDCloud).Parameters

$OSDCloudParams["OSBuild"].Attributes.ValidValues | ForEach-Object {
    $OSBuildComboBox.Items.Add($_) | Out-Null
}

$OSDCloudParams["OSEdition"].Attributes.ValidValues | ForEach-Object {
    $OSEditionComboBox.Items.Add($_) | Out-Null
}

$OSDCloudParams["OSLicense"].Attributes.ValidValues | ForEach-Object {
    $OSLicenseComboBox.Items.Add($_) | Out-Null
}

$OSDCloudParams["OSLanguage"].Attributes.ValidValues | ForEach-Object {
    $OSLanguageComboBox.Items.Add($_) | Out-Null
}

$ManufacturerTextBox.Text = Get-MyComputerManufacturer -Brief
$ProductTextBox.Text = Get-MyComputerProduct
$ModelTextBox.Text = Get-MyComputerModel -Brief
#=======================================================================
#   SetDefaultValues
#=======================================================================
function SetDefaultValues {
    $OSBuildComboBox.SelectedIndex = 0      #21H1
    $OSLanguageComboBox.SelectedIndex = 7   #en-us
    $OSEditionComboBox.SelectedIndex = 5    #Enterprise
    $OSLicenseComboBox.SelectedIndex = 1    #Volume
    $CustomImageComboBox.SelectedIndex = 0  #Nothing
    $PostConfigComboBox.SelectedIndex = 1    #OOBE
    $NotesTextBox.Text = "When OSDCloud finishes, you will still be in WinPE and nothing else will happen"
    $ImageIndexTextBox.Text = 6             #Enterprise

    $OSBuildComboBox.IsEnabled = $true
    $OSLanguageComboBox.IsEnabled = $true
    $OSEditionComboBox.IsEnabled = $true
    $OSLicenseComboBox.IsEnabled = $false
    #$NotesTextBox.IsEnabled = $false
    $ImageIndexTextBox.IsEnabled = $false
    $ModelTextBox.IsEnabled = $false
    $PostConfigComboBox.IsEnabled = $false
}
SetDefaultValues
#=======================================================================
#   PostConfigComboBox
#=======================================================================
$PostConfigComboBox.Items.Add('Do Nothing') | Out-Null
$PostConfigComboBox.Items.Add('Restart to OOBE') | Out-Null
$PostConfigComboBox.Items.Add('Restart to OOBE and run AutopilotOSD') | Out-Null
$PostConfigComboBox.Items.Add('Restart to Audit Mode') | Out-Null
$AutopilotFiles = Find-OSDCloudFile -Name "*.json" -Path '\OSDCloud\Autopilot\Profiles\' | Sort-Object FullName
$AutopilotFiles = $AutopilotFiles | Where-Object {$_.FullName -notlike "C*"}
$PostConfigComboBox.SelectedIndex = 0
if ($AutopilotFiles) {
    $AutopilotFiles | ForEach-Object {
        $PostConfigComboBox.Items.Add($_) | Out-Null
    }
}
$PostConfigComboBox.add_SelectionChanged({
    if ($PostConfigComboBox.SelectedIndex -eq 0) {
        $NotesTextBox.Text = "When OSDCloud finishes, you will still be in WinPE and nothing else will happen"
    }
    if ($PostConfigComboBox.SelectedIndex -eq 1) {
        $NotesTextBox.Text = "Computer will restart and process the Specialize Phase and stop at OOBE"
    }
    if ($PostConfigComboBox.SelectedIndex -eq 2) {
        $NotesTextBox.Text = "Computer will restart and process the Specialize Phase and stop at OOBE
Press Shift + F10 to open a Command Prompt and run AutopilotOSD.cmd"
    }
    if ($PostConfigComboBox.SelectedIndex -eq 3) {
        $NotesTextBox.Text = "Computer will restart and process the Specialize Phase and stop in Audit Mode"
    }
    if ($PostConfigComboBox.SelectedIndex -ge 4) {
        $NotesTextBox.Text = "Computer will restart and process the Specialize Phase and stop at OOBE
The selected AutopilotConfigurationFile.json will be processed"
    }
})
#=======================================================================
#   CustomImage
#=======================================================================
$CustomImageComboBox.IsEnabled = $false
$CustomImage = Find-OSDCloudFile -Name '*.wim' -Path '\OSDCloud\OS\'
$CustomImage = $CustomImage | Sort-Object -Property Length -Unique | Sort-Object FullName | Where-Object {$_.Length -gt 3GB}
        
if ($CustomImage) {
    $CustomImageComboBox.Items.Add('') | Out-Null
    $CustomImageComboBox.IsEnabled = $true
    $CustomImage | ForEach-Object {
        $CustomImageComboBox.Items.Add($_) | Out-Null
    }
    $CustomImageComboBox.SelectedIndex = 0
}
#=======================================================================
#   OSEditionComboBox
#=======================================================================
$OSEditionComboBox.add_SelectionChanged({
    #Home
    if ($OSEditionComboBox.SelectedIndex -eq 0) {
        $ImageIndexTextBox.Text = 4
        $ImageIndexLabel.IsEnabled = $false
        $ImageIndexTextBox.IsEnabled = $false   #Disable
        $OSLicenseComboBox.SelectedIndex = 0    #Retail
        $OSLicenseComboBox.IsEnabled = $false   #Disable
    }
    #Home N
    if ($OSEditionComboBox.SelectedIndex -eq 1) {
        $ImageIndexTextBox.Text = 5
        $ImageIndexTextBox.IsEnabled = $false   #Disable
        $OSLicenseComboBox.SelectedIndex = 0    #Retail
        $OSLicenseComboBox.IsEnabled = $false   #Disable
    }
    #Home Single Language
    if ($OSEditionComboBox.SelectedIndex -eq 2) {
        $ImageIndexTextBox.Text = 6
        $ImageIndexTextBox.IsEnabled = $false   #Disable
        $OSLicenseComboBox.SelectedIndex = 0    #Retail
        $OSLicenseComboBox.IsEnabled = $false   #Disable
    }
    #Education
    if ($OSEditionComboBox.SelectedIndex -eq 3) {
        $OSLicenseComboBox.IsEnabled = $true
        if ($OSLicenseComboBox.SelectedIndex -eq 0) {
            $ImageIndexTextBox.Text = 7
        }
        else {
            $ImageIndexTextBox.Text = 4
        }
    }
    #Education N
    if ($OSEditionComboBox.SelectedIndex -eq 4) {
        $OSLicenseComboBox.IsEnabled = $true
        if ($OSLicenseComboBox.SelectedIndex -eq 0) {
            $ImageIndexTextBox.Text = 8
        }
        else {
            $ImageIndexTextBox.Text = 5
        }
    }
    #Enterprise
    if ($OSEditionComboBox.SelectedIndex -eq 5) {
        $OSLicenseComboBox.SelectedIndex = 1
        $OSLicenseComboBox.IsEnabled = $false
        $ImageIndexTextBox.Text = 6
    }
    #Enterprise N
    if ($OSEditionComboBox.SelectedIndex -eq 6) {
        $OSLicenseComboBox.SelectedIndex = 1
        $OSLicenseComboBox.IsEnabled = $false
        $ImageIndexTextBox.Text = 7
    }
    #Pro
    if ($OSEditionComboBox.SelectedIndex -eq 7) {
        $OSLicenseComboBox.IsEnabled = $true
        if ($OSLicenseComboBox.SelectedIndex -eq 0) {
            $ImageIndexTextBox.Text = 9
        }
        else {
            $ImageIndexTextBox.Text = 8
        }
    }
    #Pro N
    if ($OSEditionComboBox.SelectedIndex -eq 8) {
        $OSLicenseComboBox.IsEnabled = $true
        if ($OSLicenseComboBox.SelectedIndex -eq 0) {
            $ImageIndexTextBox.Text = 10
        }
        else {
            $ImageIndexTextBox.Text = 9
        }
    }
})
#=======================================================================
#   OSLicenseComboBox
#=======================================================================
$OSLicenseComboBox.add_SelectionChanged({
    if ($OSLicenseComboBox.SelectedIndex -eq 0) {
        if ($OSEditionComboBox.SelectedIndex -eq 3) {$ImageIndexTextBox.Text = 7}
        if ($OSEditionComboBox.SelectedIndex -eq 4) {$ImageIndexTextBox.Text = 8}
        if ($OSEditionComboBox.SelectedIndex -eq 7) {$ImageIndexTextBox.Text = 9}
        if ($OSEditionComboBox.SelectedIndex -eq 8) {$ImageIndexTextBox.Text = 10}
    }
    if ($OSLicenseComboBox.SelectedIndex -eq 1) {
        if ($OSEditionComboBox.SelectedIndex -eq 3) {$ImageIndexTextBox.Text = 4}
        if ($OSEditionComboBox.SelectedIndex -eq 4) {$ImageIndexTextBox.Text = 5}
        if ($OSEditionComboBox.SelectedIndex -eq 7) {$ImageIndexTextBox.Text = 8}
        if ($OSEditionComboBox.SelectedIndex -eq 8) {$ImageIndexTextBox.Text = 9}
    }
})
#=======================================================================
#   CustomImageComboBox
#=======================================================================
$CustomImageComboBox.add_SelectionChanged({
    if ($CustomImageComboBox.SelectedIndex -eq 0) {
        SetDefaultValues
    }
    else {
        $OSBuildComboBox.IsEnabled = $false
        $OSLanguageComboBox.IsEnabled = $false
        $OSEditionComboBox.IsEnabled = $false
        $OSLicenseComboBox.IsEnabled = $false
        $ImageIndexTextBox.IsEnabled = $true
        $ImageIndexTextBox.Text = 1
    }
})
#=======================================================================
#   PostConfigComboBox
#=======================================================================

# EVENT Handlers 
$OKButton.add_Click({
    $xamGUI.Close()
    Show-PowershellWindow

    $Params = @{
        OSBuild         = $OSBuildComboBox.SelectedItem
        OSEdition       = $OSEditionComboBox.SelectedItem
        OSLanguage      = $OSLanguageComboBox.SelectedItem
        OSLicense       = $OSLicenseComboBox.SelectedItem
        Manufacturer    = $ManufacturerTextBox.Text
        Product         = $ProductTextBox.Text
    }

    Start-OSDCloud @Params
    Pause
})
#=======================================================================
#   Launch
#=======================================================================
$xamGUI.ShowDialog() | Out-Null
