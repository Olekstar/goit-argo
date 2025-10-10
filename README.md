# GoIT ArgoCD MLflow Deployment

Цей репозиторій містить конфігурацію для автоматичного розгортання MLflow через ArgoCD з використанням Helm чарта.

## Структура проекту

```
goit-argo/
├── namespaces/
│   ├── application/
│   │   ├── nginx.yaml
│   │   └── ns.yaml
│   └── infra-tools/
│     └── ns.yaml
├── application.yaml
└── README.md
```

## Як запустити Terraform

### 1. Ініціалізація Terraform

```bash
cd lesson-7/argocd
terraform init
```

### 2. Застосування конфігурації

```bash
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
- argocd-dex-server
- argocd-redis
- argocd-application-controller

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
kubectl port-forward svc/mlflow -n application 8081:80
```

### 2. Веб-інтерфейс MLflow

Відкрийте браузер і перейдіть на: http://localhost:8081

## Автоматичне розгортання

ArgoCD автоматично синхронізується з Git репозиторієм. При зміні файлу `application.yaml` та коміті змін:

1. ArgoCD автоматично виявить зміни
2. Синхронізує конфігурацію з кластером
3. Оновить ресурси (Deployment, Service, Pod)

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