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
$ComboBoxScriptPadName.Items.Add('MyScript') | Out-Null
    if (-NOT (Get-Variable -Name MyScript -Scope Global -ErrorAction Ignore)) {
        New-Variable -Name 'MyScript' -Value '#PowerShell ScriptBlock' -Scope Global -Force -ErrorAction Stop
    }

$LabelScriptPadDescription.Content = 'MyScript is the default PowerShell ScriptBlock that you can edit and Start-Process'

#   "Description": 'MyScript is the default PowerShell ScriptBlock that you can edit and Invoke-Command'
#   "Guid": "fa4a53ea-62ca-478e-95f6-2ff07f8f468a"

if ($Global:ScriptPad) {
    $Global:ScriptPad | ForEach-Object {
        #Write-Host -ForegroundColor DarkGray $_.Name
        #Write-Host -ForegroundColor DarkGray $_.Download

        $ComboBoxScriptPadName.Items.Add($_.Name) | Out-Null
        New-Variable -Name $_.SHA -Value $($_.ContentRAW) -Force -Scope Global
    }
    $LabelTitle.Content = "GitHub $($Global:ScriptPad.GitOwner[0]) $($Global:ScriptPad.GitRepo[0])"
    Write-Host -ForegroundColor DarkGray "================================================"
}
else {
    $LabelTitle.Content = 'ScriptPad'
}
#================================================
#   Set-ScriptPadContent
#================================================
function Set-ScriptPadContent {
    if ($ComboBoxScriptPadName.SelectedValue -eq 'MyScript') {
        Write-Host -ForegroundColor Cyan 'MyScript'
        $TextBoxScriptPadContent.Text = (Get-Variable -Name MyScript -Scope Global).Value
        $LabelScriptPadDescription.Content = 'MyScript is the default PowerShell ScriptBlock that you can edit and Start-Process'
    }
    else {
        $Global:WorkingScript = $Global:ScriptPad | Where-Object {$_.Name -eq $ComboBoxScriptPadName.SelectedValue} | Select-Object -First 1
        Write-Host -ForegroundColor Cyan $Global:WorkingScript.Name
        Write-Host -ForegroundColor DarkGray $Global:WorkingScript.Git
        Write-Host -ForegroundColor DarkGray $Global:WorkingScript.Download
        #Write-Host -ForegroundColor DarkCyan "Get-Variable -Name $($Global:WorkingScript.SHA)"

        $LabelScriptPadDescription.Content = $Global:WorkingScript.SHA
        $TextBoxScriptPadContent.Text = (Get-Variable -Name $Global:WorkingScript.SHA).Value
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
    if ($ComboBoxScriptPadName.SelectedValue -eq 'MyScript') {
        Set-Variable -Name 'MyScript' -Value $($TextBoxScriptPadContent.Text) -Scope Global -Force
    }
    else {
        Set-Variable -Name $($Global:WorkingScript.SHA) -Value $($TextBoxScriptPadContent.Text) -Scope Global -Force
    }
})
#================================================
#   GO
#================================================
$GoButton.add_Click({
    Write-Host -ForegroundColor Cyan "Start-Process"
    $Global:ScriptPadScriptBlock = [scriptblock]::Create($TextBoxScriptPadContent.Text)

    if ($Global:ScriptPadScriptBlock) {
        Write-Host -ForegroundColor DarkGray "Saving contents of `$Global:ScriptPadScriptBlock` to $env:Temp\ScriptPad.ps1"
        $Global:ScriptPadScriptBlock | Out-File "$env:Temp\ScriptPad.ps1"

        #$xamGUI.Close()
        #Invoke-Command $Global:ScriptPadScriptBlock
        
        #Start-Process PowerShell.exe -ArgumentList "-NoExit Invoke-Command -ScriptBlock {$Global:ScriptPadScriptBlock}"

        Write-Host -ForegroundColor DarkCyan 'Start-Process PowerShell.exe -ArgumentList "-NoExit $env:Temp\ScriptPad.ps1"'
        Start-Process PowerShell.exe -ArgumentList "-NoExit $env:Temp\ScriptPad.ps1"
    }
    #Write-Host -ForegroundColor DarkGray "================================================"
})
#================================================
#   Launch XAML
#================================================
$xamGUI.ShowDialog() | Out-Null