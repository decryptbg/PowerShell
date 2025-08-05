<#

.SYNOPSIS
    IPv4 Recon v2.1

.DESCRIPTION
    Scans active IP addresses, resolves hostnames, and retrieves MAC addresses for a single IP or an entire network.
    Includes parallel scanning, input validation, progress indicators, and export options.

.AUTHOR
    Ivo Lyubenov

.COMPILE_DATE
    Date: 13.06.2025

.EXAMPLE
    PS> .\IPv4Recon.ps1

.VERSION
    2.0 - 17.10.2024
        - Initial version with single IP and network scan functionality
    2.1 - 13.06.2025
        - Added parallel scanning for network scans
        - Added input validation for IP addresses and network prefixes
        - Added progress indicator for network scans
        - Added CSV export option
        - Improved MAC address retrieval using Get-NetNeighbor
        - Added customizable ping timeout
        - Added optional logging
#>

function Test-IPAddress {
    param (
        [string]$IPAddress
    )
    $ipPattern = "^(\d{1,3}\.){3}\d{1,3}$"
    if ($IPAddress -match $ipPattern) {
        $octets = $IPAddress.Split('.')
        return ($octets | ForEach-Object { [int]$_ -ge 0 -and [int]$_ -le 255 }) -notcontains $false
    }
    return $false
}

function Test-NetworkPrefix {
    param (
        [string]$NetworkPrefix
    )
    $prefixPattern = "^(\d{1,3}\.){2}\d{1,3}$"
    if ($NetworkPrefix -match $prefixPattern) {
        $octets = $NetworkPrefix.Split('.')
        return ($octets | ForEach-Object { [int]$_ -ge 0 -and [int]$_ -le 255 }) -notcontains $false
    }
    return $false
}

function Get-NetworkInfo {
    param (
        [string]$IPAddress,
        [int]$PingTimeout = 30
    )

    try {
        $ping = New-Object System.Net.NetworkInformation.Ping
        $pingResult = $ping.Send($IPAddress, $PingTimeout)

        if ($pingResult.Status -eq 'Success') {
            try {
                $hostname = [System.Net.Dns]::GetHostEntry($IPAddress).HostName
            } catch {
                $hostname = "N/A"
            }
            arp -d | Out-Null
            ping $IPAddress -n 1 -w $PingTimeout | Out-Null
            $macAddress = "N/A"
            try {
                $neighbor = Get-NetNeighbor -IPAddress $IPAddress -ErrorAction SilentlyContinue
                if ($neighbor) {
                    $macAddress = $neighbor.LinkLayerAddress
                } else {
                    # Fallback to arp -a
                    $arpResult = arp -a | Where-Object { $_ -match $IPAddress }
                    if ($arpResult) {
                        $arpColumns = $arpResult -split '\s+'
                        $macAddress = $arpColumns[2]
                    }
                }
            } catch {
                $macAddress = "N/A"
            }

            return [pscustomobject]@{
                IPAddress  = $IPAddress
                Hostname   = $hostname
                MACAddress = $macAddress
            }
        }
    } catch {
        Write-Log -Message "Error scanning $IPAddress : $_" -Level "Error"
        return $null
    }
    return $null
}

function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "Info",
        [string]$LogFile = "IPv4Recon.log"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    Add-Content -Path $LogFile -Value $logEntry
}

function Scan-StaticIP {
    param (
        [string]$IPAddress,
        [int]$PingTimeout = 30
    )

    if (-not (Test-IPAddress -IPAddress $IPAddress)) {
        Write-Host -Fore DarkRed "Invalid IP address format: $IPAddress"
        Write-Log -Message "Invalid IP address format: $IPAddress" -Level "Error"
        return
    }

    $result = Get-NetworkInfo -IPAddress $IPAddress -PingTimeout $PingTimeout
    if ($result) {
        $result | Format-Table -Property IPAddress, Hostname, MACAddress -AutoSize
        Write-Log -Message "Scanned IP $IPAddress - Hostname: $($result.Hostname), MAC: $($result.MACAddress)"
    } else {
        Write-Host -Fore DarkRed "The IP address $IPAddress is not reachable."
        Write-Log -Message "IP $IPAddress is not reachable" -Level "Warning"
    }
    return $result
}

function Scan-Network {
    param (
        [string]$NetworkPrefix,
        [int]$PingTimeout = 30,
        [string]$OutputFile
    )

    if (-not (Test-NetworkPrefix -NetworkPrefix $NetworkPrefix)) {
        Write-Host -Fore DarkRed "Invalid network prefix format: $NetworkPrefix"
        Write-Log -Message "Invalid network prefix format: $NetworkPrefix" -Level "Error"
        return
    }
    $results = @()
    $ips = 1..254 | ForEach-Object { "$NetworkPrefix.$_" }
    $total = $ips.Count
    $current = 0
    $results = $ips | ForEach-Object -Parallel {
        $ip = $_
        $current = [System.Threading.Interlocked]::Increment([ref]$using:current)
        Write-Progress -Activity "Scanning Network" -Status "Pinging $ip" -PercentComplete (($current / $using:total) * 100)
        $result = & $using:PSCommandPath Get-NetworkInfo -IPAddress $ip -PingTimeout $using:PingTimeout
        if ($result) {
            Write-Host "Active IP: $($result.IPAddress), Hostname: $($result.Hostname), MAC: $($result.MACAddress)" -Fore Green
            Write-Log -Message "Active IP: $ip - Hostname: $($result.Hostname), MAC: $($result.MACAddress)"
        }
        return $result
    } -ThrottleLimit 1 | Where-Object { $_ -ne $null }
    Write-Progress -Activity "Scanning Network" -Completed
    if ($results.Count -gt 0) {
        Write-Host "`nActive devices on the network:" -Fore Cyan
        $results | Format-Table -Property IPAddress, Hostname, MACAddress -AutoSize
        Write-Host -Fore Cyan "!Done"
        Write-Log -Message "Network scan completed. Found $($results.Count) active devices."

        if ($OutputFile) {
            $results | Export-Csv -Path $OutputFile -NoTypeInformation
            Write-Host -Fore Cyan "Results exported to $OutputFile"
            Write-Log -Message "Results exported to $OutputFile"
        }
    } else {
        Write-Host -Fore DarkYellow "No active devices found on the network."
        Write-Log -Message "No active devices found on the network" -Level "Warning"
    }
    return $results
}
Clear-Host
Write-Host "`n                                IPv4 Recon v2.1`n" -Fore Cyan
Write-Host -Fore DarkGreen "Choose an Option:`n"
Write-Host -Fore DarkYellow "1. Scan a single IP address"
Write-Host -Fore DarkYellow "2. Scan the entire network`n"
$choice = Read-Host "Enter 1 or 2"
$timeout = Read-Host "Enter ping timeout in milliseconds (default: 30)"
$timeout = if ($timeout -match '^\d+$') { [int]$timeout } else { 30 }
$export = Read-Host "Export results to CSV? (y/n)"
$outputFile = if ($export -eq 'y' -or $export -eq 'Y') { Read-Host "Enter CSV file path (e.g., results.csv)" } else { $null }

if ($choice -eq "1") {
    Write-Host ""
    $staticIP = Read-Host "Enter the static IP address to scan"
    Write-Host "`nScanning IP Address`n" -Fore Cyan
    $result = Scan-StaticIP -IPAddress $staticIP -PingTimeout $timeout
    if ($result -and $outputFile) {
        $result | Export-Csv -Path $outputFile -NoTypeInformation
        Write-Host -Fore Cyan "Results exported to $outputFile"
        Write-Log -Message "Results exported to $outputFile"
    }
} elseif ($choice -eq "2") {
    Write-Host ""
    $networkPrefix = Read-Host "Enter the network prefix (e.g., 192.168.1)"
    Write-Host "`nScanning Entire Network. Please wait...`n" -Fore Cyan
    Scan-Network -NetworkPrefix $networkPrefix -PingTimeout $timeout -OutputFile $outputFile
} else {
    Write-Host -Fore DarkRed "Invalid choice. Please enter 1 or 2."
    Write-Log -Message "Invalid choice entered: $choice" -Level "Error"
}