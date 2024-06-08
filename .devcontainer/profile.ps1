
while (-not (Test-Path ~/.config/.postCreateComplete)) {
    Write-Output "$($PSStyle.Background.BrightYellow)$($PSStyle.Foreground.Black)    ... Waiting for DevContainer Setup to Complete ...    "
    Start-Sleep -Seconds 1
}

Write-Output ($PSStyle.Background.Magenta + $PSStyle.Foreground.White + "DEV: Building..." + $PSStyle.Reset)
Invoke-Build

Write-Output ($PSStyle.Background.Magenta + $PSStyle.Foreground.White + "DEV: Loading Module..." + $PSStyle.Reset)
Import-Module $PWD/artifacts/MartinsProfile
