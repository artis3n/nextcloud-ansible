# NextCloud-Ansible
Ansible deployment for Nextcloud software

## Installation & Set Up

- Clone the repo.

- Run `make install` to install Ansible and set up some dependencies.
  - __Note__: at this moment, `make install` expects an Ubuntu system. I believe the "add Ansible repository to apt" command I use is Ubuntu-specific and will not work on other Debian systems. Certainly not on a system that does not use `apt`. I'll extend it for other Unix systems later.

- Create your `files/secrets.yml` file. Use `secrets-example.yml` as...an example.
  - Run `VAR_NAME=<name> VAR_VALUE=<value> make encrypt-var`
  - You will be prompted to enter an encryption password. `VAR_NAME` is the name of the variable you would like to encrypt, e.g. `sudo_password`. `VAR_VALUE` is the value of the variable that you would like to encrypt.
  - This will output the encrypted variable, which you should copy+paste into `files/secrets.yml`.
  - __IMPORTANT__: Every secret must be encrypted with the same password.

- Edit the `inventory` file with your server's specifics.
  - Modify `ansible_ssh_host` to be the IP of your remote server.
  - Modify `ansible_ssh_user` to be the username of a local user with sudo privileges on your remote server. The `sudo_password` should correspond with this account.
  - Modify the `swap_size` value to be appropriate for your system. Use the URL above the variable for assistance on deciding what size to use.

## Usage

Best practice is to run each playbook twice. If no failures occurred the first time, you should have no `changed` tasks on the second run through; they are idempotent and should all return `ok`. If that is not the case, there is likely something wrong that needs investigating.

#### 1. `make ssh`
You will be prompted for the `SSH` password and the Ansible Vault password you supplied in `make encrypt-var`. This playbook will add your local `id_rsa.pub` to the remote server to allow Ansible to run the main playbook without password-based authentication.

Note: The playbook does not currently check whether `id_rsa.pub` already exists. I'll add that soon.

#### 2. `make run`
You will be prompted for your Ansible Vault password. This will run the main playbook.

### Optional playbooks

#### `make ping`
Runs only the `ping` playbook. Useful if you just want to check whether a remote system is online. Will fail unless `make ssh` has already been run successfully once against the remote system.
