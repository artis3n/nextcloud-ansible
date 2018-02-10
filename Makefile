#!/usr/bin/make

.PHONY: all
all: install ssh run

.PHONY: install
install:
	sudo apt update
	sudo apt install software-properties-common
	if [ ! -f /usr/bin/ansible ]; then sudo add-apt-repository ppa:ansible/ansible && sudo apt update && sudo apt install ansible; fi;
	if [ ! -f /usr/bin/pip  ]; then sudo apt install python-pip; fi;
	pip install --upgrade cryptography

.PHONY: ping
ping:
	ansible-playbook -i inventory ping.yml

.PHONY: ssh
ssh:
	if [ -f ~/.vault ]; then ansible-playbook --vault-id ~/.vault -i inventory ssh.yml --ask-pass; else ansible-playbook --vault-id @prompt -i inventory ssh.yml --ask-pass; fi;

.PHONY: run
run:
	if [ -f ~/.vault ]; then ANSIBLE_PIPELINING=True ansible-playbook --vault-id ~/.vault -i inventory main.yml --force-handlers; else ANSIBLE_PIPELINING=True ansible-playbook --vault-id @prompt -i inventory main.yml --force-handlers; fi;

.PHONY: upgrade
upgrade:
	if [ -f ~/.vault ]; then ansible-playbok --vault-id ~/.vault -i inventory nextcloud_upgrade.yml; else ansible-playbok --vault-id @prompt -i inventory nextcloud_upgrade.yml; fi;

.PHONY: encrypt-var
encrypt-var:
	ansible-vault encrypt_string --ask-vault-pass $(VAR_VALUE) --name $(VAR_NAME)

.PHONY: encrypt-file
encrypt-file:
	if [ -f $${FILE:-files/secrets/secrets.yml} ]; then ansible-vault edit $${FILE:-files/secrets/secrets.yml} --ask-vault-pass; else ansible-vault create $${FILE:-files/secrets/secrets.yml} --ask-vault-pass; fi;

.PHONY: ecdh
ecdh:
	if [ ! -f /usr/bin/openssl]; then sudo apt install openssl; fi;
	mkdir -p files/secrets/nginx/
	openssl ecparam -name prime256v1 -out $${FILE:-files/secrets/nginx/ecdhparam.pem} -check
