# ===========================
# EC2 Instance Outputs
# ===========================
output "instance_id" {
  description = "The ID of the Windows SIA Connector EC2 instance"
  value       = aws_instance.windows_sia_connector.id
}

output "private_ip" {
  description = "The private IP address of the Windows SIA Connector"
  value       = aws_instance.windows_sia_connector.private_ip
}

output "instance_dns_name" {
  description = "The private DNS name of the Windows SIA Connector"
  value       = aws_instance.windows_sia_connector.private_dns
}