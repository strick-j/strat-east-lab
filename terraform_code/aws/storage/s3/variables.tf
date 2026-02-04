# ===========================
# AWS provider variables
# ===========================
variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
}

# ===========================
# Common Variables
# ===========================
variable "alias" {
  description = "Short alias identifier for naming resources (e.g., 'Papaya', 'Mango')"
  type        = string
}
variable "asset_owner_name" {
  description = "Name of the asset owner for tagging resources"
  type        = string
} 

# ===========================
# S3 Variables
# ===========================
variable "trusted_ips" {
  description = "Trusted public IPs"
  type        = list(string)
}
variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}
variable "s3_vpc_endpoint_id" {
  description = "ID of the S3 VPC endpoint to allow in the bucket policy"
  type        = string
}


