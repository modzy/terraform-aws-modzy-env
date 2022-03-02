
locals {
  replicated_config = templatefile("${path.module}/templates/replicated-config.yaml.tpl", {
    s3_upload_username = aws_iam_access_key.s3.id
    s3_upload_password = aws_iam_access_key.s3.secret
    domain = var.fqdn
    ecr_base = var.ecr_base
    db_database = aws_db_instance.modzy.name
    db_host = aws_db_instance.modzy.address
    db_password = aws_db_instance.modzy.password
    db_port = aws_db_instance.modzy.port
    db_username = aws_db_instance.modzy.username
    region = data.aws_region.current.name
    s3_job_data = aws_s3_bucket.job_data.bucket
    s3_model_data = aws_s3_bucket.model_assets_data.bucket
    s3_result_data = aws_s3_bucket.result_data.bucket
    smtp_host = local.smtp_host
    smtp_password = local.smtp_password
    smtp_port = local.smtp_port
    smtp_user_key = local.smtp_username
    embedded_registry_credentials = local.embedded_registry_credentials
    embedded_registry_username = local.embedded_registry_username
    embedded_registry_password = local.embedded_registry_password
    admin_email = var.admin_email
  })
  replicated_config_file_path = substr(var.replicated_config_output_path, -1, 1) == "/" ? "${var.replicated_config_output_path}replicated_config_${local.identifier_prefix}.yaml" : var.replicated_config_output_path
}

resource "local_file" "replicated_config" {
  // If the `replicated_config_output_path` ends in a slash then write the file
  // with the name of the installation identifier.
  // If it doesn't end in a slash then assume that the user wanted a specific
  // filename so write directly to that filename.
  filename = local.replicated_config_file_path
  file_permission = "0644"
  directory_permission = "0755"
  sensitive_content = local.replicated_config
}
