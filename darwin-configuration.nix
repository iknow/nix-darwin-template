{ config, pkgs, ... }:

{
  # Configure nixpkgs overlays (additional software packages)
  nixpkgs.overlays = [
    (import ./overlays/packages.nix)
  ];

  # Configure custom Darwin modules (service configuration).
  # Environment variable EIKAIWA_BASEDIR must be externally defined.
  imports = [
    <iknow/darwin-modules>
    ((builtins.getEnv "EIKAIWA_BASEDIR") + "/eikaiwa_content/nix/darwin-config.nix")
    ./darwin-modules/direnv.nix
  ];

  # Configure packages to be installed. Packages can be searched by name with:
  # $ nix-env -qaP | grep <packagename>
  environment.systemPackages =
    with pkgs; [
      ag
      bundix
      colordiff
      coreutils-prefixed
      fzf
      gitAndTools.diff-so-fancy
      gitFull
      git-lfs
      gron
      httpie
      jq
      lorri
      ncdu
      nix-bash-completions
      overmind
      phraseapp_updater
      pv
      rename
      rsync
      socat
      tig
      tree
      wdiff
    ];

  # Enable Eikaiwa services (postgres, elasticsearch, kibana memcached, redis)
  eikaiwa.services = {
    enable = true;
    # Configure PostgreSQL to run faster but with less safety in
    # the event of a crash. Disable if storing useful data.
    postgresql.fastUnsafe = true;
  };

  # Run a lorri daemon
  services.lorri.enable = true;

  # Use a custom configuration.nix location. Switch to new location by running once
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin-configuration.nix
  environment.darwinConfig = "$HOME/.config/nixpkgs/darwin-configuration.nix";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.bash.enable = true;
  programs.zsh.enable = true;
  programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # You should generally set this to the total number of logical cores in your system.
  # $ sysctl -n hw.ncpu
  nix.maxJobs = 8;
  nix.buildCores = 0;

  nix.nixPath = [
    "nixpkgs=$HOME/.nix-defexpr/channels/nixpkgs" # NixOS/nix#1865
  ];

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };

  nixpkgs.config = import ./config.nix;
}
