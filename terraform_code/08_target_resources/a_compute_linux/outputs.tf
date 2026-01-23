# ===========================
# EC2 Instance Outputs
# ===========================
output "instance_id" {
  description = "The ID of the Ubuntu SIA target EC2 instance"
  value       = aws_instance.ubuntu_sia_target.id
}

output "private_ip" {
  description = "The private IP address of the Ubuntu SIA target"
  value       = aws_instance.ubuntu_sia_target.private_ip
}

output "instance_dns_name" {
  description = "The private DNS name of the Ubuntu SIA connector"
  value       = aws_instance.ubuntu_sia_target.private_dns
}