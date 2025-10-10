FROM python:3.9-slim

# Встановити MLflow
RUN pip install mlflow

# Створити директорію для MLflow
RUN mkdir -p /mlflow/artifacts

# Встановити робочу директорію
WORKDIR /mlflow

# Відкрити порт
EXPOSE 5000

# Команда за замовчуванням
CMD ["mlflow", "server", "--host=0.0.0.0", "--port=5000", "--backend-store-uri=sqlite:///mlflow.db", "--default-artifact-root=/mlflow/artifacts"]
