# AWS provider variables
variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
}

variable "asset_owner_name" {
  description = "Owner of the asset or resource in the cloud"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "s3_vpc_endpoint_id" {
  description = "ID of the S3 VPC endpoint to allow in the bucket policy"
  type        = string
}

variable "trusted_ips" {
  description = "List of trusted IP addresses for external access"
  type        = list(string)
}

