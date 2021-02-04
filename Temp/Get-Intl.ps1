$LangPacks = DISM.exe /Online /Get-Intl /English |
    Select-String -SimpleMatch 'Installed language(s)'|
        ForEach-Object {
            if($_ -match ':\s*(.*)'){$Matches[1]}
        }


        $LangPacks