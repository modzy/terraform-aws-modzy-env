
locals {
  tags = merge(var.tags, {
    "ModzyInstallation": local.identifier_prefix
  })

  identifier_prefix = "${var.installation_identifier}-${random_string.installation_unique_identifier.result}"
  identifier_path_prefix = "/modzy/${local.identifier_prefix}"


  vpc_id = var.vpc_id
  public_subnets = var.public_subnets
  platform_subnets = var.platform_subnets
  model_subnets = var.model_subnets
  db_subnets = var.db_subnets
}

resource "random_string" "installation_unique_identifier" {
  length = 5
  special = false
  upper = false
}
