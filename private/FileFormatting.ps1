
class FileFormat {
    [string]$Color
    [char]$Icon

    FileFormat() {
        $this.Color = $global:Host.UI.RawUI.ForegroundColor
        $this.Icon = " "
    }

    FileFormat([string]$color) {
        $this.Color = $color
        $this.Icon = " "
    }

    FileFormat([string]$color, [char]$icon) {
        $this.Color = $color
        $this.Icon = $icon
    }
}

Add-MetadataConverter @{
    [FileFormat] = { "FileFormat '$($_.Color)' $($_.Icon)" }
    "FileFormat" = {
        param([string]$color, [char]$icon)
        [FileFormat]::new($color, $icon)
    }
}
