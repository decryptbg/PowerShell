[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
<#
.SYNOPSIS
	MikroTik WinBox Extractor.

.DESCRIPTION
	The MikroTik WinBox Extractor retrieves Host Address, Login Name, and Password from settings.cfg.viw.

.COMPILE_DATE
	Date: 28.08.2023

.EXAMPLE
	PS> .\MikroTikWinBox_Extractor.ps1

.LINK
	https://github.com/decryptbg/PowerShell/blob/main/MikroTikWinBox_Extractor/MikroTikWinBox_Extractor.ps1

.VERSION
	2.0 - 28.08.2023
	- Added retrieves Host Address
	
	1.9 - 20.08.2023
	- Fix retrieves Password with Special Symbols
	
	....
	
	1.0 - 19.08.2023
	- Begin
#>

clear
$MyVersion = "v2.0"
$t = @"

                          •[ MikroTik WinBox Extractor ]•   
                     ___                                    __         
                  __| _/ ____   ____ ___________ ________ _/  |_ 
                 / __ |_/ __ \_/ ___\\_  __ \   |  |____ \\   __\
                / /_/ |\  ___/_  \___ |  | \/\___  |  |_\ \|  |  
                \____ | \___  /\___  /|__|   / ____|   ___/|__|  
                     \/     \/     \/        \/    |__|          
                                                                  
                                                     $MyVersion   

"@

for ($i=0;$i -lt $t.length;$i++) {
if ($i%2) {
 $c = "red"
}
elseif ($i%5) {
 $c = "yellow"
}
elseif ($i%7) {
 $c = "green"
}
else {
   $c = "white"
}
write-host $t[$i] -NoNewline -ForegroundColor $c
}

Write-Host ""
Write-Host "*----------------------------[ Extracted Passwords ]---------------------------*" -ForegroundColor Green
Write-Host ""
$filePath = "C:\Users\$env:USERNAME\AppData\Roaming\Mikrotik\Winbox\settings.cfg.viw"

function ExtractPassword($content) {
    $passwordPattern = "pwd(\w+\S*?)\x0B\x00\x06"
    $passwordMatches = [Regex]::Matches($content, $passwordPattern)

    foreach ($match in $passwordMatches) {
        $password = $match.Groups[1].Value
        Write-Host "Password....: " -ForegroundColor Yellow -NoNewline
		Write-Host "$password"
    }
}


if (Test-Path -Path $filePath) {
    $fileContent = Get-Content -Path $filePath -Raw

    $loginPattern = "login(\w+)\x08\x00\x03"
    $addressPattern = "addr([\w-]+)\x05\x00\x03"

    $loginMatches = [Regex]::Matches($fileContent, $loginPattern)
    $addressMatches = [Regex]::Matches($fileContent, $addressPattern)

    foreach ($match in $loginMatches) {
        $username = $match.Groups[1].Value
        Write-Host "Username....: " -ForegroundColor Yellow -NoNewline
		Write-Host "$username"
    }

    foreach ($match in $addressMatches) {
        $hostname = $match.Groups[1].Value
        Write-Host "Host.Address: " -ForegroundColor Yellow -NoNewline
        Write-Host "$hostname"
    }

    ExtractPassword $fileContent
} else {
    Write-Host " Error.....: File not found!" -ForegroundColor DarkRed
	Write-Host " Check Path: $filePath" -ForegroundColor DarkRed
}
Write-Host ""
Write-Host "*------------------------------------------------------------------------------*" -ForegroundColor Green
Write-Host ""