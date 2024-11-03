provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}


# VPC
resource "aws_vpc" "abz_homework_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "abz-homework-vpc"
  }
}

# Public Subnets
resource "aws_subnet" "abz_homework_public_subnet_1" {
  vpc_id            = aws_vpc.abz_homework_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "abz-homework-public-subnet-1"
  }
}

resource "aws_subnet" "abz_homework_public_subnet_2" {
  vpc_id            = aws_vpc.abz_homework_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "abz-homework-public-subnet-2"
  }
}

# Private Subnets
resource "aws_subnet" "abz_homework_private_subnet_1" {
  vpc_id            = aws_vpc.abz_homework_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "abz-homework-private-subnet-1"
  }
}

resource "aws_subnet" "abz_homework_private_subnet_2" {
  vpc_id            = aws_vpc.abz_homework_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "abz-homework-private-subnet-2"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "abz_homework_igw" {
  vpc_id = aws_vpc.abz_homework_vpc.id
  tags = {
    Name = "abz-homework-igw"
  }
}

# Route Table for public subnets
resource "aws_route_table" "abz_homework_public_rt" {
  vpc_id = aws_vpc.abz_homework_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.abz_homework_igw.id
  }
  tags = {
    Name = "abz-homework-public-rt"
  }
}

# Route Table Association
resource "aws_route_table_association" "public_subnet_1_rt_association" {
  subnet_id      = aws_subnet.abz_homework_public_subnet_1.id
  route_table_id = aws_route_table.abz_homework_public_rt.id
}

resource "aws_route_table_association" "public_subnet_2_rt_association" {
  subnet_id      = aws_subnet.abz_homework_public_subnet_2.id
  route_table_id = aws_route_table.abz_homework_public_rt.id
}

# Security Group for EC2
resource "aws_security_group" "abz_homework_ec2_sg" {
  vpc_id = aws_vpc.abz_homework_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # SSH access (consider limiting to your IP)
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # HTTP access
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # HTTPS access
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "abz-homework-ec2-sg"
  }
}

# Security Group for RDS
resource "aws_security_group" "abz_homework_rds_sg" {
  vpc_id = aws_vpc.abz_homework_vpc.id
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.abz_homework_ec2_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "abz-homework-rds-sg"
  }
}

# RDS Instance
resource "aws_db_instance" "abz_homework_rds" {
  allocated_storage    = 20
  engine               = "mysql"
  identifier           = "abz-homework-rds"
  instance_class       = "db.t4g.micro"
  db_name	       = "abzwordpress"
  username             = "abzwordpress"
  password             = var.db_password
  vpc_security_group_ids = [aws_security_group.abz_homework_rds_sg.id]
  skip_final_snapshot  = true
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.abz_homework_db_subnet_group.name
  tags = {
    Name = "abz-homework-rds"
  }
}

resource "aws_db_subnet_group" "abz_homework_db_subnet_group" {
  name       = "abz-homework-db-subnet-group"
  subnet_ids = [
    aws_subnet.abz_homework_private_subnet_1.id,
    aws_subnet.abz_homework_private_subnet_2.id
  ]
  tags = {
    Name = "abz-homework-db-subnet-group"
  }
}

# Search AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


# EC2 Instance
resource "aws_instance" "abz_homework_ec2" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.abz_homework_public_subnet_1.id
  vpc_security_group_ids = [aws_security_group.abz_homework_ec2_sg.id]
  iam_instance_profile = aws_iam_instance_profile.abz_homework_ssm_profile.name
  tags = {
    Name = "abz-homework-ec2"
  }
}

# Security Group for ElastiCache Redis
resource "aws_security_group" "abz_homework_redis_sg" {
  vpc_id = aws_vpc.abz_homework_vpc.id
  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    security_groups = [aws_security_group.abz_homework_ec2_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "abz-homework-redis-sg"
  }
}

# Subnet Group for ElastiCache Redis
resource "aws_elasticache_subnet_group" "abz_homework_redis_subnet_group" {
  name       = "abz-homework-redis-subnet-group"
  subnet_ids = [
    aws_subnet.abz_homework_private_subnet_1.id,
    aws_subnet.abz_homework_private_subnet_2.id
  ]
  tags = {
    Name = "abz-homework-redis-subnet-group"
  }
}

# ElastiCache Redis Cluster
resource "aws_elasticache_cluster" "abz_homework_redis" {
  cluster_id           = "abz-homework-redis-cluster"
  engine               = "redis"
  node_type            = "cache.t2.micro" # Free Tier
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  subnet_group_name    = aws_elasticache_subnet_group.abz_homework_redis_subnet_group.name
  security_group_ids   = [aws_security_group.abz_homework_redis_sg.id]
  tags = {
    Name = "abz-homework-redis"
  }
}


#IAM Role for SSM
resource "aws_iam_role" "abz_homework_ssm_role" {
  name = "abz-homework-ssm-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "abz_homework_ssm_policy_attachment" {
  role       = aws_iam_role.abz_homework_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "abz_homework_ssm_profile" {
  name = "abz-homework-ssm-profile"
  role = aws_iam_role.abz_homework_ssm_role.name
}
