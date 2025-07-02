{ stdenv, fetchurl, dxvk, }:
stdenv.mkDerivation rec {
  pname = "proton-ge";
  version = "GE-Proton10-8";
  src = fetchurl {
    url =
      "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/${version}.tar.gz";
    hash = "sha256-dgT6q1NWMg7ilHrimBoONZC6KUsVKdSeftA775FOt8g=";
  };

  buildCommand = ''
    runHook preInstall
    runHook unpackPhase
    mkdir $out
    cp -r ./*/* $out/
    ln -sf ${dxvk}/x64/* $out/files/lib/wine/dxvk/
    runHook postInstall
  '';
}
