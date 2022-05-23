#########################################################################
#                        Add shared_assemblies                          #
#########################################################################

[Void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework') 
foreach ($item in $(gci .\assembly\ -Filter *.dll).name) {
    [Void][System.Reflection.Assembly]::LoadFrom("assembly\$item")
}
Add-Type -AssemblyName System.Windows.Forms | Out-Null
#########################################################################
#                        Load Main Panel                                #
#########################################################################

$Global:pathPanel= split-path -parent $MyInvocation.MyCommand.Definition
function LoadXaml ($filename){
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}
$XamlMainWindow=LoadXaml("$Global:pathPanel\azosdpad.xaml")
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

###################################################
#                    Variables                    #
###################################################

function GetRecurse {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline=$true)]
        $DN
    )
    Process {
        if ($ChildOrg = (Get-ADOrganizationalUnit -SearchBase $DN -SearchScope OneLevel -Filter *).DistinguishedName){
            [PscustomObject]@{
                Name = ($DN.Substring(3,(($DN.Split(',')[0]).Length - 3)))
                DN = $DN 
                GPO =  Get-ADOOUGPO $DN
                Child = $ChildOrg | GetRecurse
            }
        }Else{
            [PscustomObject]@{
                Name = ($DN.Substring(3,(($DN.Split(',')[0]).Length - 3)))
                DN = $DN
                GPO =  Get-ADOOUGPO $DN
                Child = $Null
            }
        }
    }        
}
function Get-ADOOUGPO{
 [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline=$true)]
        $DN
    )
    process{Get-ADOrganizationalUnit -Identity $DN | select -Property LinkedGroupPolicyObjects | ForEach-Object {$GUID= $_.LinkedGroupPolicyObjects| Select-String -Pattern '{[-0-9A-F]+?}' -AllMatches | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value 
            $GPO = @()
        if (!($null -eq $GUID)){

           if ($GUID.count -eq 1){ 
              $GPO = (Get-GPO -Guid $GUID).DisplayName
               }
           else{
          
                for ($i = 0; $i -lt $GUID.count; $i++)
                {   
                    $GPO += (Get-GPO -Guid $GUID[$i]).DisplayName
                }
           }
          }
           return $GPO
     
        }
    }



}
function Start-Scan {
    [CmdletBinding()]
    [Alias()]
    Param
    (
        
    )
    begin
        {
            $dummyNode = $null
            #$AllNodes =$Global:AzOSDCloudBlobScript.BlobClient.BlobContainerName |Group-Object
            $AllNode = Import-Clixml -path $global:pathPanel\work.xml
            $AllNodes = $AllNode.BlobClient.BlobContainerName |Group-Object
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
                try {
                    $ListBoxControl.ItemsSource = $null
                    $ListBoxControl.Items.Clear()                    
                }
                catch {}
                Write-Host "2" $_.OriginalSource.Header  "JJJ"
                $Sublevel = $_.OriginalSource.Header
                
		        [System.Windows.Controls.TreeViewItem]$sender = $args[0]
                $OU=  $($sender.Tag[1].DN)
                })
                $treeViewItem.Add_PreviewMouseRightButtonDown({

                    $Menu.IsOpen = $true
                })
                $treeViewItem.Add_PreviewMouseLeftButtonDown({

		            [System.Windows.Controls.TreeViewItem]$sender = $args[0]
                    $DistinguishedName.Text = $($sender.Tag[1].DN)
                    $Sobjects.Visibility="Visible" 
                    
                    #$Object= Get-AzOSDCloudBlobScriptFile Container "$($sender.Tag[1].DN)"

                    if ($null -eq $($Object).Count){
                        $CObjects.Content = 1
                        $TempArray = [System.Collections.ArrayList]::new()
                        $TempArray.Add($Object)
                        $ListBoxControl.ItemsSource = $TempArray
                    }
                    else{
                        $ListBoxControl.ItemsSource = $Object
                        $CObjects.Content = $($Object).Count
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
       $Objects = Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container -Blob *.ps1 -ErrorAction Ignore
       $Objects += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container -Blob *.ppkg -ErrorAction Ignore
       $Objects += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container -Blob *.xml -ErrorAction Ignore
    }
    catch {}
    return $Objects
}

#########################################################################
#                        Stuff                                          #
#########################################################################
Start-Scan 


$Form.ShowDialog() | Out-Null
  