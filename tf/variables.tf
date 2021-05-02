variable "dev_ssh_ami" {
  description = "AMI for ssh machine"
  default     = "ami-048f6ed62451373d9"
}

variable "dev_ssh_key" {
  description = "Public Key for ssh machine"
}

variable "dynamodb_table_name" {
  description = "Table name for DynamoDB"
}

# variable "q3_ami" {
#   description = "AMI built from q3"
# }