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
    <<-EOT
      # ArgoCD Helm values
      global:
        image:
          tag: "v2.10.4"
      
      # ArgoCD Server налаштування
      server:
        service:
          type: ClusterIP
          port: 80
        extraArgs:
          - --insecure
        config:
          # Дозволити небезпечні TLS з'єднання для Git репозиторіїв
          tls.insecure: "true"
          # Налаштування timeout
          timeout.reconciliation: "180s"
          timeout.hard.reconciliation: "300s"
          # Дозволити всі Git репозиторії
          application.instanceLabelKey: argocd.argoproj.io/instance
      
      # ArgoCD Controller налаштування
      controller:
        replicas: 1
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
      
      # ArgoCD Repo Server налаштування
      repoServer:
        replicas: 1
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
      
      # ArgoCD ApplicationSet Controller
      applicationSet:
        enabled: true
        replicas: 1
      
      # ArgoCD Dex Server (для аутентифікації)
      dex:
        enabled: false
      
      # ArgoCD Notifications
      notifications:
        enabled: false
      
      # ArgoCD Redis
      redis:
        enabled: true
        auth:
          enabled: false
        # Вимкнути аутентифікацію Redis повністю
        authSecret:
          enabled: false
        # Додаткові налаштування для вимкнення аутентифікації
        master:
          auth:
            enabled: false
        resources:
          requests:
            cpu: 50m
            memory: 64Mi
          limits:
            cpu: 200m
            memory: 256Mi
      
      # RBAC налаштування
      rbac:
        create: true
        policy.default: role:readonly
        policy.csv: |
          p, role:admin, applications, *, */*, allow
          p, role:admin, clusters, *, *, allow
          p, role:admin, repositories, *, *, allow
          p, role:admin, certificates, *, *, allow
          p, role:admin, accounts, *, *, allow
          p, role:admin, gpgkeys, *, *, allow
          p, role:admin, logs, *, *, allow
          p, role:admin, exec, *, *, allow
          p, role:admin, projects, *, *, allow
          p, role:admin, application, *, */*, allow
          p, role:admin, cluster, *, *, allow
          p, role:admin, repository, *, *, allow
          p, role:admin, certificate, *, *, allow
          p, role:admin, account, *, *, allow
          p, role:admin, gpgkey, *, *, allow
          p, role:admin, log, *, *, allow
          p, role:admin, exec, *, *, allow
          p, role:admin, project, *, *, allow
          g, argocd-admins, role:admin
      
      # Налаштування безпеки
      configs:
        secret:
          # Вимкнути TLS для спрощення налаштування
          argocdServerTlsConfig: |
            tls:
              insecure: true
        rbac:
          # Дозволити всім користувачам читати
          policy.default: role:readonly
          policy.csv: |
            p, role:admin, applications, *, */*, allow
            p, role:admin, clusters, *, *, allow
            p, role:admin, repositories, *, *, allow
            p, role:admin, certificates, *, *, allow
            p, role:admin, accounts, *, *, allow
            p, role:admin, gpgkeys, *, *, allow
            p, role:admin, logs, *, *, allow
            p, role:admin, exec, *, *, allow
            p, role:admin, projects, *, *, allow
            g, argocd-admins, role:admin
    EOT
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
