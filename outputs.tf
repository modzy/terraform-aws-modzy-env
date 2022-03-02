
output "kots_install_cmd" {
  description = "The following command can be used to install Modzy using KOTS. (Assumes kubectl and kots plugin <= v1.50.0 are installed)"
  value = <<EOS
kubectl kots install modzy/stable \
  --namespace ${var.modzy_namespace} \
  --shared-password "${random_password.replicated.result}" \
  --config-values ${local.replicated_config_file_path} \
  --port-forward=true
EOS
  sensitive = true
}
