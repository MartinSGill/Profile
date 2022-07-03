# My Profile

## Introduction

The profile I use for my own powershell sessions. Mostly this is just for my
personal use, but feel free to use it and/or derive inspiration from it for
your own profile.

## Recent Changes

* Migration of

## Dependencies

Mandatory:

```powershell
winget install JanDeDobbeleer.OhMyPosh -s winget
# OR scoop install https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/oh-my-posh.json
Install-Module Terminal-Icons
Install-Module posh-git
Install-Module PSReadline -AllowPrerelease -Force
```

## Install

To install (__after installing dependencies__):

```powershell
# Clone this repo
git clone ...
# Step into this repo
Set-Location ./Profile
# Ensure powershell profile folder exists
New-Item -ItemType Directory -Force (Split-Path $PROFILE.CurrentUserCurrentHost -Parent)
# Add import statement to profile
Add-Content -Path $PROFILE.CurrentUserAllHosts -Value "Import-Module '$PWD/MyProfile.psm1'"
```

Humanizer is no longer loaded by default, mostly because it can cause issues in
some environments. Load it with `PS> Import-MyProHumanizer`

## Troubleshooting

On Windows you can hold the "shift" key while starting the profile to enable
debug output.

Alternatively you can set `$env:MyProfileDebugMode` before attempting to import
the profile to enable debug output.
