# deepstruggleinspection

## Pre-requisite

* aws cli
* packer
* terraform
* jq
* whois

Please setup your aws cli with `aws configure` and make sure you have full access right

Your AWS account should have a default vpc and subnet to start work with

## Q1

* req_cnt.sh - count requests in access log

Usage:

```shell
req_cnt.sh -f [file.gz]
```

* top_country.sh - find top country in the access log

Usage:

```shell
top_country.sh -f [file.gz]

```

* top10_host.sh - find top 10 host with in period with access log

Usage:

```shell
top10_host.sh -f [file.gz]
```

## Q2

A script to ssh to ec2 node by Name tag

Usage:

```shell
awssh.sh [ec2 name tag]
```

## Q3

This is an url-shortener application in golang

### Config

create `variables.pkvars.hcl` under `packer` folder with following attributes

```hcl
aws_subnet_id       = "subnet-xxxxxx"
aws_region          = "us-east-1"
aws_account_id      = "xxxx"
base_ami            = "ami-042e8287309f5df03" # ubuntu 20.04 LTS
port                = "8080"
domain              = "example.com"
dynamodb_table_name = "short-url-map-xxxx"
```

create `terraform.tfvars` under `tf` folder with following attributes

```hcl
aws_account_id      = ""
dynamodb_table_name = "short-url-map-xxxx"
dev_ssh_key         = "" # ssh pub key
```

### Initialize

```shell
./init.sh
```

This script is to build base application image

### Deploy

```shell
./deploy.sh
```

This script is to build versioned application image using the base image and deploy/update the application using terraform

After the script complete, the asg would rolling update the instance with new versioned ami

** scripts is tested in MacOS shell only **