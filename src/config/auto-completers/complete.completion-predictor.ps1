
WriteDebug 'Registering improved completion.'
# Import-Module CompletionPredictor
if (-not $?) {
    Write-MyProWarning "Did not find 'CompletionPredictor' module; installing."
    Install-Module CompletionPredictor -Scope CurrentUser
    # Import-Module CompletionPredictor
}
