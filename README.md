# Nix Darwin Basic Configuration

### Easy Installation

* Set `EIKAIWA_BASEDIR` environment variable to the directory where `eikaiwa_content` and `eikaiwa_content_frontend` are checked out.
* Run `bash <(curl https://raw.githubusercontent.com/iknow/nix-darwin-template/master/install.sh)`

### Manual Installation

* Set `EIKAIWA_BASEDIR` environment variable to the directory where `eikaiwa_content` and `eikaiwa_content_frontend` are checked out
* Install [Nix][nix] in multi-user mode. Close and re-open your terminal.
* Add iKnow's Nix channel: `nix-channel --add https://github.com/iknow/nix-channel/archive/master.tar.gz iknow` then `nix-channel --update`
* Install [nix-darwin][]. "Yes" is a good answer to all the installation questions unless you want something special. Close and re-open your terminal.
* Clone this template repository and check it out into `~/.config/nixpkgs`.
* Run `darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin-configuration.nix` to activate the configuration. Close and re-open your terminal.

[nix]: https://nixos.org/nix/manual/#sect-multi-user-installation
[nix-darwin]: https://github.com/LnL7/nix-darwin#install
