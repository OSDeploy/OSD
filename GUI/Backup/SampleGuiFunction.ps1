function Test-David {
    [CmdletBinding(DefaultParameterSetName = 'Standalone')]
    param ()
    #=======================================================================
    #   GitHub
    #=======================================================================
    if ($PSCmdlet.ParameterSetName -eq 'GitHub') {
        $Uri = "https://api.github.com/repos/$GitOwner/$GitRepo/contents/$GitPath"
        Write-Host -ForegroundColor DarkCyan $Uri


        if ($OAuthToken) {
            $Params = @{
                Headers = @{Authorization = "Bearer $OAuthToken"}
                Method = 'GET'
                Uri = $Uri
                UseBasicParsing = $true
            }
        }
        else {
            $GitHubApiRateLimit = Invoke-RestMethod -UseBasicParsing -Uri 'https://api.github.com/rate_limit' -Method Get
            Write-Host -ForegroundColor DarkGray "You have used $($GitHubApiRateLimit.rate.used) of your $($GitHubApiRateLimit.rate.limit) GitHub API Requests"
            Write-Host -ForegroundColor DarkGray "You can create an OAuth Token at https://github.com/settings/tokens"
            Write-Host -ForegroundColor DarkGray 'Use the OAuthToken parameter to enable Git2PS Child-Item support'
            $Params = @{
                Method = 'GET'
                Uri = $Uri
                UseBasicParsing = $true
            }
        }

        $GitHubApiContent = @()
        $GitHubApiContent = Invoke-RestMethod @Params
        
        if ($OAuthToken) {
            foreach ($Item in $GitHubApiContent) {
                if ($Item.type -eq 'dir') {
                    Write-Host -ForegroundColor DarkCyan $Item.url
                    $GitHubApiContent += Invoke-RestMethod -UseBasicParsing -Uri $Item.url -Method Get -Headers @{Authorization = "Bearer $OAuthToken" }
                }
            }
        }

        $GitHubApiContent = $GitHubApiContent | Where-Object {$_.type -eq 'file'} | Where-Object {($_.name -match 'README.md') -or ($_.name -like "*.ps1")}

        Write-Host -ForegroundColor DarkGray "================================================"
        $Results = foreach ($Item in $GitHubApiContent) {
            #$FileContent = Invoke-RestMethod -UseBasicParsing -Uri $Item.git_url
    
            Write-Host -ForegroundColor DarkGray $Item.download_url
            try {
                $ScriptWebRequest = Invoke-WebRequest -Uri $Item.download_url -UseBasicParsing -ErrorAction Ignore
            }
            catch {
                Write-Warning $_
                $ScriptWebRequest = $null
                Continue
            }
    
            $ObjectProperties = @{
                GitOwner    = $GitOwner
                GitRepo     = $GitRepo
                Name            = $Item.name
                Guid            = New-Guid
                Path            = $Item.path
                Size            = $Item.size
                SHA             = $Item.sha
                Git             = $Item.git_url
                Download        = $Item.download_url
                ContentRAW      = $ScriptWebRequest.Content
                #NodeId         = $FileContent.node_id
                #Content        = $FileContent.content
                #Encoding       = $FileContent.encoding
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
        }
    
        $Global:Git2PS = $Results
    }
    else {
        $Global:Git2PS = $null
    }
    #================================================
    #   XamlCode
    #================================================
[xml]$Global:XamlCode = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"

        Title = "GitScriptBox"
        Width = "700"
        Height = "500"

        BorderBrush = "{DynamicResource AccentColorBrush}"
        BorderThickness = "0"
        ResizeMode = "CanResizeWithGrip"
        WindowStartupLocation = "CenterScreen">

    <Window.Resources>
        <ResourceDictionary>
            <Style TargetType="{x:Type Button}">
                <Setter Property="Background" Value="{DynamicResource FlatButtonBackgroundBrush}" />
                <Setter Property="BorderThickness" Value="0" />
                <Setter Property="FontSize" Value="{DynamicResource FlatButtonFontSize}" />
                <Setter Property="Foreground" Value="{DynamicResource FlatButtonForegroundBrush}" />
                <Setter Property="Padding" Value="5 5 5 5" />
                <Setter Property="Template">
                    <Setter.Value>
                        <ControlTemplate TargetType="{x:Type Button}">
                            <Border x:Name="Border"
                                Margin="0"
                                Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                CornerRadius = "5"
                                BorderThickness="{TemplateBinding BorderThickness}"
                                SnapsToDevicePixels="{TemplateBinding SnapsToDevicePixels}">
                                <ContentPresenter x:Name="ContentPresenter" 
                                    ContentTemplate="{TemplateBinding ContentTemplate}" 
                                    Content="{TemplateBinding Content}" 
                                    HorizontalAlignment="{TemplateBinding HorizontalContentAlignment}"
                                    Margin="{TemplateBinding Padding}" 
                                    VerticalAlignment="{TemplateBinding VerticalContentAlignment}"/>
                            </Border>
                        </ControlTemplate>
                    </Setter.Value>
                </Setter>
                <Style.Triggers>
                    <Trigger Property="IsMouseOver" Value="True">
                        <!-- Windows 11 Theme Dark Blue -->
                        <Setter Property="Background" Value="#003E92" />
                    </Trigger>
                    <Trigger Property="IsMouseOver" Value="False">
                        <!-- Windows 11 Theme Blue -->
                        <Setter Property="Background" Value="#0067C0" />
                    </Trigger>
                    <Trigger Property="IsPressed" Value="True">
                        <Setter Property="Background" Value="{DynamicResource FlatButtonPressedBackgroundBrush}" />
                        <Setter Property="Foreground" Value="{DynamicResource FlatButtonPressedForegroundBrush}" />
                    </Trigger>
                    <Trigger Property="IsEnabled" Value="False">
                        <Setter Property="Foreground" Value="{DynamicResource GrayBrush2}" />
                    </Trigger>
                </Style.Triggers>
            </Style>
            <Style TargetType="{x:Type ComboBox}">
                <Setter Property = "FontFamily" Value = "Segoe UI" />
            </Style>
            <Style TargetType="{x:Type Label}">
                <Setter Property = "FontFamily" Value = "Segoe UI" />
            </Style>
            <Style TargetType="{x:Type TextBox}">
                <Setter Property = "FontFamily" Value = "Segoe UI" />
            </Style>
            <Style TargetType="{x:Type Window}">
                <Setter Property="FontFamily" Value="Segoe UI" />
                <Setter Property="FontSize" Value="16" />
                <Setter Property="Background" Value="White" />
                <Setter Property="Foreground" Value="Black" />
            </Style>
        </ResourceDictionary>
    </Window.Resources>

    <Window.Background>
        <LinearGradientBrush StartPoint = "0,0" EndPoint = "1,1">
            <GradientStop Color = "White" Offset = "0.0" />
            <GradientStop Color = "#EDF1FA" Offset = "0.3" />
            <GradientStop Color = "#EDF3FE" Offset = "0.7" />
            <GradientStop Color = "#F7FAFC" Offset = "1.0" />
        </LinearGradientBrush>
    </Window.Background>
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="20"/>
            <ColumnDefinition Width="300"/>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="20"/>
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
            <RowDefinition Height="10"/>
            <RowDefinition Height="70"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="60"/>
            <RowDefinition Height="10"/>
        </Grid.RowDefinitions>

        <!-- Script Combo -->
        <StackPanel
            Grid.Column = "1"
            Grid.ColumnSpan = "2"
            Grid.Row = "1"
            HorizontalAlignment = "Left">
            <ComboBox
                Name = "ComboBoxGit2PSName"
                Background = "LightBlue"
                FontSize = "16"
                Height = "30"
                HorizontalAlignment = "Left"
                SelectedIndex = "0"
                VerticalAlignment = "Top" />
            <Label
                Name = "LabelGit2PSDescription"
                Content = ""
                FontSize = "14"
                Foreground = "Black"
                VerticalAlignment = "Center"/>
        </StackPanel>

        <!-- Script TextBox -->
        <TextBox
            Grid.Column="1"
            Grid.ColumnSpan = "2"
            Grid.Row = "2"
            Name = "TextBoxGit2PSContent"
            Text = ""
            AcceptsReturn = "True"
            AcceptsTab = "True"
            Background = "Gainsboro"
            FontFamily = "Consolas"
            FontSize = "15"
            Foreground = "Blue"
            HorizontalAlignment = "Stretch"
            ScrollViewer.HorizontalScrollBarVisibility = "Visible"
            ScrollViewer.VerticalScrollBarVisibility = "Visible"
            VerticalAlignment = "Stretch" />

        <!-- Title -->
        <StackPanel
            Grid.Column = "1"
            Grid.ColumnSpan = "2"
            Grid.Row = "3"
            HorizontalAlignment = "Left"
            VerticalAlignment = "Center">
            <Label
                Name = "LabelTitle"
                Content = "Start-GitCodeBox"
                FontSize = "24"
                Foreground = "#003E92" />
        </StackPanel>

        <!-- Button -->
        <StackPanel
            Grid.Column = "2"
            Grid.ColumnSpan = "1"
            Grid.Row = "3"
            HorizontalAlignment = "Right"
            VerticalAlignment = "Center">
            <Button
                Name = "GoButton"
                Content = "Start-Process"
                Foreground = "White"
                Height = "40"
                Width = "130" />
		</StackPanel>
    </Grid>
</Window>
"@
    #================================================
    #   Add Assemblies
    #================================================
    Add-Type -AssemblyName PresentationFramework

    [System.Reflection.Assembly]::LoadWithPartialName("presentationframework") | Out-Null
    [System.Reflection.Assembly]::LoadFrom("$Global:MyScriptDir\assembly\System.Windows.Interactivity.dll") | Out-Null

    # Set console size and title
    $host.ui.RawUI.WindowTitle = "Start-PSGitBox"
    #================================================
    #   LoadForm
    #================================================
    function LoadForm {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory = $false, Position = 1)]
            [string]$XamlPath
        )
        
        #[xml]$Global:XamlCode = Get-Content -Path $XamlPath

        Try {
            Add-Type -AssemblyName PresentationCore,PresentationFramework,WindowsBase,system.windows.forms
        } 
        Catch {
            Throw "Failed to load Windows Presentation Framework assemblies."
        }

        #Create the XAML reader using a new XML node reader
        $Global:XamlWindow = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $Global:XamlCode))

        #Create hooks to each named object in the XAML
        $Global:XamlCode.SelectNodes("//*[@Name]") | ForEach-Object {
            Set-Variable -Name ($_.Name) -Value $Window.FindName($_.Name) -Scope Global
        }
    }
    #================================================
    #   LoadForm
    #================================================
    LoadForm
    #================================================
    #   Customizations
    #================================================
    [string]$ModuleVersion = Get-Module -Name OSDeploy | Sort-Object -Property Version | Select-Object -ExpandProperty Version -Last 1

    $Global:XamlWindow.Title = "OSD Module $ModuleVersion"
    #$Global:XamlWindow | Out-Host
    #================================================
    #   Launch
    #================================================
    $Global:XamlWindow.ShowDialog() | Out-Null
    #================================================
}