# ===========================
# Identity Variables
# ===========================
variable "alias" {
  description = "Short alias identifier for naming resources (e.g., 'Papaya', 'Mango')"
  type        = string
}

variable "safe_prefix" {
  description = "Safe naming prefix (e.g., 'PAP', 'MAN')"
  type        = string
}

variable "safe_purpose" {
  description = "Purpose of the Identity Roles being created"
  type = list(object({
    description    = string
    short_name     = string
    scope          = string
    type           = string
    retention_days = number
  }))
}

variable "managing_cpm" {
  description = "The CPM that will manage the safe (e.g., 'PasswordManager')"
  type        = string
}

# ===========================
# AWS Variables
# ===========================
variable "aws_region" {
  description = "AWS region for remote state backend"
  type        = string
}

variable "statefile_bucket_name" {
  description = "Name of the S3 bucket storing Terraform state files"
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