#!/usr/bin/make

.PHONY: all
all: clean install

.PHONY: install
install:
	sudo apt update
	sudo apt install software-properties-common
	if [ ! -f /usr/bin/ansible ]; then sudo add-apt-repository ppa:ansible/ansible && sudo apt update && sudo apt install ansible; fi;
	sudo apt update
	if [ ! -f /usr/bin/pip  ]; then sudo apt install python-pip; fi;
	pip install cryptography
	make build-openssl

.PHONY: build-openssl
build-openssl:
	curl -O https://www.openssl.org/source/openssl-1.1.0g.tar.gz
	tar -xzvf openssl-1.1.0g.tar.gz
	cd openssl-1.1.0g && ./config -Wl,-rpath=/usr/local/ssl/lib no-ssl2 no-ssl3 no-weak-ssl-ciphers --prefix=/usr/local/ssl --openssldir=/usr/local/ssl
	cd openssl-1.1.0g && sudo make
	cd openssl-1.1.0g && sudo make install

.PHONY: clean-openssl
clean-openssl:
	-sudo rm -rf /usr/local/ssl
	-rm -rf ./openssl-1.1.0g
	-rm -f ./openssl-1.1.0g.tar.gz

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
	ansible-playbook --vault-id @prompt -i inventory main.yml

.PHONY: encrypt-var
encrypt-var:
	ansible-vault encrypt_string --ask-vault-pass $(VAR_VALUE) --name $(VAR_NAME)

.PHONY: encrypt-file
encrypt-file:
	ansible-vault encrypt $(FILE) --ask-vault-pass --output $(FILE).encrypt

.PHONY: dh
dh:
	if [ ! -f /usr/bin/openssl]; then sudo apt install openssl; fi;
	openssl dhparam -out $${FILE:-files/secrets/nginx/dhparam.pem} -5 4096
