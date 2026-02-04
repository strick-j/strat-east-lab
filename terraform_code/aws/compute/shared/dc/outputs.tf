# ===========================
# EC2 Instance Outputs
# ===========================
output "instance_id" {
  description = "The ID of the Ubuntu SIA target EC2 instance"
  value       = aws_instance.windows_domain_controller.id
}

output "private_ip" {
  description = "The private IP address of the Windows SIA target"
  value       = aws_instance.windows_domain_controller.private_ip
}

output "instance_dns_name" {
  description = "The private DNS name of the Windows SIA target"
  value       = aws_instance.windows_domain_controller.private_dns
}