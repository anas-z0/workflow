{ stdenv, fetchurl, sources }:
stdenv.mkDerivation rec {
  pname = "dxvk";
  inherit (sources.github."pythonlover02/DXVK-Sarek") version url;
  src = fetchurl { inherit url; };
  buildCommand = ''
    runHook preInstall
    runHook unpackPhase
    mkdir $out
    cp -r ./*/* $out
    runHook postInstall
  '';
}
