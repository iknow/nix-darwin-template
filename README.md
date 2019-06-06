# Nix Darwin Basic Configuration

Having installed nix and nix-darwin, extract this repository into `~/.config/nixpkgs`, set `EIKAIWA_BASEDIR` environment variable to the directory where `eikaiwa_content` and `eikaiwa_content_frontend` are configured, and run `darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin-configuration.nix` to activate.
