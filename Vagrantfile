# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure("2") do |config|

  N = 3
  (1..N).each do |machine_id|

    if N == 1
      box = "centos/7"
      name = "centos"
    elsif N == 2
      box = "debian/jessie64"
      name = "debian"
    elsif N == 3
      box = "ubuntu/bionic64"
      name = "ubuntu"
    end

    config.vm.define "#{name}#{machine_id}" do |machine|
      machine.vm.hostname = "#{name}#{machine_id}"
      machine.vm.box = "#{box}"

      machine.vm.network "public_network", ip: "192.168.1.#{20+machine_id}"
      machine.vm.network :forwarded_port, guest: 22, host: "222#{machine_id}".to_i, id: "ssh"

      # Only execute once the Ansible provisioner,
      # when all the machines are up and ready.
      if machine_id == N
        machine.vm.provision :ansible do |ansible|
          # Disable default limit to connect to all the machines
          ansible.limit = "all"

          ansible.playbook = "main.yml"
          ansible.ask_vault_pass = true

          ansible.host_vars = {
            "centos1" => {
              "swap_size" => 2097152,
              "ssh_port" => 2221,
              # "server_domain" => "<server domain name>",
            },
            "debian2" => {
              "swap_size" => 2097152,
              "ssh_port" => 2222,
              # "server_domain" => "<server domain name>",
            },
            "ubuntu3" => {
              "swap_size" => 2097152,
              "ssh_port" => 2223,
              # "server_domain" => "<server domain name>",
            },
          }

          ansible.groups = {
            "nextcloud" => ["centos1", "debian2", "ubuntu3"],
            "nextcloud:vars" => {
              "staging" => "yes",
              "server_encryption" => "no",
            }
          }
        end
      end
    end
  end
end
