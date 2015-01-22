#!/usr/bin/env bash

SCRIPT_DIR=/mnt
BUILD_DIR=/tmp/build
CACHE_DIR=/home/vagrant/cache

su vagrant -c "mkdir -p $BUILD_DIR"
su vagrant -c "mkdir -p $CACHE_DIR"
su vagrant -c "rsync --exclude /build -a /vagrant/ $BUILD_DIR"

# make sure NIX_S3_KEY, NIX_S3_SECRET, and NIX_S3_BUCKET are set by the secrets.sh file
source /vagrant/secrets.sh

cat <<EOF > /tmp/env.sh
mkdir -p /tmp/env
echo "$NIX_S3_KEY" > /tmp/env/NIX_S3_KEY
echo "$NIX_S3_SECRET" > /tmp/env/NIX_S3_SECRET
echo "$NIX_S3_BUCKET" > /tmp/env/NIX_S3_BUCKET
echo "/vagrant/build" > /tmp/env/REAL_APP_DIR
EOF

cat <<EOF > /tmp/build/do_build
#!/bin/bash
source /vagrant/build/bin/script-common
export_env_dir /tmp/env
source /vagrant/build/.profile.d/000_nix.sh
build
EOF

chmod a+x /tmp/build/do_build

if su vagrant -c "bash $SCRIPT_DIR/bin/detect $BUILD_DIR"; then
  su vagrant -c "bash /tmp/env.sh"
  su vagrant -c "bash $SCRIPT_DIR/bin/compile $BUILD_DIR $CACHE_DIR /tmp/env"
  echo "Copying BUILD_DIR to build"
  su vagrant -c "rsync -a $BUILD_DIR/ /vagrant/build"
else
  echo "Not a Nix package; terminating"
fi