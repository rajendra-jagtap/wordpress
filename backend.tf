terraform {
  backend "s3" {
    bucket = "rajendra-terraform"
    key    = "${terraform.workspace}-wordpress.tfstate"
    region = "ap-south-1"
  }
}