Vagrant.configure("2") do |config|
  config.vm.box = "heroku"
  config.vm.box_url = "https://dl.dropboxusercontent.com/s/rnc0p8zl91borei/heroku.box"
  config.vm.synced_folder "../heroku-buildpack-nix-proot", "/mnt", create: true, group: "admin", owner: "vagrant"
  config.vm.provision "shell", path: "heroku-buildpack.sh"
end