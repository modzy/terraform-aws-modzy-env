# ------------------------------------------------------------------------------
# Secrets Manager Encryption Key

resource "aws_kms_key" "secrets_manager" {
  description = "Secrets Manager Encryption for ${local.identifier_prefix}."
  key_usage = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days = 30
  enable_key_rotation = true
  is_enabled = true
  policy = data.aws_iam_policy_document.kms_secrets_manager.json
}

data "aws_iam_policy_document" "kms_secrets_manager" {
  statement {
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
    actions = [
      "kms:*"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_kms_alias" "secrets_manager" {
  target_key_id = aws_kms_key.secrets_manager.key_id
  name = "alias/${local.identifier_prefix}-secretsmanager"
}

# ------------------------------------------------------------------------------
# S3 Encryption Key
resource "aws_kms_key" "s3" {
  description = "S3 Encryption for ${local.identifier_prefix}."
  key_usage = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days = 30
  enable_key_rotation = true
  is_enabled = true
  policy = data.aws_iam_policy_document.kms_s3.json

//  lifecycle {
//    prevent_destroy = !var.force_deletion_of_all_resources
//  }
}

data "aws_iam_policy_document" "kms_s3" {
  statement {
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
    actions = [
      "kms:*"
    ]
    resources = [
      "*"
    ]
  }
  # NOTE: This statement is taken from the default S3 encryption key.
  statement {
    sid = "Allow access through S3 for all principals in the account that are authorized to use S3."
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    condition {
      test = "StringEquals"
      variable = "kms:CallerAccount"
      values = [data.aws_caller_identity.current.account_id]
    }
    condition {
      test = "StringEquals"
      variable = "kms:ViaService"
      values = ["s3.${data.aws_region.current.name}.amazonaws.com"]
    }
  }
}

resource "aws_kms_alias" "s3" {
  target_key_id = aws_kms_key.s3.key_id
  name = "alias/${local.identifier_prefix}-s3"
}

# ------------------------------------------------------------------------------
# RDS Encryption Key
resource "aws_kms_key" "rds" {
  description = "RDS Encryption for ${local.identifier_prefix}."
  key_usage = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days = 30
  enable_key_rotation = true
  is_enabled = true
  policy = data.aws_iam_policy_document.kms_rds.json

//  lifecycle {
//    prevent_destroy = !var.force_deletion_of_all_resources
//  }
}

data "aws_iam_policy_document" "kms_rds" {
  statement {
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
    actions = [
      "kms:*"
    ]
    resources = [
      "*"
    ]
  }
  # NOTE: This statement is taken from the default RDS encryption key.
  statement {
    sid = "Allow access through RDS for all principals in the account that are authorized to use RDS."
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    condition {
      test = "StringEquals"
      variable = "kms:CallerAccount"
      values = [data.aws_caller_identity.current.account_id]
    }
    condition {
      test = "StringEquals"
      variable = "kms:ViaService"
      values = ["rds.${data.aws_region.current.name}.amazonaws.com"]
    }
  }
}

resource "aws_kms_alias" "rds" {
  target_key_id = aws_kms_key.rds.key_id
  name = "alias/${local.identifier_prefix}-rds"
}

# ------------------------------------------------------------------------------
# Vault KMS Key
resource "aws_kms_key" "vault" {
  description = "Vault Auto-Unseal Key for ${local.identifier_prefix}."
  key_usage = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days = 7
  enable_key_rotation = true
  is_enabled = true
  policy = data.aws_iam_policy_document.kms_vault_policy.json
}

# Vault KMS Key Policy
data "aws_iam_policy_document" "kms_vault_policy" {
  statement {
    sid = "Allow access from account root"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
    actions = [
      "kms:*"
    ]
    resources = ["*"]
  }
  statement {
    sid = "Allow use of key"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [aws_iam_user.vault.arn]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:ReEncrypt*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }
  statement {
    sid = "Allow attachment of persistent resources"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [aws_iam_user.vault.arn]
    }
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
    resources = ["*"]
    condition {
      test = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values = ["true"]
    }
  }
}

# Vault KMS Key Alias
resource "aws_kms_alias" "vault" {
  target_key_id = aws_kms_key.vault.key_id
  name = "alias/${local.identifier_prefix}-vault-autounseal"
}
