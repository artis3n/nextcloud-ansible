# NextCloud-Ansible

Ansible deployment for Nextcloud software

## Installation & Set Up

- Clone the repo.

- Run `make install` to install Ansible and set up some dependencies.
  - At this moment, `make install` expects an Ubuntu system. I believe the "add Ansible repository to apt" command I use is Ubuntu-specific and will not work on other Debian systems. Certainly not on a system that does not use `apt`. I'll extend it for other Unix systems later.

- Create your `files/secrets/secrets.yml` file. Use `secrets-example.yml` as...an example.
  - Run [`make encrypt-var`]
  - You will be prompted to enter an encryption password.
  - This will output the encrypted variable, which you should copy+paste into `files/secrets/secrets.yml`.
  - __IMPORTANT__: Every secret must be encrypted with the same password.

- Edit the `inventory` file with your server's specifics.
  - Modify `ansible_ssh_host` to be the IP of your remote server.
  - Modify `ansible_ssh_user` to be the username of a user with sudo privileges on the remote server. The `sudo_password` should correspond with this account.
  - Modify the `swap_size` value to be appropriate for your system. Use the URL above the variable for assistance on deciding what size to use.

## Usage

Best practice is to run each playbook twice. If no failures occurred the first time, you should have no `changed` tasks on the second run through; they are idempotent and should all return `ok`. If that is not the case, there is likely something wrong that needs investigating.

### 1. `make ssh`

You will be prompted for the `SSH` password and the Ansible Vault password you supplied in `make encrypt-var`. This playbook will add your local `id_rsa.pub` to the remote server to allow Ansible to run the main playbook without password-based authentication.

Note: The playbook does not currently check whether `id_rsa.pub` already exists. I'll add that soon.

### 2. `make run`

You will be prompted for your Ansible Vault password. This will run the main playbook.

## Optional Setup

### Generate Diffie-Hellman parameters

`Nginx` will use Let's Encrypt pre-computed DH parameters. If you would like to supply your own, either:
  - Generate them by running by running `make dh && FILE=files/secrets/nginx/dhparam.pem make encrypt-file`.
  - Move pre-computed DH parameters by running `FILE=<path to DH param .pem file> make encrypt-file` and moving the resulting `.encrypt` file to `files/secrets/nginx/dhparam.pem.encrypt`.

See instructions under [`make dh`] for usage of that Make command.

## Optional playbooks

### `make ping`

Runs only the `ping` playbook. Useful if you just want to check whether a remote system is online. Will fail unless `make ssh` has already been run successfully once against the remote system.

## Other Make Commands

### `make encrypt-file`

Encrypts an entire file using Ansible Vault.

Usage: `FILE=<path to file> make encrypt-file`

`FILE` is the name of the file you would like to encrypt, e.g. `files/secrets/nginx/dhparam.pem`. It will generate a file with a `.encrypt` extension in the same location as `FILE`.

### `make encrypt-var`

Encrypts a string of text.

Usage: `VAR_NAME=<variable name> VAR_VALUE=<variable's value> make encrypt-var`

`VAR_NAME` is the _name_ of the variable you would like to encrypt, e.g. `sudo_password`. `VAR_VALUE` is the _value_ of the variable that you would like to encrypt.

### `make dh`

Generates 4096-bit Diffie-Hellman parameters. This will take a long time.

Usage: `[FILE=somewhere/else] make dh`

Will generate a file at `files/secrets/nginx/dhparam.pem` by default. You can change the file path by specifying a `FILE` environment variable.
