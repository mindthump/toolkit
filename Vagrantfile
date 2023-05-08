# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "generic/alpine317"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end

  $script = <<-ROOTSHELL
  apk update
  apk add --no-cache zsh git zip wget neovim less psmisc sudo httpie tree mc the_silver_searcher ncdu byobu bat stow
  ln -fs /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
  ROOTSHELL
  config.vm.provision "shell", inline: $script

  $script = <<-USERSHELL
  git clone --depth=1 --single-branch https://github.com/mindthump/dotfiles .dotfiles
  curl -Lo omz-install.sh https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh
  CHSH=no RUNZSH=no sh omz-install.sh --unattended
  rm -f ~/.zshrc ~/.profile omz-install.sh
  stow --dir ~/.dotfiles --stow zsh vim byobu git
  USERSHELL
  config.vm.provision "shell", inline: $script, privileged: false

end
