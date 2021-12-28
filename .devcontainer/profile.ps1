
$env:ProfileDebugMode = $true
$InformationPreference = "Continue"
Import-Module $PWD/MyProfile.psm1

if (-not (Test-Path ~/.config/.postCreateComplete)) {
    Write-Warning "====== DEV CONTAINER STARTING ====="
    Write-Warning ""
    Write-Warning "This prompt will start before the container is fully"
    Write-Warning "configured."
    Write-Warning ""
    Write-Warning "To test/explore MyProfile module, simply start another"
    Write-Warning "pwsh instance with $($PSStyle.Foreground.White)pwsh$($PSStyle.Formatting.Warning)."
    Write-Warning ""
    Write-Warning "This message will disappear once configuration is"
    Write-Warning "completed."
    Write-Warning ""
}
