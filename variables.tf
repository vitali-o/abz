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

# RDS settings:

variable "db_name" {
  description = "The name for the RDS database"
  type        = string
  sensitive   = true
  default     = "abzwpdatabase"
}

variable "db_user" {
  description = "The name for the RDS master user"
  type        = string
  sensitive   = true
  default     = "abzwpuser"
}

variable "db_password" {
  description = "The password for the RDS master user"
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
