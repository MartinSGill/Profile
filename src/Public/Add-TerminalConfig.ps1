function Add-TerminalConfig {
    [CmdletBinding()]
    param ()

    $InformationPreference = 'Continue'

    if (-not $IsWindows) {
        Write-Error 'Only supported on Windows'
        return
    }

    $file = 'default.json'
    $dir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal\Fragments\MartinsProfile'
    $path = Join-Path $dir $file

    if (-not (Test-Path $dir)) {
        Write-Information "Creating Fragments Directory '$dir'"
        $null = New-Item -ItemType Directory -Path $dir -Force
    }

    if (Test-Path $path) {
        Write-Information "File '$path' already exists, removing"
        $null = Remove-Item -Path $path -Force
    }

    @{
        profiles = @(
            @{
                name        = "Martin's Profile"
                commandline = 'pwsh -NoLogo -NoProfile -NoExit -Command "Import-Module MartinsProfile"'
                icon        = 'ms-appx:///ProfileIcons/pwsh.png'
            },
            @{
                name        = 'pwsh (NoProfile)'
                commandline = 'pwsh -NoLogo -NoProfile'
                icon        = 'ms-appx:///ProfileIcons/pwsh.png'
            }
        )
        schemes  = @(
            @{
                name = "Tokyo Night"
                black = "#15161e"
                red = "#f7768e"
                green = "#9ece6a"
                yellow = "#e0af68"
                blue = "#7aa2f7"
                purple = "#bb9af7"
                cyan = "#7dcfff"
                white = "#a9b1d6"
                brightBlack = "#414868"
                brightRed = "#f7768e"
                brightGreen = "#9ece6a"
                brightYellow = "#e0af68"
                brightBlue = "#7aa2f7"
                brightPurple = "#bb9af7"
                brightCyan = "#7dcfff"
                brightWhite = "#c0caf5"
                background = "#1a1b26"
                foreground = "#c0caf5"
                selectionBackground = "#33467c"
                cursorColor = "#c0caf5"
            },
            @{
                name                = 'Dracula'
                black               = '#000000'
                red                 = '#ff5555'
                green               = '#50fa7b'
                yellow              = '#f1fa8c'
                blue                = '#bd93f9'
                purple              = '#ff79c6'
                cyan                = '#8be9fd'
                white               = '#bbbbbb'
                brightBlack         = '#555555'
                brightRed           = '#ff5555'
                brightGreen         = '#50fa7b'
                brightYellow        = '#f1fa8c'
                brightBlue          = '#bd93f9'
                brightPurple        = '#ff79c6'
                brightCyan          = '#8be9fd'
                brightWhite         = '#ffffff'
                background          = '#1e1f29'
                foreground          = '#f8f8f2'
                selectionBackground = '#44475a'
                cursorColor         = '#bbbbbb'
            },
            @{
                name                = 'GitHub Dark'
                black               = '#000000'
                red                 = '#f78166'
                green               = '#56d364'
                yellow              = '#e3b341'
                blue                = '#6ca4f8'
                purple              = '#db61a2'
                cyan                = '#2b7489'
                white               = '#ffffff'
                brightBlack         = '#4d4d4d'
                brightRed           = '#f78166'
                brightGreen         = '#56d364'
                brightYellow        = '#e3b341'
                brightBlue          = '#6ca4f8'
                brightPurple        = '#db61a2'
                brightCyan          = '#2b7489'
                brightWhite         = '#ffffff'
                background          = '#101216'
                foreground          = '#8b949e'
                selectionBackground = '#3b5070'
                cursorColor         = '#c9d1d9'
            }
        )
    } | ConvertTo-Json | Set-Content -Path $path -Encoding UTF8

    Write-Information "Saved '$path'"
    Write-Warning "You need to restart Windows Terminal to take effect."
}
