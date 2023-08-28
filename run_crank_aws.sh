#!/usr/bin/env bash
 terraform validate
PlanName="awsCrankPS.plan"
terraform plan -out $PlanName
terraform apply $PlanName
ControllerIP=$(terraform output -raw controller_ip)
SndBoxIP=$(terraform output -raw sndbox_ip)
echo "The controller's IP is $ControllerIP"
Target="ubuntu@$ControllerIP:/home/ubuntu"
echo "Trying to copy file to controller with target: $Target"
echo "The second box's IP is $SndBoxIP"
scp -i ./MyIdentity.pem -o StrictHostKeyChecking=no ./MyIdentity.pem $Target


