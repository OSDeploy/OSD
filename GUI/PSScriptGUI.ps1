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
	Title = "$PSScriptGuiTitle" Height="600" Width="840"
	BorderBrush = "{DynamicResource AccentColorBrush}"

    Background = "#004275"
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
            <Label
                Name = "LabelTitle"
                Content = ""
                FontSize = "30"
                Foreground = "White"
                HorizontalAlignment = "Left"
                Margin = "20,0,0,0"
                VerticalAlignment = "Center"
                Width = "800" />
        </StackPanel>

        <StackPanel>
            <ComboBox
                Name = "ComboBoxPSScriptName"
                Background = "LightBlue"
                FontSize = "16"
                Height = "30"
                HorizontalAlignment = "Left"
                Margin = "280,10,0,0"
                SelectedIndex = "0"
                VerticalAlignment = "Center"
                Width = "540" />
        </StackPanel>

        <StackPanel>    
            <Label
                Name = "LabelPSScriptDescription"
                Content = ""
                FontSize = "16"
                Foreground = "White"
                HorizontalAlignment = "Left"
                Margin = "275,40,0,0"
                VerticalAlignment = "Center"
                Width = "500" />
        </StackPanel>

        <StackPanel>    
            <Label
                Name = "LabelPSScriptUri"
                Content = ""
                FontSize = "12"
                Foreground = "White"
                HorizontalAlignment = "Left"
                Margin = "15,90,0,0"
                VerticalAlignment = "Center"
                Width = "820" />
        </StackPanel>

        <StackPanel>
            <TextBox
                Name = "TextBoxPSScriptContent"
                Text = ""
                FontSize = "12"
                Foreground = "Black"
                Height = "380"
                HorizontalAlignment = "Left"
                IsReadOnly = "True"
                Margin = "20,120,0,0"
                ScrollViewer.HorizontalScrollBarVisibility = "Visible"
                ScrollViewer.VerticalScrollBarVisibility = "Visible"
                VerticalAlignment = "Top"
                Width = "800" />
        </StackPanel>

        <StackPanel Orientation="Horizontal">
            <Button
                Name = "GoButton"
                Content = "RUN"
                Background = "LightBlue"
                FontSize = "14"
                Height = "30"
                HorizontalAlignment = "Center"
                Margin = "760,500,0,0"
                VerticalAlignment = "Center"
                Width = "60" />
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
LoadForm
#=======================================================================
#   Initialize
#=======================================================================
if ($Global:PSScriptGui.Tasks) {
    $Global:PSScriptGui.Tasks | Sort-Object -Property Name -Descending | ForEach-Object {
        $ComboBoxPSScriptName.Items.Add($_.Name) | Out-Null
    }
    Write-Host -ForegroundColor DarkGray "================================================================="
    $PSScriptGuiHeader = $Global:PSScriptGui.Settings.Title
    if ($PSScriptGuiHeader) {
        $LabelTitle.Content = $PSScriptGuiHeader
        Write-Host -ForegroundColor DarkGray "$PSScriptGuiHeader"
    }
    if ($Global:PSScriptGui.Settings.Version) {
        Write-Host -ForegroundColor DarkGray $Global:PSScriptGui.Settings.Version
    }
    if ($Global:PSScriptGui.Settings.Author) {
        Write-Host -ForegroundColor DarkGray $Global:PSScriptGui.Settings.Author
    }
    if ($Global:PSScriptGui.Settings.Company) {
        Write-Host -ForegroundColor DarkGray $Global:PSScriptGui.Settings.Company
    }
    if ($Global:PSScriptGui.Settings.Help) {
        Write-Host -ForegroundColor DarkGray $Global:PSScriptGui.Settings.Help
    }
}
#=======================================================================
#   Functions
#=======================================================================
function Set-PSScriptGuiContent {
    Write-Host -ForegroundColor DarkGray "================================================================="
    $SelectedTask = $Global:PSScriptGui.Tasks | Where-Object {$_.Name -eq $ComboBoxPSScriptName.SelectedValue}

    if ($SelectedTask.Name) {
        Write-Host -ForegroundColor Cyan $SelectedTask.Name
    }
    if ($SelectedTask.Version) {
        Write-Host -ForegroundColor DarkCyan $SelectedTask.Version
    }
    if ($SelectedTask.Author) {
        Write-Host -ForegroundColor DarkCyan $SelectedTask.Author
    }
    if ($SelectedTask.Description) {
        Write-Host -ForegroundColor DarkCyan $SelectedTask.Description
        $LabelPSScriptDescription.Content = $SelectedTask.Description
    }
    if ($SelectedTask.Uri) {
        Write-Host -ForegroundColor DarkCyan $SelectedTask.Uri
        $LabelPSScriptUri.Content = $SelectedTask.Uri
    }

    $Global:PSScriptUri = $SelectedTask.Uri
    $ScriptContent = (Invoke-WebRequest -Uri $Global:PSScriptUri -UseBasicParsing).Content
    $TextBoxPSScriptContent.Text = $ScriptContent
}
#=======================================================================
#   Main
#=======================================================================
Set-PSScriptGuiContent
#=======================================================================
#   Change Selection
#=======================================================================
<# $ComboBoxPSScriptName.add_SelectionChanged({
    Set-PSScriptGuiContent
}) #>
$ComboBoxPSScriptName.add_DropDownClosed({
    Set-PSScriptGuiContent
})
#=======================================================================
#   GO
#=======================================================================
$GoButton.add_Click({
    Write-Host -ForegroundColor DarkGray "================================================================="
    if (Test-WebConnection -Uri $Global:PSScriptUri) {
        $xamGUI.Close()
        Invoke-WebPSScript -WebPSScript $Global:PSScriptUri
    }
    else {
        Write-Warning "Unable to connect to $Global:PSScriptUri"
        Write-Warning "Make sure you have an Internet connection and are not Firewall blocked"
    }
})
#=======================================================================
#   Launch XAML
#=======================================================================
$xamGUI.ShowDialog() | Out-Null