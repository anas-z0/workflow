#!/usr/bin/env nix-shell
#!nix-shell -i bash -p unzip curl jq common-updater-scripts
set -eo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

bin_file="$(realpath ./default.nix)"

new_version="$(curl -s "https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases?per_page=1" | jq -r '.[0].tag_name'|sed -s s/GE-Proton//g)"
old_version="$(sed -nE 's/\s*version = "(.*)".*/\1/p' ./default.nix)"
if [[ "$new_version" == "$old_version" ]]; then
    echo "Already up to date."
    exit 0
fi

echo "Updating from $old_version to $new_version..."
sed -Ei.bak '/ *version = "/s/".+"/"'"$new_version"'"/' "$bin_file"
rm "$bin_file.bak"
echo "Prefetching binary for ProtonGE..."
prefetch_output=$(nix --extra-experimental-features nix-command store prefetch-file --json --hash-type sha256 "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/$new_version/GE-Proton${new_version}.tar.gz")
hash=$(jq -r '.hash' <<<"$prefetch_output")
sed -Ei.bak '/ *'"src"' = /{N;N; s@("sha256-)[^;"]+@"'"$hash"'@}' "$bin_file"
rm "$bin_file.bak"

