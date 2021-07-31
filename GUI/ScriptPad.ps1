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
[System.Reflection.Assembly]::LoadFrom("$Global:MyScriptDir\assembly\MahApps.Metro.dll") | Out-Null
[System.Reflection.Assembly]::LoadFrom("$Global:MyScriptDir\assembly\System.Windows.Interactivity.dll") | Out-Null

# Set console size and title
$host.ui.RawUI.WindowTitle = ""
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
#=======================================================================
#   LoadForm
#=======================================================================
LoadForm -XamlPath (Join-Path $Global:MyScriptDir 'ScriptPad.xaml')
#=======================================================================
#   Initialize
#=======================================================================
$ComboBoxScriptPadName.Items.Add('BlankScript') | Out-Null
    if (-NOT (Get-Variable -Name BlankScript -Scope Global -ErrorAction Ignore)) {
        New-Variable -Name 'BlankScript' -Value '#PowerShell ScriptBlock' -Scope Global -Force -ErrorAction Stop
    }

$LabelScriptPadDescription.Content = 'BlankScript is the default PowerShell ScriptBlock that you can edit and Invoke-Command'

#   "Description": 'BlankScript is the default PowerShell ScriptBlock that you can edit and Invoke-Command'
#   "Guid": "fa4a53ea-62ca-478e-95f6-2ff07f8f468a"

if ($Global:ScriptPad.Scripts) {
    $Global:ScriptPad.Scripts | ForEach-Object {
        Write-Host -ForegroundColor DarkGray "Script Name: $($_.Name)"
        try {
            $ScriptPadWebRequest = Invoke-WebRequest -Uri $_.Uri -UseBasicParsing -ErrorAction Stop
        }
        catch {
            Write-Warning $_
            $ScriptPadWebRequest = $null
        }
        
        if ($ScriptPadWebRequest) {
            $ComboBoxScriptPadName.Items.Add($_.Name) | Out-Null
            New-Variable -Name $_.Guid -Value $ScriptPadWebRequest.Content -Force -Scope Global
        }
    }
    Write-Host -ForegroundColor DarkGray "========================================================================="
    if ($Global:ScriptPad.Settings.Title) {
        Write-Host -ForegroundColor Cyan $Global:ScriptPad.Settings.Title
    }
    if ($Global:ScriptPad.Settings.Version) {
        Write-Host -ForegroundColor DarkGray $Global:ScriptPad.Settings.Version
    }
    if ($Global:ScriptPad.Settings.Author) {
        Write-Host -ForegroundColor DarkGray $Global:ScriptPad.Settings.Author
    }
    if ($Global:ScriptPad.Settings.Company) {
        Write-Host -ForegroundColor DarkGray $Global:ScriptPad.Settings.Company
    }
    if ($Global:ScriptPad.Settings.Help) {
        Write-Host -ForegroundColor DarkGray $Global:ScriptPad.Settings.Help
    }
}
if ($Global:ScriptPad.Settings.Title) {
    $LabelTitle.Content = $Global:ScriptPad.Settings.Title
}
else {
    $LabelTitle.Content = 'ScriptPad'
}
#=======================================================================
#   Set-ScriptPadContent
#=======================================================================
function Set-ScriptPadContent {
    Write-Host -ForegroundColor DarkGray "========================================================================="
    if ($ComboBoxScriptPadName.SelectedValue -eq 'BlankScript') {
        $TextBoxScriptPadContent.Text = (Get-Variable -Name BlankScript -Scope Global).Value
        $LabelScriptPadDescription.Content = 'BlankScript is the default PowerShell ScriptBlock that you can edit and Invoke-Command'
    }
    else {
        $Global:WorkingScript = $Global:ScriptPad.Scripts | Where-Object {$_.Name -eq $ComboBoxScriptPadName.SelectedValue} | Select-Object -First 1
        if ($Global:WorkingScript.Name) {
            Write-Host -ForegroundColor Cyan $Global:WorkingScript.Name
        }
        if ($Global:WorkingScript.Version) {
            Write-Host -ForegroundColor DarkCyan $Global:WorkingScript.Version
        }
        if ($Global:WorkingScript.Author) {
            Write-Host -ForegroundColor DarkCyan $Global:WorkingScript.Author
        }
        if ($Global:WorkingScript.Description) {
            Write-Host -ForegroundColor DarkCyan $Global:WorkingScript.Description
            $LabelScriptPadDescription.Content = $Global:WorkingScript.Description
        }
        if ($Global:WorkingScript.Uri) {
            Write-Host -ForegroundColor DarkCyan $Global:WorkingScript.Uri
            #$LabelScriptPadUri.Content = $Global:WorkingScript.Uri
        }
        $TextBoxScriptPadContent.Text = (Get-Variable -Name $Global:WorkingScript.Guid).Value
    }
}

Set-ScriptPadContent
#=======================================================================
#   Change Selection
#=======================================================================
<# $ComboBoxScriptPadName.add_SelectionChanged({
    Set-ScriptPadContent
}) #>
$ComboBoxScriptPadName.add_DropDownClosed({
    Set-ScriptPadContent
})
$TextBoxScriptPadContent.add_TextChanged({
    if ($ComboBoxScriptPadName.SelectedValue -eq 'BlankScript') {
        Set-Variable -Name 'BlankScript' -Value $($TextBoxScriptPadContent.Text) -Scope Global -Force
    }
    else {
        Set-Variable -Name $($Global:WorkingScript.Guid) -Value $($TextBoxScriptPadContent.Text) -Scope Global -Force
    }
})
#=======================================================================
#   GO
#=======================================================================
$GoButton.add_Click({
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "Invoke-Command"
    $Global:ScriptPadScriptBlock = [scriptblock]::Create($TextBoxScriptPadContent.Text)

    if ($Global:ScriptPadScriptBlock) {
        Write-Host -ForegroundColor DarkGray "Saving contents of `$Global:ScriptPadScriptBlock` to $env:Temp\ScriptPadScriptBlock.ps1"
        $Global:ScriptPadScriptBlock | Out-File "$env:Temp\ScriptPadScriptBlock.ps1"

        #$xamGUI.Close()
        #Invoke-Command $Global:ScriptPadScriptBlock
        
        Write-Host -ForegroundColor DarkCyan 'Start-Process PowerShell.exe -ArgumentList "-NoExit Invoke-Command -ScriptBlock {$Global:ScriptPadScriptBlock}"'
        Start-Process PowerShell.exe -ArgumentList "-NoExit Invoke-Command -ScriptBlock {$Global:ScriptPadScriptBlock}"
    }
    #Write-Host -ForegroundColor DarkGray "========================================================================="
})
#=======================================================================
#   Launch XAML
#=======================================================================
$xamGUI.ShowDialog() | Out-Null