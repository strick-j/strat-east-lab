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

variable "aws_profile" {
  description = "AWS CLI profile to use for deployment"
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
  description = "Short alias identifier for safe naming (e.g., 'Papaya', 'Mango')"
  type        = string
}

# ===========================
# CyberArk Safe Variables
# ===========================
variable "managing_cpm" {
  description = "The name of the CPM that manages the safe"
  type        = string
  default     = "PasswordManager"
}

# ===========================
# Conjur Variables
# ===========================
variable "conjur_appliance_url" {
  description = "URL of the Conjur appliance"
  type        = string
  default     = "https://murphyslab.secretsmgr.cyberark.cloud/api"
}

variable "conjur_account" {
  description = "Conjur account name"
  type        = string
  default     = "conjur"
}

variable "conjur_login" {
  description = "Conjur login name"
  type        = string
  default     = "host/data/murphys-tf"
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