#!/bin/bash

private_key_path="./myKey.pem"
instance_address=$(cat ./instance_ip.txt)

ssh -i "$private_key_path" "ec2-user@$instance_address" "mkdir -p tic-tac-toe"
scp -i "$private_key_path" ../docker-compose.yml "ec2-user@$instance_address":/home/ec2-user/tic-tac-toe
ssh -i "$private_key_path" "ec2-user@$instance_address" "docker-compose -f /home/ec2-user/tic-tac-toe/docker-compose.yml up -d"
