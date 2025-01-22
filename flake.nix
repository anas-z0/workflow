{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs }:
    let
      genSystem = nixpkgs.lib.genAttrs [ "x86_64-linux" "x86_64-darwin" ];
      pkgsFor = system: nixpkgs.legacyPackages."${system}";
    in {
      packages = genSystem (system:
        let
          pkgs = pkgsFor system;
          callPackage = pkgs.lib.callPackageWith (pkgs // packages);
          packages = nixpkgs.lib.packagesFromDirectoryRecursive {
            inherit callPackage;
            directory = ./pkgs;
          };
        in packages);
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
    };
}
