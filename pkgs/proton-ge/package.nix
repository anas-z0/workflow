{ stdenv, fetchurl, dxvk, }:
stdenv.mkDerivation rec {
  pname = "proton-ge";
  version = "GE-Proton9-25";
  src = fetchurl {
    url =
      "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/${version}.tar.gz";
    hash = "sha256-iOcT6lzmGVUX+VbPoFs1LC+tS4uxx99UspMUjy3/x48=";
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
