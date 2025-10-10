terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Створення namespace для ArgoCD
resource "kubernetes_namespace" "infra_tools" {
  metadata {
    name = "infra-tools"
    labels = {
      name = "infra-tools"
    }
  }
}

# Розгортання ArgoCD через Helm
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.infra_tools.metadata[0].name
  version    = "7.4.0"

  create_namespace = false

  values = [
    file("${path.module}/values/argocd-values.yaml")
  ]

  timeout = 600

  depends_on = [kubernetes_namespace.infra_tools]
}

# Отримання паролю адміністратора ArgoCD
data "kubernetes_secret" "argocd_admin_password" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = kubernetes_namespace.infra_tools.metadata[0].name
  }
  depends_on = [helm_release.argocd]
}
