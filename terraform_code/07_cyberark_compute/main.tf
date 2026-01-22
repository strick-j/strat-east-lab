# =====================================================================
# Remote State Data Sources
# =====================================================================
data "terraform_remote_state" "aws_foundation" {
  backend = "s3"
  config = {
    region  = var.aws_region
    bucket  = var.statefile_bucket_name
    key     = "terraform/aws_foundation.tfstate"
    profile = var.aws_profile
  }
}

data "terraform_remote_state" "aws_security" {
  backend = "s3"
  config = {
    region  = var.aws_region
    bucket  = var.statefile_bucket_name
    key     = "terraform/aws_security.tfstate"
    profile = var.aws_profile
  }
}

data "terraform_remote_state" "cyberark_foundation" {
  backend = "s3"
  config = {
    region  = var.aws_region
    bucket  = var.statefile_bucket_name
    key     = "terraform/cyberark_foundation.tfstate"
    profile = var.aws_profile
  }
}

# =====================================================================
# Ubuntu AMI Data Source - Latest Ubuntu 24.04 LTS
# =====================================================================
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# =====================================================================
# SSH Key Generation
# =====================================================================
resource "tls_private_key" "ubuntu_sia_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ubuntu_sia_key" {
  key_name   = "${lower(var.alias)}-ubuntu-sia-key"
  public_key = tls_private_key.ubuntu_sia_key.public_key_openssh

  tags = {
    Name      = "${var.alias}-Ubuntu-SIA-Key"
    Alias     = var.alias
    I_Owner   = var.asset_owner_name
    I_Purpose = "${var.alias} Lab Linux SIA Key"
  }
}

# Write private key to local file for SIA connector installation
resource "local_file" "ubuntu_sia_private_key" {
  content         = tls_private_key.ubuntu_sia_key.private_key_pem
  filename        = "${path.module}/.ssh/ubuntu_sia_key.pem"
  file_permission = "0600"
}

# =====================================================================
# Store SSH Private Key in CyberArk Privilege Cloud
# =====================================================================
resource "idsec_pcloud_account" "ubuntu_sia_ssh_key" {
  safe_name   = data.terraform_remote_state.cyberark_foundation.outputs.linux_safe_id
  address     = aws_instance.ubuntu_sia_connector.private_ip
  username    = var.ubuntu_username
  platform_id = "UnixSSHKeys"
  secret      = tls_private_key.ubuntu_sia_key.private_key_pem
  secret_type = "key"

  depends_on = [aws_instance.ubuntu_sia_connector]

  lifecycle {
    prevent_destroy = true
  }
}

# =====================================================================
# EC2 Instance - Ubuntu SIA Connector
# =====================================================================
resource "aws_instance" "ubuntu_sia_connector" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = var.instance_type
  subnet_id            = data.terraform_remote_state.aws_foundation.outputs.private_subnet_id
  key_name             = aws_key_pair.ubuntu_sia_key.key_name
  iam_instance_profile = data.terraform_remote_state.aws_security.outputs.ec2_asm_instance_profile_name
  vpc_security_group_ids = [
    data.terraform_remote_state.aws_foundation.outputs.ssh_internal_flat_sg_id,
    data.terraform_remote_state.aws_foundation.outputs.https_internal_flat_sg_id
  ]

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name                 = "${var.alias}-Ubuntu-SIA-Connector"
    Project              = var.alias
    I_Owner              = var.asset_owner_name
    I_Purpose            = "${var.alias} Lab Linux SIA Connector"
    CA_iScheduler        = var.iScheduler
    CA_iSchedulerControl = "yes"
  }

  lifecycle {
    ignore_changes = [tags, ami]
  }
}

# =====================================================================
# CyberArk SIA Connector Installation
# =====================================================================
resource "idsec_sia_access_connector" "ubuntu_sia" {
  connector_type    = "AWS"
  connector_os      = "linux"
  connector_pool_id = data.terraform_remote_state.cyberark_foundation.outputs.cmgr_pool_id
  target_machine    = aws_instance.ubuntu_sia_connector.public_ip
  username          = var.ubuntu_username
  private_key_path  = local_file.ubuntu_sia_private_key.filename

  depends_on = [
    aws_instance.ubuntu_sia_connector,
    local_file.ubuntu_sia_private_key
  ]
}
