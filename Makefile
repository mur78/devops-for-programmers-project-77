init:
	terraform -chdir=./terraform/ init

apply:
	terraform -chdir=./terraform/ apply

destroy:
	terraform -chdir=./terraform/ destroy

vault-pass:
	ansible-playbook -i ansible/inventory.yml ansible/playbook.yml --vault-password-file ansible/group_vars/webservers/vault_pass

prepare:
	ansible-galaxy install -r ansible/requirements.yml
encrypt:
	ansible-vault encrypt ansible/group_vars/webservers/vault.yml

decrypt:
	ansible-vault decrypt ansible/group_vars/webservers/vault.yml

edit:
	ansible-vault edit ansible/group_vars/webservers/vault.yml
ping:
	ansible all -i ansible/inventory.yml -m ping
setup:
	ansible-playbook ansible/playbook.yml -i ansible/inventory.yml -t setup
deploy:
	ansible-playbook ansible/playbook.yml -i ansible/inventory.yml -t deploy
