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
function Convert-ByteArrayToHex{

    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [Byte[]]
        $Bytes
    )
    
    $HextString = [System.Text.StringBuilder]::new($Bytes.Length * 2)
    
    foreach ($byte in $Bytes) {
        $HextString.AppendFormat("{0:x2}", $byte) | Out-Null
    }
    
    $HextString.ToString()
    
    }
    
Hide-CmdWindow
Hide-PowershellWindow
#================================================
#   Get MyScriptDir
#================================================
$Global:MyScriptDir = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
#================================================
#   Load Assemblies
#================================================
[System.Reflection.Assembly]::LoadWithPartialName("presentationframework") | Out-Null
 ($global:tt=Get-ChildItem -Path $Global:MyScriptDir\assembly\ -Recurse -Include *.dll) | ForEach-Object {
    [void]  [System.Reflection.Assembly]::LoadFrom($_.FullName)
}
#================================================
#   Set PowerShell Window Title
#================================================
$host.ui.RawUI.WindowTitle = "AzOSDPad"
#================================================
#   Test-InWinPE
#================================================
function Test-InWinPE {
    return Test-Path -Path Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlset\Control\MiniNT
}
#================================================
#   LoadForm
#================================================
function LoadXaml ($filename){
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}
$XamlMainWindow=LoadXaml("$Global:MyScriptDir\azosdpadnew.xaml")
$reader = (New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$Form = [Windows.Markup.XamlReader]::Load($reader)
$XamlMainWindow.SelectNodes("//*[@Name]") | %{
    try {Set-Variable -Name "$("WPF_"+$_.Name)" -Value $Form.FindName($_.Name) -ErrorAction Stop}
    catch{throw}
    }

Function Get-FormVariables{
if ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}
write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
get-variable *WPF*
}
#Get-FormVariables

#================================================
#   Initialize
#================================================
function Start-Scan {
    [CmdletBinding()]
    [Alias()]
    Param
    (
        
    )
    begin
        {
            $dummyNode = $null
            
            $AllNodes = $Global:AzOSDCloudGlobalScripts | Group-Object Container
            
        }
    process
        {
            

            # ================== Handle Folders ===========================
           
            foreach ($node in $AllNodes)
            {

                $treeViewItem = [Windows.Controls.TreeViewItem]::new()
                $treeViewItem.Header = $node.Name
                $treeViewItem.Tag = @("folder",$node)
                $treeViewItem.Items.Add($dummyNode) | Out-Null

                $treeViewItem.Add_Expanded({
                })
                $treeViewItem.Add_PreviewMouseLeftButtonDown({
                    [System.Windows.Controls.TreeViewItem]$sender = $args[0]
                    [System.Windows.RoutedEventArgs]$e = $args[1]  
                    
                    # Set all properties to the same value null
                        $WPF_Name.Content = " "
                        $WPF_UrL.Content =  " "
                        $WPF_LastModified.Content = " "
                        $WPF_SHA.content = " "                       
                        if ($WPF_ScriptTextControl.Text -notlike '#This is the azOSDPad Script PowerShell') {

                            $WPF_ScriptTextControl.Text = ""
                        }
                        
                   
                    $global:Object= Get-AzOSDCloudBlobScriptFile -Container  $sender.Header
                    
                    if ($null -eq $( $global:Object).Count){
                        $WPF_CObjects.Content = 1
                        $TempArray = [System.Collections.ArrayList]::new()

                        $TempArray.Add($global:Object.Name)
                        $WPF_ListBoxControl.ItemsSource = $TempArray
                    }
                    else{
                        $TempArray = [System.Collections.ArrayList]::new()
                        for ($i = 0; $i -lt $($global:Object).count; $i++) {
                            $TempArray.Add($global:Object[$i].Name)
                        }
                        $WPF_ListBoxControl.ItemsSource = $TempArray
                        $WPF_CObjects.Content = $($global:Object).count
                    }
    })
            $WPF_TreeView.Items.Add($treeViewItem) | Out-Null
            }
        }
    end
        {

        }
}

function Get-AzOSDCloudBlobScriptFile {
    [CmdletBinding()]
    param (
    
    $Container

    )
      Try {
       $Objects = @()
       $Objects = Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container -Blob *.ps1 
       $Objects += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container -Blob *.ppkg 
       $Objects += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container -Blob *.xml 
    }
    catch {}

    return $Objects
}
$WPF_ListBoxControl.Add_MouseRightButtonUp({


})

$WPF_ListBoxControl.Add_MouseLeftButtonUp({

    $WPF_ListBoxControl.SelectedIndex =  $WPF_ListBoxControl.Items.IndexOf($WPF_ListBoxControl.SelectedItem)

   foreach ($item in $Global:AzOSDCloudBlobScript) {
    if ($item.Name -eq $WPF_ListBoxControl.SelectedValue) {
        <# Action to perform if the condition is true #>
       $File =  $item.ICloudBlob
       $WPF_Name.Content = $File.Name
       $WPF_UrL.Content =  $File.Uri.AbsoluteUri
       $WPF_LastModified.Content = $File.Properties.LastModified
       $WPF_SHA.content = Convert-ByteArrayToHex -Bytes $( $item.BlobProperties.ContentHash -split " ")
       if ($WPF_ScriptTextControl.Text -notlike '#This is the azOSDPad Script PowerShell') {

        $WPF_ScriptTextControl.Text = "#This is the azOSDPad Script PowerShell"
    }

    }
    if (!(Test-Path "$env:Temp\azOSDPad")) {New-Item "$env:Temp\azOSDPad" -ItemType Directory |Out-Null}

   }
   if ($WPF_ListBoxControl.SelectedValue -like "*.xml" -or $WPF_ListBoxControl.SelectedValue -like "*.ppkg") {
     $WPF_runfile.IsEnabled = $false
     $WPF_StartButtonControl.IsEnabled = $false
   }
   elseif ($WPF_ListBoxControl.SelectedValue -like "*.ps1") {
     $WPF_runfile.IsEnabled = $true
     $WPF_StartButtonControl.IsEnabled = $true

   }
   $global:File = $File
  # Get-AzStorageBlobContent -CloudBlob $file  -Context $Global:AzCurrentStorageContext.Context -Destination $Global:MyScriptDir\  -AsJob

})

$WPF_ViewFile.add_Click({

  Get-AzStorageBlobContent -CloudBlob $global:File  -Context $Global:AzCurrentStorageContext.Context -Destination "$env:Temp\azOSDPad\"  -AsJob
    $name = "$env:Temp\azOSDPad\" + $global:File.Name
  Start-Sleep -Seconds 2
    $WPF_ScriptTextControl.Text = Get-content -Path $name

})

$WPF_RunFile.add_Click({

    Get-AzStorageBlobContent -CloudBlob $global:File  -Context $Global:AzCurrentStorageContext.Context -Destination "$env:Temp\azOSDPad\"  -AsJob
      $name = "$env:Temp\azOSDPad\" + $global:File.Name
    
      Start-Sleep -Seconds 2
    
      & "$name"
  
  })

  $WPF_StartButtonControl.add_Click({
    
    $Global:azOSDPadScriptBlock = [scriptblock]::Create($WPF_ScriptTextControl.Text)

    if ($Global:azOSDPadScriptBlock) {
        if ($ScriptSelectionControl.SelectedValue -like '#This is the azOSDPad Script PowerShell*') {
            $ScriptFile = 'New PowerShell Script.ps1'
        }
        else {
            $ScriptFile = $global:File.Name
        }
    }
    $ScriptPath = "$env:Temp\OSDPad\$ScriptFile"
    $Global:azOSDPadScriptBlock | Out-File $ScriptPath -Encoding utf8 -Width 2000 -Force

    Start-Process -WorkingDirectory "$env:Temp\OSDPad" -FilePath PowerShell.exe -ArgumentList '-NoLogo -NoExit',"-File `"$ScriptFile`""

  })
  #########################################################################
#                        Stuff                                          #
#########################################################################
Start-Scan

$WPF_CObjects.Content = ""
$WPF_StorageAccountName.content = $Global:AzOSDCloudStorageAccounts.StorageAccountName
$WPF_ResourceGroup.Content = $Global:AzOSDCloudStorageAccounts.ResourceGroupName
$Form.ShowDialog() | Out-Null
