# ===========================
# AWS Variables
# ===========================
variable "statefile_bucket_name" {
  description = "Name of the S3 bucket to read the remote state from"
  type        = string
}

variable "aws_region" {
  description = "AWS cloud region for the deployment"
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

# ===========================
# Generic Variables
# ===========================
variable "alias" {
  description = "Short alias identifier for naming resources (e.g., 'Papaya', 'Mango')"
  type        = string
}

variable "prefix" {
  description = "Prefix for naming resources (e.g., 'PAP', 'MNG')"
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
  description = "EC2 instance type for Ubuntu SIA connector"
  type        = string
}

variable "ubuntu_username" {
  description = "Default username for Ubuntu AMI"
  type        = string
}

# ===========================
# Conjur Variables
# ===========================
variable "conjur_appliance_url" {
  description = "URL of the Conjur appliance"
  type        = string
}

variable "conjur_account" {
  description = "Conjur account name"
  type        = string
  default     = "conjur"
}

variable "conjur_login" {
  description = "Conjur login name"
  type        = string
}

variable "conjur_api_key" {
  description = "Conjur API key for the specified login"
  type        = string
  sensitive   = true
}

variable "conjur_identity_client_id_path" {
  description = "Conjur secret path for Identity client ID"
  type        = string
  default     = ""
}

variable "conjur_identity_client_secret_path" {
  description = "Conjur secret path for Identity client secret"
  type        = string
  default     = ""
}
