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
/*
data "terraform_remote_state" "cyberark_foundation" {
  backend = "s3"
  config = {
    region  = var.aws_region
    bucket  = var.statefile_bucket_name
    key     = "terraform/cyberark_foundation.tfstate"
  }
}*/

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
# EC2 Instance - Ubuntu SIA Connector
# =====================================================================
resource "aws_instance" "ubuntu_sia_connector" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = data.terraform_remote_state.aws_networking.outputs.private_subnet_id_a
  associate_public_ip_address = false
  key_name                    = data.terraform_remote_state.aws_security.outputs.key_pair_name
  iam_instance_profile        = data.terraform_remote_state.aws_security.outputs.ec2_asm_instance_profile_name
  vpc_security_group_ids = [
    data.terraform_remote_state.aws_security.outputs.ssh_internal_flat_sg_id,
    data.terraform_remote_state.aws_security.outputs.https_internal_flat_sg_id
  ]

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
    encrypted             = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name                 = "${lower(var.alias)}-ubuntu-sia-connector"
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
/*
# =====================================================================
# CyberArk SIA Connector Installation
# =====================================================================
resource "idsec_sia_access_connector" "ubuntu_sia" {
  connector_type    = "AWS"
  connector_os      = "linux"
  connector_pool_id = data.terraform_remote_state.cyberark_foundation.outputs.cmgr_pool_id
  target_machine    = aws_instance.ubuntu_sia_connector.private_ip
  username          = var.ubuntu_username
  private_key_path  = local_file.ubuntu_sia_private_key.filename

  depends_on = [
    aws_instance.ubuntu_sia_connector,
    local_file.ubuntu_sia_private_key
  ]
}*/
