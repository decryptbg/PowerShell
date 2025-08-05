<#

 Program.Name......: PowerShell SysMon SIEM
 Code.by...........: decrypt
 Script.Name.......: PowerSysSiem.ps1
 Version...........: 1.9
 Last modified date: 08.10.2024

 UtcTime........: Time the event was detected.
 ProcessID......: The PID of the process attempting to create the executable file.
 User...........: The user associated with the process creating the file.
 Image..........: The filename of the program creating the file.
 TargetFilename.: The executable file that was created. Note: In our tests, the file was always displayed under a temporary file name.
 Hash...........: The hash of the file that was being created. The displayed hashes will depend on your HashAlgorithms configuration setting.

#>
$ErrorActionPreference = "SilentlyContinue"
clear
Write-Host -Fore DarkYellow "===================================================================================================================="
Write-Host -Fore Yellow "                                               PowerShell Sysmon SIEM"
Write-Host -Fore Yellow "                                                   by decrypt v1.9"
Write-Host -Fore DarkYellow "===================================================================================================================="
Write-Host ""
Write-Host -Fore Yellow " Listening..."
Write-Host ""
Function Parse-Event {
    param(
        [Parameter(ValueFromPipeline=$true)] $Event
    )

    Process
    {
        foreach($entry in $Event)
        {
            $XML = [xml]$entry.ToXml()
            $X = $XML.Event.EventData.Data
            For( $i=0; $i -lt $X.count; $i++ ){
                $Entry = Add-Member -InputObject $entry -MemberType NoteProperty -Name "$($X[$i].name)" -Value $X[$i].'#text' -Force -Passthru
            }
            $Entry
        }
    }
}

Function Write-Alert ($alerts) {
    if ($alerts.Type -eq "Error") {
        Write-Host "Type: $($alerts.Type)" -ForegroundColor Red
    } elseif ($alerts.Type -eq "Warning") {
        Write-Host "Type: $($alerts.Type)" -ForegroundColor Yellow
    } else {
        Write-Host "Type: $($alerts.Type)" -ForegroundColor Green
    }
    $alerts.Remove("Type")
    foreach($alert in $alerts.GetEnumerator()) {
        write-host "$($alert.Name): $($alert.Value)"
    }
    write-host -Fore Cyan "-------------------------------------------------------------------------------------------------------------------"
}

$LogName = "Microsoft-Windows-Sysmon"
$maxRecordId = (Get-WinEvent -Provider $LogName -max 1).RecordID

while ($true)
{
    Start-Sleep 1

    $xPath = "*[System[EventRecordID > $maxRecordId]]"
    $logs = Get-WinEvent -Provider $LogName -FilterXPath $xPath | Sort-Object RecordID

    foreach ($log in $logs) {
        $evt = $log | Parse-Event
        if ($evt.id -eq 1) {
            $output = @{}
            $output.add("Type", "Process Create")
            $output.add(" PID...............", $evt.ProcessId)
            $output.add(" Image.............", $evt.Image)
            $output.add(" CommandLine.......", $evt.CommandLine)
            $output.add(" CurrentDirectory..", $evt.CurrentDirectory)
            $output.add(" User..............", $evt.User)
            $output.add(" ParentImage.......", $evt.ParentImage)
            $output.add(" ParentCommandLine.", $evt.ParentCommandLine)
            $output.add(" ParentUser........", $evt.ParentUser)
            write-alert $output
        }
        if ($evt.id -eq 2) {
            $output = @{}
            $output.add("Type....................", "File Creation Time Changed")
            $output.add(" PID.....................", $evt.ProcessId)
            $output.add(" Image...................", $evt.Image)
            $output.add(" TargetFilename..........", $evt.TargetFileName)
            $output.add(" CreationUtcTime.........", $evt.CreationUtcTime)
            $output.add(" PreviousCreationUtcTime.", $evt.PreviousCreationUtcTime)
            write-alert $output
        }
        if ($evt.id -eq 3) {
            $output = @{}
            $output.add("Type", "Network Connection")
            $output.add(" Image...........", $evt.Image)
            $output.add(" DestinationIp...", $evt.DestinationIp)
            $output.add(" DestinationPort.", $evt.DestinationPort)
            $output.add(" DestinationHost.", $evt.DestinationHostname)
            write-alert $output
        }
        if ($evt.id -eq 5) {
            $output = @{}
            $output.add("Type", "Process Ended")
            $output.add(" PID...............", $evt.ProcessId)
            $output.add(" Image.............", $evt.Image)
            $output.add(" CommandLine.......", $evt.CommandLine)
            $output.add(" CurrentDirectory..", $evt.CurrentDirectory)
            $output.add(" User..............", $evt.User)
            $output.add(" ParentImage.......", $evt.ParentImage)
            $output.add(" ParentCommandLine.", $evt.ParentCommandLine)
            $output.add(" ParentUser........", $evt.ParentUser)
            write-alert $output
        }
        if ($evt.id -eq 6) {
            $output = @{}
            $output.add("Type", "Driver Loaded")
			$output.add(" UTCTime.........", $evt.UtcTime)
			$output.add(" ImageLoaded.....", $evt.ImageLoaded)
			$output.add(" Signature.......", $evt.Signature)
			$output.add(" SignatureStatus.", $evt.SignatureStatus)
			$output.add(" Hashes..........", $evt.Hashes)
            write-alert $output
        }
        if ($evt.id -eq 7) {
            $output = @{}
            $output.add("Type", "DLL Loaded By Process")
			$output.add(" UTCTime..........", $evt.UtcTime)
			$output.add(" Image............", $evt.Image)
			$output.add(" ImageLoaded......", $evt.ImageLoaded)
			$output.add(" PID..............", $evt.ProcessId)
			$output.add(" Signature........", $evt.Signature)
			$output.add(" SignatureStatus..", $evt.SignatureStatus)
			$output.add(" User.............", $evt.User)
			$output.add(" Product..........", $evt.Product)
			$output.add(" Company..........", $evt.Company)
			$output.add(" OriginalFileName.", $evt.OriginalFileName)
			$output.add(" Description......", $evt.Description)
            write-alert $output
        }
        if ($evt.id -eq 8) {
            $output = @{}
            $output.add("Type", "Remote Thread Created")
            write-alert $output
        }
        if ($evt.id -eq 9) {
            $output = @{}
            $output.add("Type", "Raw Disk Access")
            write-alert $output
        }
        if ($evt.id -eq 10) {
            $output = @{}
            $output.add("Type", "Inter-Process Access")
            write-alert $output
        }
        if ($evt.id -eq 11) {
            $output = @{}
            $output.add("Type", "File Create")
			$output.add(" UTCTime........", $evt.UtcTime)
            $output.add(" RecordID.......", $evt.RecordID)
            $output.add(" TargetFilename.", $evt.TargetFileName)
            $output.add(" User...........", $evt.User)
            $output.add(" Process........", $evt.Image)
            $output.add(" PID............", $evt.ProcessID)
            write-alert $output
        }
        if ($evt.id -eq 12) {
            $output = @{}
            $output.add("Type", "Registry Added or Deleted")
			$output.add(" EventType.", $evt.EventType)
			$output.add(" PID.......", $evt.ProcessID)
			$output.add(" Process...", $evt.Image)
			$output.add(" User......", $evt.User)
            write-alert $output
        }
        if ($evt.id -eq 13) {
            $output = @{}
            $output.add("Type", "Registry Set")
			$output.add(" UTCTime......", $evt.UtcTime)
			$output.add(" EventType....", $evt.EventType)
			$output.add(" PID..........", $evt.ProcessID)
			$output.add(" Process......", $evt.Image)
			$output.add(" TargetObject.", $evt.TargetObject)
			
            write-alert $output
        }
        if ($evt.id -eq 14) {
            $output = @{}
            $output.add("Type", "Registry Object Renamed")
            write-alert $output
        }
        if ($evt.id -eq 15) {
            $output = @{}
            $output.add("Type", "ADFS Created")
            write-alert $output
        }
        if ($evt.id -eq 16) {
            $output = @{}
            $output.add("Type", "Sysmon Configuration Change")
            write-alert $output
        }
        if ($evt.id -eq 17) {
            $output = @{}
            $output.add("Type", "Pipe Created")
			$output.add(" UTCTime...", $evt.UtcTime)
			$output.add(" EventType.", $evt.EventType)
			$output.add(" PID.......", $evt.ProcessID)
			$output.add(" PipeName..", $evt.PipeName)
			$output.add(" Image.....", $evt.Image)
			
            write-alert $output
        }
        if ($evt.id -eq 18) {
            $output = @{}
            $output.add("Type", "Pipe Connected")
            write-alert $output
        }
        if ($evt.id -eq 19) {
            $output = @{}
            $output.add("Type", "WMI Event Filter Activity")
            write-alert $output
        }
        if ($evt.id -eq 20) {
            $output = @{}
            $output.add("Type", "WMI Event Consumer Activity")
            write-alert $output
        }
        if ($evt.id -eq 21) {
            $output = @{}
            $output.add("Type", "WMI Event Consumer To Filter Activity")
            write-alert $output
        }
        if ($evt.id -eq 22) {
            $output = @{}
            $output.add("Type", "DNS Query")
			$output.add(" UTCTime......", $evt.UtcTime)
			$output.add(" PID..........", $evt.ProcessID)
			$output.add(" Process......", $evt.Image)
			$output.add(" QueryName....", $evt.QueryName)
			$output.add(" QueryResults.", $evt.QueryResults)
            write-alert $output
        }
        if ($evt.id -eq 23) {
            $output = @{}
            $output.add("Type", "File Delete")
			$output.add(" UTCTime........", $evt.UtcTime)
            $output.add(" RecordID.......", $evt.RecordID)
            $output.add(" TargetFilename.", $evt.TargetFileName)
            $output.add(" User...........", $evt.User)
            $output.add(" Process........", $evt.Image)
            $output.add(" PID............", $evt.ProcessID)
            write-alert $output
        }
        if ($evt.id -eq 24) {
            $output = @{}
            $output.add("Type", "Clipboard Event Monitor")
            write-alert $output
        }
        if ($evt.id -eq 25) {
            $output = @{}
            $output.add("Type", "Process Tamper")
			$output.add(" UTCTime.", $evt.UtcTime)
			$output.add(" PID.....", $evt.ProcessID)
			$output.add(" Process.", $evt.Image)
			$output.add(" Type....", $evt.Type)
            write-alert $output
        }
        if ($evt.id -eq 26) {
            $output = @{}
            $output.add("Type", "File Delete Logged")
            $output.add(" RecordID.......", $evt.RecordID)
            $output.add(" TargetFilename.", $evt.TargetFileName)
            $output.add(" User...........", $evt.User)
            $output.add(" Process........", $evt.Image)
            $output.add(" PID............", $evt.ProcessID)
            write-alert $output
        }
        $maxRecordId = $evt.RecordId
    }
}
