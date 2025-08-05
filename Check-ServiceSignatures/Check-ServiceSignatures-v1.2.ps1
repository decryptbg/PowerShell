<# 

 Description: Scans Windows service binaries and checks their digital signatures.
 Warning....: If your system integrity is compromised, digital signature results may not be trustworthy.
 
#>
clear
function Check-Signatures {
	Write-Host ""
    Write-Host " [+] Scanning service binaries for digital signatures..." -Fore Cyan
	Write-Host ""

    $services = Get-WmiObject Win32_Service | Select-Object -ExpandProperty PathName

    foreach ($path in $services) {
        if (-not $path) { continue }

        # Extract executable path (up to .exe)
        if ($path -match '\.exe') {
            $exePath = $path.Substring(0, $path.IndexOf('.exe') + 4).Replace('"','')

            # Skip svchost.exe unless you want to check it too
            if ($exePath -ieq "C:\Windows\System32\svchost.exe") { continue }

            # Check if file exists
            if (-not (Test-Path $exePath)) {
                Write-Host " [!] File not found: $exePath" -Fore DarkGray
                continue
            }

            # Get the signature status
            $sig = Get-AuthenticodeSignature $exePath

            # Choose color based on status
            switch ($sig.Status) {
                'Valid' {
                    $color = 'Green'
                }
                'NotSigned' {
                    $color = 'Yellow'
                }
                default {
                    $color = 'Red'
                }
            }

            Write-Host (" {0,-12} : {1}" -f $sig.Status, $sig.Path) -Fore $color
        }
    }

    Write-Host "`n [!] Scan complete. Press any key to exit." -Fore Cyan
    [void][System.Console]::ReadKey($true)
}

# Run the check
Check-Signatures
Write-Host ""