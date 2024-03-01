provider "aws" {}

variable "vpc_pool" {
    description = "create vpc intances"
}
variable "subnet_pool" {
    description = "create subnet instances"
}

variable "default_igw" {
    description = "create default igw"
}

variable "instance_type" {
    description = "instance types option"
}

variable "public_key_location" {
    description = "location of the key pair"
}

variable "private_key_location" {
    description = "location of the key pair"
}
variable "vpc_default_id" {}

resource "aws_vpc" "create_vpc" {
    cidr_block = var.vpc_pool[0].cidr_block
    tags = {
        Name = var.vpc_pool[0].tags.Name
        Env = "${var.vpc_pool[0].tags.Env}-vpc"
    }
}

resource "aws_subnet" "create_subnet" {
    vpc_id = aws_vpc.create_vpc.id
    tags = {
        Name = var.subnet_pool[0].tags.Name
    }
    cidr_block = var.subnet_pool[0].cidr_block
    availability_zone = var.subnet_pool[0].availability_zone
}

resource "aws_internet_gateway" "create-igw" {
    vpc_id = aws_vpc.create_vpc.id
    tags = {
        Name = "${var.vpc_pool[0].tags.Name}-vpc-igw"
    }
}

resource "aws_route_table" "create_route_table" {
    vpc_id = aws_vpc.create_vpc.id

    route {
        cidr_block = var.default_igw
        gateway_id = aws_internet_gateway.create-igw.id
    }
    
    tags =  {
        Name = "${var.vpc_pool[0].tags.Name}-vpc-rtb"
    }
}

resource "aws_route_table_association" "associate_subnet" {
    route_table_id = aws_route_table.create_route_table.id
    subnet_id = aws_subnet.create_subnet.id
}

resource "aws_security_group" "allow_HTTP" {
    name = "main-sg"
    description = "Allow HTTP inbound traffic and all outbound traffic"
    vpc_id = aws_vpc.create_vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.default_igw]
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = [var.default_igw]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = [var.default_igw]
        prefix_list_ids = []
    }
}

data "aws_ami" "install_ec2" {
    most_recent = true
    owners = ["amazon"]
    filter {
      name = "name"
      values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
    }
    filter {
      name = "virtualization-type"
      values = ["hvm"]
    }
}

resource "aws_key_pair" "create_key_pair" {
  key_name   = "ssh-key"
  public_key = file(var.public_key_location)

}

resource "aws_instance" "create_amazon_linux" {
    ami = data.aws_ami.install_ec2.id
    instance_type = var.instance_type.t2_micro
    subnet_id = aws_subnet.create_subnet.id
    security_groups = [aws_security_group.allow_HTTP.id]
    associate_public_ip_address = true
    key_name = aws_key_pair.create_key_pair.key_name
    tags =  {
        Name = "${var.vpc_pool[0].tags.Name}-server"
    }
    #user_data = file("user_data.sh")
    connection {
        type = "ssh"
        host = self.public_ip
        user = "ec2-user"
        private_key = file(var.private_key_location)
    }

    provisioner "file" {
      source = "user_data.sh"
      destination = "/home/ec2-user/entry_data.sh"
    }

    provisioner "remote-exec" {
      inline = [
        "export ENV=dev",
        "mkdir newdir"
        #or just 
        #script = file("user_data.sh")
      ]
    }

    provisioner "local-exec" {
      command = "echo ${self.public_ip} > output.txt"
    }
}
output "IPv4_Public" {
  value = aws_instance.create_amazon_linux.public_ip
}
