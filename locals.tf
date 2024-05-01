locals {
  environment = {
    dev = {
      name_suffix   = "dev"
      instance_type = "t2.micro"
    },
    stage = {
      name_suffix   = "stage"
      instance_type = "t2.micro"
    },
    prod = {
      name_suffix   = "prod"
      instance_type = "t2.micro"
    }
  }
  env = local.environment[terraform.workspace]
}  