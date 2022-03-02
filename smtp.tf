
locals {
  smtp_host = "email-smtp.${data.aws_region.current.name}.amazonaws.com"
  smtp_port = var.smtp_port
  smtp_region = data.aws_region.current.name
  smtp_username = aws_iam_access_key.smtp.id
  smtp_password = aws_iam_access_key.smtp.ses_smtp_password_v4
}
