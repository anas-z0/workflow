{ stdenv, fetchurl, dxvk, }:
stdenv.mkDerivation rec {
  pname = "proton-ge";
  version = "GE-Proton9-27";
  src = fetchurl {
    url =
      "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/${version}.tar.gz";
    hash = "sha256-u9MQi6jc8XPdKmDvTrG40H4Ps8mhBhtbkxDFNVwVGTc=";
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
