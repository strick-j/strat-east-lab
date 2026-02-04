data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "secrets_hub_onboarding_policy" {
  name        = "${lower(var.alias)}-secrets-hub-onboarding-policy"
  description = "Permissions required to onboard Secrets Hub"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Condition" : {
            "StringEquals" : {
              "aws:RequestTag/Sourced by CyberArk" : [
                ""
              ]
            }
          },
          "Action" : "secretsmanager:CreateSecret",
          "Resource" : "arn:aws:secretsmanager:${var.secrets_manager_region}:${data.aws_caller_identity.current.account_id}:secret:*",
          "Effect" : "Allow"
        },
        {
          "Condition" : {
            "StringEquals" : {
              "aws:RequestedRegion" : var.secrets_manager_region
            }
          },
          "Action" : "secretsmanager:ListSecrets",
          "Resource" : "*",
          "Effect" : "Allow"
        },
        {
          "Condition" : {
            "StringEqualsIgnoreCase" : {
              "aws:ResourceTag/Sourced by CyberArk" : ""
            }
          },
          "Action" : [
            "secretsmanager:UpdateSecret",
            "secretsmanager:PutSecretValue",
            "secretsmanager:DeleteSecret",
            "secretsmanager:DescribeSecret",
            "secretsmanager:TagResource",
            "secretsmanager:UntagResource"
          ],
          "Resource" : "arn:aws:secretsmanager:${var.secrets_manager_region}:${data.aws_caller_identity.current.account_id}:secret:*",
          "Effect" : "Allow"
        },
        {
          "Condition" : {
            "StringNotEqualsIgnoreCase" : {
              "aws:ResourceTag/Sourced by CyberArk" : ""
            },
            "ForAllValues:StringEqualsIgnoreCase" : {
              "aws:TagKeys" : [
                "Sourced by CyberArk",
                "CyberArk Extended Access"
              ]
            }
          },
          "Action" : [
            "secretsmanager:TagResource",
            "secretsmanager:UntagResource"
          ],
          "Resource" : "arn:aws:secretsmanager:${var.secrets_manager_region}:${data.aws_caller_identity.current.account_id}:secret:*",
          "Effect" : "Allow"
        },
        {
          "Condition" : {
            "StringEqualsIgnoreCase" : {
              "aws:ResourceTag/CyberArk Extended Access" : "true"
            }
          },
          "Action" : [
            "secretsmanager:GetSecretValue"
          ],
          "Resource" : "arn:aws:secretsmanager:${var.secrets_manager_region}:${data.aws_caller_identity.current.account_id}:secret:*",
          "Effect" : "Allow"
        }
      ]
    }
  )
}

resource "aws_iam_role" "secrets_hub_onboarding_role" {
  name = "${lower(var.alias)}-secrets-hub-onboarding-role"
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [{
        Effect = "Allow",
        Principal = {
          AWS = var.cyberark_secrets_hub_role_arn
        },
        Action = "sts:AssumeRole"
      }]
    }
  )
}

resource "aws_iam_role_policy_attachment" "cyberark_secrets_hub_policy_attachment" {
  role = aws_iam_role.secrets_hub_onboarding_role.name
  policy_arn = aws_iam_policy.secrets_hub_onboarding_policy.arn
}