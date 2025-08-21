{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.nix-alien.url = "github:thiagokokada/nix-alien";
  outputs = { self, nixpkgs, nix-alien }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      lib = nixpkgs.lib;
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
                echo "  \"${n}\" = { ver = \"$LATEST_TAG\"; url = \"https://github.com/${n}/releases/download/$LATEST_TAG/$ASSET\"; };" '')
            (import ./pkgs.nix).github)))) + ";echo }");
      packages.x86_64-linux = (x: x (x { })) (self:
        let callPackage = pkgs.lib.callPackageWith (pkgs // self // {flakePath = ./.;});
        in nixpkgs.lib.packagesFromDirectoryRecursive {
          inherit callPackage;
          directory = ./pkgs;
        });
      packagesNoHash = builtins.mapAttrs (n: v:
        v.overrideAttrs (x: {
          src = lib.overrideDerivation x.src
            (x: { outputHash = pkgs.lib.fakeHash};);
        })) self.packages.x86_64-linux;
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
