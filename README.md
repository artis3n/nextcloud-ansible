# NextCloud-Ansible

Ansible deployment for Nextcloud software

## Installation & Set Up

- Clone the repo.

- Run `make install` to install Ansible and set up some dependencies.
  - At this moment, `make install` expects an Ubuntu system. I believe the "add Ansible repository to apt" command I use is Ubuntu-specific and will not work on other Debian systems. Certainly not on a system that does not use `apt`. I'll extend it for other Unix systems later.

- Create your `files/secrets/secrets.yml` file.
  - Run [`make encrypt-var`](#make-encrypt-var) for each variable. See `secrets-example.yml` for the necessary variables.
    - You will be prompted to enter an encryption password.
    - This will output the encrypted variable, which you should copy+paste into `files/secrets/secrets.yml`.
  - __IMPORTANT__: Every secret must be encrypted with the same password.

- Create a `inventory` file with your server's specifics. Use `inventory-example` as... an example.
  - Modify `ansible_ssh_host` to be the IP of your remote server.
  - Modify `ansible_ssh_user` to be the username of a user with sudo privileges on the remote server. The `sudo_password` should correspond with this account.
  - Modify the `swap_size` value to be appropriate for your system. Use the URL above the variable for assistance on deciding what size to use.

- Modify the variables in `files/vars.yml` as appropriate for you.

## Usage

Best practice is to run each playbook twice. If no failures occurred the first time, you should have no `changed` tasks on the second run through; they are idempotent and should all return `ok`. If that is not the case, there is likely something wrong that needs investigating.

### 1. `make ssh`

You will be prompted for the `SSH` password and the Ansible Vault password you supplied in `make encrypt-var`. This playbook will add your local `id_rsa.pub` to the remote server to allow Ansible to run the main playbook without password-based authentication.

Once your local public key is added to the inventory targets, you do not need to run this command again. All provisioning happens under `make run`.

Note: The playbook does not currently check whether `id_rsa.pub` already exists. I'll add that soon.

### 2. `make run`

You will be prompted for your Ansible Vault password. This will run the main playbook.

## Optional Setup

### Generate Diffie-Hellman parameters

1. `Nginx`, if you elect to set up a Let's Encrypt certificate, will use EFF Certbot's pre-computed DH parameters. If you would like to supply your own, either:
    - Generate them by running by running `make dh`.
    - Move pre-computed DH parameters to `files/secrets/nginx/dhparam.pem`.

   See instructions under [`make dh`](#make-dh) for usage of that Make command.

## Optional playbooks

### `make ping`

Runs only the `ping` playbook. Useful if you just want to check whether a remote system is online. Will fail unless `make ssh` has already been run successfully once against the remote system.

## Other Make Commands

### `make encrypt-file`

Encrypts an entire file using Ansible Vault.

Usage: `FILE=<path to file> make encrypt-file`

`FILE` is the name of the file you would like to encrypt, e.g. `files/secrets/nginx/dhparam.pem`. It will generate a file with a `.encrypt` extension in the same location as `FILE`.

__Note__: Ansible expects any file encrypted with Vault to be a YAML file containing variables.

### `make encrypt-var`

Encrypts a string of text.

Usage: `VAR_NAME=<variable name> VAR_VALUE=<variable's value> make encrypt-var`

`VAR_NAME` is the _name_ of the variable you would like to encrypt, e.g. `sudo_password`. `VAR_VALUE` is the _value_ of the variable that you would like to encrypt, e.g. `thisisabadpassword`.

### `make dh`

Generates 4096-bit Diffie-Hellman parameters. This will take a long time.

Usage: `[FILE=somewhere/else] make dh`

Will generate a file at `files/secrets/nginx/dhparam.pem` by default. You can change the file path by specifying a `FILE` environment variable.
