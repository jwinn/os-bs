# OS Bootstrap

My personal file(s) to bootstrap up a macOS, Windows, Linux, etc. machine.
Feel free to use, fork, borrow, etc.

## macOS

### Install

1. [x] install [Homebrew], if not already installed
1. [ ] install [Homebrew] formulae, based on `Brewfile`
1. [x] install [chezmoi], if not already installed
1. [ ] use [chezmoi] to add [dotfiles]
1. [ ] ?? configure macOS settings

### ?? Uninstall

1. [ ] ?? restore macOS settings
1. [ ] use [chezmoi] to cleanup [dotfiles]
1. [ ] uninstall [chezmoi], if installed
1. [ ] uninstall [Homebrew] formulae, based on `Brewfile`
1. [ ] uninstall [Homebrew], if installed

## Windows 10/11

### Install

TBD [Scoop] or [WinGet]

1. [ ] ?? update [WinGet] from Microsoft Store [App Installer]
1. [ ] ?? update [WinGet] sources
1. [ ] ?? install specific packages
1. [ ] ?? add [dotfiles]
1. [ ] ?? configure Windows settings

### ?? Uninstall

1. [ ] ?? restore Windows settings
1. [ ] ?? uninstall specific packages
1. [ ] ?? remove [dotfiles]

## Linux

TBD as probably prefer to use [NixOS] and a separate init process

### ?? Install

1. [ ] ?? install VM software to setup NixOS
1. [ ] ?? add [dotfiles]
1. [ ] ?? configure settings

### ?? Uninstall

1. [ ] ?? restore settings
1. [ ] ?? remove [dotfiles]
1. [ ] ?? uninstall VM software to setup NixOS

[App Installer]: https://www.microsoft.com/p/app-installer/9nblggh4nns1
[chezmoi]: https://www.chezmoi.io
[dotfiles]: https://github.com/jwinn/dotfiles.git
[Homebrew]: https://brew.sh
[NixOS]: https://nixos.org
[Scoop]: https://scoop.sh
[WinGet]: https://github.com/microsoft/winget-cli
