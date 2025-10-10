# GoIT ArgoCD Applications

Цей репозиторій містить ArgoCD Applications та конфігурації для автоматичного розгортання застосунків у Kubernetes кластері.

## Структура репозиторію

```
goit-argo/
├── namespaces/
│   ├── application/
│   │   └── ns.yaml          # Namespace для застосунків
│   └── infra-tools/
│       └── ns.yaml          # Namespace для інфраструктурних інструментів
├── application.yaml         # ArgoCD Application для MLflow
└── README.md               # Цей файл
```

## ArgoCD Applications

### MLflow

**Application Name:** `mlflow`  
**Namespace:** `application`  
**Chart:** MLflow Helm Chart  
**Repository:** https://community-charts.github.io/helm-charts

#### Особливості конфігурації:

- **Backend Store:** SQLite (для демонстрації)
- **Artifact Root:** `/mlflow/artifacts`
- **Service Type:** ClusterIP
- **Persistence:** 10Gi з storage class `gp2`
- **Resources:** 100m CPU, 256Mi Memory (requests)
- **Auto-sync:** Увімкнено з prune та self-heal

#### Доступ до MLflow:

1. **Через port-forward:**
   ```bash
   kubectl port-forward svc/mlflow 5000:5000 -n application
   ```
   Після цього MLflow буде доступний за адресою: http://localhost:5000

2. **Через LoadBalancer (якщо налаштовано):**
   ```bash
   kubectl get svc -n application
   ```

## Як використовувати

### 1. Підключення репозиторію до ArgoCD

1. Увійдіть в ArgoCD UI
2. Перейдіть до Settings → Repositories
3. Додайте новий репозиторій:
   - **Type:** Git
   - **Repository URL:** `https://github.com/Olekstar/goit-argo.git`
   - **Branch:** `main`

### 2. Створення Application

ArgoCD автоматично підхопить `application.yaml` з цього репозиторію та створить Application для MLflow.

### 3. Перевірка статусу

```bash
# Перевірити статус Application
kubectl get applications -n infra-tools

# Перевірити поди MLflow
kubectl get pods -n application

# Перевірити сервіси
kubectl get svc -n application
```

### 4. Доступ до MLflow UI

```bash
# Port-forward для доступу до MLflow
kubectl port-forward svc/mlflow 5000:5000 -n application
```

Після цього відкрийте браузер та перейдіть за адресою: http://localhost:5000

## Налаштування

### Зміна конфігурації MLflow

Для зміни конфігурації MLflow відредагуйте файл `application.yaml` у секції `spec.source.helm.values` та закомітьте зміни:

```bash
git add application.yaml
git commit -m "Update MLflow configuration"
git push origin main
```

ArgoCD автоматично синхронізує зміни та оновить деплой.

### Додавання нових Applications

Для додавання нових застосунків:

1. Створіть новий файл `application-<name>.yaml`
2. Додайте відповідні namespaces у директорію `namespaces/`
3. Закомітьте зміни

## Troubleshooting

### Перевірка логів ArgoCD

```bash
kubectl logs -n infra-tools deployment/argocd-application-controller
kubectl logs -n infra-tools deployment/argocd-server
```

### Перевірка логів MLflow

```bash
kubectl logs -n application deployment/mlflow
```

### Синхронізація Application вручну

```bash
kubectl patch application mlflow -n infra-tools --type merge -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"revision":"HEAD"}}}'
```

## Посилання

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [MLflow Documentation](https://mlflow.org/docs/latest/index.html)
- [Helm Charts](https://helm.sh/docs/)
