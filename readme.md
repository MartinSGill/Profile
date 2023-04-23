# Martin's Profile

## Introduction

The profile I use for my own powershell sessions. Mostly this is just for my
personal use, but feel free to use it and/or derive inspiration from it for
your own profile.

## Recent Changes

### Version 1.0

* Renamed to `MartinsProfile`
* Default Prefix changed to `Pro` for profile
* Complete re-structure of module
* Improvements to load performance
* Dependencies & Imports now handled by Manifest
* Removed a number of useless/obsolete functions
* Added build script

## Install

### Install Dependencies

```powershell
winget install --id JanDeDobbeleer.OhMyPosh
winget install --id voidtools.Everything
Install-PSResource -Name Terminal-Icons -Version 0.10.0
Install-PSResource -Name posh-git -Version 1.1.0
Install-PSResource -Name PSReadline -Version 2.2.0
```

### Build the Module

_NOTE:_ I'll eventually create release artifacts, for now manual build is required

Clone the repo and build the module

```powershell
git clone https://github.com/MartinSGill/Profile.git
cd Profile
/.build.ps1
```

### Import the Module

```powershell
Import-Module <path-to-repo>/Profile/artifacts/MartinsProfile
```

### Update your Profile

If you want the module to load automatically every time, then update your
profile with the line above.

You can find your profile path with

```powershell
$PROFILE.CurrentUserAllHosts
```

## Troubleshooting

On Windows you can hold the "shift" key while starting the profile to enable
debug output.

Alternatively you can set `$env:MyProfileDebugMode` before attempting to import
the profile to enable debug output.
