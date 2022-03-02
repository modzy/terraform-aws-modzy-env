
locals {
  embedded_registry_username = "modzy"
  embedded_registry_password = "${random_password.embedded_registry.result}"
  embedded_registry_credentials = "modzy:${htpasswd_password.embedded_registry_hash.bcrypt}"
}
