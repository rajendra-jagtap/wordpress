terraform {
  backend "s3" {
    bucket = "rajendra-terraform"
    #key    = "env/${terraform.workspace}/wordpress.tfstate"
    key     = "wordpress.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}