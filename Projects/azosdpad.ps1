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
#$host.ui.RawUI.WindowTitle = "OSDCloudGUI"
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
$XamlMainWindow=LoadXaml("$Global:MyScriptDir\azosdpad.xaml")
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
Get-FormVariables

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
            ## real mode
            #$AllNodes =$Global:AzOSDCloudBlobScript.BlobClient.BlobContainerName
            
            # test
            
            $AllNodes = $Global:AzOSDCloudGlobalScripts | Group-Object Container
            
            ## offline test

            #$AllNode = Import-Clixml -path $Global:MyScriptDir\work.xml
            #$AllNodes = $AllNode.BlobClient.BlobContainerName |Group-Object
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
                    
                    $WPF_tt.Content = $($sender.Tag[1].Name)
                   
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

    $WPF_ListBoxControl.SelectedIndex = $args[0].Source.SelectedIndex

   Write-Host $WPF_ListBoxControl.SelectedValue 

   foreach ($item in $Global:AzOSDCloudBlobScript) {
    if ($item.Name -eq $WPF_ListBoxControl.SelectedValue) {
        <# Action to perform if the condition is true #>
       $File =  $item.ICloudBlob
    }

   }
    #$Global:AzOSDCloudGlobalScripts.ICloudBlob | Where-Object {$_.Name -eq $WPF_ListBoxControl.SelectedValue} 

   Get-AzStorageBlobContent -CloudBlob $file  -Context $Global:AzCurrentStorageContext.Context -Destination d:\ -CheckMd5 

})


#########################################################################
#                        Stuff                                          #
#########################################################################
Start-Scan
$Form.ShowDialog() | Out-Null
