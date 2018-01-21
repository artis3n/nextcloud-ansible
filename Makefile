#!/usr/bin/make

.PHONY: all
all: clean install

.PHONY: install
install:
	sudo apt update
	sudo apt install software-properties-common
	if [ ! -f /usr/bin/ansible ]; then sudo add-apt-repository ppa:ansible/ansible && sudo apt update && sudo apt install ansible; fi;
	if [ ! -f /usr/bin/pip  ]; then sudo apt install python-pip; fi;
	pip install --upgrade cryptography

.PHONY: clean
clean:
	find . -name "*.retry" -delete

.PHONY: ping
ping:
	ansible-playbook -i inventory ping.yml

.PHONY: ssh
ssh:
	ansible-playbook --vault-id @prompt -i inventory ssh.yml --ask-pass

.PHONY: run
run:
	ansible-playbook --vault-id @prompt -i inventory main.yml --force-handlers

.PHONY: upgrade
upgrade:
	ansible-playbok --vault-id @prompt -i inventory nextcloud_upgrade.yml

.PHONY: encrypt-var
encrypt-var:
	ansible-vault encrypt_string --ask-vault-pass $(VAR_VALUE) --name $(VAR_NAME)

.PHONY: encrypt-file
encrypt-file:
	ansible-vault encrypt $(FILE) --ask-vault-pass --output $(FILE).encrypt

.PHONY: ecdh
ecdh:
	if [ ! -f /usr/bin/openssl]; then sudo apt install openssl; fi;
	mkdir -p files/secrets/nginx/
	openssl ecparam -name prime256v1 -out $${FILE:-files/secrets/nginx/ecdhparam.pem} -check
