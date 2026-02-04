output "safe_names" {
  description = "Map of safe keys to their safe names"
  value       = { for k, v in idsec_pcloud_safe.safes : k => v.safe_name }
}