#!/usr/bin/make

.PHONY: all
all: install ssh run

.PHONY: install
install: install-dependencies

.PHONY: dev
dev: install install-dev-dependencies local-box

.PHONY: install-dependencies
install-dependencies:
	if [ ! -f /usr/bin/python3 ]; then sudo apt update && sudo apt install -y python3; fi;
	if [ ! -f /usr/bin/pip3 ]; then sudo apt update && sudo apt install -y python3-pip; fi;
	if [ ! -f ~/.local/bin/pipenv ]; then pip3 install pipenv; fi;
	if [ ! -d ~/.local/share/virtualenvs ]; then mkdir -p ~/.local/share/virtualenvs/; fi;
	if [ ! $$(find ~/.local/share/virtualenvs/ -name "nextcloud-ansible*") ]; then ~/.local/bin/pipenv install --python /usr/bin/python3; fi;

.PHONY: dev-install
dev-install: install
	pipenv install --dev;
	if [ ! -f /usr/bin/vagrant ]; then sudo apt install vagrant; fi;
	if [ ! -f /usr/bin/virtualbox ]; then sudo apt install virtualbox; fi;

.PHONY: local-box
local-box:
	if [ ! -d ./vagrant ]; then vagrant up; fi;

.PHONY: dev-update
dev-update:
	vagrant box update
	vagrant box prune

.PHONY: clean
clean:
	vagrant destroy -f
	rm -f *.log
	-~/.local/bin/pipenv --rm

.PHONY: lint
lint:
	~/.local/bin/pipenv run ansible-lint -c .ansible-lint *.yml

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
