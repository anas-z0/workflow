{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation {
  pname = "proton-ge";
  version = "9-22";
  src = fetchurl {
    url = "https://github.com/ppy/osu/releases/download/GE-Proton${version}/osu.AppImage";
    hash = "sha256-2H2SPcUm/H/0D9BqBiTFvaCwd0c14/r+oWhyeZdNpoU=";
  };
}
