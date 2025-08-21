{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      lib = nixpkgs.lib;
      putHash = x: fake:
        builtins.mapAttrs (n: v:
          v.overrideAttrs (x: {
            src = lib.overrideDerivation x.src (x: {
              outputHash =
                if fake then lib.fakeHash else (import ./hashes.nix)."${n}";
            });
          })) x;
    in (x: x (x { })) (self: {
      test = pkgs.writers.writeBash "test" ("echo {;"
        + (builtins.concatStringsSep ";" (map (x: x.value) (lib.attrsToList
          (builtins.mapAttrs (n: v:
            "curl https://api.github.com/repos/${n}/releases/latest -so a;"
            + "export LATEST_TAG=$(cat a | jq -r .tag_name);"
            + "export ASSET=$(cat a |jq -r .assets.[].name"
            + (if builtins.hasAttr "regex" v then "|grep '${v.regex}'" else "")
            + (if builtins.hasAttr "unregex" v then
              "|grep -v '${v.unregex}'"
            else
              "") + ");" + ''
                echo "  \"${n}\" = { version = \"$LATEST_TAG\"; url = \"https://github.com/${n}/releases/download/$LATEST_TAG/$ASSET\"; };" '')
            (import ./pkgs.nix).github)))) + ";echo }");
      packagesNoHash = (x: x (x { })) (self:
        let
          callPackage = pkgs.lib.callPackageWith (pkgs // (putHash self false)
            // {
              sources = import ./packages.nix;
            });
        in nixpkgs.lib.packagesFromDirectoryRecursive {
          inherit callPackage;
          directory = ./pkgs;
        });
      packagesFakeHash = putHash self.packagesNoHash true;
      packages.x86_64-linux = putHash self.packagesNoHash false;
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
