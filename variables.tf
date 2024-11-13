variable "aws_access_key" {
  description = "AWS Access key"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
  type        = string
  sensitive   = true
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.2.0/24", "10.0.4.0/24"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.3.0/24"]
}

variable "alb_ingress_ports" {
  description = "list of allowed ports for ALB"
  type        = list(number)
  default     = [80, 443]
}

variable "ec2_ingress_ports" {
  description = "list of allowed ports for EC2"
  type        = list(number)
  default     = [80, 443]
}

variable "instance_count" {
  description = "EC2 instances count"
  type        = number
  default     = 1
}

# RDS settings:

variable "db_name" {
  description = "Name for the RDS database"
  type        = string
  sensitive   = true
  default     = "abzwpdatabase"
}

variable "db_user" {
  description = "Name for the RDS master user"
  type        = string
  sensitive   = true
  default     = "abzwpuser"
}

variable "db_password" {
  description = "Password for the RDS master user"
  type        = string
  sensitive   = true
}

# WordPress settings:

variable "wp_admin_password" {
  description = "The password for the WP admin"
  type        = string
  sensitive   = true
}

variable "wp_admin_email" {
  description = "The email for the WP admin"
  type        = string
  sensitive   = true
}

variable "wp_site_url" {
  description = "URL for WordPress installation"
  type        = string
  default     = "wp.abzhomework.work.gd"
}
