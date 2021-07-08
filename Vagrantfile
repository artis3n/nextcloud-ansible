# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure("2") do |config|

  N = 4
  (1..N).each do |machine_id|

    if machine_id == 1
      box = "centos/7"
      name = "centos"
    elsif machine_id == 2
      box = "generic/rhel7"
      name = "rhel"
    elsif machine_id == 3
      box = "debian/jessie64"
      name = "debian"
    elsif machine_id == 4
      box = "ubuntu/bionic64"
      name = "ubuntu"
    end

    $YUM_MAX = 2

    config.vm.define "#{name}#{machine_id}" do |machine|
      machine.vm.hostname = "#{name}#{machine_id}"
      machine.vm.box = "#{box}"

      machine.vm.network "public_network", ip: "192.168.1.#{20+machine_id}", bridge: "wlp3s0"
      machine.vm.network :forwarded_port, guest: 22, host: "222#{machine_id}".to_i, id: "ssh"
      machine.vm.network :forwarded_port, guest: 80, host: "180#{machine_id}".to_i, id: "http"
      machine.vm.network :forwarded_port, guest: 443, host: "443#{machine_id}".to_i, id: "https"

      if machine_id <= $YUM_MAX
        machine.vm.provision "shell",
          inline: "sudo yum install python -y",
          privileged: true
      elsif machine_id > $YUM_MAX
        machine.vm.provision "shell",
          inline: "sudo apt-get install python -y",
          privileged: true
      end

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
            "rhel2" => {
              "swap_size" => 2097152,
              "ssh_port" => 2222,
            },
            "debian3" => {
              "swap_size" => 2097152,
              "ssh_port" => 2223,
            },
            "ubuntu4" => {
              "swap_size" => 2097152,
              "ssh_port" => 2224,
            },
          }

          ansible.groups = {
            "nextcloud" => ["centos1", "rhel2", "debian3", "ubuntu4"],
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
