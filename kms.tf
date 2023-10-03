# Shared Account
data "aws_kms_key" "kms_key" {
  count  = local.confidentiality == "A" && var.encryption_at_rest_kms_key_arn != null ? 1 : 0
  key_id = var.encryption_at_rest_kms_key_arn
}

data "aws_kms_key" "validate_kms_by_level_A_tag_cia" {
  count  = local.confidentiality == "A" && var.encryption_at_rest_kms_key_arn == null ? 1 : 0
  key_id = var.encryption_at_rest_kms_key_arn
}

resource "aws_kms_key" "key" {
  count               = local.confidentiality != "A" && var.encryption_at_rest_kms_key_arn == null ? 1 : 0
  description         = "Encrypt and Decrypt Key used by AWS Backup Vault"
  key_usage           = "ENCRYPT_DECRYPT"
  is_enabled          = true
  enable_key_rotation = true
  provider            = aws.shared
  policy              = data.aws_iam_policy_document.key_policy.json
  tags                = module.tags.tags
}

resource "aws_kms_alias" "alias" {
  depends_on    = [aws_kms_key.key]
  count         = local.confidentiality != "A" && var.encryption_at_rest_kms_key_arn == null ? 1 : 0
  name          = "alias/${local.naming_kms}-amazon-mq"
  provider      = aws.shared
  target_key_id = aws_kms_key.key.0.key_id
}

data "aws_iam_policy_document" "key_policy" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.profile_shared.account_id}:root"
      ]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
  statement {
    sid    = "Allow access for Key Administrator"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.profile_shared.account_id}:root"
      ]
    }
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "Allow use of the key"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.profile_sigla.account_id}:root"
      ]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "Allow attachment of persistent resources"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.profile_sigla.account_id}:root"
      ]
    }
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
    resources = ["*"]
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}
