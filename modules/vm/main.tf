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
    instance_type = var.instance_type
    subnet_id = var.subnet_id
    security_groups = [var.sg_id]
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
}