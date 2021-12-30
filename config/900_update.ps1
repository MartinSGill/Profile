
VerboseBlock "Check for Update" {
    if (Test-Path "$PSScriptRoot/../.git") {
        if (Test-MyProCommand -Name git) {
            $null = git fetch
            $count = git rev-list --count master..origin/master
            if ($count -gt 0) {
                Write-Host "🆙 $($PSStyle.Forground.BrightGreen)MyProfile Update Available 🆙"
            } else {
                Write-MyProDebug "Local repo up-to-date with remote."
            }
        } else {
            Write-MyProDebug "GIT Cli not available. Skipping."
        }
    } else {
        Write-MyProDebug "Not a GIT repo. Skipping."
    }
}
