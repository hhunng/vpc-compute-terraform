provider "aws" {}

variable "vpc_pool" {
    description = "create vpc intances"
}
variable "subnet_pool" {
    description = "create subnet instances"
}
resource "aws_vpc" "vpc-demo" {
    cidr_block = var.vpc_pool[0].cidr_block
    tags = {
        Name = var.vpc_pool[0].tags.Name
        Env = var.vpc_pool[0].tags.Env
    }
}

resource "aws_subnet" "subnets-demo" {
    vpc_id = aws_vpc.vpc-demo.id
    tags = {
        Name = var.subnet_pool[0].tags.Name
    }
    cidr_block = var.subnet_pool[0].cidr_block
    availability_zone = var.subnet_pool[0].availability_zone
}

resource "aws_subnet" "subnets1-demo" {
    vpc_id = aws_vpc.vpc-demo.id
    tags = {
        Name = var.subnet_pool[1].tags.Name
    }
    cidr_block = var.subnet_pool[1].cidr_block
    availability_zone = var.subnet_pool[1].availability_zone
}
