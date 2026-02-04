# =====================================================================
# Remote State Data Sources
# =====================================================================
data "terraform_remote_state" "aws_networking" {
  backend = "s3"
  config = {
    region = var.aws_region
    bucket = var.statefile_bucket_name
    key    = "terraform/aws/networking/terraform.tfstate"
  }
}

data "terraform_remote_state" "aws_security" {
  backend = "s3"
  config = {
    region = var.aws_region
    bucket = var.statefile_bucket_name
    key    = "terraform/aws/security/terraform.tfstate"
  }
}

# =====================================================================
# Windows AMI Data Source - Windows Server 2025 Datacenter
# =====================================================================
data "aws_ami" "windows_2025" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2025-English-Full-Base-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# =====================================================================
# Local Admin Password Generation
# =====================================================================
resource "random_password" "local_admin_password" {
  length           = 24
  special          = true
  override_special = "!@#%^*()-_=+[]{}"
}

locals {
  user_data = templatefile("${path.module}/scripts/user_data.tpl", {
    local_admin_password = random_password.local_admin_password.result
  })
}

# =====================================================================
# EC2 Instance - Windows SIA Connector
# =====================================================================
resource "aws_instance" "windows_sia_connector" {
  ami                         = data.aws_ami.windows_2025.id
  instance_type               = var.instance_type
  subnet_id                   = data.terraform_remote_state.aws_networking.outputs.private_subnet_id_a
  key_name                    = data.terraform_remote_state.aws_security.outputs.key_pair_name
  iam_instance_profile        = data.terraform_remote_state.aws_security.outputs.ec2_asm_instance_profile_name
  associate_public_ip_address = false
  user_data                   = local.user_data
  vpc_security_group_ids = [
    data.terraform_remote_state.aws_security.outputs.rdp_internal_flat_sg_id,
    data.terraform_remote_state.aws_security.outputs.sia_windows_target_sg_id
  ]

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 50
    delete_on_termination = true
    encrypted             = true
  }

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  tags = {
    Name                 = "${lower(var.alias)}-windows-sia-connector"
    Environment          = var.alias
    Owner                = var.asset_owner_name
    CA_iScheduler        = var.iScheduler
    CA_iSchedulerControl = "yes"

  }

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [tags, ami]
  }
}
