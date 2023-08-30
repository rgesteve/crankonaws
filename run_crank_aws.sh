#!/usr/bin/env bash
# terraform validate
PlanName="awsCrankPS.plan"
terraform plan -out $PlanName
terraform apply $PlanName
ControllerIP=$(terraform output -raw controller_ip)
#SndBoxIP=$(terraform output -raw sndbox_ip)
echo "The controller's IP is $ControllerIP"
Target="ubuntu@$ControllerIP:/home/ubuntu"
echo "Trying to copy file to controller with target: $Target"
#echo "The second box's IP is $SndBoxIP"

ansible -m ping -i generated_inventory.yaml --private-key ./MyIdentity.pem all
ansible-playbook -i generated_inventory.yaml --private-key ./MyIdentity.pem install_collectd_playbook.yaml
ansible-playbook -i generated_inventory.yaml --private-key ./MyIdentity.pem config_collectd_playbook.yaml
ansible-playbook -i generated_inventory.yaml --private-key ./MyIdentity.pem setup_crank_playbook.yaml

scp -i ./MyIdentity.pem -o StrictHostKeyChecking=no ./MyIdentity.pem $Target
