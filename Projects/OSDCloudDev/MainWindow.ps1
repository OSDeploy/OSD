# PoSHPF - Version 1.2
# Grab all resources (MahApps, etc), all XAML files, and any potential static resources
$Global:resources = Get-ChildItem -Path "$PSScriptRoot\Resources\*.dll" -ErrorAction SilentlyContinue
$Global:XAML = Get-ChildItem -Path "$PSScriptRoot\*.xaml" | Where-Object {$_.Name -ne 'App.xaml'} -ErrorAction SilentlyContinue #Changed path and exclude App.xaml
$Global:MediaResources = Get-ChildItem -Path "$PSScriptRoot\Media" -ErrorAction SilentlyContinue

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
#   Manufacturer Enhacements
#================================================
<#   DISABLING VENDOR FEATURES UNTIL OFFLINE SOLUTION CREATED - 22.07.01 - GARY

function Test-HPIASupport {
    $CabPath = "$env:TEMP\platformList.cab"
    $XMLPath = "$env:TEMP\platformList.xml"
    $PlatformListCabURL = "https://hpia.hpcloud.hp.com/ref/platformList.cab"
    Invoke-WebRequest -Uri $PlatformListCabURL -OutFile $CabPath -UseBasicParsing
    $Expand = expand $CabPath $XMLPath
    [xml]$XML = Get-Content $XMLPath
    $Platforms = $XML.ImagePal.Platform.SystemID
    $MachinePlatform = (Get-CimInstance -Namespace root/cimv2 -ClassName Win32_BaseBoard).Product
    if ($MachinePlatform -in $Platforms){$HPIASupport = $true}
    else {$HPIASupport = $false}
    return $HPIASupport
    }

function Test-DCUSupport {
    $SystemSKUNumber = (Get-CimInstance -ClassName Win32_ComputerSystem).SystemSKUNumber
    $CabPathIndex = "$env:temp\DellCabDownloads\CatalogIndexPC.cab"
    $DellCabExtractPath = "$env:temp\DellCabDownloads\DellCabExtract"
    # Pull down Dell XML CAB used in Dell Command Update ,extract and Load
    if (!(Test-Path $DellCabExtractPath)){$newfolder = New-Item -Path $DellCabExtractPath -ItemType Directory -Force}
    Invoke-WebRequest -Uri "https://downloads.dell.com/catalog/CatalogIndexPC.cab" -OutFile $CabPathIndex -UseBasicParsing -ErrorAction SilentlyContinue
    New-Item -Path $DellCabExtractPath -ItemType Directory -Force | Out-Null
    $Expand = expand $CabPathIndex $DellCabExtractPath\CatalogIndexPC.xml
    [xml]$XMLIndex = Get-Content "$DellCabExtractPath\CatalogIndexPC.xml" -ErrorAction SilentlyContinue
    #Dig Through Dell XML to find Model of THIS Computer (Based on System SKU)
    $XMLModel = $XMLIndex.ManifestIndex.GroupManifest | Where-Object {$_.SupportedSystems.Brand.Model.systemID -match $SystemSKUNumber}
    if ($XMLModel){$DCUSupportedDevice = $true}
    else {$DCUSupportedDevice = $false}
    Return $DCUSupportedDevice
    }

$Manufacturer = (Get-CimInstance -Class:Win32_ComputerSystem).Manufacturer
$Model = (Get-CimInstance -Class:Win32_ComputerSystem).Model
if ($Manufacturer -match "HP" -or $Manufacturer -match "Hewlett-Packard"){
    $Manufacturer = "HP"
    $HPEnterprise = Test-HPIASupport
    }
if ($Manufacturer -match "Dell"){
    $Manufacturer = "Dell"
    $DellEnterprise = Test-DCUSupport 
}    
if ($Manufacturer -match "Microsoft"){
    if ($Model -eq "Virtual Machine"){
        $HyperV = $true
    } 
}    

if ($HPEnterprise){
    $TPM = osdcloud-HPTPMDetermine
    $BIOS = osdcloud-HPBIOSDetermine
    $formMainWindowControlManufacturerFunction.Header = "HP Functions"
    $formMainWindowControlManufacturerFunction.Visibility = 'Visible'

    $formMainWindowControlOption_Name_1.Header = "HPIA Drivers - Adds approx 20 minutes"
    $formMainWindowControlOption_Name_1.IsChecked = $true 
    $formMainWindowControlOption_Name_2.Header = "HPIA Firmware - Adds approx 5 minutes"
    $formMainWindowControlOption_Name_2.IsChecked = $true 
    $formMainWindowControlOption_Name_3.Header = "HPIA Software - Adds approx 10 minutes"
    $formMainWindowControlOption_Name_3.IsChecked = $false 
    $formMainWindowControlOption_Name_4.Header = "HPIA All Options - Adds approx 25 minutes"
    $formMainWindowControlOption_Name_4.IsChecked = $false 
    if ($TPM -eq $false){
        $formMainWindowControlOption_Name_5.Header = "HP TPM Firmware Already Current"
        $formMainWindowControlOption_Name_5.IsEnabled = $false
        }
    else
        {
        $formMainWindowControlOption_Name_5.Visibility = 'Visible'
        $formMainWindowControlOption_Name_5.Header = "HP Update TPM Firmware: $TPM - Requires Interaction"
        }
    if ($BIOS -eq $false){
        $CurrentVer = Get-HPBIOSVersion
        $formMainWindowControlOption_Name_6.Header = "HP System Firmware already Current: $CurrentVer"
        $formMainWindowControlOption_Name_6.IsEnabled = $false
        }
    else
        {
        $LatestVer = (Get-HPBIOSUpdates -Latest).ver
        $CurrentVer = Get-HPBIOSVersion
        $formMainWindowControlOption_Name_6.Visibility = 'Visible'
        $formMainWindowControlOption_Name_6.Header = "HP Update System Firmwware from $CurrentVer to $LatestVer"
        }
    # When HPIA All is selected, unselect Firmware & Software
    
    #If HPIA All is selected, deselect other options
    $formMainWindowControlOption_Name_4.add_Checked({$formMainWindowControlOption_Name_1.IsChecked = $false})
    $formMainWindowControlOption_Name_4.add_Checked({$formMainWindowControlOption_Name_2.IsChecked = $false})
    $formMainWindowControlOption_Name_4.add_Checked({$formMainWindowControlOption_Name_3.IsChecked = $false})
    #If other options are selected, make sure HPIAAll is NOT selected
    $formMainWindowControlOption_Name_1.add_Checked({$formMainWindowControlOption_Name_4.IsChecked = $false})
    $formMainWindowControlOption_Name_2.add_Checked({$formMainWindowControlOption_Name_4.IsChecked = $false})
    $formMainWindowControlOption_Name_3.add_Checked({$formMainWindowControlOption_Name_4.IsChecked = $false})

    }

elseif ($DellEnterprise){
    $formMainWindowControlManufacturerFunction.Header = "Dell Functions"
    $formMainWindowControlManufacturerFunction.Visibility = 'Visible'

    $formMainWindowControlOption_Name_1.Header = "Dell Command Update"
    $formMainWindowControlOption_Name_1.IsChecked = $true 
    $formMainWindowControlOption_Name_2.Header = "DCU Drivers"
    $formMainWindowControlOption_Name_2.IsChecked = $false
    $formMainWindowControlOption_Name_3.Header = "DCU Firmware"
    $formMainWindowControlOption_Name_3.IsChecked = $false
    $formMainWindowControlOption_Name_4.Header = "DCU BIOS"
    $formMainWindowControlOption_Name_4.IsChecked = $false
    $formMainWindowControlOption_Name_5.Header = "DCU Enable Auto Updates"
    $formMainWindowControlOption_Name_5.IsChecked = $false
    $formMainWindowControlOption_Name_6.Header = "Dell TPM Update"
    $formMainWindowControlOption_Name_6.IsChecked = $false
    $formMainWindowControlOption_Name_6.Visibility = "Hidden"

    $formMainWindowControlOption_Name_2.add_Checked({$formMainWindowControlOption_Name_1.IsChecked = $true})
    $formMainWindowControlOption_Name_3.add_Checked({$formMainWindowControlOption_Name_1.IsChecked = $true})
    $formMainWindowControlOption_Name_4.add_Checked({$formMainWindowControlOption_Name_1.IsChecked = $true})
    $formMainWindowControlOption_Name_5.add_Checked({$formMainWindowControlOption_Name_1.IsChecked = $true})

}

elseif ($HyperV){
    $formMainWindowControlManufacturerFunction.Header = "HyperV Functions"
    $formMainWindowControlManufacturerFunction.Visibility = 'Visible'    
    $formMainWindowControlOption_Name_1.Header = "Set PC Name to HyperV VM Name"
    $formMainWindowControlOption_Name_1.IsChecked = $true
    $formMainWindowControlOption_Name_2.Header = "Eject CD ISO"
    $formMainWindowControlOption_Name_2.IsChecked = $true
    $formMainWindowControlOption_Name_3.Visibility = "Hidden"
    $formMainWindowControlOption_Name_4.Visibility = "Hidden"
    $formMainWindowControlOption_Name_5.Visibility = "Hidden"
    $formMainWindowControlOption_Name_6.Visibility = "Hidden"
}
else{
    $formMainWindowControlManufacturerFunction.Visibility = 'Hidden'
    $formMainWindowControlManufacturerFunction.IsEnabled = $false
    $formMainWindowControlOption_Name_1.IsChecked = $false
    #$formMainWindowControlOption_Name_1.IsEnabled = $false 
    #$formMainWindowControlOption_Name_1.Visibility = "Hidden"
    $formMainWindowControlOption_Name_2.IsChecked = $false
    #$formMainWindowControlOption_Name_2.IsEnabled = $false 
    #$formMainWindowControlOption_Name_2.Visibility = "Hidden"
    $formMainWindowControlOption_Name_3.IsChecked = $false
    #$formMainWindowControlOption_Name_3.IsEnabled = $false 
    #$formMainWindowControlOption_Name_3.Visibility = "Hidden"
    $formMainWindowControlOption_Name_4.IsChecked = $false
    #$formMainWindowControlOption_Name_4.IsEnabled = $false 
    #$formMainWindowControlOption_Name_4.Visibility = "Hidden"
    $formMainWindowControlOption_Name_5.IsChecked = $false
    #$formMainWindowControlOption_Name_5.IsEnabled = $false 
    #$formMainWindowControlOption_Name_5.Visibility = "Hidden"
    $formMainWindowControlOption_Name_6.IsChecked = $false
    #$formMainWindowControlOption_Name_6.IsEnabled = $false 
    #$formMainWindowControlOption_Name_6.Visibility = "Hidden"
}
#>
#Disabling Vendor Features for now.
$formMainWindowControlManufacturerFunction.Visibility = 'Hidden'
$formMainWindowControlManufacturerFunction.IsEnabled = $false
$formMainWindowControlWindowsDefenderUpdate.Visibility = 'Hidden'
$formMainWindowControlWindowsDefenderUpdate.IsEnabled = $false
#================================================
#   Menu Options
#================================================
$formMainWindowControlcaptureScreenshots.IsChecked = $Global:OSDCloudGUI.captureScreenshots
$formMainWindowControlClearDiskConfirm.IsChecked = $Global:OSDCloudGUI.ClearDiskConfirm
$formMainWindowControlrestartComputer.IsChecked = $Global:OSDCloudGUI.restartComputer
$formMainWindowControlupdateDiskDrivers.IsChecked = $Global:OSDCloudGUI.updateDiskDrivers
$formMainWindowControlupdateFirmware.IsChecked = $Global:OSDCloudGUI.updateFirmware
$formMainWindowControlupdateNetworkDrivers.IsChecked = $Global:OSDCloudGUI.updateNetworkDrivers
$formMainWindowControlupdateSCSIDrivers.IsChecked = $Global:OSDCloudGUI.updateSCSIDrivers
#================================================
#   OS Name Combobox
#================================================
$Global:OSDCloudGUI.OSNameValues | ForEach-Object {
    $formMainWindowControlOSNameCombobox.Items.Add($_) | Out-Null
}
$formMainWindowControlOSNameCombobox.SelectedValue = $Global:OSDCloudGUI.OSName
#================================================
#   OS Edition Combobox
#================================================
$Global:OSDCloudGUI.OSEditionValues | ForEach-Object {
    $formMainWindowControlOSEditionCombobox.Items.Add($_) | Out-Null
}
#================================================
#   OS Language Combobox
#================================================
$Global:OSDCloudGUI.OSLanguageValues | ForEach-Object {
    $formMainWindowControlOSLanguageCombobox.Items.Add($_) | Out-Null
}
#================================================
#   OS Activation Combobox
#================================================
$Global:OSDCloudGUI.OSActivationValues | ForEach-Object {
    $formMainWindowControlOSActivationCombobox.Items.Add($_) | Out-Null
}
#================================================
#   DriverPack
#================================================
$Global:OSDCloudGUI.DriverPacks | ForEach-Object {
    $formMainWindowControlDriverPackCombobox.Items.Add($_.Name) | Out-Null
}
if ($Global:OSDCloudGUI.DriverPackName) {
    $formMainWindowControlDriverPackCombobox.SelectedValue = $Global:OSDCloudGUI.DriverPackName
}
#================================================
#   Set-OSDCloudGUIDefaultOptions
#================================================
function Set-OSDCloudGUIDefaultOptions {
    $formMainWindowControlOSEditionCombobox.IsEnabled = $true
    $formMainWindowControlOSEditionCombobox.Visibility = "Visible"
    $formMainWindowControlOSEditionCombobox.SelectedValue = $Global:OSDCloudGUI.OSEdition

    $formMainWindowControlOSLanguageCombobox.IsEnabled = $true
    $formMainWindowControlOSLanguageCombobox.Visibility = "Visible"
    $formMainWindowControlOSLanguageCombobox.SelectedValue = $Global:OSDCloudGUI.OSLanguage

    $formMainWindowControlOSActivationCombobox.IsEnabled = $false
    $formMainWindowControlOSActivationCombobox.Visibility = "Visible"
    $formMainWindowControlOSActivationCombobox.SelectedValue = $Global:OSDCloudGUI.OSActivation

    $formMainWindowControlImageNameCombobox.Items.Clear()
    $formMainWindowControlImageNameCombobox.Visibility = "Collapsed"

    $formMainWindowControlImageIndexTextbox.Text = $Global:OSDCloudGUI.OSImageIndex
    $formMainWindowControlImageIndexTextbox.IsEnabled = $false

    $formMainWindowControlAutopilotJsonCombobox.IsEnabled = $true
    $formMainWindowControlAutopilotJsonCombobox.SelectedIndex = 1   #OOBE
}
Set-OSDCloudGUIDefaultOptions
#================================================
#   CustomImage
#================================================
[array]$OSDCloudOSIso = @()
[array]$OSDCloudOSIso = Find-OSDCloudFile -Name '*.iso' -Path '\OSDCloud\OS\' | Where-Object {$_.Length -gt 3GB}

foreach ($Item in $OSDCloudOSIso) {
    if ((Get-DiskImage -ImagePath $Item.FullName).Attached) {
        #ISO is already mounted
    }
    else {
        Write-Host "Mounting OSDCloud OS ISO $($Item.FullName)" -ForegroundColor Cyan
        $Results = Mount-DiskImage -ImagePath $Item.FullName
        $Results | Select-Object -Property Attached,DevicePath,ImagePath,Number,Size | Format-List
    }
}

$CustomImageChildItem = @()
[array]$CustomImageChildItem = Find-OSDCloudFile -Name '*.wim' -Path '\OSDCloud\OS\'
[array]$CustomImageChildItem += Find-OSDCloudFile -Name 'install.wim' -Path '\Sources\'
$CustomImageChildItem = $CustomImageChildItem | Sort-Object -Property Length -Unique | Sort-Object FullName | Where-Object {$_.Length -gt 3GB}
        
if ($CustomImageChildItem) {
    $CustomImageChildItem | ForEach-Object {
        $formMainWindowControlOSNameCombobox.Items.Add($_) | Out-Null
    }
}
#================================================
#   AutopilotJsonCombobox
#================================================
$formMainWindowControlAutopilotJsonCombobox.IsEnabled = $false
$AutopilotJsonChildItem = @()
[array]$AutopilotJsonChildItem = Find-OSDCloudFile -Name "*.json" -Path '\OSDCloud\Autopilot\Profiles\' | Sort-Object FullName
[array]$AutopilotJsonChildItem += Find-OSDCloudFile -Name "*.json" -Path '\OSDCloud\Config\AutopilotJSON\' | Sort-Object FullName
$AutopilotJsonChildItem = $AutopilotJsonChildItem | Where-Object {$_.FullName -notlike "C*"}
if ($AutopilotJsonChildItem) {
    $formMainWindowControlAutopilotJsonCombobox.Items.Add('') | Out-Null
    $formMainWindowControlAutopilotJsonCombobox.IsEnabled = $true
    $AutopilotJsonChildItem | ForEach-Object {
        $formMainWindowControlAutopilotJsonCombobox.Items.Add($_) | Out-Null
    }
    $formMainWindowControlAutopilotJsonCombobox.SelectedIndex = 1
}
else {
    $formMainWindowControlAutopilotJsonLabel.Visibility = "Collapsed" 
    $formMainWindowControlAutopilotJsonCombobox.Visibility = "Collapsed"  
}
#================================================
#   OOBEDeployCombobox
#================================================
$formMainWindowControlOOBEDeployCombobox.IsEnabled = $false
$OOBEDeployJsonChildItem = Find-OSDCloudFile -Name "*.json" -Path '\OSDCloud\Config\OOBEDeploy\' | Sort-Object FullName
$OOBEDeployJsonChildItem = $OOBEDeployJsonChildItem | Where-Object {$_.FullName -notlike "C*"}
if ($OOBEDeployJsonChildItem) {
    $formMainWindowControlOOBEDeployCombobox.Items.Add('') | Out-Null
    $formMainWindowControlOOBEDeployCombobox.IsEnabled = $true
    $OOBEDeployJsonChildItem | ForEach-Object {
        $formMainWindowControlOOBEDeployCombobox.Items.Add($_) | Out-Null
    }
    $formMainWindowControlOOBEDeployCombobox.SelectedIndex = 1
}
else {
    $formMainWindowControlOOBEDeployLabel.Visibility = "Collapsed"  
    $formMainWindowControlOOBEDeployCombobox.Visibility = "Collapsed"  
}
#================================================
#   AutopilotOOBECombobox
#================================================
$formMainWindowControlAutopilotOOBECombobox.IsEnabled = $false
$AutopilotOOBEJsonChildItem = Find-OSDCloudFile -Name "*.json" -Path '\OSDCloud\Config\AutopilotOOBE\' | Sort-Object FullName
$AutopilotOOBEJsonChildItem = $AutopilotOOBEJsonChildItem | Where-Object {$_.FullName -notlike "C*"}
if ($AutopilotOOBEJsonChildItem) {
    $formMainWindowControlAutopilotOOBECombobox.Items.Add('') | Out-Null
    $formMainWindowControlAutopilotOOBECombobox.IsEnabled = $true
    $AutopilotOOBEJsonChildItem | ForEach-Object {
        $formMainWindowControlAutopilotOOBECombobox.Items.Add($_) | Out-Null
    }
    $formMainWindowControlAutopilotOOBECombobox.SelectedIndex = 1
}
else {
    $formMainWindowControlAutopilotOOBELabel.Visibility = "Collapsed"  
    $formMainWindowControlAutopilotOOBECombobox.Visibility = "Collapsed"  
}
#================================================
#   OS Edition Combobox to ImageIndex
#================================================
$formMainWindowControlOSEditionCombobox.add_SelectionChanged({

    if ($formMainWindowControlOSEditionCombobox.SelectedValue -eq 'Home') {
        #Retail edition only and disable Activation combobox
        $formMainWindowControlOSActivationCombobox.SelectedValue = 'Retail'
        $formMainWindowControlOSActivationCombobox.IsEnabled = $false

        $formMainWindowControlImageIndexLabel.IsEnabled = $false

        $formMainWindowControlImageIndexTextbox.Text = 4
        $formMainWindowControlImageIndexTextbox.IsEnabled = $false
    }
    elseif ($formMainWindowControlOSEditionCombobox.SelectedValue -eq 'Home N') {
        #Retail edition only and disable Activation combobox
        $formMainWindowControlOSActivationCombobox.SelectedValue = 'Retail'
        $formMainWindowControlOSActivationCombobox.IsEnabled = $false

        $formMainWindowControlImageIndexLabel.IsEnabled = $false

        $formMainWindowControlImageIndexTextbox.Text = 5
        $formMainWindowControlImageIndexTextbox.IsEnabled = $false
    }
    elseif ($formMainWindowControlOSEditionCombobox.SelectedValue -eq 'Home Single Language') {
        #Retail edition only and disable Activation combobox
        $formMainWindowControlOSActivationCombobox.SelectedValue = 'Retail'
        $formMainWindowControlOSActivationCombobox.IsEnabled = $false

        $formMainWindowControlImageIndexLabel.IsEnabled = $false

        $formMainWindowControlImageIndexTextbox.Text = 6
        $formMainWindowControlImageIndexTextbox.IsEnabled = $false
    }
    elseif ($formMainWindowControlOSEditionCombobox.SelectedValue -eq 'Education') {
        $formMainWindowControlOSActivationCombobox.IsEnabled = $true
        if ($formMainWindowControlOSActivationCombobox.SelectedValue -eq 'Retail') {
            $formMainWindowControlImageIndexTextbox.Text = 7
        }
        else {
            $formMainWindowControlImageIndexTextbox.Text = 4
        }
    }
    elseif ($formMainWindowControlOSEditionCombobox.SelectedValue -eq 'Education N') {
        $formMainWindowControlOSActivationCombobox.IsEnabled = $true
        if ($formMainWindowControlOSActivationCombobox.SelectedValue -eq 'Retail') {
            $formMainWindowControlImageIndexTextbox.Text = 8
        }
        else {
            $formMainWindowControlImageIndexTextbox.Text = 5
        }
    }
    elseif ($formMainWindowControlOSEditionCombobox.SelectedValue -eq 'Enterprise') {
        $formMainWindowControlOSActivationCombobox.SelectedValue = 'Volume'
        $formMainWindowControlOSActivationCombobox.IsEnabled = $false
        $formMainWindowControlImageIndexTextbox.Text = 6
    }
    elseif ($formMainWindowControlOSEditionCombobox.SelectedValue -eq 'Enterprise N') {
        $formMainWindowControlOSActivationCombobox.SelectedValue = 'Volume'
        $formMainWindowControlOSActivationCombobox.IsEnabled = $false
        $formMainWindowControlImageIndexTextbox.Text = 7
    }
    elseif ($formMainWindowControlOSEditionCombobox.SelectedValue -eq 'Pro') {
        $formMainWindowControlOSActivationCombobox.IsEnabled = $true
        if ($formMainWindowControlOSActivationCombobox.SelectedValue -eq 'Retail') {
            $formMainWindowControlImageIndexTextbox.Text = 9
        }
        else {
            $formMainWindowControlImageIndexTextbox.Text = 8
        }
    }
    elseif ($formMainWindowControlOSEditionCombobox.SelectedValue -eq 'Pro N') {
        $formMainWindowControlOSActivationCombobox.IsEnabled = $true
        if ($formMainWindowControlOSActivationCombobox.SelectedValue -eq 'Retail') {
            $formMainWindowControlImageIndexTextbox.Text = 10
        }
        else {
            $formMainWindowControlImageIndexTextbox.Text = 9
        }
    }
})
#================================================
#   OS Activation Combobox
#================================================
$formMainWindowControlOSActivationCombobox.add_SelectionChanged({
    if ($formMainWindowControlOSActivationCombobox.SelectedValue -eq 'Retail') {
        if ($formMainWindowControlOSEditionCombobox.SelectedValue -eq 'Education') {$formMainWindowControlImageIndexTextbox.Text = 7}
        if ($formMainWindowControlOSEditionCombobox.SelectedValue -eq 'Education N') {$formMainWindowControlImageIndexTextbox.Text = 8}
        if ($formMainWindowControlOSEditionCombobox.SelectedValue -eq 'Pro') {$formMainWindowControlImageIndexTextbox.Text = 9}
        if ($formMainWindowControlOSEditionCombobox.SelectedValue -eq 'Pro N') {$formMainWindowControlImageIndexTextbox.Text = 10}
    }
    if ($formMainWindowControlOSActivationCombobox.SelectedValue -eq 'Volume') {
        if ($formMainWindowControlOSEditionCombobox.SelectedValue -eq 'Education') {$formMainWindowControlImageIndexTextbox.Text = 4}
        if ($formMainWindowControlOSEditionCombobox.SelectedValue -eq 'Education N') {$formMainWindowControlImageIndexTextbox.Text = 5}
        if ($formMainWindowControlOSEditionCombobox.SelectedValue -eq 'Pro') {$formMainWindowControlImageIndexTextbox.Text = 8}
        if ($formMainWindowControlOSEditionCombobox.SelectedValue -eq 'Pro N') {$formMainWindowControlImageIndexTextbox.Text = 9}
    }
})
#================================================
#   OS Name Combobox
#================================================
$formMainWindowControlOSNameCombobox.add_SelectionChanged({
    if ($formMainWindowControlOSNameCombobox.SelectedValue -like 'Windows 1*') {
        Set-OSDCloudGUIDefaultOptions
    }
    else {
        $formMainWindowControlOSEditionCombobox.Visibility = "Collapsed"
        $formMainWindowControlOSLanguageCombobox.Visibility = "Collapsed"
        $formMainWindowControlOSActivationCombobox.Visibility = "Collapsed"
        $formMainWindowControlImageIndexTextbox.IsEnabled = $false
        $formMainWindowControlImageIndexTextbox.Text = 1

        $formMainWindowControlImageNameCombobox.Visibility = "Visible"
        $formMainWindowControlImageNameCombobox.Items.Clear()
        $formMainWindowControlImageNameCombobox.IsEnabled = $true
        $GetWindowsImageOptions = Get-WindowsImage -ImagePath $formMainWindowControlOSNameCombobox.SelectedValue
        $GetWindowsImageOptions | ForEach-Object {
            $formMainWindowControlImageNameCombobox.Items.Add($_.ImageName) | Out-Null
        }
        $formMainWindowControlImageNameCombobox.SelectedIndex = 0
    }
})
$formMainWindowControlImageNameCombobox.add_SelectionChanged({
    $formMainWindowControlImageIndexTextbox.Text = $formMainWindowControlImageNameCombobox.SelectedIndex + 1
    if ($formMainWindowControlImageIndexTextbox.Text -eq 0) {$formMainWindowControlImageIndexTextbox.Text = 1}
})
#================================================
#   StartButton
#================================================
$formMainWindowControlStartButton.add_Click({
    $formMainWindow.Close()
    Show-PowershellWindow
    #================================================
    #   AutopilotJson
    #================================================
    $AutopilotJsonName = $formMainWindowControlAutopilotJsonCombobox.SelectedValue
    if ($AutopilotJsonName) {
        $AutopilotJsonItem = $AutopilotJsonChildItem | Where-Object {$_.FullName -eq "$AutopilotJsonName"}
    }
    else {
        $SkipAutopilot = $true
        $AutopilotJsonName = $null
        $AutopilotJsonItem = $null
    }
    if ($AutopilotJsonItem) {
        $AutopilotJsonObject = Get-Content -Raw $AutopilotJsonItem.FullName | ConvertFrom-Json
        $SkipAutopilot = $false
    }
    else {
        $SkipAutopilot = $true
        $AutopilotJsonObject = $null
    }
    #================================================
    #   OOBEDeployJson
    #================================================
    $OOBEDeployJsonName = $formMainWindowControlOOBEDeployCombobox.SelectedValue
    if ($OOBEDeployJsonName) {
        $OOBEDeployJsonItem = $OOBEDeployJsonChildItem | Where-Object {$_.FullName -eq "$OOBEDeployJsonName"}
    }
    else {
        $SkipOOBEDeploy = $true
        $OOBEDeployJsonName = $null
        $OOBEDeployJsonItem = $null
    }
    if ($OOBEDeployJsonItem) {
        $OOBEDeployJsonObject = Get-Content -Raw $OOBEDeployJsonItem.FullName | ConvertFrom-Json
        $SkipOOBEDeploy = $false
    }
    else {
        $SkipOOBEDeploy = $true
        $OOBEDeployJsonObject = $null
    }
    #================================================
    #   AutopilotOOBEJson
    #================================================
    $AutopilotOOBEJsonName = $formMainWindowControlAutopilotOOBECombobox.SelectedValue
    if ($AutopilotOOBEJsonName) {
        $AutopilotOOBEJsonItem = $AutopilotOOBEJsonChildItem | Where-Object {$_.FullName -eq "$AutopilotOOBEJsonName"}
    }
    else {
        $SkipAutopilotOOBE = $true
        $AutopilotOOBEJsonName = $null
        $AutopilotOOBEJsonItem = $null
    }
    if ($AutopilotOOBEJsonItem) {
        $AutopilotOOBEJsonObject = Get-Content -Raw $AutopilotOOBEJsonItem.FullName | ConvertFrom-Json
        $SkipAutopilotOOBE = $false
    }
    else {
        $SkipAutopilotOOBE = $true
        $AutopilotOOBEJsonObject = $null
    }
    #================================================
    #   ImageFile
    #================================================
    $OSActivation = $formMainWindowControlOSActivationCombobox.SelectedValue
    $OSEdition = $formMainWindowControlOSEditionCombobox.SelectedValue
    $OSLanguage = $formMainWindowControlOSLanguageCombobox.SelectedValue
    $OSImageIndex = $formMainWindowControlImageIndexTextbox.Text

    if ($formMainWindowControlOSNameCombobox.SelectedValue -like 'Windows 1*') {
        $OSName = $formMainWindowControlOSNameCombobox.SelectedValue
        
        $OSDCloudOperatingSystem = Get-OSDCloudOperatingSystems | Where-Object {$_.Name -match $OSName} | Where-Object {$_.Activation -eq $OSActivation} | Where-Object {$_.Language -eq $OSLanguage}
        $OSBuild = $OSDCloudOperatingSystem.Build
        $OSReleaseID = $OSDCloudOperatingSystem.ReleaseID
        $OSVersion = $OSDCloudOperatingSystem.Version
        
        $ImageFileName = $OSDCloudOperatingSystem.FileName
        $ImageFileUrl = $OSDCloudOperatingSystem.Url

        $ImageFileItem = Find-OSDCloudFile -Name $OSDCloudOperatingSystem.FileName -Path '\OSDCloud\OS\' | Sort-Object FullName | Where-Object {$_.Length -gt 3GB}
        $ImageFileItem = $ImageFileItem | Where-Object {$_.FullName -notlike "C*"} | Where-Object {$_.FullName -notlike "X*"} | Select-Object -First 1

    }
    else {
        $OSName = $null
        $ImageFileFullName = $formMainWindowControlOSNameCombobox.SelectedValue
        if ($ImageFileFullName) {
            $ImageFileItem = $CustomImageChildItem | Where-Object {$_.FullName -eq "$ImageFileFullName"}
            $ImageFileName = Split-Path -Path $ImageFileItem.FullName -Leaf

            $OSActivation = $null
            $OSBuild = $null
            $OSEdition = $null
            $OSLanguage = $null
            $OSReleaseID = $null
            $OSVersion = $null
        }
        else {
            $ImageFileItem = $null
            $ImageFileFullName = $null
            $ImageFileName = $null
        }
    }
    #================================================
    #   DriverPack
    #================================================
    if ($formMainWindowControlDriverPackCombobox.Text) {
        $DriverPackName = $formMainWindowControlDriverPackCombobox.Text
        $DriverPack = $Global:OSDCloudGUI.DriverPacks | Where-Object {$_.Name -eq $DriverPackName}
    }
    #================================================
    #   Global Variables
    #================================================
    $Global:InvokeOSDCloud = $null
    $Global:InvokeOSDCloud = [ordered]@{
        Function                    = [System.String]'Start-OSDCloudGUI'
        LaunchMethod                = [System.String]$Global:OSDCloudGUI.LaunchMethod
        BrandName                   = [System.String]$Global:OSDCloudGUI.BrandName
        BrandColor                  = [System.String]$Global:OSDCloudGUI.BrandColor
        ComputerManufacturer        = [System.String]$Global:OSDCloudGUI.ComputerManufacturer
        ComputerModel               = [System.String]$Global:OSDCloudGUI.ComputerModel
        ComputerProduct             = [System.String]$Global:OSDCloudGUI.ComputerProduct
        DriverPack                  = [System.Object]$DriverPack
        DriverPacks                 = [array]$Global:OSDCloudGUI.DriverPacks
        DriverPackName              = [System.String]$DriverPackName
        IsOnBattery                 = [System.Boolean]$Global:OSDCloudGUI.IsOnBattery
        OSActivation                = [System.String]$OSActivation
        OSBuild                     = [System.String]$OSBuild
        OSEdition                   = [System.String]$OSEdition
        OSImageIndex                = [System.Int32]$OSImageIndex
        OSLanguage                  = [System.String]$OSLanguage
        OSName                      = [System.String]$OSName
        OSReleaseID                 = [System.String]$OSReleaseID
        OSVersion                   = [System.String]$OSVersion
        OSActivationValues          = [array]$Global:OSDCloudGUI.OSActivationValues
        OSEditionValues             = [array]$Global:OSDCloudGUI.OSEditionValues
        OSLanguageValues            = [array]$Global:OSDCloudGUI.OSLanguageValues
        OSNameValues                = [array]$Global:OSDCloudGUI.OSNameValues
        OSReleaseIDValues           = [array]$Global:OSDCloudGUI.OSReleaseIDValues
        OSVersionValues             = [array]$Global:OSDCloudGUI.OSVersionValues
        captureScreenshots          = [System.Boolean]$formMainWindowControlScreenshotCapture.IsChecked
        ClearDiskConfirm            = [System.Boolean]$formMainWindowControlClearDiskConfirm.IsChecked
        restartComputer             = [System.Boolean]$formMainWindowControlRestartComputer.IsChecked
        updateDiskDrivers           = [System.Boolean]$formMainWindowControlupdateDiskDrivers.IsChecked
        updateFirmware              = [System.Boolean]$formMainWindowControlupdateFirmware.IsChecked
        updateNetworkDrivers        = [System.Boolean]$formMainWindowControlupdateNetworkDrivers.IsChecked
        updateSCSIDrivers           = [System.Boolean]$formMainWindowControlupdateSCSIDrivers.IsChecked
        AutopilotJsonChildItem      = $AutopilotJsonChildItem
        AutopilotJsonItem           = $AutopilotJsonItem
        AutopilotJsonName           = $AutopilotJsonName
        AutopilotJsonObject         = $AutopilotJsonObject
        AutopilotOOBEJsonChildItem  = $AutopilotOOBEJsonChildItem
        AutopilotOOBEJsonItem       = $AutopilotOOBEJsonItem
        AutopilotOOBEJsonName       = $AutopilotOOBEJsonName
        AutopilotOOBEJsonObject     = $AutopilotOOBEJsonObject
        ImageFileDestination        = $null
        ImageFileFullName           = $ImageFileFullName
        ImageFileItem               = $ImageFileItem
        ImageFileName               = $ImageFileName
        ImageFileSource             = $null
        ImageFileUrl                = $ImageFileUrl
        OOBEDeployJsonChildItem     = $OOBEDeployJsonChildItem
        OOBEDeployJsonItem          = $OOBEDeployJsonItem
        OOBEDeployJsonName          = $OOBEDeployJsonName
        OOBEDeployJsonObject        = $OOBEDeployJsonObject
        SkipAutopilot               = $SkipAutopilot
        SkipAutopilotOOBE           = $SkipAutopilotOOBE
        SkipODT                     = $true
        SkipOOBEDeploy              = $SkipOOBEDeploy
        WindowsDefenderUpdate       = $formMainWindowControlWindowsDefenderUpdate.IsChecked
    }
    #-----------------------------------------
    # Manufacturer Enhancements - START
    #-----------------------------------------
    if ($HPEnterprise){
        $Global:InvokeOSDCloud.HPIADrivers = $formMainWindowControlOption_Name_1.IsChecked
        $Global:InvokeOSDCloud.HPIAFirmware = $formMainWindowControlOption_Name_2.IsChecked
        $Global:InvokeOSDCloud.HPIASoftware = $formMainWindowControlOption_Name_3.IsChecked
        $Global:InvokeOSDCloud.HPIAAll = $formMainWindowControlOption_Name_4.IsChecked
        $Global:InvokeOSDCloud.HPTPMUpdate = $formMainWindowControlOption_Name_5.IsChecked
        $Global:InvokeOSDCloud.HPBIOSUpdate = $formMainWindowControlOption_Name_6.IsChecked
    }
    if ($DellEnterprise){
        $Global:InvokeOSDCloud.DCUInstall = $formMainWindowControlOption_Name_1.IsChecked
        $Global:InvokeOSDCloud.DCUDrivers = $formMainWindowControlOption_Name_2.IsChecked
        $Global:InvokeOSDCloud.DCUFirmware = $formMainWindowControlOption_Name_3.IsChecked
        $Global:InvokeOSDCloud.DCUBIOS = $formMainWindowControlOption_Name_4.IsChecked
        $Global:InvokeOSDCloud.DCUAutoUpdateEnable = $formMainWindowControlOption_Name_5.IsChecked
        $Global:InvokeOSDCloud.DellTPMUpdate = $formMainWindowControlOption_Name_6.IsChecked
    }
    if ($HyperV){
        $Global:InvokeOSDCloud.HyperVSetName = $formMainWindowControlOption_Name_1.IsChecked
        $Global:InvokeOSDCloud.HyperVEjectISO = $formMainWindowControlOption_Name_2.IsChecked
    }
    <#
    #$Global:InvokeOSDCloud | Out-Host
    if ($formMainWindowControlDebugCheckBox.IsChecked -eq $true){
        Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/debugmode.psm1')
        osdcloud-addcmtrace
        #$Global:InvokeOSDCloud.restart = $false
        #$Global:InvokeOSDCloud.ClearDiskConfirm = $false
    }
    #>
    #-----------------------------------------
    # Manufacturer Enhancements - END
    #-----------------------------------------
    if ($formMainWindowControlScreenshotCapture.IsChecked) {
        $Params = @{
            Screenshot = $true
        }
        #Start-OSDCloud @Params
    }
    else {
        #Start-OSDCloud
    }
    #=================================================
    #   Invoke-OSDCloud.ps1
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Green "Invoke-OSDCloud Configuration"
    $Global:InvokeOSDCloud | Out-Host
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Green "Invoke-OSDCloud ... Starting in 5 seconds..."
    Start-Sleep -Seconds 5
    Invoke-OSDCloud
    #=================================================
})
#================================================
#   Customizations
#================================================
[string]$ModuleVersion = Get-Module -Name OSD | Sort-Object -Property Version | Select-Object -ExpandProperty Version -Last 1
$formMainWindow.Title = "OSDCloudGUI $ModuleVersion on $($Global:OSDCloudGUI.ComputerManufacturer) $($Global:OSDCloudGUI.ComputerModel) product $($Global:OSDCloudGUI.ComputerProduct)"
#================================================
#   Branding
#================================================
if ($Global:OSDCloudGuiBranding) {
    $formMainWindowControlBrandingTitleControl.Content = $Global:OSDCloudGuiBranding.Title
    $formMainWindowControlBrandingTitleControl.Foreground = $Global:OSDCloudGuiBranding.Color
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

##########################
##### SCRIPT CLEANUP #####
##########################
$jobCleanup.Flag = $false #Stop Cleaning Jobs
$jobCleanup.PowerShell.Runspace.Close() #Close the runspace
$jobCleanup.PowerShell.Dispose() #Remove the runspace from memory