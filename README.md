# NextCloud-Ansible

Ansible deployment for Nextcloud software

## Installation & Set Up

- Clone the repo.

- Run `make install` to install Ansible and set up some dependencies.
  - At this moment, `make install` expects a Debian system. I'll extend it for other Unix systems later.

- Create your `files/secrets/secrets.yml` file.
  - Run [`make encrypt-file`](#make-encrypt-file) for each necessary variable. See `secrets-example.yml` for the variables that must be in this file.
    - You will be prompted to enter an encryption password.
    - Create the file following the syntax in `secrets-example.yml`.
  - This file can be edited by running `make encrypt-file` again.

- Create a `inventory` file with your server's specifics. Use `inventory-example` as... an example.
  - Modify `ansible_host` to be the IP of your remote server.
  - Modify `ansible_user` to be the username of a user with administrator (sudo) privileges on the remote server. The `sudo_password` secrets value should correspond to this user.
  - Modify the `swap_size` value to be appropriate for your system. Use the URL above the variable for assistance on deciding what size to use.

- Modify the variables in `files/vars.yml` as appropriate for you. The defaults should be sufficient for most use cases.

## Usage

Best informal practice is to run each playbook twice. If no failures occurred the first time, you should have no `changed` tasks on the second run; tasks are built to be idempotent and should all return `ok`. If that is not the case, there is likely something wrong that needs investigating.

### 1. `make ssh`

You will be prompted for the `SSH` password and the Ansible Vault password you supplied in `make encrypt-var`. This playbook will add your local `id_rsa.pub` to the remote server to allow Ansible to run the main playbook without password-based authentication.

Once your local public key is added to the inventory targets, you do not need to run this command again. All provisioning happens under `make run`.

Note: The playbook does not currently check whether `id_rsa.pub` already exists. I'll add that soon.

### 2. `make run`

You will be prompted for your Ansible Vault password. This will run the main playbook.

## Optional Setup

### Generate Diffie-Hellman parameters

1. `Nginx`, if you elect to set up a Let's Encrypt certificate, will use EFF Certbot's pre-computed DH parameters. Instead, you should use ECDH parameters.
    - Generate them by running by running [`make ecdh`](#make-ecdh).
    - Or, move other pre-computed ECDH parameters to `files/secrets/nginx/ecdhparam.pem`.

## Optional playbooks

### `make ping`

Runs only the `ping` playbook. Useful if you just want to check whether a remote system is online. Will fail unless `make ssh` has already been run successfully once against the remote system, as it will use .

## Other Make Commands

### `make encrypt-file`

Encrypts an entire file using Ansible Vault.

Usage: `FILE=<path to file> make encrypt-file`

Example: `FILE=../test/file.yml make encrypt-file`

`FILE` is the name of the file you would like to encrypt, e.g. `files/secrets/secrets.yml`. It will generate a file with a `.encrypt` extension in the same location as `FILE`.

#### Notes

You can write your Ansible vault password to a `~/.vault` file. If that file exists, Ansible will try to read a password from that file to decrypt the Vault-encrypted files. You still need to specify this password when encrypting a file with `make encrypt-file`. If you create this file, run `chmod 600 ~/.vault` so the file is only writeable AND readable by your account.

Ansible expects any file encrypted with Vault to be a YAML file containing YAML-formatted variables.

### `make ecdh`

Generates 512-bit Elliptic Curve Diffie-Hellman parameters.

Usage: `[FILE=somewhere/else] make ecdh`

Will generate a file at `files/secrets/nginx/ecdhparam.pem` by default. You can change the file path by specifying a `FILE` environment variable.
