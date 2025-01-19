{
  stdenvNoCC,
  fetchurl
}:
stdenvNoCC.mkDerivation (self: {
  pname = "dxvk";
  version = "1.10.3";
  versionWithoutV = builtins.replaceStrings [ "v" ] [ "" ] self.version;
  src = pkgs.fetchurl {
    url = "https://github.com/doitsujin/dxvk/releases/download/v${self.version}/dxvk-${self.versionWithoutV}.tar.gz";
    hash = "sha256-jRo8kSdhtFDIefmEeK5k9vZjnkDOaEgXCg9rhZb9U8Y=";
  };
  buildCommand = ''
    runHook unpackPhase
    runHook preBuild
    cp -r ./$name $out
    runHook postBuild
  '';
})
