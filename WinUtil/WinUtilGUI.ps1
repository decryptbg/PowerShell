<# 
 
 Windows Utility Programs by decrypt
 
#>
using namespace System.Windows
using namespace System.Windows.Threading

Add-Type -AssemblyName 'PresentationFramework', 'PresentationCore'
Add-Type -AssemblyName System.Windows.Forms
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class PowerManagement {
    [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    public static extern EXECUTION_STATE SetThreadExecutionState(EXECUTION_STATE esFlags);

    [FlagsAttribute]
    public enum EXECUTION_STATE : uint {
        ES_SYSTEM_REQUIRED = 0x00000001,
        ES_DISPLAY_REQUIRED = 0x00000002,
        ES_CONTINUOUS = 0x80000000,
    }
}
"@
[PowerManagement]::SetThreadExecutionState([PowerManagement]::EXECUTION_STATE::ES_CONTINUOUS -bor [PowerManagement]::EXECUTION_STATE::ES_SYSTEM_REQUIRED -bor [PowerManagement]::EXECUTION_STATE::ES_DISPLAY_REQUIRED)

# ---------------
$scrver = "v3.2"
# ---------------

########## Opens the requested legacy panel ##########
function Invoke-WPFControlPanel {
    <#

    .SYNOPSIS
        Opens the requested legacy panel

    .PARAMETER Panel
        The panel to open
		Example: Invoke-WPFControlPanel "WPFPanelprinter"

    #>
    param($Panel)

    switch ($Panel) {
        "WPFPanelcontrol" {control}
        "WPFPanelcomputer" {compmgmt.msc}
        "WPFPanelnetwork" {ncpa.cpl}
        "WPFPanelpower"   {powercfg.cpl}
        "WPFPanelregion"  {intl.cpl}
        "WPFPanelsound"   {mmsys.cpl}
        "WPFPanelprinter" {Start-Process "shell:::{A8A91A66-3A7D-4424-8D24-04E180695C7A}"}
        "WPFPanelsystem"  {sysdm.cpl}
        "WPFPaneluser"    {control userpasswords2}
        "WPFPanelGodMode" {Start-Process "shell:::{ED7BA470-8E54-465E-825C-99712043E01C}"}
    }
}
#### END-Invoke-WPFControlPanel---------------------------------------------------------------------------------------

# Define logging function
function Write-Log {
    param (
        [string]$Message,
        [string]$TweakName = "",
        [string]$Status = "Info",
        [string]$Details = ""
    )
    $logFile = Join-Path $env:TEMP "WinTweaksGUI_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - [$Status] $Message"
    if ($TweakName) {
        $logEntry += " | Tweak: $TweakName"
    }
    if ($Details) {
        $logEntry += " | Details: $Details"
    }
    $logEntry | Out-File -FilePath $logFile -Append
}

# Define Invoke-WPFRunspace function
function Invoke-WPFRunspace {
    [CmdletBinding()]
    Param (
        $ScriptBlock,
        $ArgumentList,
        $ParameterList,
        $DebugPreference
    )
    Write-Log -Message "Starting runspace for script block: $ScriptBlock" -Status "Info"
    $runspace = [RunspaceFactory]::CreateRunspace()
    $runspace.Open()
    $powershell = [powershell]::Create()
    $powershell.Runspace = $runspace
    $powershell.AddScript({
        param($innerScriptBlock, $innerArgs, $innerParams, $innerDebug)
        try {
            # Execute the script block in the current session to allow GUI commands
            $output = & $innerScriptBlock @innerParams
            return $output
        } catch {
            throw $_
        }
    })
    $powershell.AddArgument($ScriptBlock)
    $powershell.AddArgument($ArgumentList)
    $powershell.AddArgument($ParameterList)
    $powershell.AddArgument($DebugPreference)
    Write-Log -Message "Executing script block in runspace: $ScriptBlock" -Status "Info"
    try {
        $result = $powershell.Invoke()
        $output = if ($result) { $result } else { "No output returned" }
        Write-Log -Message "Script block executed successfully" -Status "Success" -Details ($output -join "; ")
        return $output
    } catch {
        Write-Log -Message "Error executing script block in runspace" -Status "Error" -Details $_.Exception.Message
        throw
    } finally {
        $powershell.Dispose()
        $runspace.Dispose()
    }
}

# Initialize runspace pool
$sync = [Hashtable]::Synchronized(@{})
$sync.runspace = [RunspaceFactory]::CreateRunspacePool(1, [Environment]::ProcessorCount)
$sync.runspace.Open()

# Define the tweaks
$tweaks = @(
# Install Chocolatey
   # @{ Name = "Install Chocolatey"; ScriptBlock = { Install-WinUtilChoco } },
   @{ Name = "Install Chocolatey";
    Description = "Installs Chocolatey package manager.";
    ScriptBlock = {
        Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString(''https://chocolatey.org/install.ps1''))"' -Verb RunAs
    }
},

# Install WinGet
@{
    Name = "Install Winget";
    Description = "Installs Windows Package Manager (winget).";
    ScriptBlock = {
        Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile $env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle; Add-AppxPackage -Path $env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"' -Verb RunAs
    }
},

<#
@{
    Name = "Install Winget";
    Description = "Installs Windows Package Manager (winget).";
    ScriptBlock = {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Output "Winget is already installed."
    } else {
        Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile $env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle; Add-AppxPackage -Path $env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"' -Verb RunAs
    }
}},
#>

# Control Panel old links
	@{ Name = "ControlPanel-ComputerManagement"; ScriptBlock = { Invoke-WPFControlPanel -Panel "WPFPanelcomputer"} },
    @{ Name = "ControlPanel-Network"; ScriptBlock = { Invoke-WPFControlPanel -Panel "WPFPanelnetwork"} },
	@{ Name = "ControlPanel-Region"; ScriptBlock = { Invoke-WPFControlPanel -Panel "WPFPanelregion"} },
	@{ Name = "ControlPanel-Printers"; ScriptBlock = { Invoke-WPFControlPanel -Panel "WPFPanelprinter"} },
	@{ Name = "ControlPanel-User Accounts"; ScriptBlock = { Invoke-WPFControlPanel -Panel "WPFPaneluser"} },
	@{ Name = "ControlPanel-GodMode"; ScriptBlock = { Invoke-WPFControlPanel -Panel "WPFPanelGodMode"} },
# Disable Telemetry
	@{ Name = "Disable Telemetry"; ScriptBlock = {
        $details = @()
        bcdedit /set `{current`} bootmenupolicy Legacy | Out-Null
        $details += "Set bootmenupolicy to Legacy"
        If ((Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name CurrentBuild).CurrentBuild -lt 22557) {
            $taskmgr = Start-Process -WindowStyle Hidden -FilePath taskmgr.exe -PassThru
            Do {
                Start-Sleep -Milliseconds 100
                $preferences = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -ErrorAction SilentlyContinue
            } Until ($preferences)
            Stop-Process $taskmgr
            $preferences.Preferences[28] = 0
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -Type Binary -Value $preferences.Preferences
            $details += "Modified TaskManager preferences"
        }
        Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -Recurse -ErrorAction SilentlyContinue
        $details += "Removed MyComputer namespace key"
        If (Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge") {
            Remove-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Recurse -ErrorAction SilentlyContinue
            $details += "Removed Edge policies"
        }
        $ram = (Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1kb
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "SvcHostSplitThresholdInKB" -Type DWord -Value $ram -Force
        $details += "Set SvcHostSplitThresholdInKB to $ram"
        $autoLoggerDir = "$env:PROGRAMDATA\Microsoft\Diagnosis\ETLLogs\AutoLogger"
        If (Test-Path "$autoLoggerDir\AutoLogger-Diagtrack-Listener.etl") {
            Remove-Item "$autoLoggerDir\AutoLogger-Diagtrack-Listener.etl"
            $details += "Removed AutoLogger-Diagtrack-Listener.etl"
        }
        icacls $autoLoggerDir /deny SYSTEM:`(OI`)`(CI`)F | Out-Null
        $details += "Set permissions on AutoLogger directory"
        Set-MpPreference -SubmitSamplesConsent 2 -ErrorAction SilentlyContinue | Out-Null
        $details += "Set SubmitSamplesConsent to 2"
        return ($details -join "; ")
    }},
# Disable Hibernation
    @{ Name = "Disable Hibernation"; ScriptBlock = { 
        powercfg.exe /hibernate off
        return "Hibernation disabled via powercfg"
    }},
# Enable TaskbarEndTask
    @{ Name = "TaskbarEndTask"; ScriptBlock = { 
        $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings"
        $name = "TaskbarEndTask"
        $value = 1
        if (-not (Test-Path $path)) {
            New-Item -Path $path -Force | Out-Null
            $details = "Created registry path: $path"
        } else {
            $details = "Registry path already exists: $path"
        }
        New-ItemProperty -Path $path -Name $name -PropertyType DWord -Value $value -Force | Out-Null
        $details += "; Set $name to $value"
        return $details
    }},
# Disable PowerShell Telemetry
    @{ Name = "Disable PowerShell Telemetry"; ScriptBlock = { 
        [Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', '1', 'Machine')
        return "Set POWERSHELL_TELEMETRY_OPTOUT to 1"
    }},
# Disable IPv6
    @{ Name = "Disable IPv6"; ScriptBlock = { 
        Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6
        return "Disabled IPv6 on all network adapters"
    }},
# Disable Teredo
    @{ Name = "Disable Teredo"; ScriptBlock = { 
        netsh interface teredo set state disabled
        return "Teredo interface disabled"
    }},
# Disable Intel LMS
    @{ Name = "Disable Intel LMS"; ScriptBlock = { 
        $details = @()
        $serviceName = "LMS"
        Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
        $details += "Stopped service: $serviceName"
        Set-Service -Name $serviceName -StartupType Disabled -ErrorAction SilentlyContinue
        $details += "Set service $serviceName to Disabled"
        sc.exe delete $serviceName
        $details += "Deleted service: $serviceName"
        $lmsDriverPackages = Get-ChildItem -Path "C:\Windows\System32\DriverStore\FileRepository" -Recurse -Filter "lms.inf*" -ErrorAction SilentlyContinue
        foreach ($package in $lmsDriverPackages) {
            pnputil /delete-driver $package.Name /uninstall /force
            $details += "Removed driver package: $($package.Name)"
        }
        if ($lmsDriverPackages.Count -eq 0) {
            $details += "No LMS driver packages found"
        }
        $programFilesDirs = @("C:\Program Files", "C:\Program Files (x86)")
        $lmsFiles = @()
        foreach ($dir in $programFilesDirs) {
            $lmsFiles += Get-ChildItem -Path $dir -Recurse -Filter "LMS.exe" -ErrorAction SilentlyContinue
        }
        foreach ($file in $lmsFiles) {
            icacls $file.FullName /grant Administrators:F /T /C /Q
            takeown /F $file.FullName /A /R /D Y
            Remove-Item $file.FullName -Force -ErrorAction SilentlyContinue
            $details += "Deleted file: $($file.FullName)"
        }
        if ($lmsFiles.Count -eq 0) {
            $details += "No LMS.exe files found"
        }
        return ($details -join "; ")
    }},
# Set Classic Right-Click Menu
    @{ Name = "Set Classic Right-Click Menu"; ScriptBlock = { 
        $details = @()
        New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Name "InprocServer32" -Force -Value ""
        $details += "Created registry key for classic right-click menu"
        $process = Get-Process -Name "explorer"
        Stop-Process -InputObject $process
        $details += "Stopped explorer.exe"
        return ($details -join "; ")
    }},
# Disable Microsoft Recall
    @{ Name = "Disable Microsoft Recall"; ScriptBlock = { 
        DISM /Online /Disable-Feature /FeatureName:Recall
        return "Disabled Microsoft Recall via DISM"
    }}
)

# Define the WPF window XAML
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Windows Tweaks Utility $scrver by decrypt" Height="640" Width="400">
    <Grid Margin="10">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        <StackPanel Grid.Row="0" Orientation="Horizontal" Margin="0,0,0,10">
            <TextBlock x:Name="TWKAPPLY" Grid.Row="4" Text="Select Tweaks to Apply" FontSize="16"/>
            <Button x:Name="ThemeToggleButton" Content="💡" Width="30" Height="30" Margin="160,0,0,0" ToolTip="Toggle Dark/Light Theme"/>
        </StackPanel>
        <ScrollViewer Grid.Row="2" VerticalScrollBarVisibility="Auto">
            <StackPanel x:Name="TweaksPanel"/>
        </ScrollViewer>
        <StackPanel Grid.Row="3" Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,10,0,0">
            <Button x:Name="ApplyButton" Content="Apply" Width="100" Height="30" Margin="5"/>
            <Button x:Name="CancelButton" Content="Cancel" Width="100" Height="30" Margin="5"/>
        </StackPanel>
        <TextBlock x:Name="StatusText" Grid.Row="4" Text="Ready" FontSize="12" Margin="0,5,0,0"/>
    </Grid>
</Window>
"@

# Create the WPF window
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Define theme dictionaries with custom text colors
$darkTheme = New-Object System.Windows.ResourceDictionary
$darkTheme.Source = New-Object System.Uri("pack://application:,,,/PresentationFramework.Aero;component/themes/aero.normalcolor.xaml")
$darkTheme.Add("Background", [System.Windows.Media.Brushes]::Black)
$darkTheme.Add("Foreground", [System.Windows.Media.Brushes]::LightBlue) # Custom text color for dark theme
$darkTheme.Add("ButtonBackground", [System.Windows.Media.Brushes]::DarkGray)
$darkTheme.Add("StatusForeground", [System.Windows.Media.Brushes]::Cyan) # Custom status text color for dark theme
$darkTheme.Add("TWKAPPLYForeground", [System.Windows.Media.Brushes]::LightBlue) # Custom status text color for dark theme

$lightTheme = New-Object System.Windows.ResourceDictionary
$lightTheme.Source = New-Object System.Uri("pack://application:,,,/PresentationFramework.Aero;component/themes/aero.normalcolor.xaml")
$lightTheme.Add("Background", [System.Windows.Media.Brushes]::White)
$lightTheme.Add("Foreground", [System.Windows.Media.Brushes]::DarkBlue) # Custom text color for light theme
$lightTheme.Add("ButtonBackground", [System.Windows.Media.Brushes]::LightGray)
$lightTheme.Add("StatusForeground", [System.Windows.Media.Brushes]::Navy) # Custom status text color for light theme
$lightTheme.Add("TWKAPPLYForeground", [System.Windows.Media.Brushes]::Navy) # Custom status text color for light theme

# Initialize theme state
$isDarkTheme = $true
$window.Resources = $DarkTheme
$window.Background = $DarkTheme["Background"]
$window.FindName("TweaksPanel").Background = $DarkTheme["Background"]
$window.FindName("StatusText").Foreground = $DarkTheme["StatusForeground"]
$window.FindName("TWKAPPLY").Foreground = $DarkTheme["TWKAPPLYForeground"]
$window.FindName("ApplyButton").Background = $DarkTheme["ButtonBackground"]
$window.FindName("CancelButton").Background = $DarkTheme["ButtonBackground"]
$window.FindName("ThemeToggleButton").Background = $DarkTheme["ButtonBackground"]

# Add checkboxes for each tweak
$tweaksPanel = $window.FindName("TweaksPanel")
$checkboxes = @{}
foreach ($tweak in $tweaks) {
    $checkbox = New-Object System.Windows.Controls.CheckBox
    $checkbox.Content = $tweak.Name
    $checkbox.Name = $tweak.Name -replace '[^a-zA-Z0-9_]', ''
    $checkbox.Margin = "0,5,0,5"
    $checkbox.Foreground = $window.Resources["Foreground"]
    $tweaksPanel.Children.Add($checkbox)
    $checkboxes[$tweak.Name] = $checkbox
}

# -------------
$checkBox1 = New-Object System.Windows.Forms.CheckBox
$checkBox1.Text = "Install Chocolatey"
$checkBox1.Location = '10,10'
$ToolTip.SetToolTip($checkBox1, "Installs the Chocolatey package manager for Windows.")
$form.Controls.Add($checkBox1)

# Theme toggle button click event
$themeToggleButton = $window.FindName("ThemeToggleButton")
$themeToggleButton.Add_Click({
    $isDarkTheme = -not $isDarkTheme
    $newTheme = if ($isDarkTheme) { $darkTheme } else { $lightTheme }
    $window.Resources = $newTheme
    $window.Background = $newTheme["Background"]
    $window.FindName("TweaksPanel").Background = $newTheme["Background"]
    $window.FindName("StatusText").Foreground = $newTheme["StatusForeground"]
	$window.FindName("TWKAPPLY").Foreground = $newTheme["TWKAPPLYForeground"] #########
    $window.FindName("ApplyButton").Background = $newTheme["ButtonBackground"]
    $window.FindName("CancelButton").Background = $newTheme["ButtonBackground"]
    $window.FindName("ThemeToggleButton").Background = $newTheme["ButtonBackground"]
    foreach ($checkbox in $checkboxes.Values) {
        $checkbox.Foreground = $newTheme["Foreground"]
    }
    Write-Log -Message "Toggled to $(if ($isDarkTheme) { 'Dark' } else { 'Light' }) theme" -Status "Info"
})

$CancelButton = $window.FindName("CancelButton")
$CancelButton.Add_Click({
		Write-Log -Message "User cancelled operation, closing application" -Status "Info"
	try {
		$window.Close()
	} catch {
		Write-Log -Message "Error closing application in CancelButton" -Status "Error" -Details $_.Exception.Message
	}
})

###################################################### Apply button click event
$applyButton = $window.FindName("ApplyButton")
$applyButton.Add_Click({
    $statusText = $window.FindName("StatusText")
    $selectedTweaks = $tweaks | Where-Object { $checkboxes[$_.Name].IsChecked }
    $totalTweaks = $selectedTweaks.Count
    $window.Dispatcher.Invoke([Action]{ 
        $statusText.Text = "Applying tweaks..."
    })
    Write-Log -Message "Starting to apply $totalTweaks tweaks" -Status "Info"
    foreach ($tweak in $selectedTweaks) {
        try {
            Write-Host " [+] Applying tweak: " -NoNewLine -Fore Green
			Write-Host " $($tweak.Name)" -Fore DarkYellow
            Write-Log -Message "Applying tweak" -TweakName $tweak.Name -Status "Info" -Details "ScriptBlock: $($tweak.ScriptBlock)"
            $result = Invoke-WPFRunspace -ScriptBlock $tweak.ScriptBlock -DebugPreference $DebugPreference
			$window.Dispatcher.Invoke([Action]{
                $statusText.Text = "Applied $($tweak.Name)"
            })
            # Write-Host " [!] Successfully applied tweak: $($tweak.Name)" -Fore Cyan
		    Write-Host " [!] Done" -Fore Cyan
			Write-Host ""
            Write-Log -Message "Successfully applied tweak" -TweakName $tweak.Name -Status "Success" -Details ($result -join "; ")
        } catch {
            $errorMessage = "Error applying tweak '$($tweak.Name)': $_"
            Write-Log -Message "Error applying tweak" -TweakName $tweak.Name -Status "Error" -Details $_.Exception.Message
            [System.Windows.MessageBox]::Show($errorMessage, "Error", "OK", "Error")
        }
    }
    # Clear all checkboxes after applying tweaks
    foreach ($checkbox in $checkboxes.Values) {
        $checkbox.IsChecked = $false
    }
    Write-Log -Message "Cleared all checkboxes after applying tweaks" -Status "Info"
    $window.Dispatcher.Invoke([Action]{
        $statusText.Text = "Ready"
    })
    Write-Log -Message "Finished applying tweaks" -Status "Info"
 #   [System.Windows.MessageBox]::Show("Selected tweaks have been applied and checkboxes cleared.", "Success", "OK", "Information")
})

# Clean up runspace on window close
$window.Add_Closed({
	$sync.runspace.Dispose()
	$sync.runspace.Close()
	[System.GC]::Collect()
    Write-Log -Message "Application closed" -Status "Info"
})

clear
Write-Host ""
Write-Host "      *** Windows Tweaks Utility $scrver by decrypt ***" -Fore Cyan
Write-Host ""
Write-Host ""
# Show the window
Write-Log -Message "Application started" -Status "Info"
$window.ShowDialog() | Out-Null