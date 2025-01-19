{
  stdenvNoCC,
  fetchurl
}:
stdenvNoCC.mkDerivation (self: {
  pname = "dxvk";
  version = "1.10.3";
  src = let versionWithoutV = builtins.replaceStrings [ "v" ] [ "" ] self.version;
  in fetchurl {
    url = "https://github.com/doitsujin/dxvk/releases/download/v${self.version}/dxvk-${versionWithoutV}.tar.gz";
    hash = "sha256-jRo8kSdhtFDIefmEeK5k9vZjnkDOaEgXCg9rhZb9U8Y=";
  };
  buildCommand = ''
    runHook unpackPhase
    runHook preBuild
    mkdir $out
    ln -s $src/* $out
    runHook postBuild
  '';
})
