{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation (self: {
  pname = "proton-ge";
  version = "GE-Proton9-23";
  src = fetchurl {
    url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${self.version}/${self.version}.tar.gz";
    hash = "sha256-1pWRbn4bjMlwWsR2LIsxFFvEJE4VD8fUIwtSM1MC6I8=";
  };
  buildCommand = ''
    mkdir $out
    ln -s $src/* $out
  '';
})
