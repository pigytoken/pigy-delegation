#!/usr/bin/env nix-shell
#!nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/b889a3f7a07515108cc9614639cd307cf2acbec5.tar.gz
#!nix-shell -i bash -p ipfs postgresql

set -ex

. $HOME/secrets/ipfs.sh
. $HOME/secrets/postgresql.sh

psql -f pigy-history.sql
