terraform {
  backend "s3" {
    bucket = "kyue1005-dev-tf-state"
    key    = "state/terraform.tfstate"
    region = "ap-southeast-1"
  }
}
