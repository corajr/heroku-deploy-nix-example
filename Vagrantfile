Vagrant.configure("2") do |config|
  config.vm.box = "heroku"
  config.vm.box_url = "https://dl.dropboxusercontent.com/s/rnc0p8zl91borei/heroku.box"
  config.vm.synced_folder "/Users/chrisjr/Development/heroku-buildpack-nix-proot", "/mnt", create: true, group: "admin", owner: "vagrant"
  config.vm.provision "shell", path: "/Users/chrisjr/Development/heroku-buildpack.sh"
end