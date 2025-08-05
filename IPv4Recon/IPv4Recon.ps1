<#
.SYNOPSIS
	IPv4 Recon v2.0

.DESCRIPTION
	The IPv4 Recon script allows users to check the network's active IP addresses, hostnames, and MAC addresses.
	The script allows scanning the entire network or a specific static IP address based on user input.

.COMPILE_DATE
	Date: 17.10.2024

.EXAMPLE
	PS> .\IPv4Recon.ps1

.LINK
	https://github.com/decryptbg/IPv4Recon/tree/main

.VERSION
	1.0 - 16.10.2024
		- Begin
	1.1 - 16.10.2024
		- Fix the problem with the last octet
	1.2 - 16.10.2024
		- Fine-tune the ping and arp
	1.3 - 17.10.2024
		- Correct hostname extraction
		- Add MAC address lookup
	1.4 - 17.10.2024
		- Static IP and Network Scan Handling:
			Both methods (Scan-Network and Scan-StaticIP) now utilize the ping command for host detection and hostname resolution,
			ensuring consistent behavior across both cases.
	1.5 - 17.10.2024
		- Feedback for each ping:
			Messages like "Pinging IP: x.x.x.x" and "Active/Inactive: x.x.x.x" are shown to provide clarity during the scan.
	1.6 - 17.10.2024
		- Fix the resolving the hostname
	1.7 - 17.10.2024
		- Update the Script to Correctly Extract the MAC Address
	1.8 - 17.10.2024
		- Improve the hostname extraction
	1.9 - 17.10.2024
		- Update the script with an option to scan a single IP address or the entire network.
	2.0 - 17.10.2024
		- Remove the feedback message for each ping. The script now only shows active IP addresses without printing out each IP being scanned.

#>
function Get-NetworkInfo {
    param (
        [string]$IPAddress
    )

    $pingResult = ping $IPAddress -a -n 1 -f -4 -w 30

    if ($pingResult -match "Reply from") {
        $hostnameMatch = $pingResult | Select-String -Pattern "Pinging (.+) \[.*\]" | ForEach-Object {
            if ($_ -match "Pinging (.+) \[.*\]") {
                return $matches[1]
            }
        }
        if (-not $hostnameMatch) {
            try {
                $hostnameMatch = [System.Net.Dns]::GetHostEntry($IPAddress).HostName
            }
            catch {
                $hostnameMatch = "N/A"
            }
        }
        $hostname = if ($hostnameMatch) { $hostnameMatch } else { "N/A" }
        arp -d
        ping $IPAddress -n 1 | Out-Null
        $arpResult = arp -a | Where-Object { $_ -match $IPAddress }

        if ($arpResult) {
            $arpColumns = $arpResult -split '\s+'
            $macAddress = $arpColumns[2]
        } else {
            $macAddress = "N/A"
        }

        [pscustomobject]@{
            IPAddress  = $IPAddress
            Hostname   = $hostname
            MACAddress = $macAddress
        }
    } else {
        return $null
    }
}

function Scan-StaticIP {
    param (
        [string]$IPAddress
    )

    $result = Get-NetworkInfo -IPAddress $IPAddress
    if ($result) {
        $result | Format-Table -Property IPAddress, Hostname, MACAddress -AutoSize
    } else {
        Write-Host -Fore DarkRed " The IP address $IPAddress is not reachable."
    }
}

function Scan-Network {
    param (
        [string]$NetworkPrefix
    )

    $results = @()
    for ($i = 1; $i -le 254; $i++) {
        $ip = "$NetworkPrefix.$i"
        $result = Get-NetworkInfo -IPAddress $ip
        if ($result) {
            $results += $result
            Write-Host " Active IP: $($result.IPAddress), Hostname: $($result.Hostname), MAC: $($result.MACAddress)" -ForegroundColor Green
        }
    }

    if ($results.Count -gt 0) {
        Write-Host "`nActive devices on the network:" -ForegroundColor Cyan
        $results | Format-Table -Property IPAddress, Hostname, MACAddress -AutoSize
		Write-Host -Fore Cyan " !Done"
		Write-Host ""
    } else {
        Write-Host -Fore DarkYellow " No active devices found on the network."
    }
}
clear
Write-Host ""
Write-Host -Fore Cyan "                                IPv4 Recon v2.0"
Write-Host ""
Write-Host -Fore DarkGreen " Choose an Option:"
Write-Host ""
Write-Host -Fore DarkYellow " 1. Scan a single IP address"
Write-Host -Fore DarkYellow " 2. Scan the entire network (e.g., 192.168.1.x)"
Write-Host ""
$choice = Read-Host " Enter 1 or 2"
if ($choice -eq "1") {
	Write-Host ""
    $staticIP = Read-Host " Enter the static IP address to scan"
	Write-Host ""
	Write-Host -Fore Cyan " Scanning IP Address"
	Write-Host ""
    Scan-StaticIP -IPAddress $staticIP
} elseif ($choice -eq "2") {
	Write-Host ""
    $networkPrefix = Read-Host " Enter the network prefix (e.g., 192.168.1)"
	Write-Host ""
	Write-Host -Fore Cyan " Scanning Entire Network. Please wait..."
	Write-Host ""
    Scan-Network -NetworkPrefix $networkPrefix
} else {
    Write-Host -Fore DarkRed " Invalid choice. Please enter 1 or 2."
}
