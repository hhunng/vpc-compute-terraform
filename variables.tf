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