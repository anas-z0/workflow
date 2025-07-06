{
stdenv,
fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "dxvk";
  version = "v1.10.9";
  src = fetchurl {
    url = "http://github.com/pythonlover02/DXVK-Sarek/releases/download/${version}/dxvk-sarek-async-${version}.tar.gz";
    #hash = "sha256-Hb7EEqOMUEdoFUlh/Isc1lnh4GsZ7q0/Atarda50I/Q=";
  };
  buildCommand = ''
    runHook preInstall
    runHook unpackPhase
    mkdir $out
    cp -r ./*/* $out
    runHook postInstall
  '';
}
