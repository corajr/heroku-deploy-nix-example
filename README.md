This is an example for Nix deployment to Heroku using the
[heroku-buildpack-nix-proot](http://github.com/chrisjr/heroku-buildpack-nix-proot)
buildpack. See that buildpack for more general instructions.

Dokku can be used for a local test environment.

To start, create a `secrets.sh` file with your S3 credentials like this:
```
export NIX_S3_KEY=...
export NIX_S3_SECRET=...
export NIX_S3_BUCKET=...
```

## Deployment

### Dokku

Easiest to set up [Dokku using Vagrant](http://progrium.viewdocs.io/dokku/installation#user-content-install-dokku-using-vagrant).

(Note: As of 2015-01-23, you should ignore the advice to set the port in ~/.ssh/config.)

You will need to change the mode of apparmor (installed by Docker) to allow proot to work.

Enter your Dokku folder and type:
```bash
vagrant ssh
# on vm
sudo apt-get install apparmor-utils
sudo aa-complain /etc/apparmor.d/docker
```

Then, in this repo:

```bash
source secrets.sh
APP_NAME=deploy_nix
ssh dokku@dokku.me config:set $APP_NAME \
                  NIX_S3_KEY=$NIX_S3_KEY \
                  NIX_S3_SECRET=$NIX_S3_SECRET \
                  NIX_S3_BUCKET=$NIX_S3_BUCKET
git remote add dokku dokku@dokku.me:$APP_NAME
git push dokku master
ssh dokku@dokku.me dokku run $APP_NAME build
```

### Heroku
To deploy directly to Heroku:

```bash
source secrets.sh
heroku create -b http://github.com/chrisjr/heroku-buildpack-nix-proot
heroku config:set NIX_S3_KEY=$NIX_S3_KEY \
                  NIX_S3_SECRET=$NIX_S3_SECRET \
                  NIX_S3_BUCKET=$NIX_S3_BUCKET
git push heroku master
# wait for Nix install...
```

If you use the Dokku method above, a binary closure will already be saved
that Heroku can pick up without needing to use up dyno hours building.

If not, you can build remotely as follows:

```bash
heroku run build
# for a larger app, you may need `heroku run -s PX build`

# final deploy
git commit --amend --no-edit
git push -f heroku master
```

If you wish to recompile when pushing changes directly to Heroku,
you can set `heroku config:set NIX_BUILD_ON_PUSH=1`. (This might make
more sense on dokku, since it will not run out of time.)