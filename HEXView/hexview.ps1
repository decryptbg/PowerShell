<#
    .SYNOPSIS
		HEX-View Command Line.

    .DESCRIPTION
		The HEX-View Command Line is a utility that assists in viewing small files displayed in hex format..
		
    .COMPILE_DATE
		Date: 12.08.2023

    .EXAMPLE
		To view a file in HEX
		PS> .\hexview.ps1 -filePath "<FilePath\FileName>"

    .EXAMPLE
		To view a text string in HEX
		PS> .\hexview.ps1 -Text "Hello, World!"

    .EXAMPLE
		To view a file in HEX and produce a report.
		PS> .\hexview.ps1 -filePath "<FilePath\FileName>" -Report

    .LINK
		https://github.com/decryptbg/PowerShell/tree/main/HEXView
	
    .VERSION
		1.2 - 12.08.2023
			- Added produce a report
		
		1.1 - 11.08.2023
			- Added view a text string in HEX
		
		1.0 - 11.08.2023
			- Begin
			- View a file in HEX
#>

param(
    [string]$FilePath,
    [string]$Text,
	[switch]$Report
)

<#
$chunkSize = 100
$offset = 0

function DisplayHexChunk($fileBytes, $offset, $chunkSize) {
    $hexFormatted = $fileBytes[$offset..($offset + $chunkSize - 1)] | Format-Hex
    Write-Host $hexFormatted
}
#>

clear
Write-Host "▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄" -ForegroundColor Cyan
Write-Host ""
Write-Host "                                 HEX-View Command Line" -ForegroundColor Cyan
Write-Host "                                    by decrypt v1.2" -ForegroundColor Gray
Write-Host ""
Write-Host "▄▄▄[INFO]▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄" -ForegroundColor Cyan
if ($FilePath -and $Text) {
	Write-Host ""
    Write-Host " Please specify either -FilePath or -Text, not both." -ForegroundColor Red
	Write-Host ""
    return
}

if ($FilePath) {
	$fileBytes = [System.IO.File]::ReadAllBytes($FilePath)
	$sizeInBytes = $fileBytes.Length
    $sizeInKB = [math]::Round($sizeInBytes / 1024, 2)
	Write-Host " Input File: $FilePath" -ForegroundColor Yellow
	Write-Host " File Size: $sizeInBytes bytes ($sizeInKB KB)" -ForegroundColor Yellow
	Write-Host "▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄" -ForegroundColor Cyan
    $hexFormatted = $fileBytes | Format-Hex
    $hexFormatted
    # DisplayHexChunk $fileBytes $offset $chunkSize
	
}
elseif ($Text) {
	Write-Host " Input String: $Text" -ForegroundColor Yellow
	Write-Host "▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄" -ForegroundColor Cyan
    $textBytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
	
    $hexFormatted = $textBytes | Format-Hex
    $hexFormatted
	# DisplayHexChunk $textBytes $offset $chunkSiz
}
else {
	Write-Host ""
    Write-Host " Please specify either -FilePath(To view a file in HEX) or -Text(To view a text string in HEX)." -ForegroundColor Red
	Write-Host ""
}

if ($Report) {
    $reportFilePath = "HexViewReport.html"
    $reportContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>HEX-View Command Line</title>
</head>
<body>
    <h1>HEX-View Command Line</h1>
	<p> [ by decrypt v1.2]</p>
    <p> Generated at: $(Get-Date)</p>
    <h2>File Information</h2>
    <p> Input File: $FilePath</p>
    <p> File Size: $sizeInBytes bytes ($sizeInKB KB)</p>
    <h2>Hex View</h2>
    <pre> $hexFormatted</pre>
</body>
</html>
"@
    $reportContent | Set-Content -Path $reportFilePath
	Write-Host ""
    Write-Host " Report generated: $reportFilePath" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄" -ForegroundColor Cyan