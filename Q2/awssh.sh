#! /bin/bash

NAME="${1}"

INSTANCE=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${NAME}")

IP=$(echo ${INSTANCE} | jq -r '.Reservations | .[] | .Instances | .[] | .PublicIpAddress' | head -n 1)

exec ssh ec2-user@${IP}