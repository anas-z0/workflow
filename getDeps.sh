#mkdir db
#curl -L https://github.com/nix-community/nix-index-database/releases/download/2025-07-06-034719/index-x86_64-linux db/files
rm test.nix
PKGS_LIST=$(nix eval --impure --expr "builtins.attrNames(import ./packages.nix)"|cut -b 2- |rev|cut -b 2- |rev)
echo { >> test.nix
for PKG in $PKGS_LIST; do
  PKG=$(echo $PKG|cut -b 2- |rev|cut -b 2- |rev)
  URL=$(nix eval --impure --expr "(import ./packages.nix).\"$PKG\".url"|cut -b 2- |rev|cut -b 2- |rev);
  rm -rf testing
  mkdir testing
  curl -Lso testing/output "$URL";
  tar -xf testing/output -C testing
  BINARIES=$(find ./testing -type f|xargs file |grep LSB|grep executable|cut -d: -f-1)
  LIBS=$(for BIN in $BINARIES; do
    patchelf --print-needed $BIN
  done | sort -u)
  echo "  \"${PKG}\".lib = [" >> test.nix
  for LIB in $LIBS; do
    nix-locate -d db --minimal --top-level $LIB | grep \.out | head -n1 | xargs -I {} echo "    \"{}\""
  done >> test.nix
  echo "  ];" >> test.nix
done
echo } >> test.nix
