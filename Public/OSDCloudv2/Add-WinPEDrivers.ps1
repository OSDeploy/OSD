function Add-WinPEDrivers {
    <#
    .SYNOPSIS
        Adds the WinPEDrivers repository in the OSDCache at $env:ProgramData\OSDCache from the GitHub Origin.

    .DESCRIPTION
        Adds the WinPEDrivers repository in the OSDCache at $env:ProgramData\OSDCache from the GitHub Origin.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param ()

    begin {
        #=================================================
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))] $($MyInvocation.MyCommand)"
        #=================================================
        #region Update Windows Environment
        if (-NOT (Get-Command 'git' -ErrorAction SilentlyContinue)) {
            $locations = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'HKCU:\Environment'
            $locations | ForEach-Object {   
                $k = Get-Item $_
                $k.GetValueNames() | ForEach-Object {
                    $name = $_
                    $value = $k.GetValue($_)
                    Set-Item -Path Env:\$name -Value $value
                }
            }
        }
        #endregion
        #=================================================
        #region Require Git for Windows
        if (-NOT (Get-Command 'git' -ErrorAction SilentlyContinue)) {
            Write-Error -Message 'Git for Windows is not installed.  Use the following command to install Git for Windows:'
            Write-Output 'winget install -e --id Git.Git'
            break
        }
        #endregion
        #=================================================
    }

    process {
        #=================================================
        #region Get InputObject
        $InputObject = (Get-Content -Raw -Path "$($MyInvocation.MyCommand.Module.ModuleBase)\Cache\WinPEDriversRepos.json" | ConvertFrom-Json)
        #endregion
        #=================================================
        #region Process foreach
        foreach ($Repository in $InputObject) {
            Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))] Repository Name: $($Repository.name)"
            Write-Verbose "description: $($Repository.description)"

            $Source = $Repository.clone_url
            Write-Verbose "clone_url: $Source"
            # TODO Test the Clone URL
            
            $Destination = Join-Path -Path $(Get-OSDCachePath) -ChildPath $($Repository.name)
            Write-Verbose "Destination: $Destination"

            if (Test-Path -Path "$Destination\.git") {
                Write-Warning "Destination repository already exists"
                Write-Warning "Use the Update-WinPEDrivers cmdlet to update this repository"
                Write-Host
                continue
            }

            Write-Verbose "git clone --verbose --progress --single-branch --depth 1 `"$Source`" `"$Destination`""
            git clone --verbose --progress --single-branch --depth 1 "$Source" "$Destination"

            Write-Verbose "Push-Location `"$Destination`""
            Push-Location "$Destination"

            Write-Verbose 'git fetch --verbose --progress --depth 1 origin'
            git fetch --verbose --progress --depth 1 origin

            Write-Verbose 'git reset --hard origin/main'
            git reset --hard origin/main

            Write-Verbose 'git clean -f -d'
            git clean -d --force

            Write-Verbose 'Pop-Location'
            Pop-Location
            Write-Host
        }
        #endregion
        #=================================================
    }
    
    end {}
}