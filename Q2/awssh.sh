#! /bin/bash

usage() {
    echo "Usage:"
    echo "awssh.sh INSTANCE_NAME_TAG"
    echo "Description:"
    echo "INSTANCE_NAME_TAG, name tag of the ec2 instance"
    exit -1
}

INSTANCE_NAME_TAG="${1}"

if [ -z ${INSTANCE_NAME_TAG} ]; then
  usage
fi

IP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${INSTANCE_NAME_TAG}" --query "Reservations[].Instances[].PublicIpAddress" | jq -r '.[]' | head -n 1)

if [ -z "${IP}" ]; then
  echo "Host not found"
  exit -1
fi

exec ssh ec2-user@${IP}