#!/usr/bin/env bash

set -ex

REPO_URL="https://${GH_TOKEN}@github.com/fsquillace/junest-repo.git"
REPO_DIR="$(mktemp -d -t ci-XXXXXXXXXX)/repo"

git clone ${REPO_URL} ${REPO_DIR}

cp ./junest.db.tar.gz ${REPO_DIR}/any/junest.db
cp ./junest.files.tar.gz ${REPO_DIR}/any/junest.files

# TODO A smarter approach is to push only if files have changed
rm -f ${REPO_DIR}/any/*.pkg.tar.zst
cp ./pkgs/*/*.pkg.tar.zst ${REPO_DIR}/any/

cd ${REPO_DIR}
ls -l ${REPO_DIR}/any/*

git add ${REPO_DIR}/any/junest.db
git add ${REPO_DIR}/any/junest.files
git add ${REPO_DIR}/any/*.pkg.tar.zst
git remote
git config user.email ${EMAIL}
git config user.name "${USERNAME}"
git commit -m "Update repo from junest-aur-repo: ${TRAVIS_COMMIT}"
git push "${REPO_URL}" main

