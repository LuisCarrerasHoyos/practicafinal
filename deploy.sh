#!/bin/bash
set -e

echo "[0/3] Inicializando Terraform..."
terraform -chdir=./TERRAFORM_LIMPIO init

echo "[1/3] Aplicando Terraform..."
terraform -chdir=./TERRAFORM_LIMPIO apply -auto-approve

echo "[2/3] Esperando a que las instancias estén disponibles..."
sleep 120

echo "[3/3] Ejecutando Ansible con inventario dinámico..."
cd ANSIBLE_CLEAN
ansible-playbook -i inventory_aws_ec2.yml site.yml


