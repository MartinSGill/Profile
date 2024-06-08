
$env:MyProfileDebugMode = $true

Write-Output "Building..."
Invoke-Build

Write-Output "Loading Module..."
Write-Output "$($PSStyle.Foreground.White)MyProfile Debug Mode: $env:MartinsProfileDebugMode$($PSStyle.Reset)"
Import-Module $PWD/artifacts/MartinsProfile

if (-not (Test-Path ~/.config/.postCreateComplete)) {
    Write-Warning "====== DEV CONTAINER STARTING ====="
    Write-Warning ""
    Write-Warning "This prompt may show before the container is fully"
    Write-Warning "configured."
    Write-Warning ""
    Write-Warning "To test/explore MartinsProfile module, simply start another"
    Write-Warning "pwsh instance with $($PSStyle.Foreground.White)pwsh$($PSStyle.Formatting.Warning)."
    Write-Warning ""
    Write-Warning "This message will disappear once configuration is"
    Write-Warning "completed."
    Write-Warning ""
}
