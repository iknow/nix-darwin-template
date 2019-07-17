# Nix Darwin Basic Configuration (for designers)

### Easy Installation

* Run `zsh <(curl https://raw.githubusercontent.com/iknow/nix-darwin-template/design/install.sh)`

### Manual Installation

* Install [Nix][nix] in multi-user mode. Close and re-open your terminal.
* Add iKnow's Nix channel: `nix-channel --add https://github.com/iknow/nix-channel/archive/design.tar.gz iknow` then `nix-channel --update`
* Install [nix-darwin][]. "Yes" is a good answer to all the installation questions unless you want something special. Close and re-open your terminal.
* Clone this template repository and check it out into `~/.config/nixpkgs`.
* Run `darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin-configuration.nix` to activate the configuration. Close and re-open your terminal.

[nix]: https://nixos.org/nix/manual/#sect-multi-user-installation
[nix-darwin]: https://github.com/LnL7/nix-darwin#install
