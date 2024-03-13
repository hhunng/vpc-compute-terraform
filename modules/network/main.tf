resource "aws_subnet" "create_subnet" {
    vpc_id = var.vpc_id
    tags = {
        Name = var.subnet_pool[0].tags.Name
    }
    cidr_block = var.subnet_pool[0].cidr_block
    availability_zone = var.subnet_pool[0].availability_zone
}

resource "aws_internet_gateway" "create-igw" {
    vpc_id = var.vpc_id
    tags = {
        Name = "${var.vpc_pool[0].tags.Name}-vpc-igw"
    }
}

resource "aws_route_table" "create_route_table" {
    vpc_id = var.vpc_id

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
    vpc_id = var.vpc_id

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