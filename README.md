# Nix Darwin Basic Configuration

### Prerequisites
* Install [Nix][nix]
* Install [nix-darwin][]
* Add iKnow's Nix channel: `nix-channel --add https://github.com/iknow/nix-channel/archive/master.tar.gz iknow`
* set `EIKAIWA_BASEDIR` environment variable to the directory where `eikaiwa_content` and `eikaiwa_content_frontend` are checked out

[nix]: https://nixos.org/nix/manual/#sect-multi-user-installation
[nix-darwin]: https://github.com/LnL7/nix-darwin#install

### Installation

Extract this repository into `~/.config/nixpkgs`, and run `darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin-configuration.nix` to activate.
