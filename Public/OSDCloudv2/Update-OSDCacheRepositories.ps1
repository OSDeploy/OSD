function Update-OSDCacheRepositories {
    <#
    .SYNOPSIS
        Updates the OSDCache repository in $env:ProgramData\OSDCache from the GitHub Origin.

    .DESCRIPTION
        Updates the OSDCache repository in $env:ProgramData\OSDCache from the GitHub Origin.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        # Force the update of the Git Repository, overwriting all content.
        [System.Management.Automation.SwitchParameter]
        $Force
    )

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
        $InputObject = @()
        $InputObject = Get-OSDCacheRepositories
        #endregion
        #=================================================
        #region Process foreach
        foreach ($Repository in $InputObject) {
            Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))] Repository: $($Repository.FullName)"

            if ($Force -eq $true) {
                $Destination = $Repository.FullName
                Write-Verbose "Push-Location `"$Destination`""
                Push-Location "$Destination"

                Write-Verbose 'git fetch --verbose --progress --depth 1 origin'
                git fetch --verbose --progress --depth 1 origin

                Write-Verbose 'git reset --hard origin/main'
                git reset --hard origin/main

                Write-Verbose 'git clean -f -d'
                git clean -d --force

                Pop-Location
            }
            else {
                Write-Warning 'This command will update this Git repository to the latest GitHub commit in the main branch.'
                Write-Warning 'Any local content that has been modified or changed will be lost.'
                Write-Warning 'To update this Git Repository, use the -Force switch when running this command.'
                Write-Host
            }
        }
        #endregion
        #=================================================
    }

    end {}
}