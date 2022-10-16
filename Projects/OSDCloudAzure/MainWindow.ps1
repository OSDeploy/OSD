# PoSHPF - Version 1.2
# Grab all resources (MahApps, etc), all XAML files, and any potential static resources
#$Global:resources = Get-ChildItem -Path "$PSScriptRoot\Resources\*.dll" -ErrorAction SilentlyContinue
$Global:XAML = Get-ChildItem -Path "$PSScriptRoot\*.xaml" | Where-Object {$_.Name -ne 'App.xaml'} -ErrorAction SilentlyContinue #Changed path and exclude App.xaml
#$Global:MediaResources = Get-ChildItem -Path "$PSScriptRoot\Media" -ErrorAction SilentlyContinue

# This class allows the synchronized hashtable to be available across threads,
# but also passes a couple of methods along with it to do GUI things via the
# object's dispatcher.
class SyncClass 
{
    #Hashtable containing all forms/windows and controls - automatically created when newing up
    [hashtable]$SyncHash = [hashtable]::Synchronized(@{}) 
    
    # method to close the window - pass window name
    [void]CloseWindow($windowName){ 
        $this.SyncHash.$windowName.Dispatcher.Invoke([action]{$this.SyncHash.$windowName.Close()},"Normal") 
    }
    
    # method to update GUI - pass object name, property and value   
    [void]UpdateElement($object,$property,$value){ 
        $this.SyncHash.$object.Dispatcher.Invoke([action]{ $this.SyncHash.$object.$property = $value },"Normal") 
    } 
}
$Global:SyncClass = [SyncClass]::new() # create a new instance of this SyncClass to use.

###################
## Import Resources
###################
# Load WPF Assembly
Add-Type -assemblyName PresentationFramework

# Load Resources
foreach($dll in $resources) { [System.Reflection.Assembly]::LoadFrom("$($dll.FullName)") | out-null }

##############
## Import XAML
##############
$xp = '[^a-zA-Z_0-9]' # All characters that are not a-Z, 0-9, or _
$vx = @()             # An array of XAML files loaded

foreach($x in $XAML) { 
    # Items from XAML that are known to cause issues
    # when PowerShell parses them.
    $xamlToRemove = @(
        'mc:Ignorable="d"',
        "x:Class=`"(.*?)`"",
        "xmlns:local=`"(.*?)`""
    )

    $xaml = Get-Content $x.FullName # Load XAML
    $xaml = $xaml -replace "x:N",'N' # Rename x:Name to just Name (for consumption in variables later)
    foreach($xtr in $xamlToRemove){ $xaml = $xaml -replace $xtr } # Remove items from $xamlToRemove
    
    # Create a new variable to store the XAML as XML
    New-Variable -Name "xaml$(($x.BaseName) -replace $xp, '_')" -Value ($xaml -as [xml]) -Force
    
    # Add XAML to list of XAML documents processed
    $vx += "$(($x.BaseName) -replace $xp, '_')"
}
#######################
## Add Media Resources
#######################
$imageFileTypes = @(".jpg",".bmp",".gif",".tif",".png") # Supported image filetypes
$avFileTypes = @(".mp3",".wav",".wmv") # Supported audio/visual filetypes
$xp = '[^a-zA-Z_0-9]' # All characters that are not a-Z, 0-9, or _
if($MediaResources.Count -gt 0){
    ## Okay... the following code is just silly. I know
    ## but hear me out. Adding the nodes to the elements
    ## directly caused big issues - mainly surrounding the
    ## "x:" namespace identifiers. This is a hacky fix but
    ## it does the trick.
    foreach($v in $vx)
    {
        $xml = ((Get-Variable -Name "xaml$($v)").Value) # Load the XML

        # add the resources needed for strings
        $xml.DocumentElement.SetAttribute("xmlns:sys","clr-namespace:System;assembly=System")

        # if the document doesn't already have a "Window.Resources" create it
        if($null -eq ($xml.DocumentElement.'Window.Resources')){ 
            $fragment = "<Window.Resources>" 
            $fragment += "<ResourceDictionary>"
        }
        
        # Add each StaticResource with the key of the base name and source to the full name
        foreach($sr in $MediaResources)
        {
            $srname = "$($sr.BaseName -replace $xp, '_')$($sr.Extension.Substring(1).ToUpper())" #convert name to basename + Uppercase Extension
            if($sr.Extension -in $imageFileTypes){ $fragment += "<BitmapImage x:Key=`"$srname`" UriSource=`"$($sr.FullName)`" />" }
            if($sr.Extension -in $avFileTypes){ 
                $uri = [System.Uri]::new($sr.FullName)
                $fragment += "<sys:Uri x:Key=`"$srname`">$uri</sys:Uri>" 
            }    
        }

        # if the document doesn't already have a "Window.Resources" close it
        if($null -eq ($xml.DocumentElement.'Window.Resources'))
        {
            $fragment += "</ResourceDictionary>"
            $fragment += "</Window.Resources>"
            $xml.DocumentElement.InnerXml = $fragment + $xml.DocumentElement.InnerXml
        }
        # otherwise just add the fragment to the existing resource dictionary
        else
        {
            $xml.DocumentElement.'Window.Resources'.ResourceDictionary.InnerXml += $fragment
        }

        # Reset the value of the variable
        (Get-Variable -Name "xaml$($v)").Value = $xml
    }
}
#################
## Create "Forms"
#################
$forms = @()
foreach($x in $vx)
{
    $Reader = (New-Object System.Xml.XmlNodeReader ((Get-Variable -Name "xaml$($x)").Value)) #load the xaml we created earlier into XmlNodeReader
    New-Variable -Name "form$($x)" -Value ([Windows.Markup.XamlReader]::Load($Reader)) -Force #load the xaml into XamlReader
    $forms += "form$($x)" #add the form name to our array
    $SyncClass.SyncHash.Add("form$($x)", (Get-Variable -Name "form$($x)").Value) #add the form object to our synched hashtable
}
#################################
## Create Controls (Buttons, etc)
#################################
$controls = @()
$xp = '[^a-zA-Z_0-9]' # All characters that are not a-Z, 0-9, or _
foreach($x in $vx)
{
    $xaml = (Get-Variable -Name "xaml$($x)").Value #load the xaml we created earlier
    $xaml.SelectNodes("//*[@Name]") | %{ #find all nodes with a "Name" attribute
        $cname = "form$($x)Control$(($_.Name -replace $xp, '_'))"
        Set-Variable -Name "$cname" -Value $SyncClass.SyncHash."form$($x)".FindName($_.Name) #create a variale to hold the control/object
        $controls += (Get-Variable -Name "form$($x)Control$($_.Name)").Name #add the control name to our array
        $SyncClass.SyncHash.Add($cname, $SyncClass.SyncHash."form$($x)".FindName($_.Name)) #add the control directly to the hashtable
    }
}
############################
## FORMS AND CONTROLS OUTPUT
############################
<# Write-Host -ForegroundColor Cyan "The following forms were created:"
$forms | %{ Write-Host -ForegroundColor Yellow "  `$$_"} #output all forms to screen
if($controls.Count -gt 0){
    Write-Host ""
    Write-Host -ForegroundColor Cyan "The following controls were created:"
    $controls | %{ Write-Host -ForegroundColor Yellow "  `$$_"} #output all named controls to screen
} #>
#######################
## DISABLE A/V AUTOPLAY
#######################
foreach($x in $vx)
{
    $carray = @()
    $fts = $syncClass.SyncHash."form$($x)"
    foreach($c in $fts.Content.Children)
    {
        if($c.GetType().Name -eq "MediaElement") #find all controls with the type MediaElement
        {
            $c.LoadedBehavior = "Manual" #Don't autoplay
            $c.UnloadedBehavior = "Stop" #When the window closes, stop the music
            $carray += $c #add the control to an array
        }
    }
    if($carray.Count -gt 0)
    {
        New-Variable -Name "form$($x)PoSHPFCleanupAudio" -Value $carray -Force # Store the controls in an array to be accessed later
        $syncClass.SyncHash."form$($x)".Add_Closed({
            foreach($c in (Get-Variable "form$($x)PoSHPFCleanupAudio").Value)
            {
                $c.Source = $null #stops any currently playing media
            }
        })
    }
}

#####################
## RUNSPACE FUNCTIONS
#####################
## Yo dawg... Runspace to clean up Runspaces
## Thank you Boe Prox / Stephen Owen
#region RSCleanup
$Script:JobCleanup = [hashtable]::Synchronized(@{}) 
$Script:Jobs = [system.collections.arraylist]::Synchronized((New-Object System.Collections.ArrayList)) #hashtable to store all these runspaces
$jobCleanup.Flag = $True #cleanup jobs
$newRunspace =[runspacefactory]::CreateRunspace() #create a new runspace for this job to cleanup jobs to live
$newRunspace.ApartmentState = "STA"
$newRunspace.ThreadOptions = "ReuseThread"
$newRunspace.Open()
$newRunspace.SessionStateProxy.SetVariable("jobCleanup",$jobCleanup) #pass the jobCleanup variable to the runspace
$newRunspace.SessionStateProxy.SetVariable("jobs",$jobs) #pass the jobs variable to the runspace
$jobCleanup.PowerShell = [PowerShell]::Create().AddScript({
    #Routine to handle completed runspaces
    Do {    
        Foreach($runspace in $jobs) {            
            If ($runspace.Runspace.isCompleted) {                         #if runspace is complete
                [void]$runspace.powershell.EndInvoke($runspace.Runspace)  #then end the script
                $runspace.powershell.dispose()                            #dispose of the memory
                $runspace.Runspace = $null                                #additional garbage collection
                $runspace.powershell = $null                              #additional garbage collection
            } 
        }
        #Clean out unused runspace jobs
        $temphash = $jobs.clone()
        $temphash | Where {
            $_.runspace -eq $Null
        } | ForEach {
            $jobs.remove($_)
        }        
        Start-Sleep -Seconds 1 #lets not kill the processor here 
    } while ($jobCleanup.Flag)
})
$jobCleanup.PowerShell.Runspace = $newRunspace
$jobCleanup.Thread = $jobCleanup.PowerShell.BeginInvoke() 
#endregion RSCleanup

#This function creates a new runspace for a script block to execute
#so that you can do your long running tasks not in the UI thread.
#Also the SyncClass is passed to this runspace so you can do UI
#updates from this thread as well.
function Start-BackgroundScriptBlock($scriptBlock){
    $newRunspace =[runspacefactory]::CreateRunspace()
    $newRunspace.ApartmentState = "STA"
    $newRunspace.ThreadOptions = "ReuseThread"          
    $newRunspace.Open()
    $newRunspace.SessionStateProxy.SetVariable("SyncClass",$SyncClass) 
    $PowerShell = [PowerShell]::Create().AddScript($scriptBlock)
    $PowerShell.Runspace = $newRunspace
    $PowerShell.BeginInvoke()

    #Add it to the job list so that we can make sure it is cleaned up
<#     [void]$Jobs.Add(
        [pscustomobject]@{
            PowerShell = $PowerShell
            Runspace = $PowerShell.BeginInvoke()
        }
    ) #>
}
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
#================================================
#   StorageAccounts
#================================================
if ($Global:AzOSDCloudBlobImage) {

}
else {
    Break
}

$formMainWindowControlStorageAccountCombobox.Items.Clear()
$GuiStorageAccounts = @()
foreach ($Item in $Global:AzOSDCloudBlobImage) {
    $GuiStorageAccounts += $Item.BlobClient.AccountName
}
$GuiStorageAccounts | Select-Object -Unique | ForEach-Object {
    $formMainWindowControlStorageAccountCombobox.Items.Add($_) | Out-Null
}
$formMainWindowControlStorageAccountCombobox.SelectedIndex = 0
#================================================
#   Containers
#================================================
$formMainWindowControlContainerCombobox.Items.Clear()
$GuiContainers = @()
foreach ($Item in $Global:AzOSDCloudBlobImage | Where-Object {$_.BlobClient.AccountName -eq $formMainWindowControlStorageAccountCombobox.SelectedValue}) {
    $GuiContainers += $Item.BlobClient.BlobContainerName
}
$GuiContainers | Select-Object -Unique | ForEach-Object {
    $formMainWindowControlContainerCombobox.Items.Add($_) | Out-Null
}
$formMainWindowControlContainerCombobox.SelectedIndex = 0
#================================================
#   Blobs
#================================================
$formMainWindowControlBlobCombobox.Items.Clear()
$GuiBlobs = @()
foreach ($Item in $Global:AzOSDCloudBlobImage | Where-Object {$_.BlobClient.BlobContainerName -eq $formMainWindowControlContainerCombobox.SelectedValue}) {
    $GuiBlobs += $Item.BlobClient.Name
}
$GuiBlobs | ForEach-Object {
    $formMainWindowControlBlobCombobox.Items.Add($_) | Out-Null
}
$formMainWindowControlBlobCombobox.SelectedIndex = 0
#================================================
#   DriverPack
#================================================
$DriverPack = Get-OSDCloudDriverPack
$DriverPacks = @()
$DriverPacks = Get-OSDCloudDriverPacks
$DriverPacks | ForEach-Object {
    $formMainWindowControlDriverPackCombobox.Items.Add($_.Name) | Out-Null
}
if ($DriverPack) {
    $formMainWindowControlDriverPackCombobox.SelectedValue = $DriverPack.Name
}
#================================================
#   StorageAccountCombobox SelectionChanged
#================================================
$formMainWindowControlStorageAccountCombobox.add_SelectionChanged({
    $formMainWindowControlContainerCombobox.Items.Clear()
    $GuiContainers = @()
    foreach ($Item in $Global:AzOSDCloudBlobImage | Where-Object {$_.BlobClient.AccountName -eq $formMainWindowControlStorageAccountCombobox.SelectedValue}) {
        $GuiContainers += $Item.BlobClient.BlobContainerName
    }
    $GuiContainers | Select-Object -Unique | ForEach-Object {
        $formMainWindowControlContainerCombobox.Items.Add($_) | Out-Null
    }
    $formMainWindowControlContainerCombobox.SelectedIndex = 0

    $formMainWindowControlBlobCombobox.Items.Clear()
    $GuiBlobs = @()
    foreach ($Item in $Global:AzOSDCloudBlobImage | Where-Object {$_.BlobClient.BlobContainerName -eq $formMainWindowControlContainerCombobox.SelectedValue}) {
        $GuiBlobs += $Item.BlobClient.Name
    }
    $GuiBlobs | ForEach-Object {
        $formMainWindowControlBlobCombobox.Items.Add($_) | Out-Null
    }
    $formMainWindowControlBlobCombobox.SelectedIndex = 0
})
#================================================
#   ContainerCombobox SelectionChanged
#================================================
$formMainWindowControlContainerCombobox.add_SelectionChanged({
    $formMainWindowControlBlobCombobox.Items.Clear()
    $GuiBlobs = @()
    foreach ($Item in $Global:AzOSDCloudBlobImage | Where-Object {$_.BlobClient.BlobContainerName -eq $formMainWindowControlContainerCombobox.SelectedValue}) {
        $GuiBlobs += $Item.BlobClient.Name
    }
    $GuiBlobs | ForEach-Object {
        $formMainWindowControlBlobCombobox.Items.Add($_) | Out-Null
    }
    $formMainWindowControlBlobCombobox.SelectedIndex = 0
})
#================================================
#   StartButton
#================================================
$formMainWindowControlStartButton.add_Click({

    if ($formMainWindowControlScreenshotCapture.IsChecked) {
        Start-ScreenPNGProcess -Directory "$env:TEMP\Screenshots"
        Start-Sleep -Seconds 3
    }

    $formMainWindow.Close()
    Show-PowershellWindow
    #================================================
    #   Set Selection
    #================================================
    $Global:AzOSDCloudAutopilotFile = $Global:AzOSDCloudBlobAutopilotFile | `
    Where-Object {$_.BlobClient.AccountName -eq $formMainWindowControlStorageAccountCombobox.SelectedValue} | `
    Where-Object {($_.BlobClient.BlobContainerName -like "provision*") -or ($_.BlobClient.BlobContainerName -eq $formMainWindowControlContainerCombobox.SelectedValue)} | `
    Select-Object -First 1

    $Global:AzOSDCloudImage = $Global:AzOSDCloudBlobImage | `
    Where-Object {$_.BlobClient.AccountName -eq $formMainWindowControlStorageAccountCombobox.SelectedValue} | `
    Where-Object {$_.BlobClient.BlobContainerName -eq $formMainWindowControlContainerCombobox.SelectedValue} | `
    Where-Object {$_.Name -eq $formMainWindowControlBlobCombobox.SelectedValue}
    $Global:AzOSDCloudImage | Select-Object * | Export-Clixml "$env:SystemDrive\AzOSDCloudImage.xml"
    $Global:AzOSDCloudImage | Select-Object * | ConvertTo-Json | Out-File "$env:SystemDrive\AzOSDCloudImage.json" -Encoding ascii -Width 2000 -Force

    $Global:AzOSDCloudPackage = $Global:AzOSDCloudBlobPackage | `
    Where-Object {$_.BlobClient.AccountName -eq $formMainWindowControlStorageAccountCombobox.SelectedValue} | `
    Where-Object {($_.BlobClient.BlobContainerName -like "provision*") -or ($_.BlobClient.BlobContainerName -eq $formMainWindowControlContainerCombobox.SelectedValue)}

    $Global:AzOSDCloudScript = $Global:AzOSDCloudBlobScript | `
    Where-Object {$_.BlobClient.AccountName -eq $formMainWindowControlStorageAccountCombobox.SelectedValue} | `
    Where-Object {($_.BlobClient.BlobContainerName -like "provision*") -or ($_.BlobClient.BlobContainerName -eq $formMainWindowControlContainerCombobox.SelectedValue)}
    #================================================
    #   Global Variables
    #================================================
    $Global:StartOSDCloud = $null
    $Global:StartOSDCloud = [ordered]@{
        AzOSDCloudBlobAutopilotFile = $Global:AzOSDCloudBlobAutopilotFile
        AzOSDCloudBlobDriverPack    = $Global:AzOSDCloudBlobDriverPack
        AzOSDCloudBlobImage         = $Global:AzOSDCloudBlobImage
        AzOSDCloudBlobPackage       = $Global:AzOSDCloudBlobPackage
        AzOSDCloudBlobScript        = $Global:AzOSDCloudBlobScript
        AzOSDCloudAutopilotFile     = $Global:AzOSDCloudAutopilotFile
        AzOSDCloudDriverPack        = $Global:AzOSDCloudBlobDriverPack
        AzOSDCloudImage             = $Global:AzOSDCloudImage
        AzOSDCloudPackage           = $Global:AzOSDCloudPackage
        AzOSDCloudScript            = $Global:AzOSDCloudScript
        DriverPackName              = $formMainWindowControlDriverPackCombobox.Text
        MSCatalogDiskDrivers        = $formMainWindowControlMSCatalogDiskDrivers.IsChecked
        MSCatalogNetDrivers         = $formMainWindowControlMSCatalogNetDrivers.IsChecked
        MSCatalogScsiDrivers        = $formMainWindowControlMSCatalogScsiDrivers.IsChecked
        MSCatalogFirmware           = $formMainWindowControlMSCatalogFirmware.IsChecked
        OSImageIndex                = $formMainWindowControlImageIndexCombobox.Text
        Restart                     = $formMainWindowControlRestart.IsChecked
        ScreenshotCapture           = $formMainWindowControlScreenshotCapture.IsChecked
        ZTI                         = $formMainWindowControlZTI.IsChecked
    }
    $Global:StartOSDCloud | Out-Host
    #Call Invoke-OSDCloud at this point
})
#================================================
#   Customizations
#================================================
[string]$ModuleVersion = Get-Module -Name OSD | Sort-Object -Property Version | Select-Object -ExpandProperty Version -Last 1
$formMainWindow.Title = "OSDCloudAzure $ModuleVersion on $(Get-MyComputerManufacturer -Brief) $(Get-MyComputerModel -Brief) $(Get-MyComputerProduct)"
#================================================
#   Branding
#================================================
if ($Global:OSDCloudGuiBranding) {
    #$formMainWindowControlBrandLabel.Content = $Global:OSDCloudGuiBranding.Title
    #$formMainWindowControlBrandLabel.Foreground = $Global:OSDCloudGuiBranding.Color
}
#================================================
#   Hide Windows
#================================================
Hide-CmdWindow
Hide-PowershellWindow
########################
## WIRE UP YOUR CONTROLS
########################
# simple example: $formMainWindowControlButton.Add_Click({ your code })
#
# example with BackgroundScriptBlock and UpdateElement
# $formmainControlButton.Add_Click({
#     $sb = {
#         $SyncClass.UpdateElement("formmainControlProgress","Value",25)
#     }
#     Start-BackgroundScriptBlock $sb
# })

############################
###### DISPLAY DIALOG ######
############################
[void]$formMainWindow.ShowDialog()
$Global:AzOSDCloudImage = @()

##########################
##### SCRIPT CLEANUP #####
##########################
$jobCleanup.Flag = $false #Stop Cleaning Jobs
$jobCleanup.PowerShell.Runspace.Close() #Close the runspace
$jobCleanup.PowerShell.Dispose() #Remove the runspace from memory