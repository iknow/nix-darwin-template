self: {
  lorri = let
    src = builtins.fetchGit {
      url = "https://github.com/target/lorri";
      ref = "rolling-release";
    };
  in import src { inherit src; };
}
