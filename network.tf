# VPC
resource "aws_vpc" "abz_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "abz-vpc"
  }
}

# Data source to fetch all availability zones dynamically
data "aws_availability_zones" "available" {
  state = "available"
}

# Dynamic Public Subnets
resource "aws_subnet" "abz_public_subnets" {
  for_each                = { for i, cidr in var.public_subnet_cidrs : i => cidr }
  vpc_id                  = aws_vpc.abz_vpc.id
  cidr_block              = each.value
  availability_zone       = element(data.aws_availability_zones.available.names, each.key % length(data.aws_availability_zones.available.names))
  map_public_ip_on_launch = true

  tags = {
    Name = "abz-public-subnet-${each.key + 1}"
  }
}

# Dynamic Private Subnets
resource "aws_subnet" "abz_private_subnets" {
  for_each                = { for i, cidr in var.private_subnet_cidrs : i => cidr }
  vpc_id                  = aws_vpc.abz_vpc.id
  cidr_block              = each.value
  availability_zone       = element(data.aws_availability_zones.available.names, each.key % length(data.aws_availability_zones.available.names))
  map_public_ip_on_launch = false

  tags = {
    Name = "abz-private-subnet-${each.key + 1}"
  }
}


# Internet Gateway
resource "aws_internet_gateway" "abz_igw" {
  vpc_id = aws_vpc.abz_vpc.id
  tags = {
    Name = "abz-igw"
  }
}

# Route Table for public subnets
resource "aws_route_table" "abz_public_rt" {
  vpc_id = aws_vpc.abz_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.abz_igw.id
  }
  tags = {
    Name = "abz-public-rt"
  }
}

# Create ElasticIP for NAT gateway
resource "aws_eip" "abz_nat_eip" {
  domain = "vpc"
  tags = {
    Name = "abz-elastic-for-NAT"
  }
}

resource "aws_nat_gateway" "abz_nat_gw" {
  allocation_id = aws_eip.abz_nat_eip.id
  subnet_id     = aws_subnet.abz_public_subnets[0].id
  tags = {
    Name = "abz-nat-gw"
  }
}

# Private Route Table for private subnets with NAT Gateway
resource "aws_route_table" "abz_private_rt" {
  vpc_id = aws_vpc.abz_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.abz_nat_gw.id
  }
  tags = {
    Name = "abz-private-rt"
  }
}

# Public Route Table Associations
resource "aws_route_table_association" "public_rt_association" {
  for_each       = aws_subnet.abz_public_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.abz_public_rt.id
}

# Private Route Table Associations
resource "aws_route_table_association" "private_rt_association" {
  for_each       = aws_subnet.abz_private_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.abz_private_rt.id
}
