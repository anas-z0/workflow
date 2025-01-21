{ lib, stdenv, fetchurl, }:
stdenv.mkDerivation rec {
  pname = "proton-ge";
  version = "GE-Proton9-22";
  src = fetchurl {
    url =
      "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/${version}.tar.gz";
    hash = "sha256-1pWRbn4bjMlwWsR2LIsxFFvEJE4VD8fUIwtSM1MC6I8=";
  };

  dxvk = stdenv.mkDerivation rec {
    pname = "dxvk";
    version = "1.10.3";
    src = fetchurl {
      url =
        "https://github.com/doitsujin/dxvk/releases/download/v${version}/dxvk-${version}.tar.gz";
      hash = "sha256-jRo8kSdhtFDIefmEeK5k9vZjnkDOaEgXCg9rhZb9U8Y=";
    };
    buildCommand = ''
      runHook preInstall
      runHook unpackPhase
      mkdir $out
      cp -r ./*/* $out
      runHook postInstall
    '';
  };
  buildCommand = ''
    runHook preInstall
    runHook unpackPhase
    mkdir $out
    cp -r ./*/* $out/
    ln -sf ${dxvk}/x32/* $out/files/lib/wine/dxvk/
    ln -sf ${dxvk}/x64/* $out/files/lib64/wine/dxvk/
    runHook postInstall
  '';
}
