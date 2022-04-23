$InstalledModule = Import-Module Microsoft.Graph.Intune -PassThru -ErrorAction Ignore
if (-not $InstalledModule) {
    Write-Host -ForegroundColor DarkGray 'Install-Module Microsoft.Graph.Intune [CurrentUser]'
    Install-Module Microsoft.Graph.Intune -Force -Scope CurrentUser
}
if (Get-Command Connect-MSGraph -ErrorAction Ignore) {
    Connect-MSGraph
    $graphApiVersion = "Beta"
    $graphUrl = "https://graph.microsoft.com/$graphApiVersion"
    $graphRequest = Invoke-MSGraphRequest -Url "$graphUrl/deviceManagement/deviceManagementScripts" -HttpMethod GET
    
    $deviceManagementScripts = $graphRequest.Value | Select-Object *
    $deviceManagementScripts = $deviceManagementScripts | Out-GridView -PassThru
    
    foreach($deviceScript in $deviceManagementScripts) {
        $deviceManagementScript = Invoke-MSGraphRequest -Url "$graphUrl/deviceManagement/deviceManagementScripts/$($deviceScript.id)" -HttpMethod GET
    
        $encodedScript = $deviceManagementScript.scriptContent
        $decodedscript = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($encodedScript))
    
        $outScript = "$env:TEMP\$($deviceScript.displayName).ps1"
    
        $decodedscript | Out-File -FilePath $outScript -Encoding utf8 -Width 2000
    
        $invokeScript = Get-Content -Raw -Encoding Utf8 $outScript
        if ($invokeScript.Contains([char] 0xfffd)) {
            $invokeScript = Get-Content -Raw $outScript
        }
        [System.IO.File]::WriteAllText($outScript, $invokeScript)
    
        $runScript = Get-Content $outScript -RAW
        $null = Remove-Item -Path $outScript -Force
        Write-Verbose -Verbose "Invoke $($deviceScript.displayName)"
        Invoke-Expression $runScript
    }
}