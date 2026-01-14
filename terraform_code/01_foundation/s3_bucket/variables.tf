# AWS provider variables
variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
} 

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
}

variable "region" {
  description = "AWS cloud region for the deployment"
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

variable "allowed_ips" {
  description = "Additional IPs/CIDRs allowed to access the bucket"
  type        = list(string)
}

variable "s3_vpc_endpoint_id" {
  description = "ID of the S3 VPC endpoint to allow in the bucket policy"
  type        = string
}


