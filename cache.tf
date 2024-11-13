# Subnet Group for ElastiCache Redis
resource "aws_elasticache_subnet_group" "abz_redis_subnet_group" {
  name       = "abz-redis-subnet-group"
  subnet_ids = [for subnet in aws_subnet.abz_private_subnets : subnet.id]
  tags = {
    Name = "abz-redis-subnet-group"
  }
}

# ElastiCache Redis Cluster
resource "aws_elasticache_cluster" "abz_redis" {
  cluster_id           = "abz-redis-cluster"
  engine               = "redis"
  node_type            = "cache.t2.micro" # Free Tier
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  subnet_group_name    = aws_elasticache_subnet_group.abz_redis_subnet_group.name
  security_group_ids   = [aws_security_group.abz_redis_sg.id]
  tags = {
    Name = "abz-redis"
  }
}
