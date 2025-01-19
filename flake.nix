{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    genSystem = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
    pkgsFor = system: nixpkgs.legacyPackages."${system}";
    in {
      packages = genSystem (system: let pkgs = pkgsFor system; in 
        pkgs.lib.packagesFromDirectoryRecursive { callPackage = pkgs.callPackage; directory = ./pkgs;
      });
      pinned = {
        dxvk = "1.10.3";
        test-but-with-space = "9.1.1 ";
        test = "9.1.1";
      };
    };
  }

