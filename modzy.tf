resource "kubernetes_namespace" "modzy" {
  depends_on = [module.eks]
  metadata {
    name = var.modzy_namespace
  }
}

resource "kubernetes_secret" "aws_access_key" {
  depends_on = [kubernetes_namespace.modzy]
  metadata {
    namespace = var.modzy_namespace
    name = "aws-access-key"
  }
  data = {
    AWS_ACCESS_KEY_ID = aws_iam_access_key.vault.id
  }
}

resource "kubernetes_secret" "aws_secret_key" {
  depends_on = [kubernetes_namespace.modzy]
  metadata {
    namespace = var.modzy_namespace
    name = "aws-secret-key"
  }
  data = {
    AWS_SECRET_ACCESS_KEY = aws_iam_access_key.vault.secret
  }
}

resource "kubernetes_secret" "kms_seal_id" {
  depends_on = [kubernetes_namespace.modzy]
  metadata {
    namespace = var.modzy_namespace
    name = "kms-seal-id"
  }
  data = {
    VAULT_AWSKMS_SEAL_KEY_ID = aws_kms_key.vault.key_id
  }
}