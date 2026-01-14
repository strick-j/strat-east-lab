# ===========================
# AWS provider variables
# ===========================
variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
}


# ===========================
# Common Variables
# ===========================
variable "asset_owner_name" {
  description = "Name of the human that the cloud team can contact with questions"
  type        = string
}

variable "team_name" {
  description = "Cloud naming identifier"
  type        = string
  default     = "us-strat-east"
}

# ===========================
# IAM Role Variables
# ===========================
variable "CyberArkSecretsHubRoleARN" {
  description = "The Secrets Hub tenant role ARN which will be trusted by this role - get this from the cyberark tenant in secrets hub settings."
  type        = string
}

variable "cyberark_secret_arn" {
  description = "ARN of the identity service account. Used if retrieving the service account from ASM."
  type        = string
}
