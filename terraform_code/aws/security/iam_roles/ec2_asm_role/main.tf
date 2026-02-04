# 1) IAM role & instance profile so EC2 can call Secrets Manager & STS
data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions   = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_asm_role" {
  name               = "${lower(var.alias)}-ec2-asm-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

resource "aws_iam_instance_profile" "ec2_asm_instance_profile" {
  name = "${lower(var.alias)}-instance-profile"
  role = aws_iam_role.ec2_asm_role.name
}