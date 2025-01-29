function Add-OSDCacheWinPEDrivers {
    [CmdletBinding()]
    param ()

    begin {
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))] $($MyInvocation.MyCommand)"
        # Update Environment as Git for Windows may have just been installed
        if (-NOT (Get-Command 'git' -ErrorAction SilentlyContinue)) {
            $locations = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
            'HKCU:\Environment'

            $locations | ForEach-Object {   
                $k = Get-Item $_
                $k.GetValueNames() | ForEach-Object {
                    $name = $_
                    $value = $k.GetValue($_)
                    Set-Item -Path Env:\$name -Value $value
                }
            }
        }

        # Git for Windows is needed to sync the OSDRepos
        if (-NOT (Get-Command 'git' -ErrorAction SilentlyContinue)) {
            Write-Error -Message 'Git for Windows is not installed.  Use the following command to install Git for Windows:'
            Write-Output 'winget install -e --id Git.Git'
            break
        }
    }

    process {
        $InputObject = (Get-Content -Raw -Path "$($MyInvocation.MyCommand.Module.ModuleBase)\Cache\WinPEDriversRepos.json" | ConvertFrom-Json)
        
        foreach ($Repository in $InputObject) {
            Write-Verbose "Name: $($Repository.name)"
            Write-Verbose "Description: $($Repository.description)"

            $Source = $Repository.clone_url
            Write-Verbose "Clone URL: $Source"
            # TODO Test the Clone URL
            
            $Destination = Join-Path -Path $(Get-OSDCachePath) -ChildPath $($Repository.name)
            Write-Verbose "Destination: $Destination"

            #if (-NOT (Test-Path "$Destination\.git" -PathType Container)) {
                Write-Verbose "git clone --verbose --progress --single-branch --depth 1 `"$Source`" `"$Destination`""
                git clone --verbose --progress --single-branch --depth 1 "$Source" "$Destination"
            #}

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
    }
    
    end {}
}