#! /bin/bash

echo "Build base image"
(cd packer && packer init aws-ubuntu.base.pkr.hcl)
(cd packer && packer build -var-file="variables.pkvars.hcl" aws-ubuntu.base.pkr.hcl)
