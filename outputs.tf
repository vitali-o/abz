output "vpc_id" {
  value = aws_vpc.abz_homework_vpc.id
}

output "rds_endpoint" {
  value = aws_db_instance.abz_homework_rds.endpoint
}

output "redis_endpoint" {
  value = aws_elasticache_cluster.abz_homework_redis.cache_nodes[0].address
}

output "redis_port" {
  value = aws_elasticache_cluster.abz_homework_redis.cache_nodes[0].port
}

output "alb_dns" {
  value       = aws_lb.abz_homework_alb.dns_name
  description = "Public DNS name of the ALB"
}

output "ec2_instance_id" {
  value = aws_instance.abz_homework_ec2.id
}