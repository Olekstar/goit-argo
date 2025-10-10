output "argocd_namespace" {
  description = "Namespace де розгорнуто ArgoCD"
  value       = kubernetes_namespace.infra_tools.metadata[0].name
}

output "argocd_admin_password" {
  description = "Пароль адміністратора ArgoCD"
  value       = data.kubernetes_secret.argocd_admin_password.data.password
  sensitive   = true
}

output "argocd_server_service_name" {
  description = "Ім'я сервісу ArgoCD Server"
  value       = "argocd-server"
}

output "argocd_server_namespace" {
  description = "Namespace ArgoCD Server"
  value       = kubernetes_namespace.infra_tools.metadata[0].name
}

