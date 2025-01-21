{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    #nix-update = {
      #url = "github:Mic92/nix-update";
      #inputs.nixpkgs.follows = "nixpkgs";
    #};
  };

  outputs = { self, nixpkgs }: let
    genSystem = nixpkgs.lib.genAttrs [ "x86_64-linux" "x86_64-darwin" ];
    pkgsFor = system: nixpkgs.legacyPackages."${system}";
    in {
      packages = genSystem (system: let pkgs = pkgsFor system; in 
        pkgs.lib.packagesFromDirectoryRecursive { callPackage = pkgs.callPackage; directory = ./pkgs;
      });
      updateArgs = {
        dxvk = "--version v1.10.3";
      };
      shell = let
        packages = nixpkgs.lib.unique (builtins.concatLists (map (x: builtins.attrNames x) (builtins.attrValues self.packages)));
        argsNames = builtins.attrNames self.updateArgs;
        list = map (package: "nix-update --commit --flake " + (if (builtins.elem package argsNames) then builtins.concatStringsSep " " [ package self.updateArgs.${package}] else package ) + " 1>/dev/null" ) packages;
        in builtins.concatStringsSep "\n" list;
    };
  }

