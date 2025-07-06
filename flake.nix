{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs }:
    let pkgs = nixpkgs.legacyPackages.x86_64-linux; lib = nixpkgs.lib;
    in (x: x (x {})) (self: {
      packagesNoHash = (x: x (x {})) (self:
        let
          callPackage = pkgs.lib.callPackageWith (pkgs // self);
         in nixpkgs.lib.packagesFromDirectoryRecursive {
            inherit callPackage;
            directory = ./pkgs;
          });
      packages.x86_64-linux = builtins.mapAttrs (n: v: v.overrideAttrs (x: { src = lib.overrideDerivation packagesNoHash.x86_64-linux.${n}.src (x: { outputHash = (import ./hashes.nix).${n}; }); })) self.packagesNoHash;
      shell = let
        updateArgs = import ./nix-update.nix;
        packages = nixpkgs.lib.unique (builtins.concatLists
          (map (x: builtins.attrNames x) (builtins.attrValues self.packages)));
        argsNames = builtins.attrNames updateArgs;
        list = map (package:
          "nix-update --commit --flake "
          + (if (builtins.elem package argsNames) then
            builtins.concatStringsSep " " [ updateArgs.${package} package ]
          else
            package) + " 1>/dev/null") packages;
      in builtins.concatStringsSep "\n" list;
    });
}
