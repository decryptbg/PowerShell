clear
function Create-PSTRegistryKey {
    param (
        [string]$outlookVersion
    )

    $registryPath = "HKCU:\Software\Microsoft\Office\$outlookVersion\Outlook\PST"

    if (-not (Test-Path $registryPath)) {
        New-Item -Path $registryPath -Force | out-null
		Write-Host ""
        Write-Host " [INFO] Created PST registry key for Outlook version $outlookVersion." -ForeGroundColor Yellow
		Write-Host ""
    }
}
Write-Host ""
Write-Host "                   Expand Outlook PST File Size Limit" -ForeGroundColor Cyan
Write-Host "                               by decrypt" -ForeGroundColor DarkGray
Write-Host ""
$Keys = Get-Item -Path HKLM:\Software\RegisteredApplications | Select-Object -ExpandProperty property
$Product = $Keys | Where-Object {$_ -Match "Excel.Application."}
$outlookVersion = ($Product.Replace("Excel.Application.","")+".0")

function Set-PSTLimit {
     # $outlookVersion = Read-Host "Enter Outlook Version (e.g., 16.0, 15.0, 14.0, 12.0, 11.0):"
    if ($outlookVersion -match "^\d+\.\d+$") {
        Create-PSTRegistryKey -outlookVersion $outlookVersion
        $registryPath = "HKCU:\Software\Microsoft\Office\$outlookVersion\Outlook\PST"
        $regValueName1 = "MaxLargeFileSize"
		$regValueName2 = "WarnLargeFileSize"
		Write-Host ""
        $limit = Read-Host " Enter PST File Size Limit (in GB)"
		$MaxLargeFileSize = 1024 * $limit
		Write-Host ""
		Write-Host " MaxLargeFileSize is set to $MaxLargeFileSize MB" -ForeGroundColor Green
		$WarnLargeFileSize = $MaxLargeFileSize * .95
		Write-Host " WarnLargeFileSize is set to $WarnLargeFileSize MB" -ForeGroundColor Green
		Write-Host ""
		$Value01 = $MaxLargeFileSize
		$Value02 = $WarnLargeFileSize
		New-ItemProperty -Path $registryPath -Name $regValueName1 -Value $Value01 -PropertyType DWORD -Force | out-null
		New-ItemProperty -Path $registryPath -Name $regValueName2 -Value $Value02 -PropertyType DWORD -Force | out-null
		Write-Host " !Done" -ForeGroundColor Cyan
		Write-Host ""
	}
}
Set-PSTLimit