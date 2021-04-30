terraform {
  backend "s3" {
    bucket = "off-site-test-tf-state"
    key    = "state/terraform.tfstate"
    region = "us-east-1"
  }
}
