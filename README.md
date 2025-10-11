# GoIT ArgoCD MLflow Deployment

Цей репозиторій містить конфігурацію для автоматичного розгортання MLflow через ArgoCD з використанням готового Helm чарта з ArtifactHub.

## Поточний стан ArgoCD ✅

**ArgoCD успішно розгорнутий та працює:**
- ✅ Application Controller - працює
- ✅ ApplicationSet Controller - працює  
- ✅ Redis - працює (проблему вирішено)
- ✅ Repo Server - працює
- ✅ Server - працює

**Доступ до ArgoCD:**
- URL: http://localhost:8080 (після port-forward)
- Логін: `admin`
- Пароль: `-2zH4k-oMnYZ8otF`

**Швидкий старт:**
```bash
# Перевірити стан ArgoCD
kubectl get pods -n infra-tools

# Запустити port-forward
kubectl port-forward svc/argocd-server -n infra-tools 8080:80
```

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

**Структура відповідає вимогам:**
- ✅ Основні файли: namespaces/, README.md
- ✅ ArgoCD Application: application.yaml
- ✅ Namespaces: application, infra-tools
- ✅ Додаткові ресурси: nginx.yaml

## Особливості

- ✅ Використовує готовий Helm-чарт `mlflow` з `community-charts`
- ✅ Образ: `burakince/mlflow:3.4.0`
- ✅ Ресурси: CPU 400m/2000m, Memory 1Gi/2Gi (GitOps v5.0)
- ✅ Автоматична синхронізація через GitOps
- ✅ Inline values в ArgoCD Application (Варіант A)
- ✅ Доступ через kubectl port-forward

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

#### Варіант A: kubectl port-forward (рекомендовано)

```bash
# Запустити port-forward в фоновому режимі
kubectl port-forward svc/mlflow -n application 5000:80 > /dev/null 2>&1 &

# Перевірити доступ
curl http://localhost:5000/health
# Має повернути: OK
```

**Відкрийте браузер і перейдіть на:** http://localhost:5000

#### Варіант B: LoadBalancer (для продакшену)

```bash
# Оновити сервіс на LoadBalancer
kubectl patch svc mlflow -n application -p '{"spec":{"type":"LoadBalancer"}}'

# Отримати зовнішній IP
kubectl get svc mlflow -n application
```

**Примітка:** LoadBalancer створює зовнішній IP, але може коштувати додатково в AWS.

## GitOps процес

### Як оновити MLflow через Git

1. **Відредагуйте `application.yaml`:**
   ```yaml
   helm:
     values: |
       # Змініть ресурси або інші параметри
       resources:
         requests:
           cpu: 500m
           memory: 1.5Gi
   ```

2. **Закомітьте зміни:**
   ```bash
   git add application.yaml
   git commit -m "Update MLflow resources"
   git push origin main
   ```

3. **ArgoCD автоматично синхронізує:**
   ```bash
   # Перевірити статус
   kubectl get applications -n infra-tools
   
   # Перевірити поди
   kubectl get pods -n application
   ```

### Перевірка GitOps

```bash
# Перевірити історію синхронізації
argocd app history mlflow

# Перевірити поточний стан
argocd app get mlflow
```

## Посилання на репозиторії

- **Infrastructure (Terraform)**: https://github.com/Olekstar/lesson-7.git
- **GitOps (ArgoCD Applications)**: https://github.com/Olekstar/goit-argo.git
- **ArgoCD Application**: https://github.com/Olekstar/goit-argo/blob/main/application.yaml

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

### Проблема з Redis ArgoCD (ВИРІШЕНО ✅)

**Симптоми:**
- Redis под має статус `CreateContainerConfigError`
- Помилка: `secret "argocd-redis" not found`

**Рішення:**
```bash
# Створити секрет для Redis
kubectl create secret generic argocd-redis --from-literal=auth=redis-password -n infra-tools

# Видалити проблемний Redis под для перезапуску
kubectl delete pod <redis-pod-name> -n infra-tools

# Перевірити, що новий под запустився
kubectl get pods -n infra-tools
```

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