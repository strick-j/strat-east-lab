# ===========================
# AWS Variables
# ===========================
variable "aws_region" {
  description = "AWS cloud region for the deployment"
  type        = string
}
variable "statefile_bucket_name" {
  description = "The name of the S3 bucket where the remote state file is stored."
  type        = string
}

# ===========================
# Resource Tagging Variables 
# ===========================
variable "alias" {
  description = "Short alias identifier for naming resources (e.g., 'Papaya', 'Mango')"
  type        = string
} 
variable "asset_owner_name" {
  description = "Name of the asset owner for tagging resources"
  type        = string
}
variable "iScheduler" {
  description = "Instance scheduler tag for automated shutdown"
  type        = string
}

# ===========================
# RDS PostgreSQL Variables
# ===========================
variable "instance_class" {
  description = "The instance type of the RDS PostgreSQL instance"
  type        = string
} 
variable "db_name" {
  description = "The name of the initial database to create"
  type        = string
}
variable "username" {
  description = "The master username for the RDS PostgreSQL instance"
  type        = string
}
variable "backup_retention" {
  description = "The days to retain backups for the RDS PostgreSQL instance"
  type        = number
  default     = 7
}
variable "publicly_accessible" {
  description = "Specifies whether the RDS PostgreSQL instance is publicly accessible"
  type        = bool
  default     = false
} 
variable "deletion_protection" {
  description = "Specifies whether deletion protection is enabled for the RDS PostgreSQL instance"
  type        = bool
  default     = false
}
variable "allocated_storage" {
  description = "The allocated storage in gigabytes for the RDS PostgreSQL instance"
  type        = number
  default     = 20
}
