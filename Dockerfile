# Stage 1: "builder" - Instala dependências em um ambiente temporário
# Usamos uma imagem slim estável para começar.
FROM python:3.11-slim-bullseye AS builder

# Define o diretório de trabalho
WORKDIR /app

# Define variáveis de ambiente para otimizar a build
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Cria um ambiente virtual para isolar as dependências
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copia e instala as dependências. Isso aproveita o cache do Docker,
# pois as dependências não mudam com tanta frequência quanto o código.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: "final" - Cria a imagem de produção final
FROM python:3.11-slim-bullseye

WORKDIR /app

# Copia o ambiente virtual com as dependências da stage "builder"
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copia o código da aplicação
COPY . .

# Expõe a porta em que o Uvicorn irá rodar
EXPOSE 8000

# Comando para iniciar a aplicação FastAPI com Uvicorn
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
