#!/usr/bin/env bash

set -ex

# This ensures to have the most up to date keys before installing any
# other packages
pacman --noconfirm -Sy archlinux-keyring
pacman-key --init
pacman-key --populate archlinux
pacman -Sy --noconfirm git shadow util-linux base-devel

# Create a travis user
echo "travis ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/travis
chmod 'u=r,g=r,o=' /etc/sudoers.d/travis
groupadd --gid "2000" "travis"
useradd --create-home --uid "2000" --gid "2000" --shell /usr/bin/false "travis"
mkdir /home/travis/.cache
chown travis /home/travis/.cache

# Here do not make any validation (-n) because it will be done later on in the Ubuntu host directly
cd /build
runuser -u travis -- /build/bin/build_packages.sh
runuser -u travis -- /build/bin/update_db_and_deploy.sh
