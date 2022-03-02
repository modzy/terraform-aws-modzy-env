
# Job Data Bucket
resource "aws_s3_bucket" "job_data" {
  bucket = "${local.identifier_prefix}-job-data"
  acl = "private"

//  lifecycle {
//    prevent_destroy = !var.force_deletion_of_all_resources
//  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
        kms_master_key_id = aws_kms_key.s3.key_id
      }
      bucket_key_enabled = true
    }
  }
}

resource "aws_s3_bucket_public_access_block" "job_data" {
  bucket = aws_s3_bucket.job_data.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

# Result Data Bucket
resource "aws_s3_bucket" "result_data" {
  bucket = "${local.identifier_prefix}-result-data"
  acl = "private"

//  lifecycle {
//    prevent_destroy = !var.force_deletion_of_all_resources
//  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
        kms_master_key_id = aws_kms_key.s3.key_id
      }
      bucket_key_enabled = true
    }
  }
}

resource "aws_s3_bucket_public_access_block" "result_data" {
  bucket = aws_s3_bucket.result_data.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

# Model Asset Bucket
resource "aws_s3_bucket" "model_assets_data" {
  bucket = "${local.identifier_prefix}-model-assets-data"
  acl = "private"

//  lifecycle {
//    prevent_destroy = !var.force_deletion_of_all_resources
//  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
        kms_master_key_id = aws_kms_key.s3.key_id
      }
      bucket_key_enabled = true
    }
  }
}

resource "aws_s3_bucket_public_access_block" "model_assets_data" {
  bucket = aws_s3_bucket.model_assets_data.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}
