#! /bin/bash

echo "Build base image"
(cd packer && packer init aws-ubuntu.base.pkr.hcl)
(cd packer && packer build -var-file="variables.pkvars.hcl" aws-ubuntu.base.pkr.hcl)

echo  "Deploy terraform stack"
(cd tf && terraform init)
(cd tf && terraform plan -out tfplan -var-file="terraform.tfvars")
(cd tf && terraform apply "tfplan")

echo "ALB dns name:"
(cd tf && terraform state show 'module.url_shortener_alb.aws_lb.this[0]' | grep dns_name)