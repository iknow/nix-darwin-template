# Nix Darwin Basic Configuration

### Prerequisites
* Install [Nix][nix] in multi-user mode.
* Install [nix-darwin][]. "Yes" is a good answer to all the installation questions unless you want something special.
* Add iKnow's Nix channel: `nix-channel --add https://github.com/iknow/nix-channel/archive/master.tar.gz iknow` then `nix-channel --update`
* set `EIKAIWA_BASEDIR` environment variable to the directory where `eikaiwa_content` and `eikaiwa_content_frontend` are checked out

[nix]: https://nixos.org/nix/manual/#sect-multi-user-installation
[nix-darwin]: https://github.com/LnL7/nix-darwin#install

### Installation

* Clone this template repository and check it out into `~/.config/nixpkgs`.
* Run `darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin-configuration.nix` to activate the configuration. Having done so, close your terminal and open a new one.
