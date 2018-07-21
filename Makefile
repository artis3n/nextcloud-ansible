#!/usr/bin/make

.PHONY: all
all: install ssh run

.PHONY: install
install: install-dependencies

.PHONY: dev
dev: install local-box

.PHONY: install-dependencies
install-dependencies:
	dpkg -s software-properties-common > /dev/null; if [ ! $$? -eq 0 ]; then sudo apt update && sudo apt install software-properties-common; fi;
	if [ ! -f /usr/bin/python ]; then sudo apt install python; fi;
	if [ ! -f /usr/bin/pip ]; then sudo apt install python-pip; fi;
	if [ ! -f /usr/bin/ansible ]; then sudo add-apt-repository ppa:ansible/ansible && sudo apt update && sudo apt install ansible; fi;
	if [ ! -f /usr/bin/vagrant ]; then sudo apt install vagrant; fi;
	if [ ! -f /usr/bin/virtualbox ]; then sudo apt install virtualbox; fi;
	pip install --upgrade cryptography > /dev/null;

.PHONY: local-box
local-box:
	if [ ! -d ./vagrant ]; then vagrant up; fi;

.PHONY: clean
clean:
	vagrant destroy -f

.PHONY: ping
ping:
	ansible-playbook -i inventory ping.yml

.PHONY: ssh
ssh:
	if [ -f ~/.vault ]; then ANSIBLE_PIPELINING=False ansible-playbook --vault-id ~/.vault -i inventory ssh.yml; else ANSIBLE_PIPELINING=False ansible-playbook --vault-id @prompt -i inventory ssh.yml; fi;

.PHONY: run
run:
	if [ -f ~/.vault ]; then ansible-playbook --vault-id ~/.vault -i inventory main.yml --force-handlers; else ansible-playbook --vault-id @prompt -i inventory main.yml --force-handlers; fi;

.PHONY: dry-run
dry-run:
	if [ -f ~/.vault ]; then ansible-playbook --check --diff --vault-id ~/.vault -i inventory main.yml --force-handlers; else ansible-playbook --check --diff --vault-id @prompt -i inventory main.yml --force-handlers; fi;

.PHONY: upgrade
upgrade:
	if [ -f ~/.vault ]; then ansible-playbok --vault-id ~/.vault -i inventory nextcloud_upgrade.yml; else ansible-playbok --vault-id @prompt -i inventory nextcloud_upgrade.yml; fi;

.PHONY: encrypt-var
encrypt-var:
	ansible-vault encrypt_string $(VAR_VALUE) --name $(VAR_NAME)

.PHONY: encrypt-file
encrypt-file:
	if [ -f $${FILE:-files/secrets/secrets.yml} ]; then ansible-vault edit $${FILE:-files/secrets/secrets.yml}; else ansible-vault create $${FILE:-files/secrets/secrets.yml}; fi;

.PHONY: ecdh
ecdh:
	if [ ! -f /usr/bin/openssl]; then sudo apt install openssl; fi;
	mkdir -p files/secrets/nginx/
	openssl ecparam -name prime256v1 -out $${FILE:-files/secrets/nginx/ecdhparam.pem} -check
