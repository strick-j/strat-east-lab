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

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "default"
}

# ===========================
# Identity User Variables
# ===========================
variable "users" {
  description = "List of Users to add"
  type = list(object({
    first_name   = string
    last_name    = string
    email        = string
    mobile_number = string
  }))
}

variable "domain_name" {
  description = "Domain name for Identity users"
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