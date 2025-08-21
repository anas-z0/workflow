{ stdenv, fetchurl, dxvk, sources }:
stdenv.mkDerivation rec {
  pname = "proton-ge";
  inherit (sources."GloriousEggroll/proton-ge-custom") version url;
  src = fetchurl { url = url; };
  buildCommand = ''
    runHook preInstall
    runHook unpackPhase
    mkdir $out
    cp -r ./*/* $out/
    ln -sf ${dxvk}/x32/* $out/files/lib/wine/dxvk/i386-windows/
    ln -sf ${dxvk}/x64/* $out/files/lib/wine/dxvk/x86_64-windows/
    runHook postInstall
  '';
}
