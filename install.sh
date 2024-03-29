#!/bin/zsh

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

if ! [ "$SHELL" = "/bin/zsh" ]; then
    echo "Run this script under Apple's default /bin/zsh shell"
    exit 1
fi

# Authenticate to sudo: nix installers are going to need it, but we're detaching
# them from the terminal
echo "Obtaining sudo:"
sudo echo "Obtained!"

test_t2_chip_present(){
    # from create-darwin-volume.sh, returns 0 if the system has a t2 chip
    sudo xartutil --list >/dev/null 2>/dev/null
}

# If we have MacOS 10.15 or newer and no T2 chip, we need to manually create the
# nix volume, encrypted. If we have a T2 chip, we rely on the T2's encryption at
# rest.
darwin_version="$(uname -r)"
if (! test_t2_chip_present) && [ "${darwin_version%%.*}" -ge 19 ]; then
    if ! [ -d "/nix" ]; then
        (echo 'nix'; echo -e 'run\tprivate/var/run') | sudo tee -a /etc/synthetic.conf >/dev/null
        echo "Added /nix and /run to synthetic.conf. You must now reboot and re-run this script."
        exit 0
    fi

    # If 10.15 and nothing mounted on /nix
    if ! LANG=en_US /sbin/mount | grep -q 'on /nix'; then
        PASSPHRASE=$(openssl rand -base64 32)
        echo "Creating and mounting /nix volume encrypted with passphrase: $PASSPHRASE"
        sudo diskutil apfs addVolume disk1 'Case-sensitive APFS' Nix -mountpoint /nix -passphrase "$PASSPHRASE"

        UUID=$(diskutil info -plist /nix | plutil -extract VolumeUUID xml1 - -o - | plutil -p - | sed -e 's/"//g')
        security add-generic-password -l Nix -a "$UUID" -s "$UUID" -D "Encrypted Volume Password" -w "$PASSPHRASE" \
                 -T "/System/Library/CoreServices/APFSUserAgent" -T "/System/Library/CoreServices/CSUserAgent"

        sudo diskutil enableOwnership /nix
        sudo mdutil -i off /nix

        echo 'LABEL=Nix /nix apfs rw' | sudo tee -a /etc/fstab >/dev/null
    fi
fi

mkdir -p ~/.config/nixpkgs
curl -fsSL https://github.com/iknow/nix-darwin-template/archive/master.zip | tar --strip-components 1 -C ~/.config/nixpkgs -x

local -a nix_install_options=("--daemon")
if test_t2_chip_present; then
   nix_install_options+=("--darwin-use-unencrypted-nix-store-volume")
fi

# Install Nix
yes | sh <(curl -fsSL https://nixos.org/nix/install) "${nix_install_options[@]}"

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

# nix-darwin expects to be able to replace configuration files: move them out of the way
for i in /etc/nix/nix.conf; do
    sudo mv $i $i.backup-before-nix-darwin
done

# bashrc is a bit special because we have to care about Apple's defaults
sudo cp /etc/bashrc.backup-before-nix /etc/bashrc
sudo sh -c "echo 'if test -e /etc/static/bashrc; then . /etc/static/bashrc; fi' >> /etc/bashrc"

# install nix-darwin
nixpkgs="$(nix-instantiate --find-file nixpkgs)"
export NIX_PATH="nixpkgs=$nixpkgs:darwin-config=$HOME/.config/nixpkgs/darwin-configuration.nix"
export NIX_BUILD_CORES=0
export NIX_MAX_JOBS=8
yes | nix --extra-experimental-features 'nix-command' \
    shell -f https://github.com/LnL7/nix-darwin/archive/master.tar.gz installer -c darwin-installer

# Import nix-darwin config
set +u
. /etc/zshenv
set -u

echo 'Waiting for nix-daemon..'
while ! nix --extra-experimental-features 'nix-command' store ping; do
    echo -n '.'
    sleep 1
done
echo

# Enforce opinions: developer macs are effectively single user systems,
# nix-darwin should only have user channels.
sudo -i nix-channel --remove nixpkgs
nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
nix-channel --update nixpkgs

sudo rm /nix/var/nix/profiles/default
sudo rm /nix/var/nix/profiles/default-*-link

echo "All done! Now close this terminal."
