{
stdenv,
fetchurl,
}:
stdenv.mkDerivation rec {
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
}
