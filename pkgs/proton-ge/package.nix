{ lib, stdenv, fetchurl, }:
stdenv.mkDerivation (self: {
  pname = "proton-ge";
  version = "GE-Proton9-23";
  src = fetchurl {
    url =
      "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${self.version}/${self.version}.tar.gz";
    hash = "sha256-1pWRbn4bjMlwWsR2LIsxFFvEJE4VD8fUIwtSM1MC6I8=";
  };

  dxvk = stdenvNoCC.mkDerivation (self: {
    pname = "dxvk";
    version = "1.10.3";
    src = fetchurl {
      url =
        "https://github.com/doitsujin/dxvk/releases/download/v${self.version}/dxvk-${version}.tar.gz";
      hash = "sha256-jRo8kSdhtFDIefmEeK5k9vZjnkDOaEgXCg9rhZb9U8Y=";
    };
    buildCommand = ''
      runHook unpackPhase
      runHook preBuild
      mkdir $out
      ln -s $src/* $out
      runHook postBuild
    '';
  });
  buildCommand = ''
    mkdir $out
    ln -s $src/* $out
    ln -sf ${dxvk}/x32/* $out/files/lib/wine/dxvk/
    ln -sf ${dxvk}/x64/* $out/files/lib64/wine/dxvk/
  '';
})
