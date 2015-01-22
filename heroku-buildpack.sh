#!/usr/bin/env bash

SCRIPT_DIR=/mnt
BUILD_DIR=/tmp/build
CACHE_DIR=/home/vagrant/cache

su vagrant -c "mkdir -p $BUILD_DIR"
su vagrant -c "mkdir -p $CACHE_DIR"
su vagrant -c "rsync -a /vagrant/ $BUILD_DIR"

# make sure NIX_S3_KEY, NIX_S3_SECRET, and NIX_S3_BUCKET are set by the secrets.sh file
source secrets.sh

cat <<EOF > /tmp/env.sh
  mkdir -p /tmp/env
  echo "$NIX_S3_KEY" > /tmp/env/NIX_S3_KEY
  echo "$NIX_S3_SECRET" > /tmp/env/NIX_S3_SECRET
  echo "$NIX_S3_BUCKET" > /tmp/env/NIX_S3_BUCKET
EOF

cat <<EOF > /vagrant/do_build
  source /vagrant/.buildpack/bin/script-common
  export_env_dir /tmp/env
  source /vagrant/.profile.d/000_nix.sh
  build
EOF

chmod a+x /vagrant/do_build

if su vagrant -c "bash $SCRIPT_DIR/bin/detect $BUILD_DIR"; then
  su vagrant -c "bash /tmp/env.sh"
  su vagrant -c "bash $SCRIPT_DIR/bin/compile $BUILD_DIR $CACHE_DIR /tmp/env"
  rsync -a $BUILD_DIR/ /vagrant/build
else
  echo "Not a Nix package; terminating"
fi