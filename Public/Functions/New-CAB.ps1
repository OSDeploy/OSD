<#
.LINK
	https://www.osdeploy.com/
.SYNOPSIS
	Creates a CAB file from a Directory
.DESCRIPTION
	Creates a CAB file from a Directory
.PARAMETER SourceDirectory
	Directory to create the CAB from
.EXAMPLE
	New-CAB -SourceDirectory C:\DeploymentShare\OSDeploy\OSConfig
	Creates LZX High Compression CAB from of C:\DeploymentShare\OSDeploy\OSConfig
	Saves file in Parent Directory C:\DeploymentShare\OSDeploy\OSConfig.cab
.NOTES
	NAME:	New-CAB.ps1
	AUTHOR:	David Segura, david@segura.org
	BLOG:	http://www.osdeploy.com
	VERSION:	18.9.4
#>

function New-CAB
{
	[CmdletBinding()]
	Param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$SourceDirectory
	)
	BEGIN {}
    PROCESS {
		#=================================================
		Write-Verbose "Processing '$SourceDirectory' ..."
		#=================================================
		$ArchiveBaseName = (Get-Item $SourceDirectory).Name
		$ArchiveFileName = "$ArchiveBaseName.cab"
		$FolderFullName = (Get-Item $SourceDirectory).Fullname
		$DestinationFolder = (Get-Item $SourceDirectory).Parent.FullName
		$ArchiveFullName = Join-Path -Path $DestinationFolder -ChildPath $ArchiveFileName

		#=================================================
		Write-Verbose "Generating MakeCAB DDF ..."
		#=================================================
		$DirectiveString = [System.Text.StringBuilder]::new()
		[void]$DirectiveString.AppendLine(';*** MakeCAB Directive file;')
		[void]$DirectiveString.AppendLine('.OPTION EXPLICIT')
		[void]$DirectiveString.AppendLine(".Set CabinetNameTemplate=$ArchiveFileName")
		[void]$DirectiveString.AppendLine(".Set DiskDirectory1=$DestinationFolder")
		[void]$DirectiveString.AppendLine('.Set Cabinet=ON')
		[void]$DirectiveString.AppendLine('.Set Compress=ON')
		[void]$DirectiveString.AppendLine('.Set CompressionType=LZX')
		[void]$DirectiveString.AppendLine('.Set CabinetFileCountThreshold=0')
		[void]$DirectiveString.AppendLine('.Set FolderFileCountThreshold=0')
		[void]$DirectiveString.AppendLine('.Set FolderSizeThreshold=0')
		[void]$DirectiveString.AppendLine('.Set MaxCabinetSize=0')
		[void]$DirectiveString.AppendLine('.Set MaxDiskFileCount=0')
		[void]$DirectiveString.AppendLine('.Set MaxDiskSize=0')

		#=================================================
		Write-Verbose "Unblocking Files ..."
		#=================================================
		Get-ChildItem $FolderFullName -Recurse | Unblock-File
		
		#=================================================
		Write-Verbose "Adding DDF Content ..."
		#=================================================
		$DirectivePath = Join-Path -Path $DestinationFolder -ChildPath "$ArchiveBaseName.ddf"
		Get-ChildItem -Recurse $SourceDirectory | Where-Object { -Not($_.psiscontainer)} | Select-Object -ExpandProperty Fullname | Foreach-Object {
			[void]$DirectiveString.AppendLine("""$_"" ""$($_.SubString($FolderFullName.Length + 1))""")
		}
		
		#=================================================
		Write-Verbose "Compressing '$FolderFullName' to '$ArchiveFullName' ..."
		#=================================================
		$DirectiveString.ToString() | Out-File -FilePath $DirectivePath -Encoding UTF8 -Width 2000 -Force
		makecab /F $DirectivePath
    }
    END {
		#=================================================
		Write-Verbose "Complete"
		#=================================================
	}
}