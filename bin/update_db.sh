#!/usr/bin/env bash

set -ex

BASE_DIR="$(readlink -f $(dirname $(readlink -f "$0"))/..)"

REPO_URL="https://github.com/fsquillace/junest-repo.git"
REPO_DIR="$(mktemp -d -t ci-XXXXXXXXXX)/repo"

git clone ${REPO_URL} ${REPO_DIR}

if [[ -e ${REPO_DIR}/any/junest.db ]]
then
    echo "junest.db already exists. Using it..."
    cp ${REPO_DIR}/any/junest.db $BASE_DIR/junest.db.tar.gz
    cp ${REPO_DIR}/any/junest.files $BASE_DIR/junest.files.tar.gz
else
    # This gives a signal that a new deploy has to occur
    touch $BASE_DIR/.different_files
fi

for pkgfile in $BASE_DIR/pkgs/*/*.pkg.tar.zst
do
    pkgfilename=$(basename $pkgfile)
    if [[ -e ${REPO_DIR}/any/$pkgfilename ]]
    then
        # Re-use the existing package
        echo Copying the existing package...
        cp ${REPO_DIR}/any/$pkgfilename $pkgfile
    else
        echo $pkgfile is not in DB, adding it...
        repo-add $BASE_DIR/junest.db.tar.gz $pkgfile
        # This gives a signal that a new deploy has to occur
        touch $BASE_DIR/.different_files
    fi
done

