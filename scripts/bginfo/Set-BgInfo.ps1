[CmdletBinding()]
param (
    [switch]$NoClean
)

if (-not (Test-Path "bginfo.exe")) {
    Invoke-WebRequest -Uri https://live.sysinternals.com/Bginfo.exe -OutFile './bginfo.exe'
    Unblock-File './bginfo.exe'
}

if (-not (Test-Path "default.bgi")) {
    Invoke-WebRequest -Uri https://raw.githubusercontent.com/MartinSGill/Profile/master/scripts/bginfo/default.bgi -OutFile './default.bgi'
}

./bginfo.exe "default.bgi" /silent /nolicprompt /timer:0

if ($NoClean) { return }

Start-Sleep -Seconds 2

Remove-Item -Path './bginfo.exe'
Remove-Item -Path './default.bgi'
