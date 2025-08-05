<#

Simple-PowerShell-HTTP-File-Server
A crude and simple HTTP File Server PowerShell Script

Listens on port 8081 by default
Use /stop - to stop the script/http listener
Use / - to list the directories and files in the webroot (this will be where the PowerShell script is stored)
Use /filename.ext - to download files, display text content in the web browser, etc. (works with Invoke-WebRequest/wget)

#>
clear
$getcurrip = (Test-Connection -ComputerName (hostname) -Count 1).IPV4Address.IPAddressToString
Write-Host ""
Write-Host -Fore DarkCyan "                            **[ PowerShell HTTP File Server ]**"
Write-Host ""
Write-Host -Fore Green " [ Info: ]"
Write-Host " Listen on IP Address: $getcurrip"
Write-Host " Listen on Port......: 8081"
Write-Host " Directory...........: $PWD"
Write-Host ""
Write-Host -Fore Green " [ Help: ]"
Write-Host " Use /stop - to stop the script/http listener(http://localhost:8081/stop)"
Write-Host " Use /filename.ext - to download files(http://localhost:8081/filename.ext)"
Write-Host " Use / - to list the directories and files in the webroot (this will be where the PowerShell script is stored)"
Write-Host ""
Write-Host -Fore Cyan " Listening..."
$httpsrvlsnr = New-Object System.Net.HttpListener;
$httpsrvlsnr.Prefixes.Add("http://+:8081/");
$httpsrvlsnr.Start();
$webroot = New-PSDrive -Name webroot -PSProvider FileSystem -Root $PWD.Path
[byte[]]$buffer = $null

while ($httpsrvlsnr.IsListening) {
    try {
        $ctx = $httpsrvlsnr.GetContext();
        
        if ($ctx.Request.RawUrl -eq "/") {
            $buffer = [System.Text.Encoding]::UTF8.GetBytes("<html><pre>$(Get-ChildItem -Path $PWD.Path -Force | Out-String)</pre></html>");
            $ctx.Response.ContentLength64 = $buffer.Length;
            $ctx.Response.OutputStream.WriteAsync($buffer, 0, $buffer.Length)
        }
        elseif ($ctx.Request.RawUrl -eq "/stop"){
            $httpsrvlsnr.Stop();
            Remove-PSDrive -Name webroot -PSProvider FileSystem;
        }
        elseif ($ctx.Request.RawUrl -match "\/[A-Za-z0-9-\s.)(\[\]]") {
            if ([System.IO.File]::Exists((Join-Path -Path $PWD.Path -ChildPath $ctx.Request.RawUrl.Trim("/\")))) {
                $buffer = [System.Text.Encoding]::UTF8.GetBytes((Get-Content -Path (Join-Path -Path $PWD.Path -ChildPath $ctx.Request.RawUrl.Trim("/\"))));
                $ctx.Response.ContentLength64 = $buffer.Length;
                $ctx.Response.OutputStream.WriteAsync($buffer, 0, $buffer.Length)
            } 
        }

    }
    catch [System.Net.HttpListenerException] {
        Write-Host ($_);
    }
}

<#
version 1.1		Added automaticaly detect active IP Address
version 1.0		Create script
#>