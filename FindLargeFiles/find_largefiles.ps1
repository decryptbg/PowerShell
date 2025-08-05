$s_path = "D:"
clear
Write-host ""
Write-host -fore darkgreen " Searching in location: " -NoNewLine
Write-host -fore Yellow "$s_path"
Write-host -fore DarkYellow " Please wait..."
Write-host ""
ls $s_path -File -Force -Recurse -ea 0|? Length -gt (10GB)|select @{n='GB';e={[int]($_.Length / 1GB)}},@{n='Modified';e={$_.LastWriteTime.ToString('yyyy/MM/dd')}},FullName