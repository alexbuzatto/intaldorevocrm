#!/bin/bash

set -e

export LANG=C.UTF-8
export LC_ALL=C.UTF-8

amarelo="\e[33m"
verde="\e[32m"
branco="\e[97m"
bege="\e[93m"
vermelho="\e[91m"
reset="\e[0m"

echo -e "$amarelo===================================================================================================\e[0m"
echo -e "$amarelo=                                                                                                 =\e[0m"
echo -e "$amarelo=                  INSTALADOR EVO CRM COMMUNITY - BASE SETUPORION                        =\e[0m"
echo -e "$amarelo=                                                                                                 =\e[0m"
echo -e "$amarelo===================================================================================================\e[0m"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

REPO_URL="https://raw.githubusercontent.com/alexbuzatto/intaldorevocrm/main"

echo "Verificando arquivos de configuracao..."

if [ ! -f "${SCRIPT_DIR}/portainer.yaml" ]; then
    echo "Baixando portainer.yaml..."
    curl -sSL "${REPO_URL}/portainer.yaml" -o "${SCRIPT_DIR}/portainer.yaml"
fi

if [ ! -f "${SCRIPT_DIR}/traefik.yaml" ]; then
    echo "Baixando traefik.yaml..."
    curl -sSL "${REPO_URL}/traefik.yaml" -o "${SCRIPT_DIR}/traefik.yaml"
fi

if [ ! -f "${SCRIPT_DIR}/n8n.yaml" ]; then
    echo "Baixando n8n.yaml..."
    curl -sSL "${REPO_URL}/n8n.yaml" -o "${SCRIPT_DIR}/n8n.yaml"
fi

if [ -f "${SCRIPT_DIR}/portainer.yaml" ]; then
    echo "Encontrado portainer.yaml, extraindo configuracoes..."
    NETWORK_NAME=$(grep 'networks:' ${SCRIPT_DIR}/portainer.yaml -A 1 | grep '    - ' | awk '{print $2}' | head -1)
    PORTAINER_DOMAIN=$(grep 'traefik.http.routers.portainer.rule' ${SCRIPT_DIR}/portainer.yaml | sed 's/.*Host(`//' | sed 's/`.*//' | tr -d ' ')
    echo "   Rede interna: ${NETWORK_NAME}"
    echo "   Dominio Portainer: ${PORTAINER_DOMAIN}"
    
    PORTAINER_URL=${PORTAINER_DOMAIN}
else
    echo -e "$vermelho portainer.yaml nao encontrado!$reset"
    exit 1
fi

if [ -f "${SCRIPT_DIR}/traefik.yaml" ]; then
    echo "Encontrado traefik.yaml, extraindo configuracoes..."
    TRAEFIK_DOMAIN=$(grep 'traefik.http.routers.traefik.rule' ${SCRIPT_DIR}/traefik.yaml | sed 's/.*Host(`//; s/`.*//' || echo "")
    TRAEFIK_EMAIL=$(grep 'acme.email' ${SCRIPT_DIR}/traefik.yaml | sed 's/.*acme.email=//; s/".*//' | head -1)
    echo "   Dominio Traefik: ${TRAEFIK_DOMAIN}"
    echo "   Email LetsEncrypt: ${TRAEFIK_EMAIL}"
fi

if [ -f "${SCRIPT_DIR}/n8n.yaml" ]; then
    echo "Encontrado n8n.yaml, extraindo senhas..."
    POSTGRES_PASSWORD=$(grep 'DB_POSTGRESDB_PASSWORD=' ${SCRIPT_DIR}/n8n.yaml | head -1 | sed 's/.*DB_POSTGRESDB_PASSWORD=//' | tr -d ' ')
    REDIS_PASSWORD=$(openssl rand -hex 16)
    echo "   Senha PostgreSQL: ${POSTGRES_PASSWORD}"
    echo "   Senha Redis: [Gerada automaticamente]"
else
    echo "n8n.yaml nao encontrado, gerando senhas..."
    read -p "Senha do PostgreSQL: " POSTGRES_PASSWORD
    read -p "Senha do Redis: " REDIS_PASSWORD
fi

echo ""
echo -e "$amarelo===================================================================================================\e[0m"
echo -e "$amarelo=                          Dominios                            $amarelo=\e[0m"
echo -e "$amarelo===================================================================================================\e[0m"

read -p "Dominio principal (API): " API_DOMAIN
read -p "Dominio do Frontend: " FRONTEND_DOMAIN

echo ""
echo -e "$amarelo===================================================================================================\e[0m"
echo -e "$amarelo=                          Dados do Administrador                            $amarelo=\e[0m"
echo -e "$amarelo===================================================================================================\e[0m"

read -p "Email do administrador: " ADMIN_EMAIL
read -p "Nome do administrador: " ADMIN_NAME
read -p "Senha do administrador (minimo 8 caracteres): " ADMIN_PASSWORD
echo ""
read -p "Nome da organizacao: " ORGANIZATION_NAME

echo ""
echo -e "$amarelo===================================================================================================\e[0m"
echo -e "$amarelo=                          $branco Gerando chaves de segurança...                            $amarelo=\e[0m"
echo -e "$amarelo===================================================================================================\e[0m"

SECRET_KEY_BASE=$(openssl rand -hex 64)
JWT_SECRET_KEY=$(openssl rand -hex 64)
DOORKEEPER_JWT_SECRET_KEY=$(openssl rand -hex 64)
EVOAI_CRM_API_TOKEN=$(openssl rand -hex 16)
BOT_RUNTIME_SECRET=$(openssl rand -hex 16)
ENCRYPTION_KEY=$(python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())" 2>/dev/null || openssl rand -base64 32)

echo ""
echo -e "$amarelo===================================================================================================\e[0m"
echo -e "$amarelo=                          $branco Baixando repositório...                            $amarelo=\e[0m"
echo -e "$amarelo===================================================================================================\e[0m"

if [ ! -d "evo-crm-community" ]; then
    echo "Clonando repositorio principal..."
    git config --global url."https://github.com/".insteadOf "git@github.com:"
    git clone --recurse-submodules https://github.com/EvolutionAPI/evo-crm-community.git evo-crm-community
    cd evo-crm-community
    git submodule update --init --recursive
    cd ..
else
    echo "Repositorio ja existe. Removendo para clone limpo..."
    rm -rf evo-crm-community
    echo "Clonando repositorio principal..."
    git config --global url."https://github.com/".insteadOf "git@github.com:"
    git clone --recurse-submodules https://github.com/EvolutionAPI/evo-crm-community.git evo-crm-community
    cd evo-crm-community
    git submodule update --init --recursive
    cd ..
fi

echo ""
echo -e "$amarelo===================================================================================================\e[0m"
echo -e "$amarelo=                          $branco Criando arquivos de configuração...                            $amarelo=\e[0m"
echo -e "$amarelo===================================================================================================\e[0m"

mkdir -p "evo-crm-stack"
cp -r evo-crm-community/evo-auth-service-community evo-crm-stack/
cp -r evo-crm-community/evo-ai-crm-community evo-crm-stack/
cp -r evo-crm-community/evo-ai-core-service-community evo-crm-stack/
cp -r evo-crm-community/evo-ai-processor-community evo-crm-stack/
cp -r evo-crm-community/evo-bot-runtime evo-crm-stack/
cp -r evo-crm-community/evo-ai-frontend-community evo-crm-stack/

cat > evo-crm-stack/.env <<EOF
# =============================================================================
# EVO CRM Community - Configuração Gerada
# =============================================================================

# =============================================================================
# DOMAINS
# =============================================================================
API_DOMAIN=${API_DOMAIN}
FRONTEND_DOMAIN=${FRONTEND_DOMAIN}

# =============================================================================
# SHARED SECRETS
# =============================================================================
SECRET_KEY_BASE=${SECRET_KEY_BASE}
JWT_SECRET_KEY=${JWT_SECRET_KEY}
DOORKEEPER_JWT_SECRET_KEY=${DOORKEEPER_JWT_SECRET_KEY}
EVOAI_CRM_API_TOKEN=${EVOAI_CRM_API_TOKEN}
BOT_RUNTIME_SECRET=${BOT_RUNTIME_SECRET}
ENCRYPTION_KEY=${ENCRYPTION_KEY}

# =============================================================================
# DATABASE (PostgreSQL)
# =============================================================================
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_USERNAME=postgres
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
POSTGRES_DATABASE=evo_community

# =============================================================================
# REDIS
# =============================================================================
REDIS_URL=redis://:${REDIS_PASSWORD}@redis:6379/0
REDIS_PASSWORD=${REDIS_PASSWORD}
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_DB=0
REDIS_SSL=false

PROCESSOR_REDIS_HOST=redis
PROCESSOR_REDIS_PORT=6379
PROCESSOR_REDIS_PASSWORD=${REDIS_PASSWORD}
PROCESSOR_REDIS_DB=0

PROCESSOR_POSTGRES_CONNECTION_STRING=postgresql://postgres:${POSTGRES_PASSWORD}@postgres:5432/evo_community

# =============================================================================
# CORE SERVICE
# =============================================================================
DB_HOST=postgres
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=${POSTGRES_PASSWORD}
DB_NAME=evo_community
DB_SSLMODE=disable
DB_MAX_IDLE_CONNS=10
DB_MAX_OPEN_CONNS=100
DB_CONN_MAX_LIFETIME=1h
DB_CONN_MAX_IDLE_TIME=30m

# =============================================================================
# EMAIL (SMTP)
# =============================================================================
MAILER_SENDER_EMAIL=noreply@${FRONTEND_DOMAIN}
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_DOMAIN=${FRONTEND_DOMAIN}
SMTP_AUTHENTICATION=plain
SMTP_ENABLE_STARTTLS_AUTO=true
SMTP_USERNAME=
SMTP_PASSWORD=
SMTP_ENABLE_STARTTLS_AUTO=true
SMTP_USERNAME=
SMTP_PASSWORD=

# =============================================================================
# ADMIN SEED
# =============================================================================
ADMIN_EMAIL=${ADMIN_EMAIL}
ADMIN_PASSWORD=${ADMIN_PASSWORD}
ADMIN_NAME=${ADMIN_NAME}
ORGANIZATION_NAME=${ORGANIZATION_NAME}
SEED_ADMIN_EMAIL=${ADMIN_EMAIL}
SEED_ADMIN_PASSWORD=${ADMIN_PASSWORD}
SEED_ADMIN_NAME=${ADMIN_NAME}
SEED_ORGANIZATION_NAME=${ORGANIZATION_NAME}

# =============================================================================
# AUTH SERVICE
# =============================================================================
RAILS_ENV=production
RAILS_MAX_THREADS=5
FRONTEND_URL=https://${FRONTEND_DOMAIN}
MFA_ISSUER=EvoCRM
SIDEKIQ_CONCURRENCY=10
ACTIVE_STORAGE_SERVICE=local
DOORKEEPER_JWT_SECRET_KEY=${DOORKEEPER_JWT_SECRET_KEY}
DOORKEEPER_JWT_ALGORITHM=hs256
DOORKEEPER_JWT_ISS=evo-auth-service

# =============================================================================
# CRM SERVICE
# =============================================================================
BACKEND_URL=https://${API_DOMAIN}
EVO_AI_CORE_SERVICE_URL=http://evo-core:5555
EVO_AUTH_SERVICE_URL=http://evo-auth:3001
CORS_ORIGINS=https://${FRONTEND_DOMAIN},https://${API_DOMAIN}
DISABLE_TELEMETRY=true
RAILS_LOG_TO_STDOUT=true
LOG_LEVEL=info
LOG_SIZE=500
ENABLE_ACCOUNT_SIGNUP=true
ENABLE_PUSH_RELAY_SERVER=true
ENABLE_INBOX_EVENTS=true

# =============================================================================
# CORE SERVICE
# =============================================================================
JWT_ALGORITHM=HS256
EVOLUTION_BASE_URL=http://evo-crm:3000
EVO_AUTH_BASE_URL=http://evo-auth:3001
AI_PROCESSOR_URL=http://evo-processor:8000

# =============================================================================
# PROCESSOR SERVICE
# =============================================================================
API_TITLE=Agent Processor Community
API_DESCRIPTION=Agent Processor Community for Evo CRM
API_VERSION=1.0.0
API_URL=http://localhost:8000
ORGANIZATION_URL=https://${FRONTEND_DOMAIN}
POSTGRES_CONNECTION_STRING=postgresql://postgres:${POSTGRES_PASSWORD}@postgres:5432/evo_community
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=${REDIS_PASSWORD}
REDIS_DB=0
REDIS_SSL=false
REDIS_KEY_PREFIX=a2a:
REDIS_TTL=3600
TOOLS_CACHE_ENABLED=true
TOOLS_CACHE_TTL=3600
EVO_AI_CRM_URL=http://evo-crm:3000
HOST=0.0.0.0
PORT=8000
DEBUG=false
CORE_SERVICE_URL=http://evo-core:5555/api/v1
APP_URL=https://${API_DOMAIN}

# =============================================================================
# BOT RUNTIME
# =============================================================================
LISTEN_ADDR=0.0.0.0:8080
BOT_RUNTIME_SECRET=${BOT_RUNTIME_SECRET}
AI_PROCESSOR_API_KEY=${EVOAI_CRM_API_TOKEN}
AI_CALL_TIMEOUT_SECONDS=30
BOT_RUNTIME_URL=http://evo-bot-runtime:8080
BOT_RUNTIME_POSTBACK_BASE_URL=http://evo-crm:3000

# =============================================================================
# FRONTEND
# =============================================================================
VITE_APP_ENV=production
VITE_API_URL=https://${API_DOMAIN}
VITE_AUTH_API_URL=https://${API_DOMAIN}
VITE_EVOAI_API_URL=https://${API_DOMAIN}
VITE_AGENT_PROCESSOR_URL=https://${API_DOMAIN}
EOF

cat > evo-crm-stack/docker-compose.yaml <<EOF
version: "3.8"

services:
  postgres:
    image: pgvector/pgvector:pg16
    restart: unless-stopped
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: evo_community
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    networks:
      - ${NETWORK_NAME}
    deploy:
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: 1
          memory: 1024M
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 10

  redis:
    image: redis:alpine
    restart: unless-stopped
    command: ["sh", "-c", "redis-server --requirepass ${REDIS_PASSWORD} --appendonly yes"]
    volumes:
      - redis_data:/data
    networks:
      - ${NETWORK_NAME}
    deploy:
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: 0.5
          memory: 512M

  evo-auth:
    build:
      context: ./evo-auth-service-community
      dockerfile: Dockerfile
    restart: unless-stopped
    env_file: .env
    environment:
      RAILS_ENV: production
      REDIS_URL: redis://:${REDIS_PASSWORD}@redis:6379/1
      POSTGRES_HOST: postgres
    networks:
      - ${NETWORK_NAME}
    volumes:
      - evo_auth_uploads:/app/public/uploads
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_started
    deploy:
      placement:
        constraints:
          - node.role == manager
      replicas: 1
      resources:
        limits:
          cpus: 1
          memory: 1024M
      labels:
        - traefik.enable=true
        - traefik.http.routers.evo-auth.rule=Host(\`${API_DOMAIN}\`) && PathPrefix(\`/auth\`)
        - traefik.http.routers.evo-auth.entrypoints=websecure
        - traefik.http.routers.evo-auth.tls.certresolver=letsencryptresolver
        - traefik.http.routers.evo-auth.service=evo-auth
        - traefik.http.services.evo-auth.loadbalancer.server.port=3001
        - traefik.http.middlewares.evo-auth-stripprefix.stripprefix.forceSlash=false
        - traefik.http.routers.evo-auth.middlewares=evo-auth-stripprefix

  evo-auth-sidekiq:
    build:
      context: ./evo-auth-service-community
      dockerfile: Dockerfile
    restart: unless-stopped
    env_file: .env
    environment:
      RAILS_ENV: production
      REDIS_URL: redis://:${REDIS_PASSWORD}@redis:6379/1
      POSTGRES_HOST: postgres
    networks:
      - ${NETWORK_NAME}
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_started
    command: sidekiq
    deploy:
      placement:
        constraints:
          - node.role == manager
      replicas: 1

  evo-crm:
    build:
      context: ./evo-ai-crm-community
      dockerfile: docker/Dockerfile
    restart: unless-stopped
    env_file: .env
    environment:
      RAILS_ENV: production
      REDIS_URL: redis://:${REDIS_PASSWORD}@redis:6379/0
      POSTGRES_HOST: postgres
      EVO_AUTH_SERVICE_URL: http://evo-auth:3001
      EVO_AI_CORE_SERVICE_URL: http://evo-core:5555
      BOT_RUNTIME_URL: http://evo-bot-runtime:8080
      BOT_RUNTIME_SECRET: ${BOT_RUNTIME_SECRET}
      BOT_RUNTIME_POSTBACK_BASE_URL: http://evo-crm:3000
    networks:
      - ${NETWORK_NAME}
    volumes:
      - evo_crm_uploads:/app/public/uploads
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_started
      evo-auth:
        condition: service_started
    deploy:
      placement:
        constraints:
          - node.role == manager
      replicas: 1
      resources:
        limits:
          cpus: 1
          memory: 1024M
      labels:
        - traefik.enable=true
        - traefik.http.routers.evo-crm.rule=Host(\`${API_DOMAIN}\`) && PathPrefix(\`/api\`)
        - traefik.http.routers.evo-crm.entrypoints=websecure
        - traefik.http.routers.evo-crm.tls.certresolver=letsencryptresolver
        - traefik.http.routers.evo-crm.service=evo-crm
        - traefik.http.services.evo-crm.loadbalancer.server.port=3000

  evo-crm-sidekiq:
    build:
      context: ./evo-ai-crm-community
      dockerfile: docker/Dockerfile
    restart: unless-stopped
    env_file: .env
    environment:
      RAILS_ENV: production
      REDIS_URL: redis://:${REDIS_PASSWORD}@redis:6379/0
      POSTGRES_HOST: postgres
      EVO_AUTH_SERVICE_URL: http://evo-auth:3001
      EVO_AI_CORE_SERVICE_URL: http://evo-core:5555
      BOT_RUNTIME_URL: http://evo-bot-runtime:8080
      BOT_RUNTIME_SECRET: ${BOT_RUNTIME_SECRET}
      BOT_RUNTIME_POSTBACK_BASE_URL: http://evo-crm:3000
    networks:
      - ${NETWORK_NAME}
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_started
    command: bundle exec sidekiq -C config/sidekiq.yml
    deploy:
      placement:
        constraints:
          - node.role == manager
      replicas: 1

  evo-core:
    build:
      context: ./evo-ai-core-service-community
      dockerfile: Dockerfile
    restart: unless-stopped
    env_file: .env
    environment:
      DB_HOST: postgres
      DB_PORT: "5432"
      DB_USER: postgres
      DB_PASSWORD: ${POSTGRES_PASSWORD}
      DB_NAME: evo_community
      DB_SSLMODE: disable
      PORT: "5555"
      EVOLUTION_BASE_URL: http://evo-crm:3000
      EVO_AUTH_BASE_URL: http://evo-auth:3001
      AI_PROCESSOR_URL: http://evo-processor:8000
    networks:
      - ${NETWORK_NAME}
    depends_on:
      postgres:
        condition: service_healthy
    deploy:
      placement:
        constraints:
          - node.role == manager
      replicas: 1
      resources:
        limits:
          cpus: 1
          memory: 512M

  evo-processor:
    build:
      context: ./evo-ai-processor-community
      dockerfile: Dockerfile
    restart: unless-stopped
    env_file: .env
    environment:
      POSTGRES_CONNECTION_STRING: postgresql://postgres:${POSTGRES_PASSWORD}@postgres:5432/evo_community
      REDIS_HOST: redis
      REDIS_PORT: "6379"
      REDIS_PASSWORD: ${REDIS_PASSWORD}
      REDIS_SSL: "false"
      HOST: 0.0.0.0
      PORT: "8000"
      EVO_AI_CRM_URL: http://evo-crm:3000
      CORE_SERVICE_URL: http://evo-core:5555/api/v1
    networks:
      - ${NETWORK_NAME}
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_started
    deploy:
      placement:
        constraints:
          - node.role == manager
      replicas: 1
      resources:
        limits:
          cpus: 1
          memory: 1024M

  evo-bot-runtime:
    build:
      context: ./evo-bot-runtime
      dockerfile: Dockerfile
    restart: unless-stopped
    env_file: .env
    environment:
      LISTEN_ADDR: 0.0.0.0:8080
      REDIS_URL: redis://:${REDIS_PASSWORD}@redis:6379
      AI_PROCESSOR_URL: http://evo-processor:8000
      BOT_RUNTIME_SECRET: ${BOT_RUNTIME_SECRET}
    networks:
      - ${NETWORK_NAME}
    depends_on:
      redis:
        condition: service_started
      evo-processor:
        condition: service_started
    deploy:
      placement:
        constraints:
          - node.role == manager
      replicas: 1
      resources:
        limits:
          cpus: 0.5
          memory: 512M

  evo-frontend:
    build:
      context: ./evo-ai-frontend-community
      dockerfile: Dockerfile
    restart: unless-stopped
    env_file: .env
    environment:
      VITE_API_URL: https://${API_DOMAIN}
      VITE_AUTH_API_URL: https://${API_DOMAIN}
      VITE_WS_URL: https://${API_DOMAIN}
      VITE_EVOAI_API_URL: https://${API_DOMAIN}
      VITE_AGENT_PROCESSOR_URL: https://${API_DOMAIN}
    networks:
      - ${NETWORK_NAME}
    depends_on:
      evo-auth:
        condition: service_started
      evo-crm:
        condition: service_started
    deploy:
      placement:
        constraints:
          - node.role == manager
      replicas: 1
      resources:
        limits:
          cpus: 0.5
          memory: 256M
      labels:
        - traefik.enable=true
        - traefik.http.routers.evo-frontend.rule=Host(\`${FRONTEND_DOMAIN}\`)
        - traefik.http.routers.evo-frontend.entrypoints=websecure
        - traefik.http.routers.evo-frontend.tls.certresolver=letsencryptresolver
        - traefik.http.routers.evo-frontend.service=evo-frontend
        - traefik.http.services.evo-frontend.loadbalancer.server.port=80

volumes:
  postgres_data:
  redis_data:
  evo_auth_uploads:
  evo_crm_uploads:

networks:
  ${NETWORK_NAME}:
    driver: overlay
    attachable: true
    ipam:
      config:
        - subnet: 10.10.0.0/16
EOF

cd evo-crm-stack

echo ""
echo -e "$amarelo===================================================================================================\e[0m"
echo -e "$amarelo=                          $branco Autenticando no Portainer...                            $amarelo=\e[0m"
echo -e "$amarelo===================================================================================================\e[0m"

echo "Tentando autenticar em: https://${PORTAINER_URL}/api/auth"

auth_response=$(curl -k -s -X POST "https://${PORTAINER_URL}/api/auth" \
    -H "Content-Type: application/json" \
    -d "{\"username\":\"${PORTAINER_USER}\",\"password\":\"${PORTAINER_PASS}\"}")

echo "Resposta: ${auth_response}"

token=$(echo "${auth_response}" | jq -r '.jwt' 2>/dev/null)

if [ "$token" = "null" ] || [ -z "$token" ] || [ "$token" = "." ]; then
    echo ""
    echo "Erro na autenticacao. Tentando formato alternativo..."
    
    auth_response=$(curl -k -s -X POST "https://${PORTAINER_URL}/api/auth" \
        -H "Content-Type: application/json" \
        -d "{\"username\":\"${PORTAINER_USER}\",\"password\":\"${PORTAINER_PASS}\"}")
    
    token=$(echo "${auth_response}" | jq -r '.jwt' 2>/dev/null)
    
    if [ "$token" = "null" ] || [ -z "$token" ]; then
        echo -e "$vermelho Erro ao autenticar no Portainer! Verifique as credenciais.$reset"
        echo "Usuario usado: ${PORTAINER_USER}"
        echo "Resposta completa: ${auth_response}"
        exit 1
    fi
fi

echo -e "$verde Autenticado com sucesso!$reset"

echo ""
echo -e "$amarelo===================================================================================================\e[0m"
echo -e "$amarelo=                          $branco Criando stack no Portainer...                            $amarelo=\e[0m"
echo -e "$amarelo===================================================================================================\e[0m"

stack_name="evo_crm"

endpoint_id=1

response=$(curl -k -s -X POST "https://${PORTAINER_URL}/api/stacks/create/swarm/file" \
    -H "Authorization: Bearer ${token}" \
    -H "Content-Type: application/json" \
    -d "{
        \"name\": \"${stack_name}\",
        \"endpointId\": ${endpoint_id},
        \"composeFile\": \"docker-compose.yaml\",
        \"env\": [
            {\"name\": \"NETWORK_NAME\", \"value\": \"${NETWORK_NAME}\"},
            {\"name\": \"POSTGRES_PASSWORD\", \"value\": \"${POSTGRES_PASSWORD}\"},
            {\"name\": \"REDIS_PASSWORD\", \"value\": \"${REDIS_PASSWORD}\"},
            {\"name\": \"API_DOMAIN\", \"value\": \"${API_DOMAIN}\"},
            {\"name\": \"FRONTEND_DOMAIN\", \"value\": \"${FRONTEND_DOMAIN}\"},
            {\"name\": \"ADMIN_EMAIL\", \"value\": \"${ADMIN_EMAIL}\"},
            {\"name\": \"ADMIN_NAME\", \"value\": \"${ADMIN_NAME}\"},
            {\"name\": \"ADMIN_PASSWORD\", \"value\": \"${ADMIN_PASSWORD}\"},
            {\"name\": \"ORGANIZATION_NAME\", \"value\": \"${ORGANIZATION_NAME}\"},
            {\"name\": \"BOT_RUNTIME_SECRET\", \"value\": \"${BOT_RUNTIME_SECRET}\"},
            {\"name\": \"SECRET_KEY_BASE\", \"value\": \"${SECRET_KEY_BASE}\"},
            {\"name\": \"JWT_SECRET_KEY\", \"value\": \"${JWT_SECRET_KEY}\"},
            {\"name\": \"DOORKEEPER_JWT_SECRET_KEY\", \"value\": \"${DOORKEEPER_JWT_SECRET_KEY}\"},
            {\"name\": \"EVOAI_CRM_API_TOKEN\", \"value\": \"${EVOAI_CRM_API_TOKEN}\"},
            {\"name\": \"ENCRYPTION_KEY\", \"value\": \"${ENCRYPTION_KEY}\"}
        ]
    }")

if echo "$response" | grep -q "id"; then
    echo -e "$verde Stack criada com sucesso!$reset"
else
    echo -e "$vermelho Erro ao criar stack: $response$reset"
    exit 1
fi

echo ""
echo "==================================================================================================="
echo "                           INSTALACAO CONCLUIDA COM SUCESSO!"
echo "==================================================================================================="
echo ""
echo "ACESSO AO EVO CRM:"
echo "  Frontend:  https://${FRONTEND_DOMAIN}"
echo "  API:       https://${API_DOMAIN}"
echo ""
echo "CREDENCIAIS DO ADMINISTRADOR:"
echo "  Email:     ${ADMIN_EMAIL}"
echo "  Senha:     ${ADMIN_PASSWORD}"
echo "  Organizacao: ${ORGANIZATION_NAME}"
echo ""
echo "ACESSO AO PORTAINER:"
echo "  URL:       https://${PORTAINER_URL}"
echo "  Usuario:   ${PORTAINER_USER}"
echo "  Senha:     ${PORTAINER_PASS}"
echo ""
echo "INFORMACOES DO SERVIDOR:"
echo "  Rede Interna: ${NETWORK_NAME}"
echo "  PostgreSQL:   postgres / ${POSTGRES_PASSWORD}"
echo "  Redis:        ${REDIS_PASSWORD}"
echo ""
echo -e "$amarelo===================================================================================================\e[0m"
echo -e "$amarelo=                          Credenciais do Portainer                            $amarelo=\e[0m"
echo -e "$amarelo===================================================================================================\e[0m"

echo "Url do Portainer: https://${PORTAINER_URL}"

read -p "Usuario do Portainer: " PORTAINER_USER
read -p "Senha do Portainer: " PORTAINER_PASS
echo ""