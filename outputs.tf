output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.abz_homework_vpc.id
}

output "rds_endpoint" {
  description = "RDS public DNS"
  value       = aws_db_instance.abz_homework_rds.endpoint
}

output "redis_endpoint" {
  description = "Redis ElastiCache public DNS"
  value       = aws_elasticache_cluster.abz_homework_redis.cache_nodes[0].address
}

output "redis_port" {
  description = "Redis ElastiCache port"
  value       = aws_elasticache_cluster.abz_homework_redis.cache_nodes[0].port
}

output "alb_dns" {
  description = "ALB public DNS"
  value       = aws_lb.abz_homework_alb.dns_name
}

output "ec2_instance_ids" {
  description = "EC2 instances IDs"
  value       = [for instance in aws_instance.abz_homework_ec2 : instance.id]
}

output "wp_auth_keys_and_salts" {
  description = "Salts and keys for WordPress installation"
  value       = data.http.auth_keys_and_salts.response_body
}
