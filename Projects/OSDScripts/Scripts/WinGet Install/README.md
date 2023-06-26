Applications require WinGet to be installed first.  You can test if you have WinGet installed by running this command in PowerShell

Get-Command WinGet

If that works, you are god to go.  If not, you may have to install Microsoft.DesktopAppInstaller in PowerShell using the following command

Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe -Verbose

WinGet has many options that can be run at the Command Line which you can access by running WinGet without any switches

PS C:\> winget
Windows Package Manager v1.4.11071
Copyright (c) Microsoft Corporation. All rights reserved.

The winget command line utility enables installing applications and other packages from the command line.

usage: winget  <command> <options>

The following commands are available:
  install    Installs the given package
  show       Shows information about a package
  source     Manage sources of packages
  search     Find and show basic info of packages
  list       Display installed packages
  upgrade    Shows and performs available upgrades
  uninstall  Uninstalls the given package
  hash       Helper to hash installer files
  validate   Validates a manifest file
  settings   Open settings or set administrator settings
  features   Shows the status of experimental features
  export     Exports a list of the installed packages
  import     Installs all the packages in a file

For more details on a specific command, pass it the help argument. -?

The following options are available:
  -v,--version              Display the version of the tool
  --info                    Display general info of the tool
  -?,--help                 Shows help about the selected command
  --wait                    Prompts the user to press any key before exiting
  --verbose,--verbose-logs  Enables verbose logging for WinGet
  --disable-interactivity   Disable interactive prompts

More help can be found at: https://aka.ms/winget-command-help
