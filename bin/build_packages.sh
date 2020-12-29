#!/usr/bin/env bash

set -ex

BASE_DIR="$(readlink -f $(dirname $(readlink -f "$0"))/..)"

for pkgname in $BASE_DIR/pkgs/*
do
    cd $pkgname
    makepkg -sfc --noconfirm
done
