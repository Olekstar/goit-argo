# Lesson 7-8: EKS + ArgoCD Infrastructure

Цей репозиторій містить Terraform конфігурації для розгортання EKS кластера та ArgoCD у AWS.

## Структура проєкту

```
lesson-7/
├── vpc/                    # VPC інфраструктура
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tf
│   ├── backend.tf
│   └── terraform.tfvars
├── eks/                    # EKS кластер
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── data.tf
│   ├── terraform.tf
│   └── backend.tf
├── argocd/                 # ArgoCD розгортання
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tf
│   ├── backend.tf
│   └── values/
│       └── argocd-values.yaml
├── main.tf                 # Root модуль
├── variables.tf
├── outputs.tf
├── terraform.tf
├── backend.tf
└── README.md
```

## Передумови

1. **AWS CLI** налаштований з відповідними credentials
2. **Terraform** версії >= 1.0
3. **kubectl** встановлений
4. **helm** встановлений

## Розгортання інфраструктури

### Крок 1: Розгортання VPC

```bash
cd vpc
terraform init
terraform plan
terraform apply
```

### Крок 2: Розгортання EKS кластера

```bash
cd ../eks
terraform init
terraform plan
terraform apply
```

### Крок 3: Налаштування kubectl

```bash
# Отримати конфігурацію для kubectl
aws eks update-kubeconfig --region us-east-1 --name goit-eks-cluster

# Перевірити підключення
kubectl get nodes
```

### Крок 4: Розгортання ArgoCD

```bash
cd ../argocd
terraform init
terraform plan
terraform apply
```

## Доступ до ArgoCD

### Отримання паролю адміністратора

```bash
# Отримати пароль адміністратора
kubectl -n infra-tools get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

### Доступ через port-forward

```bash
# Port-forward для ArgoCD Server (HTTP)
kubectl port-forward svc/argocd-server -n infra-tools 8080:80
```

### Вхід в ArgoCD UI

1. Відкрийте браузер та перейдіть за адресою: http://localhost:8080
2. Логін: `admin`
3. Пароль: (отриманий на попередньому кроці)

## Підключення Git репозиторію

### Додавання репозиторію в ArgoCD

1. У ArgoCD UI перейдіть до **Settings** → **Repositories**
2. Натисніть **Connect Repo**
3. Заповніть форму:
   - **Type:** Git
   - **Repository URL:** `https://github.com/Olekstar/goit-argo.git`
   - **Branch:** `main`

### Створення Application

ArgoCD автоматично підхопить `application.yaml` з репозиторію `goit-argo` та створить Application для MLflow.

## Перевірка розгортання

### Перевірка ArgoCD

```bash
# Перевірити поди ArgoCD
kubectl get pods -n infra-tools

# Перевірити сервіси ArgoCD
kubectl get svc -n infra-tools

# Перевірити Applications
kubectl get applications -n infra-tools
```

### Перевірка MLflow

```bash
# Перевірити поди MLflow
kubectl get pods -n application

# Перевірити сервіси MLflow
kubectl get svc -n application

# Доступ до MLflow через port-forward
kubectl port-forward svc/mlflow 5000:80 -n application
```

Після цього MLflow буде доступний за адресою: http://localhost:5000

## Видалення інфраструктури

⚠️ **УВАГА!** Видалення інфраструктури призведе до втрати всіх даних.

### Видалення в зворотному порядку

```bash
# Видалити ArgoCD
cd argocd
terraform destroy

# Видалити EKS
cd ../eks
terraform destroy

# Видалити VPC
cd ../vpc
terraform destroy
```

## Troubleshooting

### Проблеми з ArgoCD

```bash
# Перевірити логи ArgoCD Server
kubectl logs -n infra-tools deployment/argocd-server

# Перевірити логи ArgoCD Application Controller
kubectl logs -n infra-tools deployment/argocd-application-controller

# Перевірити статус ArgoCD
kubectl get pods -n infra-tools
```

### Проблеми з MLflow

```bash
# Перевірити логи MLflow
kubectl logs -n application deployment/mlflow

# Перевірити статус Application в ArgoCD
kubectl describe application mlflow -n infra-tools
```

### Проблеми з доступом

```bash
# Перевірити RBAC
kubectl auth can-i get pods --as=system:serviceaccount:infra-tools:argocd-application-controller

# Перевірити network policies
kubectl get networkpolicies -A
```

## Корисні команди

### ArgoCD CLI (опціонально)

```bash
# Встановити ArgoCD CLI
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

# Логін в ArgoCD через CLI
argocd login localhost:8080 --insecure

# Список Applications
argocd app list

# Синхронізація Application
argocd app sync mlflow
```

## Посилання

- [EKS Documentation](https://docs.aws.amazon.com/eks/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [MLflow Documentation](https://mlflow.org/docs/latest/index.html)

## Git репозиторії

- **lesson-7:** https://github.com/Olekstar/lesson-7 (інфраструктура)
- **goit-argo:** https://github.com/Olekstar/goit-argo (Applications)