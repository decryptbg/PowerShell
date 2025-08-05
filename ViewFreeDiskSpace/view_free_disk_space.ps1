<# 
 tag-ps-script
 dscr-View Free Disk Space
 catgry-System
#>
Get-PSDrive -PSProvider FileSystem | Select-Object Name, @{Name="FreeSpace(GB)"; Expression={[math]::Round($_.Free/1GB, 2)}}, @{Name="TotalSize(GB)"; Expression={[math]::Round($_.Used/1GB + $_.Free/1GB, 2)}}