# VPC
resource "aws_vpc" "abz_homework_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "abz-homework-vpc"
  }
}

# Data source to fetch all availability zones dynamically
data "aws_availability_zones" "available" {
  state = "available"
}

# Dynamic Public Subnets
resource "aws_subnet" "abz_homework_public_subnets" {
  for_each                = { for i, cidr in var.public_subnet_cidrs : i => cidr }
  vpc_id                  = aws_vpc.abz_homework_vpc.id
  cidr_block              = each.value
  availability_zone       = element(data.aws_availability_zones.available.names, each.key % length(data.aws_availability_zones.available.names))
  map_public_ip_on_launch = true

  tags = {
    Name = "abz-homework-public-subnet-${each.key + 1}"
  }
}

# Dynamic Private Subnets
resource "aws_subnet" "abz_homework_private_subnets" {
  for_each                = { for i, cidr in var.private_subnet_cidrs : i => cidr }
  vpc_id                  = aws_vpc.abz_homework_vpc.id
  cidr_block              = each.value
  availability_zone       = element(data.aws_availability_zones.available.names, each.key % length(data.aws_availability_zones.available.names))
  map_public_ip_on_launch = false

  tags = {
    Name = "abz-homework-private-subnet-${each.key + 1}"
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

# NAT Gateway for private subnet Internet access
resource "aws_eip" "abz_homework_nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "abz_homework_nat_gw" {
  allocation_id = aws_eip.abz_homework_nat_eip.id
  subnet_id     = aws_subnet.abz_homework_public_subnets[0].id
  tags = {
    Name = "abz-homework-nat-gw"
  }
}

# Private Route Table for private subnets with NAT Gateway
resource "aws_route_table" "abz_homework_private_rt" {
  vpc_id = aws_vpc.abz_homework_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.abz_homework_nat_gw.id
  }
  tags = {
    Name = "abz-homework-private-rt"
  }
}

# Public Route Table Associations
resource "aws_route_table_association" "public_rt_association" {
  for_each       = aws_subnet.abz_homework_public_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.abz_homework_public_rt.id
}

# Private Route Table Associations
resource "aws_route_table_association" "private_rt_association" {
  for_each       = aws_subnet.abz_homework_private_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.abz_homework_private_rt.id
}

# Application Load Balancer
resource "aws_lb" "abz_homework_alb" {
  name               = "abz-homework-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.abz_homework_alb_sg.id]
  subnets            = [for subnet in aws_subnet.abz_homework_public_subnets : subnet.id]
  tags = {
    Name = "abz-homework-alb"
  }
}

# Security Group for ALB
resource "aws_security_group" "abz_homework_alb_sg" {
  vpc_id = aws_vpc.abz_homework_vpc.id
  dynamic "ingress" {
    for_each = var.alb_ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "abz-homework-alb-sg"
  }
}

# Target Group for ALB
resource "aws_lb_target_group" "abz_homework_tg" {
  name     = "abz-homework-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.abz_homework_vpc.id
  health_check {
    path = "/"
    port = "traffic-port"
  }
  tags = {
    Name = "abz-homework-tg"
  }
}

# ALB Listener
resource "aws_lb_listener" "abz_homework_listener" {
  load_balancer_arn = aws_lb.abz_homework_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.abz_homework_tg.arn
  }
}

# Security Group for EC2
resource "aws_security_group" "abz_homework_ec2_sg" {
  vpc_id = aws_vpc.abz_homework_vpc.id
  dynamic "ingress" {
    for_each = var.ec2_ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
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
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
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
  allocated_storage      = 20
  engine                 = "mysql"
  identifier             = "abz-homework-rds"
  instance_class         = "db.t4g.micro"
  db_name                = var.db_name
  username               = var.db_user
  password               = var.db_password
  vpc_security_group_ids = [aws_security_group.abz_homework_rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.abz_homework_db_subnet_group.name
  tags = {
    Name = "abz-homework-rds"
  }
}

resource "aws_db_subnet_group" "abz_homework_db_subnet_group" {
  name       = "abz-homework-db-subnet-group"
  subnet_ids = [for subnet in aws_subnet.abz_homework_public_subnets : subnet.id]
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

# Get WordPress salt and keys
data "http" "auth_keys_and_salts" {
  url = "https://api.wordpress.org/secret-key/1.1/salt/"
}

# Create wp-config.php from template
data "template_file" "wp_config" {
  template = file("./wp-config.php.tpl")
  vars = {
    db_name             = var.db_name
    db_user             = var.db_user
    db_password         = var.db_password
    db_host             = aws_db_instance.abz_homework_rds.endpoint
    site_url            = var.wp_site_url
    admin_email         = var.wp_admin_email
    admin_password      = var.wp_admin_password
    redis_host          = aws_elasticache_cluster.abz_homework_redis.cache_nodes[0].address
    redis_port          = aws_elasticache_cluster.abz_homework_redis.cache_nodes[0].port
    auth_keys_and_salts = data.http.auth_keys_and_salts.response_body
  }
}

# Create user_data
data "template_file" "wp_setup" {
  template = file("./wordpress_setup.sh.tpl")
  vars = {
    db_name           = var.db_name
    db_user           = var.db_user
    db_password       = var.db_password
    db_host           = aws_db_instance.abz_homework_rds.endpoint
    site_url          = var.wp_site_url
    admin_email       = var.wp_admin_email
    admin_password    = var.wp_admin_password
    redis_host        = aws_elasticache_cluster.abz_homework_redis.cache_nodes[0].address
    redis_port        = aws_elasticache_cluster.abz_homework_redis.cache_nodes[0].port
    wp_config_content = data.template_file.wp_config.rendered
  }
}

# Dynamically create EC2 instances and place each in a different private subnet
resource "aws_instance" "abz_homework_ec2" {
  count                  = var.instance_count
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.abz_homework_private_subnets[count.index % length(aws_subnet.abz_homework_private_subnets)].id
  vpc_security_group_ids = [aws_security_group.abz_homework_ec2_sg.id]
  user_data              = data.template_file.wp_setup.rendered

  tags = {
    Name = "abz-homework-ec2-${count.index + 1}"
  }
}

# Attach instances to ALB target group
resource "aws_lb_target_group_attachment" "abz_homework_ec2_tg_attachment" {
  for_each         = { for idx, instance in tolist(aws_instance.abz_homework_ec2) : idx => instance }
  target_group_arn = aws_lb_target_group.abz_homework_tg.arn
  target_id        = each.value.id
  port             = 80
}

# Security Group for ElastiCache Redis
resource "aws_security_group" "abz_homework_redis_sg" {
  vpc_id = aws_vpc.abz_homework_vpc.id
  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
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
  subnet_ids = [for subnet in aws_subnet.abz_homework_private_subnets : subnet.id]
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
