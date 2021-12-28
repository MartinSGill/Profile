
if (Test-MyProCommand docker) {
    Write-MyProDebug "Found 'docker', registering completer."

    Import-Module DockerCompletion
    if (-not $?) {
        Write-MyProWarning "Found 'docker' but not 'DockerCompletion' module; installing."
        Install-Module DockerCompletion -Scope CurrentUser
        Import-Module DockerCompletion
    }
}
