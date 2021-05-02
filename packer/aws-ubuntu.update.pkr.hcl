packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_subnet_id" {
  type = string
}
variable "aws_region" {
  type = string
}
variable "source_ami" {
  type = string
}
variable "domain" {
  type = string
}
variable "db_table" {
  type = string
}
variable "port" {
  type = number
}

source "amazon-ebs" "url-shortener" {
  subnet_id                   = var.aws_subnet_id
  region                      = var.aws_region
  source_ami                  = var.source_ami
  associate_public_ip_address = true
  ami_name                    = "url_shorter_ubuntu_{{timestamp}}"
  instance_type               = "t2.micro"
  ssh_username                = "ubuntu"
}

build {
  sources = [
    "source.amazon-ebs.url-shortener"
  ]
  provisioner "file" {
    destination = "./nginx.conf.tpl"
    source      = "files/nginx.conf.tpl"
  }
  provisioner "file" {
    destination = "./shortener.service.tpl"
    source      = "files/shortener.service.tpl"
  }
  provisioner "file" {
    destination = "./src"
    source      = "../Q3"
  }
  provisioner "shell" {
    environment_vars = [
      "DOMAIN=${var.domain}",
      "PORT=${var.port}"
      "DB_TABLE=${var.db_table}",
      "REGION=${var.aws_region}"
    ]
    execute_command = "sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
    script = "files/update.sh"
  }
}