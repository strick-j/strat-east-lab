output "role_arn" {
  description = "ARN of the Secrets Hub onboarding role"
  value       = aws_iam_role.secrets_hub_onboarding_role.arn
}

output "role_name" {
  description = "Name of the Secrets Hub onboarding role"
  value       = aws_iam_role.secrets_hub_onboarding_role.name
}

output "policy_arn" {
  description = "ARN of the Secrets Hub onboarding policy"
  value       = aws_iam_policy.secrets_hub_onboarding_policy.arn
}
