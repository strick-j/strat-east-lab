# ===========================
# AWS provider variables
# ===========================
variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
}

variable "aws_profile" {
  description = "AWS CLI profile to use. Leave empty to use IAM role of the host (e.g., for orchestration servers)"
  type        = string
  default     = ""
}

# ===========================
# Common Variables
# ===========================
variable "alias" {
  description = "Short alias identifier for naming resources (e.g., 'Papaya', 'Mango')"
  type        = string
}

# ===========================
# IAM Role Variables
# ===========================
variable "cyberark_secrets_hub_role_arn" {
  description = "The Secrets Hub tenant role ARN which will be trusted by this role - get this from the cyberark tenant in secrets hub settings."
  type        = string
}

