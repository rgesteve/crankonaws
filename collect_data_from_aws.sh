#!/usr/bin/env bash

OUTPUT_DIR="sep20_6_3"

mkdir -p $OUTPUT_DIR

#MachineType=$(terraform output -raw machine_type)
ControllerIP=$(terraform output -raw controller_ip)
echo "The controller's IP is $ControllerIP"
Target="ubuntu@$ControllerIP:/home/ubuntu"
OutDir="$OUTPUT_DIR/aws_${MachineType}"
echo "Trying to copy file from controller with target: ${Target}, to directory ${OutDir}"

mkdir $OutDir

#scp -r -i ./MyIdentity.pem "$Target/csv" "$OutDir/csv"
scp -r -i ./MyIdentity.pem "$Target/*.json" "$OutDir"
