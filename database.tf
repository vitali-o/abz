# RDS Instance
resource "aws_db_instance" "abz_rds" {
  allocated_storage      = 20
  engine                 = "mysql"
  identifier             = "abz-rds"
  instance_class         = "db.t4g.micro"
  db_name                = var.db_name
  username               = var.db_user
  password               = var.db_password
  vpc_security_group_ids = [aws_security_group.abz_rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.abz_db_subnet_group.name
  tags = {
    Name = "abz-rds"
  }
}

# RDS subnet group
resource "aws_db_subnet_group" "abz_db_subnet_group" {
  name       = "abz-db-subnet-group"
  subnet_ids = [for subnet in aws_subnet.abz_public_subnets : subnet.id]
  tags = {
    Name = "abz-db-subnet-group"
  }
}
