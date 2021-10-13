#!/usr/bin/env bash
# More info about how to create a custom repository:
# https://wiki.archlinux.org/title/unofficial_user_repositories
# https://wiki.archlinux.org/title/Pacman/Tips_and_tricks#Custom_local_repository

set -ex

BASE_DIR="$(readlink -f $(dirname $(readlink -f "$0"))/..)"

REPO_URL="https://${GH_TOKEN}@github.com/fsquillace/junest-repo.git"
REPO_DIR="$(mktemp -d -t ci-XXXXXXXXXX)/repo"

git clone ${REPO_URL} ${REPO_DIR}

DEPLOY=false

if [[ -e ${REPO_DIR}/any/junest.db ]]
then
    echo "junest.db already exists. Using it..."
    # This is required in order to repo-add to work. Unfortunately it is not possible
    # to use symlink in repository based on github raw URL that's why this is needed:
    mv ${REPO_DIR}/any/junest.db $REPO_DIR/any/junest.db.tar.gz
    mv ${REPO_DIR}/any/junest.files $REPO_DIR/any/junest.files.tar.gz
fi

for pkgfile in $BASE_DIR/pkgs/*/*.pkg.tar.zst
do
    pkgfilename=$(basename $pkgfile)
    if [[ -e ${REPO_DIR}/any/$pkgfilename ]]
    then
        echo Package $pkgfilename did not change. Re-using the existing package...
    else
        echo $pkgfile is not in DB, adding it...
        repo-add $REPO_DIR/any/junest.db.tar.gz $pkgfile
        cp $pkgfile $REPO_DIR/any/
        DEPLOY=true
    fi
done


if ! $DEPLOY
then
    echo There are no new packages to deploy. Exiting...
    exit 0
fi

# Revert the db and files names back:
mv ${REPO_DIR}/any/junest.db.tar.gz $REPO_DIR/any/junest.db
mv ${REPO_DIR}/any/junest.files.tar.gz $REPO_DIR/any/junest.files

cd ${REPO_DIR}
echo
echo List of packages in repo:
ls -l ${REPO_DIR}/any/*

git add ${REPO_DIR}/any/junest.db
git add ${REPO_DIR}/any/junest.files
git add ${REPO_DIR}/any/*.pkg.tar.zst
git remote
git config user.email "${EMAIL}"
git config user.name "${USERNAME}"
git commit -m "Update repo from junest-aur-repo: ${TRAVIS_COMMIT}"
git push "${REPO_URL}" main


