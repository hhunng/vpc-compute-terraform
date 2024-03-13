provider "aws" {}

resource "aws_vpc" "create_vpc" {
    cidr_block = var.vpc_pool[0].cidr_block
    tags = {
        Name = var.vpc_pool[0].tags.Name
        Env = "${var.vpc_pool[0].tags.Env}-vpc"
    }
}

module "terraform-vpc" {
  source = "./modules/network"
  vpc_id = aws_vpc.create_vpc.id
  subnet_pool = var.subnet_pool
  vpc_pool = var.vpc_pool
  default_igw = var.default_igw
}

module "terraform-vm" {
  source = "./modules/vm"
  public_key_location = var.public_key_location
  private_key_location = var.private_key_location
  subnet_id = module.terraform-vpc.subnet_id.id
  sg_id = module.terraform-vpc.security-group-id.id
  vpc_pool = var.vpc_pool
  instance_type = var.instance_type.t2_micro
}