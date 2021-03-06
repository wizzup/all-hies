{ pkgs ? import ./nixpkgs.nix
}:
let
  inherit (pkgs) lib;
  hpkgs = pkgs.haskellPackages;
  runtimeDeps = [
    pkgs.nix-prefetch-scripts
    pkgs.git
    pkgs.haskellPackages.cabal-install
    pkgs.nix
    pkgs.coreutils
    pkgs.gawk
  ];
  pkg = (hpkgs.callCabal2nix "all-hies" (pkgs.lib.sourceByRegex ./. [
    "src.*"
    "all-hies.cabal"
  ]) {}).overrideAttrs (old: {
    nativeBuildInputs = old.nativeBuildInputs or [] ++ [
      pkgs.makeWrapper
    ];
    postInstall = old.postInstall or "" + ''
      wrapProgram $out/bin/update \
        --set PATH "${lib.makeBinPath runtimeDeps}"
    '';
  });
in pkg // {
  env = pkg.env.overrideAttrs (old: {
    nativeBuildInputs = old.nativeBuildInputs or [] ++ runtimeDeps;
  });
}
