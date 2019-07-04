#!/usr/bin/env bash

set -e
set -u

if ! [ -d "${EIKAIWA_BASEDIR:-}" ]; then
    echo "EIKAIWA_BASEDIR not set to a existing directory" >&2
    exit 1
fi

if ! [ -d "$EIKAIWA_BASEDIR/eikaiwa_content" ]; then
    echo "eikaiwa_content not checked out in EIKAIWA_BASEDIR" >&2
    exit 1
fi

mkdir -p ~/.config/nixpkgs
curl -L https://github.com/iknow/nix-darwin-template/archive/master.zip | tar --strip-components 1 -C ~/.config/nixpkgs -x

# Authenticate to sudo: nix installers are going to need it, but we're detaching
# them from the terminal
echo "Obtaining sudo:"
sudo echo "Obtained!"

# Install Nix
yes | sh <(curl https://nixos.org/nix/install) --daemon

# and pull it into the current shell
. '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'

# Set up nix channel and darwin configuration
nix-channel --add https://github.com/iknow/nix-channel/archive/master.tar.gz iknow
nix-channel --update

# builtins.fetchGit calls git from the path rather than the nix package. Ensure
# we're using nix's git.
sudo nix-env -p /nix/var/nix/profiles/default -iA nixpkgs.git

# Initialize a git repository for the darwin configuration
pushd ~/.config/nixpkgs
git init .
git add -A
git commit -m 'Initial commit' --author 'Initialization <systems@iknow.jp>'
popd

# nix-darwin expects to be able to replace several shell startup files: move them out of the way
for i in /etc/nix/nix.conf /etc/zshrc /etc/zprofile; do
    sudo mv $i $i.backup-before-nix-darwin
done

# bashrc is a bit special because we have to care about Apple's defaults
sudo cp /etc/bashrc.backup-before-nix /etc/bashrc
sudo sh -c "echo 'if test -e /etc/static/bashrc; then . /etc/static/bashrc; fi' >> /etc/bashrc"

# install nix-darwin
export NIX_PATH="$NIX_PATH:darwin-config=$HOME/.config/nixpkgs/darwin-configuration.nix"
export NIX_BUILD_CORES=0
export NIX_MAX_JOBS=8
yes | nix run -f https://github.com/LnL7/nix-darwin/archive/master.tar.gz installer -c darwin-installer

# Import nix-darwin config
set +u
. /etc/bashrc
set -u

# Enforce opinions: developer macs are effectively single user systems,
# nix-darwin should only have user channels.
sudo -i nix-channel --remove nixpkgs
nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
nix-channel --update nixpkgs

sudo rm /nix/var/nix/profiles/default
sudo rm /nix/var/nix/profiles/default-*-link

echo "All done! Now close this terminal."
