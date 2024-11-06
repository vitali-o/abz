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

variable "db_password" {
  description = "The password for the RDS master user"
  type        = string
  sensitive   = true
}

variable "wp_admin_password" {
  description = "The password for the WP abzwordpress user"
  type        = string
  sensitive   = true
}
