variable "policy" {
  description = "Meaningful policy name"
  type        = string
  default = "SecretsHubInstallPolicy"
}

variable "cyberark_secrets_hub_role_arn" {
  description = "The Secrets Hub tenant role ARN which will be trusted by this role - get this from the cyberark tenant in secrets hub settings."
  type        = string
}

variable "secrets_manager_region" {
  description = "The AWS Secrets Manager Account region that the Secrets Hub will have access to"
  type        = string
}

variable "allow_secret_extended_access" {
  description = "Allow Secrets Hub to retrieve secret values"
  type        = bool
  default     = true
}

variable "alias" {
  description = "Short alias identifier for safe naming (e.g., 'Papaya', 'Mango')"
  type        = string
}