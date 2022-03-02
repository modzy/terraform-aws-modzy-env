
resource "kubernetes_role" "modzy_dev" {
  depends_on = [kubernetes_namespace.modzy]
  metadata {
    namespace = var.modzy_namespace
    name = "modzy-developer"
  }
  rule {
    api_groups = ["*"]
    resources = [
      "configmaps",
      "componentstatuses",
      "deployments",
      "endpoints",
      "events",
      "namespaces",
      "nodes",
      "persistentvolumeclaims",
      "persistentvolumes",
      "pods",
      "podtemplates",
      "pods/log",
      "replicationcontrollers",
      "services"
    ]
    verbs = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["apps"]
    resources = [
      "daemonsets",
      "deployments",
      "replicasets",
      "statefulsets"
    ]
    verbs = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["*"]
    resources = ["pods/portforward"]
    verbs = ["create", "get", "list"]
  }
  rule {
    api_groups = ["autoscaling"]
    resources = [
      "horizontalpodautoscalers",
      "horizontalpodautoscalers/status"
    ]
    verbs = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding" "modzy_dev" {
  depends_on = [kubernetes_namespace.modzy, kubernetes_role.modzy_dev]
  metadata {
    namespace = var.modzy_namespace
    name = "modzy-developer"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "Role"
    name = "modzy-developer"
  }
  subject {
    kind = "Group"
    name = "modzy:developer"
  }
}

# ------------------------------------------------------------------------------

resource "kubernetes_role" "modzy_power_user" {
  depends_on = [kubernetes_namespace.modzy]
  metadata {
    namespace = var.modzy_namespace
    name = "modzy-power-user"
  }
  rule {
    api_groups = ["*"]
    resources = [
      "configmaps",
      "componentstatuses",
      "deployments",
      "endpoints",
      "events",
      "namespaces",
      "nodes",
      "persistentvolumeclaims",
      "persistentvolumes",
      "pods",
      "podtemplates",
      "pods/log",
      "replicationcontrollers",
      "services"
    ]
    verbs = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["apps"]
    resources = [
      "daemonsets",
      "deployments",
      "replicasets",
      "statefulsets"
    ]
    verbs = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["*"]
    resources = ["pods/portforward"]
    verbs = ["create", "get", "list"]
  }
  rule {
    api_groups = ["autoscaling"]
    resources = [
      "horizontalpodautoscalers",
      "horizontalpodautoscalers/status"
    ]
    verbs = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["*"]
    resources = ["pods/exec"]
    verbs = ["create"]
  }
}

resource "kubernetes_role_binding" "modzy_power_user" {
  depends_on = [kubernetes_namespace.modzy, kubernetes_role.modzy_power_user]
  metadata {
    namespace = var.modzy_namespace
    name = "modzy-power-user"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "Role"
    name = "modzy-power-user"
  }
  subject {
    kind = "Group"
    name = "modzy:power-user"
  }
}
