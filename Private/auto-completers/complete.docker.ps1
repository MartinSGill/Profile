
if (Test-MyProCommand docker) {
    Write-PrfDebug "Found 'docker', registering completer."

    Import-Module DockerCompletion
    if (-not $?) {
        Write-PrfWarning "Found 'docker' but not 'DockerCompletion' module; installing."
        Install-Module DockerCompletion -Scope CurrentUser
        Import-Module DockerCompletion
    }
}
