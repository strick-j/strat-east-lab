# ===========================
# EC2 Instance Outputs
# ===========================
output "instance_id" {
  description = "The ID of the Ubuntu SIA connector EC2 instance"
  value       = aws_instance.ubuntu_sia_connector.id
}

output "private_ip" {
  description = "The private IP address of the Ubuntu SIA connector"
  value       = aws_instance.ubuntu_sia_connector.private_ip
}

output "instance_dns_name" {
  description = "The private DNS name of the Ubuntu SIA connector"
  value       = aws_instance.ubuntu_sia_connector.private_dns
}
/*
# ===========================
# SSH Key Outputs
# ===========================
output "ssh_key_account_id" {
  description = "The CyberArk account ID for the stored SSH private key"
  value       = idsec_pcloud_account.ubuntu_sia_ssh_key.account_id
}

output "public_ssh_key" {
  description = "The public SSH key for the Ubuntu SIA connector"
  value       = tls_private_key.ubuntu_sia_key.public_key_openssh
}

output "key_pair_name" {
  description = "The name of the AWS key pair"
  value       = aws_key_pair.ubuntu_sia_key.key_name
}

# ===========================
# SIA Connector Outputs
# ===========================
output "connector_id" {
  description = "The ID of the SIA connector"
  value       = idsec_sia_access_connector.ubuntu_sia.connector_id
}*/