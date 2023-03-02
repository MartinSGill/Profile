
function script:Show-MyProCustomViews() {

    $formats = @(
        @{ File = (Get-Item "$PSScriptRoot/../Formats/FileSystemTypes.formats.ps1xml" ); Example = { Get-ChildItem "$PSScriptRoot/.." | Format-Table } }
        @{ File = (Get-Item "$PSScriptRoot/../Formats/CommandInfo.formats.ps1xml" ); Example = { Get-Command -Name gi, sm } }
        @{ File = (Get-Item "$PSScriptRoot/../Formats/HistoryInfo.formats.ps1xml" ); Example = { Get-History -Count 2 | Format-Table } }
        @{ File = (Get-Item "$PSScriptRoot/../Formats/Runtime.formats.ps1xml" ); Example = { ''.GetType() | Format-Table } }
        @{ File = (Get-Item "$PSScriptRoot/../Formats/TimeSpan.formats.ps1xml" ); Example = { New-TimeSpan -Seconds 4 -Minutes 2 -Hours 3 } }
    )

    $types = @(
        @{ File = (Get-Item "$PSScriptRoot/../Types/CommandInfo.formats.ps1xml" ); Example = { Get-Command -Name gi, sm } }
    )

    foreach ($item in @($formats + $types)) {
        $header = $item.File.BaseName
        Write-Host "$($PSStyle.Foreground.BrightBlue)====== $($PSStyle.Foreground.White)${header} $($PSStyle.Foreground.BrightBlue)======"

        $item.Example.Invoke()

        Write-Host ''
        Write-Host "$($PSStyle.Foreground.BrightBlue)======"
        Write-Host ''
    }
}
