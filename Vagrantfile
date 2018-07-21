# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.define :centos1

  config.vm.network "public_network", ip: "192.168.1.176"
  config.vm.network :forwarded_port, guest: 22, host: 2222, id: "ssh"

  # Ansible
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "main.yml"
    ansible.ask_vault_pass = true

    ansible.host_vars = {
      "centos1" => {
        "swap_size" => 2097152,
        # "server_domain" => "<server domain name>",
      }
    }

    ansible.groups = {
      "nextcloud" => ["centos1"],
      "nextcloud:vars" => {
        "staging" => "yes",
        "server_encryption" => "no",
        "ssh_port" => 2222,
      }
    }
  end
end
