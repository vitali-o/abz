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
    db_host             = aws_db_instance.abz_rds.endpoint
    site_url            = var.wp_site_url
    admin_email         = var.wp_admin_email
    admin_password      = var.wp_admin_password
    redis_host          = aws_elasticache_cluster.abz_redis.cache_nodes[0].address
    redis_port          = aws_elasticache_cluster.abz_redis.cache_nodes[0].port
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
    db_host           = aws_db_instance.abz_rds.endpoint
    site_url          = var.wp_site_url
    admin_email       = var.wp_admin_email
    admin_password    = var.wp_admin_password
    redis_host        = aws_elasticache_cluster.abz_redis.cache_nodes[0].address
    redis_port        = aws_elasticache_cluster.abz_redis.cache_nodes[0].port
    wp_config_content = data.template_file.wp_config.rendered
  }
}

# Dynamically create EC2 instances and place each in a different private subnet
resource "aws_instance" "abz_ec2" {
  count                  = var.instance_count
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.abz_private_subnets[count.index % length(aws_subnet.abz_private_subnets)].id
  vpc_security_group_ids = [aws_security_group.abz_ec2_sg.id]
  user_data              = data.template_file.wp_setup.rendered

  tags = {
    Name = "abz-ec2-${count.index + 1}"
  }
}
