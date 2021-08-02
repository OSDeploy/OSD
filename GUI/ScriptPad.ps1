#================================================
#   PowershellWindow Functions
#================================================
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
#================================================
#   MahApps.Metro
#================================================
# Assign current script directory to a global variable
$Global:MyScriptDir = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)

# Load presentationframework and Dlls for the MahApps.Metro theme
[System.Reflection.Assembly]::LoadWithPartialName("presentationframework") | Out-Null
[System.Reflection.Assembly]::LoadFrom("$Global:MyScriptDir\assembly\MahApps.Metro.dll") | Out-Null
[System.Reflection.Assembly]::LoadFrom("$Global:MyScriptDir\assembly\System.Windows.Interactivity.dll") | Out-Null

# Set console size and title
$host.ui.RawUI.WindowTitle = ""
#================================================
#   Test-InWinPE
#================================================
function Test-InWinPE {
    return Test-Path -Path Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlset\Control\MiniNT
}
#================================================
#   LoadForm
#================================================
function LoadForm {
    [CmdletBinding()]
    param (
     [Parameter(Mandatory=$False,Position=1)]
     [string]$XamlPath
    )
    
    # Import the XAML code
    [xml]$Global:xmlWPF = Get-Content -Path $XamlPath

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
#================================================
#   LoadForm
#================================================
LoadForm -XamlPath (Join-Path $Global:MyScriptDir 'ScriptPad.xaml')
#================================================
#   Initialize
#================================================
$ComboBoxScriptPadName.Items.Add('NewPSScript.ps1') | Out-Null
if (-NOT (Get-Variable -Name 'NewPSScript.ps1' -Scope Global -ErrorAction Ignore)) {
    New-Variable -Name 'NewPSScript.ps1' -Value '#Blank PowerShell Script' -Scope Global -Force -ErrorAction Stop
}
$LabelScriptPadDescription.Content = 'NewPSScript.ps1 is a blank PowerShell Script that you can edit and Start-Process'

if ($Global:ScriptPad) {
    $Global:ScriptPad | ForEach-Object {
        $ComboBoxScriptPadName.Items.Add($_.Path) | Out-Null
        New-Variable -Name $_.Guid -Value $($_.ContentRAW) -Force -Scope Global
    }
    $LabelTitle.Content = "GitHub $($Global:ScriptPad.GitOwner[0]) $($Global:ScriptPad.GitRepo[0])"
    Write-Host -ForegroundColor DarkGray "================================================"
}
else {
    $LabelTitle.Content = ''
}
#================================================
#   Set-ScriptPadContent
#================================================
function Set-ScriptPadContent {
    if ($ComboBoxScriptPadName.SelectedValue -eq 'NewPSScript.ps1') {
        Write-Host -ForegroundColor Cyan 'NewPSScript.ps1'
        $TextBoxScriptPadContent.Text = (Get-Variable -Name 'NewPSScript.ps1' -Scope Global).Value
        $LabelScriptPadDescription.Content = 'NewPSScript.ps1 is a blank PowerShell Script that you can edit and Start-Process'
    }
    else {
        $Global:WorkingScript = $Global:ScriptPad | Where-Object {$_.Path -eq $ComboBoxScriptPadName.SelectedValue} | Select-Object -First 1
        Write-Host -ForegroundColor Cyan $Global:WorkingScript.Path
        Write-Host -ForegroundColor DarkGray $Global:WorkingScript.Git
        Write-Host -ForegroundColor DarkGray $Global:WorkingScript.Download
        #Write-Host -ForegroundColor DarkCyan "Get-Variable -Name $($Global:WorkingScript.Guid)"

        $LabelScriptPadDescription.Content = $Global:WorkingScript.Guid
        $TextBoxScriptPadContent.Text = (Get-Variable -Name $Global:WorkingScript.Guid).Value
    }
    Write-Host -ForegroundColor DarkGray "================================================"
}

Set-ScriptPadContent
#================================================
#   Change Selection
#================================================
<# $ComboBoxScriptPadName.add_SelectionChanged({
    Set-ScriptPadContent
}) #>
$ComboBoxScriptPadName.add_SelectionChanged({
    Set-ScriptPadContent
})
$TextBoxScriptPadContent.add_TextChanged({
    if ($ComboBoxScriptPadName.SelectedValue -eq 'NewPSScript.ps1') {
        Set-Variable -Name 'NewPSScript.ps1' -Value $($TextBoxScriptPadContent.Text) -Scope Global -Force
    }
    else {
        Set-Variable -Name $($Global:WorkingScript.Guid) -Value $($TextBoxScriptPadContent.Text) -Scope Global -Force
    }
})
#================================================
#   GO
#================================================
$GoButton.add_Click({
    Write-Host -ForegroundColor Cyan "Start-Process"
    $Global:ScriptPadScriptBlock = [scriptblock]::Create($TextBoxScriptPadContent.Text)

    if ($Global:ScriptPadScriptBlock) {
        if ($ComboBoxScriptPadName.SelectedValue -eq 'NewPSScript.ps1') {
            $ScriptFile = 'NewPSScript.ps1'
        }
        else {
            $ScriptFile = $Global:WorkingScript.Name
        }
        if (!(Test-Path "$env:Temp\ScriptPad")) {New-Item "$env:Temp\ScriptPad" -ItemType Directory}
        
        $ScriptPath = "$env:Temp\ScriptPad\$ScriptFile"
        Write-Host -ForegroundColor DarkGray "Saving contents of `$Global:ScriptPadScriptBlock` to $ScriptPath"
        $Global:ScriptPadScriptBlock | Out-File $ScriptPath -Encoding utf8

        #$xamGUI.Close()
        #Invoke-Command $Global:ScriptPadScriptBlock
        #Start-Process PowerShell.exe -ArgumentList "-NoExit Invoke-Command -ScriptBlock {$Global:ScriptPadScriptBlock}"

        Write-Host -ForegroundColor DarkCyan "Start-Process -WorkingDirectory `"$env:Temp\ScriptPad`" -FilePath PowerShell.exe -ArgumentList '-NoExit',`"-File `"$ScriptFile`"`""
        Start-Process -WorkingDirectory "$env:Temp\ScriptPad" -FilePath PowerShell.exe -ArgumentList '-NoExit',"-File `"$ScriptFile`""
    }
    #Write-Host -ForegroundColor DarkGray "================================================"
})
#================================================
#   Launch XAML
#================================================
$xamGUI.ShowDialog() | Out-Null