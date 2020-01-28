
function Get-ParentProcessId {
    <#
        .Synopsis
            Get the Process Id of the current process' parent.
    #>
    [CmdletBinding()]
    param ()

    if ($PSVersionTable.PSVersion.Major -lt 6)
    {
        # PS 5 isn't as smart...
        ((Get-WmiObject win32_process | Where-Object processid -eq  $pid).parentprocessid)
    } else {
        (Get-Process -Id $pid).Parent.Id
    }
}
