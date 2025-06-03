init:
	terraform -chdir=./terraform/ init -backend-config=secrets.backend.tfvars

reconfigure:
	terraform -chdir=./terraform/ init -migrate-state -backend-config=secrets.backend.tfvars

apply:
	terraform -chdir=./terraform/ apply

destroy:
	terraform -chdir=./terraform/ destroy

