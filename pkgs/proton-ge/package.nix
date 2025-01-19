{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation (self: {
  pname = "proton-ge";
  version = "9-22";
  src = fetchurl {
    url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton${self.version}/GE-Proton${self.version}.tar.gz";
    hash = "sha256-2H2SPcUm/H/0D9BqBiTFvaCwd0c14/r+oWhyeZdNpoU=";
  };
  buildCommand = ''
    mkdir $out
    ln -s $src/* $out
  '';
})
