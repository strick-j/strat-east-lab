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
variable "instance_type" {
  description = "EC2 instance type for Windows target"
  type        = string
}
