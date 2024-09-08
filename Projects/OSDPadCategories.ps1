#================================================
#   Window Functions
#   Minimize Command and PowerShell Windows
#================================================
$Script:showWindowAsync = Add-Type -MemberDefinition @"
[DllImport("user32.dll")]
public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
"@ -Name "Win32ShowWindowAsync" -Namespace Win32Functions -PassThru
function Hide-CmdWindow() {
    $CMDProcess = Get-Process -Name cmd -ErrorAction Ignore
    foreach ($Item in $CMDProcess) {
        $null = $showWindowAsync::ShowWindowAsync((Get-Process -Id $Item.id).MainWindowHandle, 2)
    }
}
function Hide-PowershellWindow() {
    $null = $showWindowAsync::ShowWindowAsync((Get-Process -Id $pid).MainWindowHandle, 2)
}
function Show-PowershellWindow() {
    $null = $showWindowAsync::ShowWindowAsync((Get-Process -Id $pid).MainWindowHandle, 10)
}
#Hide-CmdWindow
#Hide-PowershellWindow
#================================================
#   Get MyScriptDir
#================================================
$Global:MyScriptDir = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
#================================================
#   Load Assemblies
#================================================
[System.Reflection.Assembly]::LoadWithPartialName("presentationframework") | Out-Null
[System.Reflection.Assembly]::LoadFrom("$Global:MyScriptDir\assembly\System.Windows.Interactivity.dll") | Out-Null
#================================================
#   Set PowerShell Window Title
#================================================
#$host.ui.RawUI.WindowTitle = "OSDPad"
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
        [Parameter(Mandatory = $False, Position = 1)]
        [string]$XamlPath
    )
    
    # Import the XAML code
    [xml]$Global:XamlCode = Get-Content -Path $XamlPath

    # Add WPF and Windows Forms assemblies
    try {
        Add-Type -AssemblyName PresentationCore,PresentationFramework,WindowsBase,system.windows.forms
    } 
    catch {
        throw "Failed to load Windows Presentation Framework assemblies."
    }

    #Create the XAML reader using a new XML node reader
    $Global:XamlWindow = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $Global:XamlCode))

    #Create hooks to each named object in the XAML
    $Global:XamlCode.SelectNodes("//*[@Name]") | ForEach-Object {
        Set-Variable -Name ($_.Name) -Value $Global:XamlWindow.FindName($_.Name) -Scope Global
    }
}
#================================================
#   LoadForm
#================================================
LoadForm -XamlPath (Join-Path $Global:MyScriptDir 'OSDPadCategories.xaml')
#================================================
#   Initialize Category Selection
#================================================
$ScriptLabel.Visibility = "Collapsed"
$ScriptCombobox.Visibility = "Collapsed"

if ($Global:OSDPadCategories) {
    $Global:OSDPadCategories | ForEach-Object {
        $CategoryCombobox.Items.Add($_.Name) | Out-Null
    }
}
$Global:OSDPadScripts = $null
$Global:OSDPadScriptsContent = $null
#================================================
#   Set-OSDPadScript
#================================================
function Set-OSDPadScript {
    $Global:OSDPadScripts = $null
    $Global:OSDPadScriptsContent = $null

    $RepoOwner = $Global:OSDPadRepository.Owner
    $RepoName = $Global:OSDPadRepository.Name
    $RepoFolder = $CategoryCombobox.SelectedItem

    if ($RepoFolder) {
        $Params = @{
            Method = 'GET'
            Uri = "https://api.github.com/repos/$RepoOwner/$RepoName/contents/$RepoFolder"
            UseBasicParsing = $true
        }
    
        try {
            $Global:OSDPadScripts = Invoke-RestMethod @Params -ErrorAction Stop
        }
        catch {
            Write-Warning $_
            Break
        }
        $Global:OSDPadScripts = $Global:OSDPadScripts | Where-Object {($_.name -like "*.md") -or ($_.name -like "*.ps1")} | Sort-Object Name
        
        $Global:OSDPadScriptsContent = foreach ($Item in $Global:OSDPadScripts) {
            Write-Host -ForegroundColor DarkGray $Item.download_url
            try {
                $ScriptWebRequest = Invoke-WebRequest -Uri $Item.download_url -UseBasicParsing -ErrorAction Stop
            }
            catch {
                Write-Warning $_
                $ScriptWebRequest = $null
                Continue
            }

            $ObjectProperties = @{
                RepoOwner       = $RepoOwner
                RepoName        = $RepoName
                RepoFolder      = $RepoFolder
                Name            = $Item.name
                Type            = $Item.type
                Path            = $Item.path
                Size            = $Item.size
                SHA             = $Item.sha
                Git             = $Item.git_url
                Download        = $Item.download_url
                ContentRAW      = $ScriptWebRequest.Content
                #NodeId         = $FileContent.node_id
                #Content        = $FileContent.content
                #Encoding       = $FileContent.encoding
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
        }
    }
    if ($Global:OSDPadScriptsContent) {  
        # Clear existing content
        $ScriptCombobox.Items.Clear()
        $ScriptCombobox.SelectedIndex = 0

        $Global:OSDPadScriptsContent | ForEach-Object {
            $ScriptCombobox.Items.Add($_.Name) | Out-Null
            New-Variable -Name $_.SHA -Value $($_.ContentRAW) -Force -Scope Global
    
            $ScriptLabel.Visibility = "Visible"
            $ScriptCombobox.Visibility = "Visible"
    
            if ($_.Name -match 'README.md') {
                $ScriptCombobox.SelectedValue = $_.Name
            }
        }
    }
    else {
        Write-Verbose "Results have NOT been gathered" -Verbose
        $ScriptLabel.Visibility = "Collapsed"
        $ScriptCombobox.Visibility = "Collapsed"
    }
}
#================================================
#   Set-OSDPadContent
#================================================
function Set-OSDPadContent {
    if ($ScriptCombobox.SelectedValue -eq 'New PowerShell Script.ps1') {
        Write-Host -ForegroundColor Cyan 'New PowerShell Script.ps1'
        $ScriptTextBox.Foreground = 'Blue'
        $ScriptTextBox.IsReadOnly = $false
        $ScriptTextBox.Text = (Get-Variable -Name 'New PowerShell Script.ps1' -Scope Global).Value
        $StartButtonControl.Visibility = "Visible"
        $BrandingTitleControl.Content = $Global:OSDPadBranding.RepoName
        #$BrandingTitleControl.Visibility = "Collapsed"
    }
    else {
        $Global:WorkingScript = $Global:OSDPadScriptsContent | Where-Object {$_.Name -eq $ScriptCombobox.SelectedValue} | Select-Object -First 1

        #Write-Host -ForegroundColor Cyan $Global:WorkingScript.Path
        #Write-Host -ForegroundColor DarkGray $Global:WorkingScript.Git
        #Write-Host -ForegroundColor DarkGray $Global:WorkingScript.Download
        #Write-Host -ForegroundColor DarkCyan "Get-Variable -Name $($Global:WorkingScript.Guid)"

        $ScriptTextBox.Text = $Global:WorkingScript.ContentRAW

        if ($Global:WorkingScript.Name -like "*.md") {
            $ScriptTextBox.Foreground = 'Black'
            $ScriptTextBox.IsReadOnly = $true
            $StartButtonControl.Visibility = "Collapsed"
        }
        else {
            $ScriptTextBox.Foreground = 'Blue'
            $ScriptTextBox.IsReadOnly = $false
            $StartButtonControl.Visibility = "Visible"
        }
        $BrandingTitleControl.Content = $Global:OSDPadBranding.Title
    }
    foreach ($Item in $Hide) {
        if ($Item -eq 'Branding') {$BrandingTitleControl.Visibility = "Collapsed"}
        if ($Item -eq 'Script') {
            $Global:XamlWindow.Height="140"
            $ScriptTextBox.Visibility = "Collapsed"
        }
    }
}

#Set-OSDPadContent
#================================================
#   Change Selection
#================================================
$CategoryCombobox.add_SelectionChanged({
    #Write-Verbose "Category Selection Changed" -Verbose
    Set-OSDPadScript
})
$ScriptCombobox.add_SelectionChanged({
    #Write-Verbose "Script Selection Changed" -Verbose
    Set-OSDPadContent
})
$ScriptTextBox.add_TextChanged({
    #Write-Verbose "Script Text Changed" -Verbose
    #Set-Variable -Name $($Global:WorkingScript.ContentRAW) -Value $($ScriptTextBox.Text) -Scope Global -Force -ErrorAction Ignore
})
#================================================
#   GO
#================================================
$StartButtonControl.add_Click({
    Write-Host -ForegroundColor Cyan "Start-Process"
    $Global:OSDPadScriptBlock = [scriptblock]::Create($ScriptTextBox.Text)

    if ($Global:OSDPadScriptBlock) {
        if ($ScriptSelectionControl.SelectedValue -like "*#Requires -PSEdition Core*")  {
             Write-Host -ForegroundColor DarkCyan "PowerShell Core detected"
             $global:PwshCore = $true
         }
        
         if ($ScriptSelectionControl.SelectedValue -eq 'New PowerShell Script.ps1') {
             $ScriptFile = 'New PowerShell Script.ps1'
         }
         else {
             $ScriptFile = $Global:WorkingScript.Name
         }
         if (!(Test-Path "$env:Temp\OSDPad")) {New-Item "$env:Temp\OSDPad" -ItemType Directory}
         
         $ScriptPath = "$env:Temp\OSDPad\$ScriptFile"
         Write-Host -ForegroundColor DarkGray "Saving contents of `$Global:OSDPadScriptBlock` to $ScriptPath"
         $Global:OSDPadScriptBlock | Out-File $ScriptPath -Encoding utf8 -Width 2000 -Force
 
         #$Global:XamlWindow.Close()
         #Invoke-Command $Global:OSDPadScriptBlock
         #Start-Process PowerShell.exe -ArgumentList "-NoExit Invoke-Command -ScriptBlock {$Global:OSDPadScriptBlock}"
 
         if ($global:PwshCore -eq $true) {
             Write-Host -ForegroundColor DarkCyan "Start-Process -WorkingDirectory `"$env:Temp\OSDPad`" -FilePath pwsh.exe -ArgumentList '-NoLogo -NoExit',`"-File `"$ScriptFile`"`""
             Start-Process -WorkingDirectory "$env:Temp\OSDPad" -FilePath pwsh.exe -ArgumentList '-NoLogo -NoExit',"-File `"$ScriptFile`"" -Wait
         }
         else {
             Write-Host -ForegroundColor DarkCyan "Start-Process -WorkingDirectory `"$env:Temp\OSDPad`" -FilePath PowerShell.exe -ArgumentList '-NoLogo -NoExit',`"-File `"$ScriptFile`"`""
             Start-Process -WorkingDirectory "$env:Temp\OSDPad" -FilePath PowerShell.exe -ArgumentList '-NoLogo -NoExit',"-File `"$ScriptFile`"" -Wait
         }
         #Write-Host -ForegroundColor DarkCyan "Start-Process -WorkingDirectory `"$env:Temp\OSDPad`" -FilePath PowerShell.exe -ArgumentList '-NoLogo -NoExit',`"-File `"$ScriptFile`"`""
         #Start-Process -WorkingDirectory "$env:Temp\OSDPad" -FilePath PowerShell.exe -ArgumentList '-NoLogo -NoExit',"-File `"$ScriptFile`""
     }
    #Write-Host -ForegroundColor DarkGray "========================================================================="
})
#================================================
#   Customizations
#================================================
[string]$ModuleVersion = Get-Module -Name OSD | Sort-Object -Property Version | Select-Object -ExpandProperty Version -Last 1
$Global:XamlWindow.Title = "$ModuleVersion OSDPad"
#================================================
#   Branding
#================================================
if ($Global:OSDPadBranding) {
    $BrandingTitleControl.Content = $Global:OSDPadBranding.Title
    $BrandingTitleControl.Foreground = $Global:OSDPadBranding.Color
}
#================================================
#   Launch
#================================================
$Global:XamlWindow.ShowDialog() | Out-Null
#================================================