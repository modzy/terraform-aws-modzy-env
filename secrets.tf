
# ------------------------------------------------------------------------------
# Vault Secrets => Secrets Manager
resource "aws_secretsmanager_secret" "vault" {
  name = "${local.identifier_path_prefix}/vault"
  kms_key_id = aws_kms_key.secrets_manager.key_id
}

resource "aws_secretsmanager_secret_version" "vault" {
  secret_id = aws_secretsmanager_secret.vault.id
  secret_string = jsonencode({
    access-key-id = aws_iam_access_key.vault.id
    secret-access-key = aws_iam_access_key.vault.secret
    kms-key = aws_kms_key.vault.key_id
  })
}

# ------------------------------------------------------------------------------
# Application Secrets => Secrets Manager
resource "random_password" "replicated" {
  length = 32
  special = false
}

resource "aws_secretsmanager_secret" "modzy" {
  name = "${local.identifier_path_prefix}/app"
  kms_key_id = aws_kms_key.secrets_manager.key_id
}

resource "aws_secretsmanager_secret_version" "modzy" {
  secret_id = aws_secretsmanager_secret.modzy.id
  secret_string = jsonencode({
    config-password = random_password.replicated.result
    db-hostname = aws_db_instance.modzy.address
    db-name = aws_db_instance.modzy.name
    db-port = aws_db_instance.modzy.port
    db-user = aws_db_instance.modzy.username
    s3-job-data = aws_s3_bucket.job_data.bucket
    s3-model-data = aws_s3_bucket.model_assets_data.bucket
    s3-result-data = aws_s3_bucket.result_data.bucket
    s3-upload-username = aws_iam_access_key.s3.id
    s3-upload-password = aws_iam_access_key.s3.secret
    smtp-host = local.smtp_host
    smtp-port = local.smtp_port
    smtp-region = local.smtp_region
    smtp-user-key = local.smtp_username
    smtp-user-secret = local.smtp_password
  })
}

# ------------------------------------------------------------------------------
# Database Secrets => Secrets Manager
resource "random_password" "db" {
  length = 32
  special = false
}

resource "aws_secretsmanager_secret" "db" {
  name = "${local.identifier_path_prefix}/db"
  kms_key_id = aws_kms_key.secrets_manager.key_id
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = aws_db_instance.modzy.username
    password = random_password.db.result
    dbname = aws_db_instance.modzy.name
    engine = aws_db_instance.modzy.engine
    port = aws_db_instance.modzy.port
    host = aws_db_instance.modzy.address
    dbInstanceIdentifier = aws_db_instance.modzy.id
  })
}

# ------------------------------------------------------------------------------
# Embedded Registry Secrets => Secrets Manager
resource "random_password" "embedded_registry" {
  length = 32
  special = false
}

resource "htpasswd_password" "embedded_registry_hash" {
  password = random_password.embedded_registry.result
}

resource "aws_secretsmanager_secret" "embedded_registry" {
  name = "${local.identifier_path_prefix}/embedded_registry"
  kms_key_id = aws_kms_key.secrets_manager.key_id
}

resource "aws_secretsmanager_secret_version" "embedded_registry" {
  secret_id = aws_secretsmanager_secret.embedded_registry.id
  secret_string = jsonencode({
    password = random_password.embedded_registry.result
    apr1 = htpasswd_password.embedded_registry_hash.apr1
    bcrypt = htpasswd_password.embedded_registry_hash.bcrypt
  })
}