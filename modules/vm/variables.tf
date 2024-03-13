variable "public_key_location" {
    description = "location of the key pair"
}

variable "private_key_location" {
    description = "location of the key pair"
}

variable "subnet_id" {
    description = "id of the subnet"
}

variable "sg_id" {
    description = "id of the security group"
}

variable "vpc_pool" {
    description = "vpc of the network"
}

variable "instance_type" {
    description = "declare instance type"
}