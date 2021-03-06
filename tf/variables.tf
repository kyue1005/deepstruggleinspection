variable "aws_account_id" {
  description = "AMI for ssh machine"
}

variable "dynamodb_table_name" {
  description = "Table name for DynamoDB"
}

variable "subnet_a_cidr" {
  description = "Subnet cidr for zone a"
}

variable "subnet_b_cidr" {
  description = "Subnet cidr for zone b"
}

variable "subnet_c_cidr" {
  description = "Subnet cidr for zone c"
}

variable "dev_ssh_key" {
  description = "Public Key for ssh machine"
}

variable "dev_ssh_cidr" {
  description = "CIDR for accessing machine through ssh"
}

variable "asg_min" {
  description = "Minimum replica for autoscaling group"
}

variable "asg_max" {
  description = "Maximum replica for autoscaling group"
}