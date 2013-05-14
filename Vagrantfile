# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "centos-6.3-chef-10.14.2.box"
  config.vm.box_url = "https://s3.amazonaws.com/itmat-public/centos-6.3-chef-10.14.2.box"

  config.vm.network :forwarded_port, guest: 80,  host: 80
  config.vm.network :forwarded_port, guest: 443, host: 443

  config.vm.hostname = "webapp.dev"

  config.vm.synced_folder ".", "/vagrant", :extra => 'dmode=777', :id => "vagrant-root"

  config.vm.provision :chef_solo do |chef|
    chef.provisioning_path = "/tmp/vagrant-chef"
    chef.cookbooks_path = "cookbooks"
    chef.add_recipe("vagrant_main::default")
  end

end


