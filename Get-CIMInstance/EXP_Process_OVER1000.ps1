<# 
 
 Filter the Get-CimInstance results to only return command lines that have over 1000 characters
 
#>

clear
Write-Host ""
Get-CimInstance -Class Win32_Process | Where-Object { $_.CommandLine.Length -gt 1000 } | Select-Object -Property Name, HandleCount, ProcessId, ParentProcessId, Path, CommandLine, WriteTransferCount, ReadTransferCount, WorkingSetSize

# Example OUTPUT
<#

Name               : msedgewebview2.exe
HandleCount        : 385
ProcessId          : 10208
ParentProcessId    : 8872
Path               : C:\Program Files (x86)\Microsoft\EdgeWebView\Application\121.0.2277.128\msedgewebview2.exe
CommandLine        : "C:\Program Files (x86)\Microsoft\EdgeWebView\Application\121.0.2277.128\msedgewebview2.exe" --type=renderer --noerrdialogs --user-data-dir="C:\Users\
                     Kevin Mitnick\AppData\Local\Packages\MicrosoftWindows.Client.WebExperience_cw5n1h2txyewy\LocalState\EBWebView" --webview-exe-name=Widgets.exe --webvie
                     w-exe-version=424.1301.2620.0 --embedded-browser-webview=1 --no-appcompat-clear --first-renderer-process --lang=en-US --device-scale-factor=1 --num-ra
                     ster-threads=3 --enable-main-frame-before-activation --renderer-client-id=5 --js-flags="--harmony-weak-refs-with-cleanup-some --expose-gc --ms-user-lo
                     cale=" --time-ticks-at-unix-epoch=-1708414702130344 --launch-time-ticks=310269512 --mojo-platform-channel-handle=2920 --field-trial-handle=2076,i,6940
                     883263129098075,618569756419682379,262144 --enable-features=MojoIpcz,UseBackgroundNativeThreadPool,UseNativeThreadPool,msWebView2TreatAppSuspendAsDevi
                     ceSuspend --variations-seed-version /pfhostedapp:202ca31efb77d39b712217c7dd83a95e416d5618 /prefetch:1
WriteTransferCount : 12241649
ReadTransferCount  : 24350388
WorkingSetSize     : 2269184

#>