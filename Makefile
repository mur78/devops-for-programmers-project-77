init:
	terraform -chdir=./terraform/ init -backend-config=secrets.backend.tfvars

reconfigure:
	terraform -chdir=./terraform/ init -migrate-state -backend-config=secrets.backend.tfvars

apply:
	terraform -chdir=./terraform/ apply

destroy:
	terraform -chdir=./terraform/ destroy


prepare:
	ansible-galaxy install -r requirements.yml
encrypt:
	ansible-vault encrypt group_vars/webservers/vault.yml

vault-pass:
	ansible-playbook -i inventory.yml playbook.yml --vault-password-file group_vars/webservers/vault_pass

decrypt:
	ansible-vault decrypt group_vars/webservers/vault.yml

edit:
	ansible-vault edit group_vars/webservers/vault.yml
ping:
	ansible all -i inventory.yml -m ping
setup:
	ansible-playbook playbook.yml -i inventory.yml -t setup
deploy:
	ansible-playbook playbook.yml -i inventory.yml -t deploy
