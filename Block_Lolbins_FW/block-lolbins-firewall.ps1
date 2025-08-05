<#
	Blocks internet access from: powershell_ise.exe, powershell.exe, cscript.exe, wscript.exe, mshta.exe, cmd.exe, rundll32.exe, regsvr32.exe, msdt.exe
#>

$rules = @()

Class FirewallRule {
    [string]$DisplayName
    [string]$Program
    [string]$Description
    [string]$Action = 'Block'
    [string]$LocalAddress = 'Any'
    [string]$Direction = 'Outbound'
    [string[]]$RemoteAddress = @('0.0.0.0-9.255.255.255','11.0.0.0-172.15.255.255','172.32.0.0-192.167.255.255','192.169.0.0-255.255.255.255')
}

# PowerShell ISE
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - powershell_ise.exe';Program='%SystemRoot%\SysWOW64\WindowsPowerShell\v1.0\powershell_ise.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - powershell_ise.exe (x64)';Program='%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell_ise.exe'}

# PowerShell
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - powershell.exe';Program='%SystemRoot%\SysWOW64\WindowsPowerShell\v1.0\powershell.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - powershell.exe (x64)';Program='%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe'}

# 32 and 64 bit versions of cscript.exe
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - cscript.exe';Program='%SystemRoot%\SysWOW64\cscript.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - cscript.exe (x64)';Program='%SystemRoot%\System32\cscript.exe'}

# 32 and 64 bit versions of wscript.exe
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - wscript.exe';Program='%SystemRoot%\SysWOW64\wscript.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - wscript.exe (x64)';Program='%SystemRoot%\System32\wscript.exe'}

# 32 and 64 bit versions of mshta.exe
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - mshta.exe';Program='%SystemRoot%\SysWOW64\mshta.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - mshta.exe (x64)';Program='%SystemRoot%\System32\mshta.exe'}

# 32 and 64 bit versions of cmd.exe
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - cmd.exe';Program='%SystemRoot%\SysWOW64\cmd.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - cmd.exe (x64)';Program='%SystemRoot%\System32\cmd.exe'}

# 32 and 64 bit versions of regsvr32.exe - application whitelisting bypass
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - regsvr32.exe';Program='%SystemRoot%\SysWOW64\regsvr32.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - regsvr32.exe (x64)';Program='%SystemRoot%\System32\regsvr32.exe'}

# 32 and 64 bit versions of rundll32.exe - application whitelisting bypass
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - rundll32.exe';Program='%SystemRoot%\SysWOW64\rundll32.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - rundll32.exe (x64)';Program='%SystemRoot%\System32\rundll32.exe'}

# 32 and 64 bit versions of msdt.exe - application whitelisting bypass
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - msdt.exe';Program='%SystemRoot%\SysWOW64\msdt.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - msdt.exe (x64)';Program='%SystemRoot%\System32\msdt.exe'}

# .Net-based application whitelisting bypasses
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - dfsvc.exe - 2.0.50727';Program='%SystemRoot%\Microsoft.NET\Framework\v2.0.50727\dfsvc.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - dfsvc.exe - 2.0.50727 (x64)';Program='%SystemRoot%\Microsoft.NET\Framework64\v2.0.50727\dfsvc.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - dfsvc.exe - 4.0.30319';Program='%SystemRoot%\Microsoft.NET\Framework\v4.0.30319\dfsvc.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - dfsvc.exe - 4.0.30319 (x64)';Program='%SystemRoot%\Microsoft.NET\Framework64\v4.0.30319\dfsvc.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - ieexec.exe - 2.0.50727';Program='%SystemRoot%\Microsoft.NET\Framework\v2.0.50727\IEExec.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - ieexec.exe - 2.0.50727 (x64)';Program='%SystemRoot%\Microsoft.NET\Framework64\v2.0.50727\IEExec.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - MSBuild.exe - 2.0.50727';Program='%SystemRoot%\Microsoft.NET\Framework\v2.0.50727\MSBuild.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - MSBuild.exe - 2.0.50727 (x64)';Program='%SystemRoot%\Microsoft.NET\Framework64\v2.0.50727\MSBuild.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - MSBuild.exe - 3.5';Program='%SystemRoot%\Microsoft.NET\Framework\v3.5\MSBuild.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - MSBuild.exe - 3.5 (x64)';Program='%SystemRoot%\Microsoft.NET\Framework64\v3.5\MSBuild.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - MSBuild.exe - 4.0.30319';Program='%SystemRoot%\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - MSBuild.exe - 4.0.30319 (x64)';Program='%SystemRoot%\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - InstallUtil.exe - 2.0.50727';Program='%SystemRoot%\Microsoft.NET\Framework\v2.0.50727\InstallUtil.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - InstallUtil.exe - 2.0.50727 (x64)';Program='%SystemRoot%\Microsoft.NET\Framework64\v2.0.50727\InstallUtil.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - InstallUtil.exe - 4.0.30319';Program='%SystemRoot%\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - InstallUtil.exe - 4.0.30319 (x64)';Program='%SystemRoot%\Microsoft.NET\Framework64\v4.0.30319\InstallUtil.exe'}

# Create all of the rules using New-NetFirewallRule
foreach ($rule in $rules) {
    New-NetFirewallRule -DisplayName $rule.DisplayName -Direction $rule.Direction -Description $rule.Description -Action $rule.Action `
                        -LocalAddress $rule.LocalAddress -RemoteAddress $rule.RemoteAddress -Program $rule.Program
}
