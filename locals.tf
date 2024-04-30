locals {
  instance_types = {
    dev   = "t2.micro"
    stage = "t2.micro"
    prod  = "t2.micro"
  }

  subnet_ids = {
    dev   = var.subnets[0]
    stage = var.subnets[1]
    prod  = var.subnets[2]
  }
}
