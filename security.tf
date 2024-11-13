# Security Group for ALB
resource "aws_security_group" "abz_alb_sg" {
  vpc_id = aws_vpc.abz_vpc.id
  name   = "abz-alb-sg"
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
    Name = "abz-alb-sg"
  }
}

# Security Group for EC2
resource "aws_security_group" "abz_ec2_sg" {
  name   = "abz-ec2-sg"
  vpc_id = aws_vpc.abz_vpc.id
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
    Name = "abz-ec2-sg"
  }
}

# Security Group for RDS
resource "aws_security_group" "abz_rds_sg" {
  name   = "abz-rds-sg"
  vpc_id = aws_vpc.abz_vpc.id
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.abz_ec2_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "abz-rds-sg"
  }
}

# Security Group for ElastiCache Redis
resource "aws_security_group" "abz_redis_sg" {
  name   = "abz-redis-sg"
  vpc_id = aws_vpc.abz_vpc.id
  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.abz_ec2_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "abz-redis-sg"
  }
}
