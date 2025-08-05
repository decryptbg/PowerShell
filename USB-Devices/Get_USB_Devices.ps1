<#
	Retrieves all connected USB devices and extracts their Vendor
	
	Code by: decrypt
	
	1.0 - 21.07.2025 - Begin
	1.1 - 21.07.2025 - Added '-vid' parameter so that you can either list all devices, or just look up the vendor for a specific VID

#>

param (
    [string]$vid
)
clear
Write-Host "-----------------------------------------------------------------------------------------------" -Fore Green
Write-Host ""
Write-Host "                [ Retrieves all connected USB devices and extracts their Vendor ]" -Fore Cyan
Write-Host "                                        by decrypt v1.1" -Fore DarkYellow
Write-Host ""
Write-Host "-----------------------------------------------------------------------------------------------" -Fore Green
$vendorListPath = ".\vendor.list"
$vidVendorMap = @{}

if (Test-Path $vendorListPath) {
    Get-Content $vendorListPath | ForEach-Object {
        if ($_ -match '"([0-9A-Fa-f]{4})"\s*=\s*"(.+)"') {
            $vidKey = $matches[1].ToUpper()
            $vendor = $matches[2]
            $vidVendorMap[$vidKey] = $vendor
        }
    }
} else {
    Write-Warning " [!] Vendor list not found at: $vendorListPath"
    exit
}

if ($vid) {
    $vid = $vid.ToUpper()
    if ($vidVendorMap.ContainsKey($vid)) {
		Write-Host ""
        Write-Host " [*] VID $vid belongs to: $($vidVendorMap[$vid])" -Fore DarkYellow
		Write-Host ""
    } else {
		Write-Host ""
        Write-Host "[!] VID $vid is not found in vendor list." -Fore Red
		Write-Host ""
    }
    exit
}

Get-PnpDevice -PresentOnly | Where-Object {
    $_.InstanceId -like 'USB\VID*'
} | ForEach-Object {
    $deviceID = $_.InstanceId

    if ($deviceID -match 'VID_([0-9A-Fa-f]{4})&PID_([0-9A-Fa-f]{4})') {
        $vidFound = $matches[1].ToUpper()
        $productID = $matches[2]

        $vendor = if ($vidVendorMap.ContainsKey($vidFound)) {
            $vidVendorMap[$vidFound]
        } else {
            "Unknown"
        }

        [PSCustomObject]@{
            Name       = $_.FriendlyName
            VID        = $vidFound
            Vendor     = $vendor
            ProductID  = $productID
            InstanceId = $_.InstanceId
        }
    }
} | Format-Table -AutoSize

Write-Host "-----------------------------------------------------------------------------------------------" -Fore Green