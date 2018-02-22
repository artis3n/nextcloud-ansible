# NextCloud-Ansible

Ansible deployment for Nextcloud software

__Note__: At the moment, the machine running the Ansible playbook is required to be a Debian system (for the `make install` command to succeed). That can be manually adjusted pretty easily for the time being. However, the target servers in the `inventory` file _must_ be CentOS machines for the time being. That support will be extended.

## Installation & Set Up

- Clone the repo.

- Run `make install` to install Ansible and set up some dependencies.
  - At this moment, `make install` expects a Debian system. I'll extend it for other Unix systems later.

- Create your `files/secrets/secrets.yml` file.
  - Run [`make encrypt-file`](#make-encrypt-file) to create the necessary variables. See `secrets-example.yml` for the variables that must be in this file.
    - You will be prompted to enter an encryption password.
    - Create the file following the syntax in `secrets-example.yml`.
  - This file can be edited by running `make encrypt-file` again.

- Create a `inventory` file with your server's specifics. Use `inventory-example` as... an example.
  - Modify `ansible_host` to be the IP of your remote server.
  - Modify `ansible_user` to be the username of a user with administrator (sudo) privileges on the remote server. The `sudo_password` value in `files/secrets/secrets.yml` should correspond to this user.
  - Modify the `swap_size` value to be appropriate for your system. Use the URL above the variable for assistance on deciding what size to use.
  - Repeat for however many servers you would like to deploy.
  - Set the `public_key_file` to the path corresponding to the public key you would like to use during the main playbook. A suggested default is listed in `inventory-example`.
  - Set the `staging` variable based on the description provided in `inventory-example`.

- Modify the variables in `files/vars.yml` as appropriate for you. The defaults should be sufficient for most use cases.
  - Optionally, customize the certificate details under _OpenSSL Config Options_ in `files/vars.yml`. The U.S. capital is left as the default for lack of anything else.

- __Optionally__, create a `.vault` file in your home directory (`~/.vault`) and enter the encryption password you used in `make encrypt-file`. Ansible will prompt for you to enter this encryption password on every run of a playbook unless you create a `~/.vault` file. If that file exists, Ansible will read that file and use its contents as the password to your Vault-encrypted files. You can decide whether you would like to take advantage of this.

- After these set up steps, you can run the ssh and main playbooks via the commands `make ssh` and `make run`. See below for more information on those commands.

## Usage

Best informal practice is to run each playbook twice. If no failures occurred the first time, you should have no `changed` tasks on the second run; tasks are built to be idempotent and should all return `ok`. If that is not the case, there is likely something wrong that needs investigating.

### 1. `make ssh`

You will be prompted for the `SSH` password and, optionally, the Ansible Vault password you supplied in `make encrypt-file`. This playbook will add the public keys located in the `public_key_file` file to the remote server to allow Ansible to run the main playbook without password-based authentication, which is a requirement.

Once your local public key is added to the inventory targets, you do not need to run this command again. All provisioning happens under `make run`.

Note: The playbook will fail if the `public_key_file` does not exist. You are expected to generate a key pair, if you do not have a public key to provide. Github has [excellent documentation][github ssh keys] on how to create an SSH key pair.

[github ssh keys]: https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/#generating-a-new-ssh-key

### 2. `make run`

You will be prompted for your Ansible Vault password if you have not created a `~/.vault` file. This will run the main playbook. Done!

## Optional Setup

### Generate ECDH parameters

1. `Nginx`, if you elect to set up a Let's Encrypt certificate, will use Nginx's packaged ECDH parameters, which are fine. You do, however, have other options:
    - Generate parameters with our recommended settings by running by running [`make ecdh`](#make-ecdh).
    - Or, move other pre-computed ECDH parameters to `files/secrets/nginx/ecdhparam.pem`.

## Optional playbooks

### `make ping`

Runs only the `ping` playbook. Useful if you just want to check whether a remote system is online. Will fail unless `make ssh` has already been run successfully once against the remote system, as it will expect that the user's public key is authorized on the target system.

## Other Make Commands

### `make encrypt-file`

Encrypts an entire file using Ansible Vault.

Usage: `FILE=<path to file> make encrypt-file`

Example: `FILE=../test/file.yml make encrypt-file`

`FILE` is the name of the file you would like to encrypt, e.g. `files/secrets/secrets.yml`. It will generate a file with a `.encrypt` extension in the same location as `FILE`.

__Note__: this command will target `files/secrets/secrets.yml` by default unless another file is specified with the `FILE` environment variable.

#### Notes

You can write your Ansible vault password to a `~/.vault` file. If that file exists, Ansible will try to read a password from that file to decrypt the Vault-encrypted files. You still need to specify this password when encrypting a file with `make encrypt-file`. If you create this file, run `chmod 600 ~/.vault` so the file is only writeable AND readable by your account.

Ansible expects any file encrypted with Vault to be a YAML file containing YAML-formatted variables.

### `make ecdh`

Generates 512-bit Elliptic Curve Diffie-Hellman parameters.

Usage: `[FILE=somewhere/else] make ecdh`

Will generate a file at `files/secrets/nginx/ecdhparam.pem` by default. You can change the file path by specifying a `FILE` environment variable.
