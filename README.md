# GoIT ArgoCD MLflow Deployment

Цей репозиторій містить конфігурацію для автоматичного розгортання MLflow через ArgoCD з використанням готового Helm чарта з ArtifactHub.

## Структура проекту

```
goit-argo/
├── namespaces/
│   ├── application/
│   │   ├── nginx.yaml
│   │   └── ns.yaml
│   └── infra-tools/
│       └── ns.yaml
├── application.yaml    # ArgoCD Application з Helm-чартом
└── README.md          # Документація
```

## Особливості

- ✅ Використовує готовий Helm-чарт `mlflow` з `community-charts`
- ✅ Образ: `burakince/mlflow:3.4.0`
- ✅ Ресурси: CPU 700m/3000m, Memory 2.5Gi/5Gi
- ✅ Автоматична синхронізація через GitOps
- ✅ Inline values в ArgoCD Application

## Передумови

1. **EKS кластер** розгорнутий через Terraform
2. **ArgoCD** розгорнутий через Terraform
3. **kubectl** налаштований для роботи з кластером
4. **Git репозиторій** підключений до ArgoCD

## Як запустити Terraform

### 1. Ініціалізація Terraform

```bash
cd lesson-7/vpc
terraform init
terraform plan
terraform apply
```

### 2. Розгортання EKS

```bash
cd ../eks
terraform init
terraform plan
terraform apply
```

### 3. Розгортання ArgoCD

```bash
cd ../argocd
terraform init
terraform plan
terraform apply
```

## Як перевірити, що ArgoCD працює

### 1. Перевірка подів ArgoCD

```bash
kubectl get pods -n infra-tools
```

Має бути кілька подів з префіксом `argocd-`:
- argocd-server
- argocd-repo-server
- argocd-redis
- argocd-application-controller
- argocd-applicationset-controller

### 2. Перевірка сервісів

```bash
kubectl get svc -n infra-tools
```

## Як відкрити UI ArgoCD

### 1. Port-forward

```bash
kubectl port-forward svc/argocd-server -n infra-tools 8080:80
```

### 2. Доступ до веб-інтерфейсу

Відкрийте браузер і перейдіть на: http://localhost:8080

### 3. Логін

- **Username**: `admin`
- **Password**: Отримайте через команду:
```bash
kubectl -n infra-tools get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

## Як перевірити, що деплой відбувся

### 1. Перевірка Application

```bash
kubectl get applications -n infra-tools
```

### 2. Перевірка подів MLflow

```bash
kubectl get pods -n application
```

### 3. Доступ до MLflow

```bash
kubectl port-forward svc/mlflow -n application 5000:80
```

Відкрийте браузер і перейдіть на: http://localhost:5000

## Посилання на репозиторії

- **Infrastructure (Terraform)**: https://github.com/Olekstar/lesson-7.git
- **GitOps (ArgoCD Applications)**: https://github.com/Olekstar/goit-argo.git

## Автоматичне розгортання

ArgoCD автоматично підхопить `application.yaml` з цього репозиторію та розгорне MLflow.

```bash
kubectl get pods -n infra-tools
```

Має бути кілька подів з префіксом `argocd-`:
- argocd-server
- argocd-repo-server
- argocd-redis
- argocd-application-controller
- argocd-applicationset-controller

### 2. Перевірка сервісів

```bash
kubectl get svc -n infra-tools
```

## Як відкрити UI ArgoCD

### 1. Port-forward

```bash
kubectl port-forward svc/argocd-server -n infra-tools 8080:80
```

### 2. Доступ до веб-інтерфейсу

Відкрийте браузер і перейдіть на: http://localhost:8080

### 3. Логін

- **Username**: admin
- **Password**: отримати пароль командою:
```bash
kubectl -n infra-tools get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## Як перевірити, що деплой відбувся

### 1. Перевірка ArgoCD Application

```bash
kubectl get applications -n infra-tools
```

### 2. Перевірка подів MLflow

```bash
kubectl get pods -n application
```

Має бути под `mlflow-*` у стані `Running`.

### 3. Перевірка сервісів MLflow

```bash
kubectl get svc -n application
```

## Доступ до MLflow

### 1. Port-forward MLflow

```bash
kubectl port-forward svc/mlflow -n application 5000:80
```

### 2. Веб-інтерфейс MLflow

Відкрийте браузер і перейдіть на: http://localhost:5000

## GitOps процес

ArgoCD автоматично синхронізується з Git репозиторієм. При зміні файлу `application.yaml` та коміті змін:

1. ArgoCD автоматично виявить зміни
2. Синхронізує конфігурацію з кластером
3. Оновить ресурси (Deployment, Service, Pod)

### Приклад роботи з GitOps

```bash
# Внести зміни в application.yaml
vim application.yaml

# Закомітити зміни
git add application.yaml
git commit -m "Update MLflow configuration"
git push origin main

# ArgoCD автоматично синхронізує зміни
# Kubernetes автоматично оновить поди
```

## Посилання

- **Git репозиторій**: https://github.com/Olekstar/goit-argo
- **ArgoCD документація**: https://argo-cd.readthedocs.io/
- **MLflow документація**: https://mlflow.org/docs/latest/index.html
- **Helm чарт MLflow**: https://artifacthub.io/packages/helm/community-charts/mlflow

## Troubleshooting

### Проблема: Под не запускається

```bash
kubectl describe pod <pod-name> -n application
kubectl logs <pod-name> -n application
```

### Проблема: ArgoCD не синхронізується

```bash
# Перевірити статус Application
kubectl get applications -n infra-tools

# Синхронізувати вручну через CLI
argocd login localhost:8080 --insecure
argocd app get mlflow
argocd app sync mlflow
```

### Проблема: Недостатньо пам'яті

Перевірте ресурси в `application.yaml`:
```yaml
resources:
  requests:
    cpu: 200m
    memory: 512Mi
  limits:
    cpu: 1000m
    memory: 1Gi
```