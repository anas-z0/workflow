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
      }) // {
        nixUpdateExclude = [ "dxvk" "test" ];
      };
    };
  }

