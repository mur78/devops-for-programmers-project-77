### Hexlet tests and linter status:
[![Actions Status](https://github.com/mur78/devops-for-programmers-project-77/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/mur78/devops-for-programmers-project-77/actions)

Project
devops-for-programmers-project-77

Requirements: Ansible Python Terraform



File secrets.auto.tfvars


yc_token - a token to access.
yc_folder - identifier of the directory
yc_user - the username
db_name - database name.
db_user - database user name.
db_password - database password.




Makefile:


make init - Terraform initialization

make apply - Create Infrastructure

make destroy - Delete Infrastructure


