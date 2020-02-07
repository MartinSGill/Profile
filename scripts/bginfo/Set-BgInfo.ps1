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

./bginfo.exe /silent "default.bgi"

if ($NoClean) { return }

Remove-Item -Path './bginfo.exe'
Remove-Item -Path './default.bgi'
