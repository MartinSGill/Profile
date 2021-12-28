# My Profile

## Introduction

The profile I use for my own powershell sessions. Mostly this is just for my
personal use, but feel free to use it and/or derive inspiration from it for
your own profile.

## Recent Changes

* Simplified to improve load times.
* Recommended for 7.2-preview, but works with 7.1.
* Not tested extensively with 5.0.

## Dependencies

Mandatory:

```powershell
Install-Module Terminal-Icons
Install-Module oh-my-posh
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
mkdir -Force ~/Documents/Powershell
# Add import statement to profile
Add-Content -Path ~/Documents/Powershell/profile.ps1 -Value "Import-Module '$PWD/my.profile.psm1'"
```

Humanizer is no longer loaded by default, mostly because it can cause issues in
some environments. Load it with `PS> Import-Humanizer`

## Troubleshooting

On Windows you can hold the "shift" key while starting the profile to enable
debug output.

Alternatively you can set `$env:ProfileDebugMode` before attempting to import
the profile to enable debug output.
