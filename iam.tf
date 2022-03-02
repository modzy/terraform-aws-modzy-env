
# ------------------------------------------------------------------------------
# Vault IAM User
resource "aws_iam_user" "vault" {
  name = "${local.identifier_prefix}-vault-user"
}

# Vault IAM AccessKey
resource "aws_iam_access_key" "vault" {
  user = aws_iam_user.vault.name
}

# Vault IAM User Policy
# TODO - I'm not sure this is needed but including it here just in case.
//resource "aws_iam_policy" "vault_user" {
//  policy = data.aws_iam_policy_document.vault_user_policy.json
//}
//
//resource "aws_iam_user_policy_attachment" "vault" {
//  user = aws_iam_user.vault.name
//  policy_arn = aws_iam_policy.vault_user.arn
//}
//
//data "aws_iam_policy_document" "vault_user_policy" {
//  statement {
//    sid = "Allow use of key by Vault IAM User"
//    effect = "Allow"
//    principals {
//      type = "AWS"
//      identifiers = [aws_iam_user.vault.arn]
//    }
//    actions = [
//      "kms:Encrypt",
//      "kms:Decrypt",
//      "kms:DescribeKey"
//    ]
//    resources = [aws_kms_key.vault.arn]
//  }
//}


# ------------------------------------------------------------------------------
# S3 Upload User
resource "aws_iam_user" "s3" {
  name = "${local.identifier_prefix}-s3-user"
}

# S3 Upload AccessKey
resource "aws_iam_access_key" "s3" {
  user = aws_iam_user.s3.name
}

# S3 Upload Policy
resource "aws_iam_user_policy" "s3" {
  user = aws_iam_user.s3.name
  policy = data.aws_iam_policy_document.s3_user_policy.json
}

data "aws_iam_policy_document" "s3_user_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListBucketMultipartUploads"
    ]
    resources = [
      aws_s3_bucket.job_data.arn,
      aws_s3_bucket.result_data.arn,
      aws_s3_bucket.model_assets_data.arn
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:*Object",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload"
    ]
    resources = [
      "${aws_s3_bucket.job_data.arn}/*",
      "${aws_s3_bucket.result_data.arn}/*",
      "${aws_s3_bucket.model_assets_data.arn}/*"
    ]
  }
}

# ------------------------------------------------------------------------------
# SMTP User
resource "aws_iam_user" "smtp" {
  name = "${local.identifier_prefix}-smtp-user"
}

# SMTP AccessKey
resource "aws_iam_access_key" "smtp" {
  user = aws_iam_user.smtp.name
}

# SMTP Policy
resource "aws_iam_user_policy" "smtp" {
  user = aws_iam_user.smtp.name
  policy = data.aws_iam_policy_document.smtp_user_policy.json
}

data "aws_iam_policy_document" "smtp_user_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ses:SendRawEmail"
    ]
    resources = ["*"]
  }
}
