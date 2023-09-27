#!/usr/bin/env bash

arg=$1

if [ -z "$arg" ]; then
  instance_size=12     # fixing at 48 vCPU count
else
  instance_size=$arg
fi

# terraform validate
PlanName="awsCrankPS.plan"

terraform plan -out $PlanName -var instance_size=${instance_size}
terraform apply $PlanName
ControllerIP=$(terraform output -raw controller_ip)
#SndBoxIP=$(terraform output -raw sndbox_ip)
echo "The controller's IP is $ControllerIP"
Target="ubuntu@$ControllerIP:/home/ubuntu"

ansible -m ping -i generated_inventory.yaml --private-key ./MyIdentity.pem all
ansible-playbook -i generated_inventory.yaml --private-key ./MyIdentity.pem install_collectd_playbook.yaml
ansible-playbook -i generated_inventory.yaml --private-key ./MyIdentity.pem config_collectd_playbook.yaml
#ansible-playbook -i generated_inventory.yaml --private-key ./MyIdentity.pem setup_crank_playbook.yaml

echo "Trying to copy file to controller with target: $Target"
scp -i ./MyIdentity.pem -o StrictHostKeyChecking=no ./MyIdentity.pem $Target
