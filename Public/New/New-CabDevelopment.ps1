#Requires -Version 5
#Requires -RunAsAdministrator

#Version: 0.0.0.1

function New-CabDevelopment
{
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$True)]
		[string]$Path,
		[switch]$LZXHighCompression,
		[switch]$MakeCABsFromSubDirs
	)
	
	If ($LZXHighCompression) {
		$Compress = ".Set CompressionType=LZX"
	} Else { 
		$Compress = ".Set CompressionType=MSZIP"
	}
	
	If ($MakeCABsFromSubDirs) {
		Get-ChildItem -Directory -Path $Path | ForEach ($_) {
		PSMakeCAB $_.FullName }
	} Else {
		PSMakeCAB $Path
	}

}

function PSMakeCAB($Path)
{
	#Set the CAB File Name
	$CabFileName = (Get-Item $Path).Name
	$CabFileNameExt = (Get-Item $Path).Name + ".cab"
	
	#Set the Destination Directory
	$DestinationDir = (Get-Item $Path).Parent.FullName
	
	Write-Host "Creating " $DestinationDir\$CabFileNameExt
	
    $ddf = ";*** MakeCAB Directive file;
.OPTION EXPLICIT
.Set CabinetNameTemplate=$CabFileNameExt
.Set DiskDirectory1=$DestinationDir
.Set Cabinet=on
.Set Compress=on
$Compress
.Set CabinetFileCountThreshold=0
.Set FolderFileCountThreshold=0
.Set FolderSizeThreshold=0
.Set MaxCabinetSize=0
.Set MaxDiskFileCount=0
.Set MaxDiskSize=0
"
    $PathFullName = (Get-Item $Path).fullname
	#Remove Streams
	Get-ChildItem $PathFullName -Recurse | Unblock-File
    $ddfpath = ($DestinationDir+"\$CabFileName.ddf")
    $ddf += (ls -recurse $Path | ? {!$_.psiscontainer}|select -expand fullname|%{'"'+$_+'" "'+$_.SubString($PathFullName.length+1)+'"'}) -join "`r`n"
    $ddf
    $ddf | Out-File -encoding UTF8 $ddfpath
    makecab /F $ddfpath
    #rm $ddfpath
    #rm setup.inf
    #rm setup.rpt
}