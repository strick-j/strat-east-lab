output "user_ids" {
  description = "Map of user keys to their user IDs"
  value       = { for k, v in idsec_identity_user.users : k => v.user_id }
}