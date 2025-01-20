{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-update = {
      url = "github:Mic92/nix-update";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs }@inputs: let
    genSystem = nixpkgs.lib.genAttrs [ "x86_64-linux" "x86_64-darwin" ];
    pkgsFor = system: nixpkgs.legacyPackages."${system}";
    in {
      packages = genSystem (system: let pkgs = pkgsFor system; in 
        pkgs.lib.packagesFromDirectoryRecursive { callPackage = pkgs.callPackage; directory = ./pkgs;
      });
      updateArgs = {
        proton-ge = "v1.10.3";
        test-but-with-space = "9.1.1 ";
        test = "9.1.1";
      };
      func = let
        packages = inputs.nixpkgs.lib.unique (builtins.concatLists (map (x: builtins.attrNames x) (builtins.attrValues self.packages)));
        argsNames = builtins.attrNames self.updateArgs;
        args = map (package: if (builtins.elem package argsNames) then builtins.concatStringsSep " " [ "--flake" package self.updateArgs.${package}] else package ) packages;
      in 
      test = self;
    };
  }

