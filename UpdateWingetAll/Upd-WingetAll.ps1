<#

	Uses "-ExecutionPolicy Bypass" to avoid policy blocks.


#>
Function Update-WingetAll {
    $wingetScript = @"
`$host.ui.RawUI.WindowTitle = '*** Update All Installed Software by decrypt ***'
Start-Transcript -Path .\winget-update.log -Append
winget upgrade --all --accept-source-agreements --accept-package-agreements --scope=machine --silent
Stop-Transcript
"@
    $tempScriptPath = "$env:TEMP\winget-update-temp.ps1"
    $wingetScript | Set-Content -Path $tempScriptPath -Encoding UTF8
    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$tempScriptPath`"" -Verb RunAs -Wait
	Remove-Item -Path $tempScriptPath -Force
}
Clear-Host
Write-Host ""
Write-Host "                                    Update All Installed Software with WinGet" -Fore Green
Write-Host " Please wait..." -Fore Yellow
Write-Host ""
Update-WingetAll
Write-Host " [!] Done" -Fore Cyan
Write-Host ""
Write-Host ""
