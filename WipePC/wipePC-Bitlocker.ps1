<# 
 
 WipePC BitLocker
 
#>

# Obtain the bitlocker recoverypassword
try {
    $pass = manage-bde -protectors -get "C:" -type recoverypassword
    $pass = $pass.split([Environment]::NewLine)[9].trim()
} catch {
    $output = ",Error obtaining RecoveryKey"
    Write-Output $output
    exit
}
# forces bitlocker into recovery mode
try {
    $result = manage-bde -forcerecovery C:
    # get rid of commas and linebreaks
    $result = $($result.replace(',', ' ') -join ' ')
    $output = "${pass},${result}"
} catch {
    $output = "${pass},Error forcing recovery"
    Write-Output $output
    exit
}
# create a scheduled task to force a second reboot (just in case)
try {
    $restartTask = 'ForceSecondRestart'
    $action = New-ScheduledTaskAction -Execute "C:\WINDOWS\system32\shutdown.exe" -Argument "/r /t 0 /f"
    $principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM'
    $trigger = New-ScheduledTaskTrigger -Once -At ([DateTime]::Now.AddMinutes(10))
    $trash = Register-ScheduledTask -Action $action -TaskName $restartTask -Trigger $trigger -Principal $principal
} catch {
    Write-Output $output
    Start-Sleep 30
    C:\WINDOWS\system32\shutdown.exe /r /t 0 /f
    exit
}
# sleep before restarting
Write-Output $output
Start-Sleep 30
C:\WINDOWS\system32\shutdown.exe /r /t 0 /f