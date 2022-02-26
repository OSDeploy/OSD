<#
.SYNOPSIS
Returns a PowerShell Object of the Dell Family Packs

.DESCRIPTION
Returns a PowerShell Object of the Dell Family Packs by parsing http://downloads.delltechcenter.com/DIA/Drivers/
This function is used with Save-DellFamilyPack

.LINK
https://osddrivers.osdeploy.com/functions/get-dellfamilypack
#>
function Get-OSDDriverDellFamily {
    [CmdletBinding()]
    param ()

    #=================================================
    #   Uri
    #=================================================
    #$Uri = 'http://downloads.delltechcenter.com/DIA/Drivers/'
    $Uri = 'http://downloads.delltechcenter.com/DIA/Drivers/'
    #=================================================
    #   DriverWebContentRaw
    #=================================================
    Write-Verbose "OSD: Get Latest Driver Versions $Uri" -Verbose
    $DriverWebContentRaw = @()
    try {
        $DriverWebContentRaw = (Invoke-WebRequest $Uri -UseBasicParsing).RawContent
    }
    catch {
        Write-Error "OSDDrivers uses Internet Explorer to parse the HTML data.  Make sure you can open the URL in Internet Explorer and that you dismiss any first run wizards" -ErrorAction Stop
    }
    #=================================================
    #   DriverWebContentByLine
    #=================================================
    $DriverWebContentByLine = @()
    #$DriverWebContentByLine = [array]$DriverWebContentRaw.Split("`n")
    try {
        $DriverWebContentByLine = $DriverWebContentRaw.Split("`n")
    }
    catch {
        Write-Error "Unable to parse $Uri" -ErrorAction Stop
    }
    #=================================================
    #   DriverWebContent
    #=================================================
    $DriverWebContent = @()
    foreach ($ContentLine in $DriverWebContentByLine) {
        if ($ContentLine -notmatch 'FILE') {Continue}
        if ($ContentLine -notmatch 'HREF') {Continue}

        $ContentLine = $ContentLine -replace '\s+', ' '

        $DriverWebContent += $ContentLine
    }
    #=================================================
    #   ForEach
    #=================================================
    $global:GetOSDDriverDellFamily = @()
    $global:GetOSDDriverDellFamily = foreach ($ContentLine in $DriverWebContent) {
        #=================================================
        #   Defaults
        #=================================================
        $OSDVersion = $(Get-Module -Name OSD | Sort-Object Version | Select-Object Version -Last 1).Version
        $LastUpdate = [datetime] $(Get-Date)
        $OSDStatus = $null
        $OSDType = 'FamilyPack'
        $OSDGroup = 'DellFamily'

        $DriverName = $null
        $DriverVersion = $null
        $DriverReleaseId = $null
        $DriverGrouping = $null

        $OperatingSystem = @()
        $OsVersion = @()
        $OsArch = @()
        $OsBuildMax = @()
        $OsBuildMin = @()

        $Make = @('Dell')
        $MakeNe = @()
        $MakeLike = @()
        $MakeNotLike = @()
        $MakeMatch = @()
        $MakeNotMatch = @()

        $Generation = $null
        $SystemFamily = $null

        $Model = @()
        $ModelNe = @()
        $ModelLike = @()
        $ModelNotLike = @()
        $Model = @()
        $ModelNotMatch = @()

        $SystemSku = @()
        $SystemSkuNe = @()

        $DriverBundle = $null
        $DriverWeight = 100

        $DownloadFile = $null
        $SizeMB = $null
        $DriverUrl = $null
        $DriverInfo = $null
        $DriverDescription = $null
        $Hash = $null
        $OSDGuid = $(New-Guid)
        #=================================================
        #   DriverFamily
        #=================================================
        if ($ContentLine -match 'Latitude') {$SystemFamily = 'Latitude'}
        elseif ($ContentLine -match 'OptiPlex') {$SystemFamily = 'OptiPlex'}
        elseif ($ContentLine -match 'Precision') {$SystemFamily = 'Precision'}
        elseif ($ContentLine -match 'Venue') {$SystemFamily = 'Venue'}
        elseif ($ContentLine -match 'Vostro') {$SystemFamily = 'Vostro'}
        elseif ($ContentLine -match 'XPS') {$SystemFamily = 'XPS'}
        else {$SystemFamily = ''}
        #=================================================
        #   OSNameMatch OsVersion OSVersionMax
        #=================================================
        if ($ContentLine -match "Win7") {
            $OSNameMatch = 'Win7'
            $OsVersion = '6.1'
            $OsArch = 'x64'
        }
        if ($ContentLine -match "Win8") {
            $OSNameMatch = 'Win8.1'
            $OsVersion = '6.3'
            $OsArch = 'x64'
        }
        if ($ContentLine -match "Win10") {
            $OSNameMatch = 'Win10'
            $OsVersion = '10.0'
            $OsArch = 'x64'
        }
        #=================================================
        #   DriverPackFile
        #=================================================
        $DriverPackFile = ($ContentLine.Split('<>')[4]).Trim()
        $DriverUrl = $Uri + $DriverPackFile
        #=================================================
        #   SizeMB
        #=================================================
        $SizeMB = (($ContentLine.Split('<>')[6]).Trim()).Split(' ')[2] -replace 'M',''
        $SizeMB = [int]$SizeMB

        $DriverChild = $DriverPackFile.split('_')[1]
        $DriverChild = $DriverChild -replace "$SystemFamily"
        $DriverChild = $DriverChild.Trim()
        $DriverChild = $DriverChild.ToUpper()

        $DriverReleaseId = "$SystemFamily $DriverChild"

        $DriverVersion = $DriverPackFile.split('_.')[2]
        $DriverVersion = $DriverVersion.Trim()
        $DriverVersion = $DriverVersion.ToUpper()
        #=================================================
        #   Model Latitude
        #=================================================
        if ($DriverReleaseId -match 'Latitude') {
            $IsLaptop = $true
            $IsDesktop = $false
        }
        if ($DriverReleaseId -eq 'Latitude 3X40') {$Model = 'Latitude 3340','Latitude 3440','Latitude 3540'}

        if ($DriverReleaseId -eq 'Latitude E1') {$Model = 'Latitude E4200','Latitude E4300','Latitude E5400','Latitude E5500','Latitude E6400','Latitude E6500','Precision M2400','Precision M4400','Precision M6400'}
        if ($DriverReleaseId -eq 'Latitude E2') {$Model = 'Latitude E4310','Latitude E5410','Latitude E5510','Latitude E6410','Latitude E6510','Precision M2400','Precision M4500','Precision M6500','Latitude Z600'}
        if ($DriverReleaseId -eq 'Latitude E3') {$Model = 'Latitude 13','Latitude E5420','Latitude E5520','Latitude E6220','Latitude E6320','Latitude E6420','Latitude E6520','Precision M4600','Precision M6600','Latitude XT2'}
        if ($DriverReleaseId -eq 'Latitude E4') {$Model = 'Precision M4700','Precision M4700'}

        if ($DriverReleaseId -eq 'Latitude E5') {$Model = 'Latitude E5440','Latitude E5540','Latitude E6440','Latitude E6540','Latitude E7240','Latitude E7440'}
        if ($DriverReleaseId -eq 'Latitude E6') {$Model = 'Latitude 3150','Latitude 3450','Latitude 3550','Latitude 5250','Latitude 5450','Latitude 5550','Latitude 7250','Latitude 7350','Latitude 7450','Latitude E5250','Latitude E5450','Latitude E5550','Latitude E7250','Latitude E7350','Latitude E7450'}
        if ($DriverReleaseId -eq 'Latitude E6XFR') {$Model = 'Latitude 5404','Latitude 7204','Latitude 7404'}
        if ($DriverReleaseId -eq 'Latitude E7') {$Model = 'Latitude 3160','Latitude 3460','Latitude 3560'}

        if ($DriverReleaseId -eq 'Latitude E8') {$Model = 'Latitude 3350','Latitude 3470','Latitude 3570','Latitude 7370','Latitude E3350','Latitude E5270','Latitude E5470','Latitude E5570','Latitude E7270','Latitude E7470'}
        if ($DriverReleaseId -eq 'Latitude E8RUGGED') {$Model = 'Latitude 5414','Latitude 7214','Latitude 7414'}
        if ($DriverReleaseId -eq 'Latitude E8TABLET') {$Model = 'Latitude 3379','Latitude 5175','Latitude 5179','Latitude 7275','Latitude E7275'}

        if ($DriverReleaseId -eq 'Latitude E9') {$Model = 'Latitude 3180','Latitude 3189','Latitude 3380','Latitude 3480','Latitude 3580','Latitude 5280','Latitude 5289','Latitude 5480','Latitude 5580','Latitude 7380','Latitude 7389','Latitude 7280','Latitude 7480'}
        if ($DriverReleaseId -eq 'Latitude E9RUGGED') {$Model = 'Latitude 7212'}
        if ($DriverReleaseId -eq 'Latitude E9TABLET') {$Model = 'Latitude 5285','Latitude 7285'}

        if ($DriverReleaseId -eq 'Latitude E10') {$Model = 'Latitude 3190','Latitude 3490','Latitude 3590','Latitude 5290','Latitude 5490','Latitude 5590','Latitude 7290','Latitude 7390','Latitude 7490'}
        if ($DriverReleaseId -eq 'Latitude E10CFL') {$Model = 'Latitude 5491','Latitude 5495','Latitude 5591'}
        if ($DriverReleaseId -eq 'Latitude E10RUGGED') {$Model = 'Latitude 5420','Latitude 5424','Latitude 7424'}
        if ($DriverReleaseId -eq 'Latitude E10TABLET') {$Model = 'Latitude 3390'}

        if ($DriverReleaseId -eq 'Latitude E11') {$Model = 'Latitude 3300'}
        if ($DriverReleaseId -eq 'Latitude E11WHL') {$Model = 'Latitude 3400','Latitude 3500','Latitude 5300','Latitude 5400','Latitude 5500'}
        if ($DriverReleaseId -eq 'Latitude E11WHL2') {$Model = 'Latitude 7200','Latitude 7300','Latitude 7400'}
        if ($DriverReleaseId -eq 'Latitude E11WHL3301') {$Model = 'Latitude 3301'}
        if ($DriverReleaseId -eq 'Latitude E11WHL5x01') {$Model = 'Latitude 5401','Latitude 5501'}
        #=================================================
        #   Model OptiPlex
        #=================================================
        if ($DriverReleaseId -match 'OptiPlex') {
            $IsLaptop = $false
            $IsDesktop = $true
        }
        if ($DriverReleaseId -eq 'OptiPlex D1') {$Model = 'OptiPlex 360','OptiPlex 760','OptiPlex 760'} #Win7
        if ($DriverReleaseId -eq 'OptiPlex D2') {$Model = 'OptiPlex 380','OptiPlex 780','OptiPlex 980','OptiPlex XE'} #Win7
        if ($DriverReleaseId -eq 'OptiPlex D3') {$Model = 'OptiPlex 390','OptiPlex 790','OptiPlex 990'} #Win7

        if ($DriverReleaseId -eq 'OptiPlex D4') {$Model = 'OptiPlex 3010','OptiPlex 7010','OptiPlex 9010'}
        if ($DriverReleaseId -eq 'OptiPlex D5') {$Model = 'OptiPlex 3020','OptiPlex 9020','OptiPlex XE2'}
        if ($DriverReleaseId -eq 'OptiPlex D6') {$Model = 'OptiPlex 3020M','OptiPlex 3030','OptiPlex 7020','OptiPlex 9020M','OptiPlex 9030'}
        if ($DriverReleaseId -eq 'OptiPlex D7') {$Model = 'OptiPlex 3040','OptiPlex 3046','OptiPlex 3240','OptiPlex 5040','OptiPlex 7040','OptiPlex 7440'}
        if ($DriverReleaseId -eq 'OptiPlex D8') {$Model = 'OptiPlex 3050','OptiPlex 5050','OptiPlex 5055','OptiPlex 5250','OptiPlex 7050','OptiPlex 7450'}
        if ($DriverReleaseId -eq 'OptiPlex D9') {$Model = 'OptiPlex 3060','OptiPlex 5060','OptiPlex 5260','OptiPlex 7060','OptiPlex 7460','OptiPlex 7760','OptiPlex XE3'}
        if ($DriverReleaseId -eq 'OptiPlex D9MLK') {$Model = 'OptiPlex 3070','OptiPlex 5070','OptiPlex 5270','OptiPlex 7070','OptiPlex 7470','OptiPlex 7770'}
        
        if ($DriverReleaseId -eq 'OptiPlex 5055') {$Model = 'OptiPlex 5055'}
        if ($DriverReleaseId -eq 'OptiPlex 5055R') {$Model = 'OptiPlex 5055R'}
        #=================================================
        #   Model Precision M
        #=================================================
        if ($DriverReleaseId -match 'Precision M') {
            $IsLaptop = $true
            $IsDesktop = $false
        }
        if ($DriverReleaseId -eq 'Precision M3800') {$Model = 'Precision M3800'}
        if ($DriverReleaseId -eq 'Precision M5') {$Model = 'Precision M2800','Precision M4800','Precision M6800'}
        if ($DriverReleaseId -eq 'Precision M6') {$Model = 'Precision 3510','Precision 5510','Precision 7510','Precision 7710','XPS*9550'}
        if ($DriverReleaseId -eq 'Precision M7') {$Model = 'Precision 3520','Precision 5520','Precision 7520','Precision 7720'}
        if ($DriverReleaseId -eq 'Precision M8') {$Model = 'Precision 3530','Precision 5530','Precision 7530','Precision 7730'}
        if ($DriverReleaseId -eq 'Precision M8WHL') {$Model = 'Precision 3540'}
        if ($DriverReleaseId -eq 'Precision M9') {$Model = 'Precision 3541'}
        if ($DriverReleaseId -eq 'Precision M9CFLR5540') {$Model = 'Precision 5540'}
        if ($DriverReleaseId -eq 'Precision M9MLK') {$Model = 'Precision 7540','Precision 7740'}
        #=================================================
        #   Model Precision M
        #=================================================
        if ($DriverReleaseId -match 'Precision W') {
            $IsLaptop = $false
            $IsDesktop = $true
        }
        if ($DriverReleaseId -eq 'Precision WS5') {$Model = 'Precision T1700'}
        if ($DriverReleaseId -eq 'Precision WS6') {$Model = 'Precision 5810','Precision T5810','Precision 7810','Precision T7810','Precision 7910','Precision R7910','Precision T7910'}
        if ($DriverReleaseId -eq 'Precision WS7') {$Model = 'Precision 3420','Precision 3620'}
        if ($DriverReleaseId -eq 'Precision WS8') {$Model = 'Precision 5720','Precision 5820','Precision 7820','Precision 7920'}
        if ($DriverReleaseId -eq 'Precision WS9') {$Model = 'Precision 3430','Precision 3630','Precision 3930'}
        if ($DriverReleaseId -eq 'Precision WS9CFL3431') {$Model = 'Precision 3431'}
        #=================================================
        #   Model Venue Pro
        #=================================================
        if ($DriverReleaseId -match 'Venue') {
            $IsLaptop = $true
            $IsDesktop = $false
        }
        if ($DriverReleaseId -eq 'Venue PRO2') {$Model = 'Venue 8 Pro 5830','Venue 11 Pro 5130','Venue 11 Pro 7130','Venue 11 Pro 7139'}
        if ($DriverReleaseId -eq 'Venue PRO3') {$Model = 'Venue 11 Pro 7140'}
        if ($DriverReleaseId -eq 'Venue PRO4') {$Model = 'Venue 5056','Venue 10PRO5056','Venue5855','Venue 8PRO5855'}
        #=================================================
        #   Model Vostro
        #=================================================
        if ($DriverReleaseId -match 'Vostro') {
            $IsLaptop = $true
            $IsDesktop = $false
        }
        if ($DriverReleaseId -eq 'Vostro D8') {$Model = 'CHENGMING 3967','CHENGMING 3968'}
        if ($DriverReleaseId -eq 'Vostro D9') {$Model = 'CHENGMING 3980'}
        #=================================================
        #   Model XPS
        #=================================================
        if ($DriverReleaseId -match 'XPS NOTEBOOK') {
            $IsLaptop = $true
            $IsDesktop = $false
        }
        if ($DriverReleaseId -eq 'XPS NOTEBOOK1') {$Model = 'XPS 9530'}
        if ($DriverReleaseId -eq 'XPS NOTEBOOK3') {$Model = 'XPS 9343'}
        if ($DriverReleaseId -eq 'XPS NOTEBOOK4') {$Model = 'XPS 9250','XPS 9350'}
        if ($DriverReleaseId -eq 'XPS NOTEBOOK5') {$Model = 'XPS 9360','XPS 9365','XPS 9560'}
        if ($DriverReleaseId -eq 'XPS NOTEBOOK6') {$Model = 'XPS 9370','XPS 9570','XPS 9575'}
        if ($DriverReleaseId -eq 'XPS NOTEBOOK7') {$Model = 'XPS 9380'}
        if ($DriverReleaseId -eq 'XPS NOTEBOOK8') {$Model = 'XPS 7590'}
        #=================================================
        #   LastUpdate
        #=================================================
        $LastUpdateRaw = ((($ContentLine.Split('<>')[6]).Trim()).Split(' ')[0,1])
        $LastUpdate = [datetime]::ParseExact($LastUpdateRaw, "dd-MMM-yyyy HH:mm", $null)
        #=================================================
        #   DriverName
        #=================================================
        $DriverName = "$OSDGroup $SystemFamily $DriverChild $OSNameMatch $DriverVersion"
        #if ($OSArch) {$DriverName = "$OSDGroup $SystemFamily $DriverChild $OSNameMatch $OSArch $DriverVersion"}
        #=================================================
        #   DriverGrouping
        #=================================================
        $DriverGrouping = "$SystemFamily $DriverChild $OSNameMatch"
        #=================================================
        #   DriverDescription
        #=================================================
        $DriverDescription = ''
        #=================================================
        #   FileType
        #=================================================
        $FileType = $DriverPackFile.split('.')[1]
        $FileType = $FileType.ToLower()
        #=================================================
        #   FileType
        #=================================================
        $FileName = Split-Path $DriverUrl -Leaf
        $FileName = $FileName.split('.')[1]
        $FileType = $FileName.ToLower()
        #=================================================
        #   DownloadFile
        #=================================================
        $OSNameEdit = $OSNameMatch
        $OSNameEdit = $OSNameEdit.Replace('.','')
        $DownloadFile = "$OSNameEdit`_$SystemFamily$DriverChild`_$DriverVersion.$FileType"
        #=================================================
        #   DriverInfo
        #=================================================
        $DriverInfo = 'https://www.dell.com/support/article/us/en/04/how13322/dell-family-driver-packs?lang=en'
        #=================================================
        #   Create Object 
        #=================================================
        $ObjectProperties = @{
            OSDVersion              = $OSDVersion
            LastUpdate              = $(($LastUpdate).ToString("yyyy-MM-dd"))
            OSDStatus               = $OSDStatus
            OSDType                 = $OSDType
            OSDGroup                = $OSDGroup

            DriverName              = $DriverName
            DriverVersion           = $DriverVersion
            DriverReleaseId         = $DriverReleaseID

            OperatingSystem         = $OperatingSystem
            OsVersion               = $OsVersion
            OsArch                  = $OsArch
            OsBuildMax              = $OsBuildMax
            OsBuildMin              = $OsBuildMin

            Make                    = $Make
            MakeNe                  = $MakeNe
            MakeLike                = $MakeLike
            MakeNotLike             = $MakeNotLike
            MakeMatch               = $MakeMatch
            MakeNotMatch            = $MakeNotMatch

            Generation              = $Generation
            SystemFamily            = $SystemFamily

            Model                   = $Model
            ModelNe                 = $ModelNe
            ModelLike               = $ModelLike
            ModelNotLike            = $ModelNotLike
            ModelMatch              = $ModelMatch
            ModelNotMatch           = $ModelNotMatch

            SystemSku               = $SystemSku
            SystemSkuNe             = $SystemSkuNe

            DriverGrouping          = $DriverGrouping
            DriverBundle            = $DriverBundle
            DriverWeight            = [int] $DriverWeight

            DownloadFile            = $DownloadFile
            SizeMB                  = [int] $SizeMB
            DriverUrl               = $DriverUrl
            DriverInfo              = $DriverInfo
            DriverDescription       = $DriverDescription
            Hash                    = $Hash
            OSDGuid                 = $OSDGuid
            IsSuperseded            = [bool] $IsSuperseded
        }
        New-Object -TypeName PSObject -Property $ObjectProperties
    }
    #=================================================
    #   Select-Object
    #=================================================
    $global:GetOSDDriverDellFamily = $global:GetOSDDriverDellFamily | Select-Object OSDVersion, LastUpdate,`
    OSDStatus, OSDType, OSDGroup,`
    DriverName, DriverVersion, DriverReleaseId,`
    OsVersion, OsArch,` #OperatingSystem
    Generation,`
    Make,` #MakeNe, MakeLike, MakeNotLike
    SystemFamily,`
    Model,` #ModelNe, ModelLike, ModelNotLike, ModelMatch, ModelNotMatch
    SystemSku,` #SystemSkuNe
    DriverGrouping,`
    DownloadFile, SizeMB, DriverUrl, DriverInfo,` #DriverDescription
    Hash, OSDGuid, IsSuperseded
    #=================================================
    #   Supersedence
    #=================================================
    $global:GetOSDDriverDellFamily = $global:GetOSDDriverDellFamily | Sort-Object DriverName -Descending
    $CurrentOSDDriverDellFamily = @()
    foreach ($FamilyPack in $global:GetOSDDriverDellFamily) {
        if ($CurrentOSDDriverDellFamily.DriverGrouping -match $FamilyPack.DriverGrouping) {
            $FamilyPack.IsSuperseded = $true
        } else { 
            $CurrentOSDDriverDellFamily += $FamilyPack
        }
    }
    $global:GetOSDDriverDellFamily = $global:GetOSDDriverDellFamily | Where-Object {$_.IsSuperseded -eq $false}
    #$global:GetOSDDriverDellFamily = $global:GetOSDDriverDellFamily | Where-Object {$_.OsVersion -match '10.0'}
    #=================================================
    #   Sort Object
    #=================================================
    $global:GetOSDDriverDellFamily = $global:GetOSDDriverDellFamily | Sort-Object LastUpdate -Descending
    #=================================================
    #   Return
    #=================================================
    Return $global:GetOSDDriverDellFamily
    #=================================================
}