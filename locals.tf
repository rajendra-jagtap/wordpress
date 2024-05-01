locals {
  environment = {
    dev = {
      name_suffix   = "dev"
      instance_type = "t4g.medium"
    },
    stage = {
      name_suffix   = "stage"
      instance_type = "t3.micro"
    },
    prod = {
      name_suffix   = "prod"
      instance_type = "t3.micro"
    }
  }
  env = local.environment[terraform.workspace]
}  