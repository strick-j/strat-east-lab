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
# Local Admin Password Generation
# =====================================================================
resource "random_password" "oracle_admin_password" {
  length  = 16
  special = false
}

data "aws_rds_engine_version" "oracle_latest" {
  engine = "oracle-ee"
}

# =====================================================================
# RDS Instance - Oracle Database Target
# =====================================================================
resource "aws_db_instance" "oracle" {
  identifier              = "${lower(var.alias)}-oracle"
  engine                  = "oracle-ee"
  engine_version          = data.aws_rds_engine_version.oracle_latest.version
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  storage_encrypted       = true
  db_name                 = var.db_name
  username                = var.username
  password                = random_password.oracle_admin_password.result
  license_model           = var.license_model
  db_subnet_group_name    = data.terraform_remote_state.aws_networking.outputs.db_subnet_group_name
  vpc_security_group_ids  = [data.terraform_remote_state.aws_security.outputs.oracle_target_sg_id]
  publicly_accessible     = false
  deletion_protection     = false
  backup_retention_period = var.backup_retention
  skip_final_snapshot     = true

  tags = {
    Name                 = "${lower(var.alias)}-oracle"
    Project              = var.alias
    I_Owner              = var.asset_owner_name
    I_Purpose            = "${var.alias} Lab Oracle Target"
    CA_iScheduler        = var.iScheduler
    CA_iSchedulerControl = "yes"
  }

  depends_on = [data.terraform_remote_state.aws_networking, data.terraform_remote_state.aws_security]
}
