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
# EC2 Instance - Windows Domain Controller
# =====================================================================
resource "aws_instance" "windows_domain_controller" {
  ami                         = data.aws_ami.windows_2025.id
  instance_type               = var.instance_type
  subnet_id                   = data.terraform_remote_state.aws_networking.outputs.private_subnet_id_a
  key_name                    = data.terraform_remote_state.aws_security.outputs.key_pair_name
  iam_instance_profile        = data.terraform_remote_state.aws_security.outputs.ec2_asm_instance_profile_name
  associate_public_ip_address = false
  private_ip                  = data.terraform_remote_state.aws_networking.outputs.dns_server_ip
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
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name                 = "${lower(var.alias)}-windows-domain-controller"
    Environment          = var.alias
    Owner                = var.asset_owner_name
    CA_iScheduler        = var.iScheduler
    CA_iSchedulerControl = "yes"
  }

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [tags, ami]
  }

  depends_on = [data.aws_ami.windows_2025, data.terraform_remote_state.aws_networking, data.terraform_remote_state.aws_security]

}
