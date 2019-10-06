function Get-PromptPathString() {
    [CmdletBinding()]
    param (
        [Int]$Segments = 6
    )

    $dirSep = [System.IO.Path]::DirectorySeparatorChar;

    $currentPath = $PWD -replace [regex]::Escape($HOME), "~"
    $splitPath = $currentPath -split [regex]::Escape($dirSep)

    $resultPathArray = @()
    if ($splitPath.Length -gt $Segments) {
        $resultPathArray += $splitPath[0..1]
        $resultPathArray += "…"
    }
    $resultPathArray += $splitPath | Select-Object -Last ($Segments - 2)
    $resultPath = $resultPathArray -join $dirSep
    $dirIcon = if ($PromptUseSafeCharacters) {
        " "
    } else {
        if ($resultPath -eq "~") {
            "  "
        }
        elseif ($resultPath.StartsWith($env:SystemRoot) -or
            $resultPath.StartsWith($env:ProgramFiles) -or
            $resultPath.StartsWith(${env:ProgramFiles(x86)})) {
            "  "
        }
        elseif ($splitPath -contains ".vscode" -or
                $splitPath -contains ".vs") {
            "  "
        }
        elseif ($splitPath -contains ".idea") {
            "  "
        }
        elseif ($splitPath -contains "node_modules") {
            "  "
        } else {
            "  "
        }
    }

    $dirIcon + $resultPath
}
