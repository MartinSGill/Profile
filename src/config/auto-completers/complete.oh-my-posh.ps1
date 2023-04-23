
if (Test-Command oh-my-posh) {
    WriteDebug "Found 'oh-my-posh', registering completer."
    oh-my-posh completion powershell | Invoke-Expression
}
