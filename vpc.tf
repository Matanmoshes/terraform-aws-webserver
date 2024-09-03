resource "aws_vpc" "vpc" {
    cidr_block           = var.cidr_block
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags = {
        Name = "terraform-vpc"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id
}

data "aws_route_table" "main_route_table" {
    filter {
        name   = "association.main"
        values = ["true"]
    }
    filter {
        name   = "vpc-id"
        values = [aws_vpc.vpc.id]
    }
}

resource "aws_default_route_table" "internet_route" {
    default_route_table_id = data.aws_route_table.main_route_table.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "Terraform-RouteTable"
    }
}

data "aws_availability_zones" "azs" {
    state = "available"
}

resource "aws_subnet" "webserver_subnet" {
    count = 2
    vpc_id = aws_vpc.vpc.id
    cidr_block = element(var.subnet_cidrs, count.index)
    availability_zone = element(data.aws_availability_zones.azs.names, count.index)
    tags = {
        Name = "public-subnet-${count.index}"
    }
}

resource "aws_route_table_association" "public_rt_assoc" {
    count = 2
    subnet_id = element(aws_subnet.webserver_subnet[*].id, count.index)
    route_table_id = aws_default_route_table.internet_route.id
}