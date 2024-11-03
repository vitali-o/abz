output "vpc_id" {
  value = aws_vpc.abz_homework_vpc.id
}

output "rds_endpoint" {
  value = aws_db_instance.abz_homework_rds.endpoint
}

output "ec2_instance_id" {
  value = aws_instance.abz_homework_ec2.id
}

output "ec2_public_ip" {
  value = aws_instance.abz_homework_ec2.public_ip
  description = "Public IP address of the EC2 instance"
}

output "ec2_public_dns" {
  value = aws_instance.abz_homework_ec2.public_dns
  description = "Public DNS of the EC2 instance"
}

output "redis_endpoint" {
  value = aws_elasticache_cluster.abz_homework_redis.cache_nodes[0].address
}

output "redis_port" {
  value = aws_elasticache_cluster.abz_homework_redis.cache_nodes[0].port
}

#output "private_key_pem" {
#  value     = tls_private_key.abz_homework_key.private_key_pem
#  sensitive = true
#}
