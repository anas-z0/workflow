{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.nix-alien.url = "github:thiagokokada/nix-alien";
  outputs = { self, nixpkgs, nix-alien }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      lib = nixpkgs.lib;
    in (x: x (x { })) (self: {
      alien-fake-fzf = nix-alien.packages.x86_64-linux.nix-alien.overrideAttrs
        (x: {
          propagatedBuildInputs = x.propagatedBuildInputs ++ [
            (pkgs.writers.writeBashBin "fzf" ''
              if IFS= read -r first_line; then
                  echo "$first_line"
              else
                  # If no input, exit with failure to mimic fzf
                  exit 1
              fi'')
          ];
        });
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
      #what = builtins.listToAttrs (builtins.concatLists
      #(map (x: lib.attrsToList x) (map (x:
      #let list = (lib.splitString " " x);
      #in {
      #${(builtins.elemAt list 0)} = {
      #ver = (lib.elemAt list 1);
      #url = (lib.elemAt list 2);
      #};
      #}) (lib.lists.tail (lib.lists.reverseList
      #(lib.splitString "\n" (builtins.readFile ./nonixfmt)))))));
      packagesNoHash = (x: x (x { })) (self:
        let callPackage = pkgs.lib.callPackageWith (pkgs // self);
        in nixpkgs.lib.packagesFromDirectoryRecursive {
          inherit callPackage;
          directory = ./pkgs;
        });
      packages.x86_64-linux = builtins.mapAttrs (n: v:
        v.overrideAttrs (x: {
          src = lib.overrideDerivation self.packagesNoHash.${n}.src
            (x: { outputHash = (import ./hashes.nix).${n}; });
        })) self.packagesNoHash;
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
