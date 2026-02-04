# =====================================================================
# SSH Key Generation
# =====================================================================
resource "tls_private_key" "default_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "aws_default_key_pair" {
  key_name   = "${lower(var.alias)}-default-key"
  public_key = tls_private_key.default_key_pair.public_key_openssh

  tags = {
    Name      = "${var.alias}-Default-Key"
    Project   = var.alias
    I_Owner   = var.asset_owner_name
    I_Purpose = "${var.alias} Default Lab Key"
  }
}

# Write private key to local file later use
resource "local_file" "default_key_pair_private_key" {
  content         = tls_private_key.default_key_pair.private_key_pem
  filename        = "${path.module}/../../.ssh/default_ssh_key.pem"
  file_permission = "0600"
}
