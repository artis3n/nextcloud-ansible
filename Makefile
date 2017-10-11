#!/usr/bin/make

.PHONY: all
all: clean install

.PHONY: install
install:
	sudo apt update
	sudo apt install software-properties-common
	if [ ! -f /usr/bin/ansible ]; then sudo add-apt-repository ppa:ansible/ansible && sudo apt update && sudo apt install ansible; fi;
	sudo apt update
	sudo apt install python-pip
	pip install cryptography

.PHONY: clean
clean:
	find . -name "*.retry" -delete

.PHONY: ping
ping:
	ansible-playbook -i inventory ping.yml

.PHONY: ssh
ssh:
	ansible-playbook -i inventory ssh.yml --ask-pass

.PHONY: run
run:
	ansible-playbook --vault-id @prompt -i inventory main.yml