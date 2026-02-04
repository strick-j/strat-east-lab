output "key_pair_name" {
  description = "The name of the generated key pair"
  value       = aws_key_pair.aws_default_key_pair.key_name
}