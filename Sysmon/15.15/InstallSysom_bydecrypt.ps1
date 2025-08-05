<#

*** Detecting Sysmon ***
Registry
	- reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Sysmon/Operational

Services
	- Get-Service | where-object {$_.DisplayName -like "*sysmon*"}

Sysmon Tools + Accepted Eula
	- ls HKCU:\Software\Sysinternals

#>
clear
$sysmonService = Get-Service | Where-Object { $_.DisplayName -like "*sysmon*" }
if ($sysmonService) {
    foreach ($service in $sysmonService) {
		Write-Host ""
		Write-Host "       Detecting Sysmon Service" -Fore Cyan
		Write-Host " ------------------------------------" -Fore DarkYellow
        Write-Host " Service.Name......: " -NoNewLine -Fore DarkYellow
		Write-Host "$($service.ServiceName)" -Fore Yellow
        Write-Host " Display.Name......: " -NoNewLine -Fore DarkYellow
		Write-Host "$($service.DisplayName)" -Fore Yellow
        Write-Host " Status............: " -NoNewLine -Fore DarkYellow
		Write-Host "$($service.Status)" -Fore Green
        Write-Host " Start.Type........: " -NoNewLine -Fore DarkYellow
		Write-Host "$($service.StartType)" -Fore Yellow
		Write-Host " Dependent.Services: " -NoNewLine -Fore DarkYellow
		Write-Host "$($service.DependentServices)" -Fore Yellow
        Write-Host " ------------------------------------" -Fore DarkYellow
        if ($service.Status -eq "Running") {
			Write-Host ""
            Write-Host " Sysmon service is currently running." -ForegroundColor Green
			Write-Host ""
			Write-Host " !Exiting" -Fore Cyan
			Write-Host ""
			Write-Host ""
			exit
        } elseif ($service.Status -eq "Stopped") {
			Write-Host ""
			Write-Host "       Detecting Sysmon Service" -Fore Cyan
			Write-Host " ------------------------------------" -Fore DarkYellow
            Write-Host " Sysmon service is installed but not running." -Fore Yellow
			Write-Host ""
			Write-Host ""
        } else {
			Write-Host ""
			Write-Host "       Detecting Sysmon Service" -Fore Cyan
			Write-Host " ------------------------------------" -Fore DarkYellow
            Write-Host " Sysmon service is in an unknown state." -ForegroundColor Red
			Write-Host ""
			Write-Host ""
        }
    }
} else {
	Write-Host ""
	Write-Host "       Detecting Sysmon Service" -Fore Cyan
	Write-Host " ---------------------------------------------------------------" -Fore DarkYellow
    Write-Host " Sysmon is not installed or no Sysmon-related service was found." -Fore Red
	Write-Host ""
	Write-Host " Continue with installation after 3 seconds." -Fore Green
}
sleep (3)
clear
Write-Host ""
Write-Host "                                *** Installing Sysnternals Sysmon v15.15 by decrypt ***" -fore cyan
Write-Host ""
$sysmonPath = "C:\Programdata\Sysmon\Sysmon64.exe"
$sysmonConfigPath = "C:\Programdata\Sysmon\sysmonconfig-export.xml"
$sysmonFolderPath = "C:\ProgramData\Sysmon\"
if (-not (Test-Path $sysmonFolderPath)) {
    try {
        New-Item -ItemType Directory -Path $sysmonFolderPath -Force | Out-Null
        Write-Host " Folder created successfully at $sysmonFolderPath" -fore green
    }
    catch {
        Write-Host " Error creating the folder: $_" -fore red
    }
}
else {
	Write-Host ""
    Write-Host " The folder already exists at $sysmonFolderPath" -fore yellow
	$sysmonServiceName = "Sysmon64"
	$sysmonServiceName2 = "Sysmon"
try {
    $service = Get-Service -Name $sysmonServiceName -ErrorAction SilentlyContinue
	$service2 = Get-Service -Name $sysmonServiceName2 -ErrorAction SilentlyContinue
	Write-Host " The service Sysmon64 is already registered. Uninstall Sysmon before reinstalling." -fore red
	Write-Host ""
	Write-Host ""
} catch {
    Throw " Sysmon service does not exist"
}
	exit
}
Write-Host ""
Write-Host " Copying Sysmon Files..." -fore darkyellow
Copy-Item -Path "Sysmon64.exe", "sysmonconfig-export.xml", "Eula.txt" -Destination $sysmonFolderPath
Write-Host ""
Write-Host " !Done" -fore cyan
Write-Host ""
Write-Host " Start Sysmon Precess..." -fore darkyellow
Start-Process -FilePath $sysmonPath -ArgumentList "-accepteula -i $sysmonConfigPath" -NoNewWindow -Wait
Write-Host ""
Write-Host " !Done"
Write-Host ""