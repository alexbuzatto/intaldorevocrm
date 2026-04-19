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

echo "==================================================================================================="
echo "                           INSTALADOR EVO CRM COMMUNITY"
echo "==================================================================================================="
echo ""

echo "==================================================================================================="
echo "                          Credenciais do Portainer"
echo "==================================================================================================="

read -p "Url do Portainer (ex: painel.eclicksolucoes.com.br): " PORTAINER_URL
read -p "Usuario do Portainer: " PORTAINER_USER
read -p "Senha do Portainer: " PORTAINER_PASS
echo ""

echo "==================================================================================================="
echo "                          Configuracoes do Banco de Dados"
echo "==================================================================================================="

read -p "Nome da rede interna (ex: eclick): " NETWORK_NAME
read -p "Senha do PostgreSQL: " POSTGRES_PASSWORD
read -p "Senha do Redis (ENTER=sem senha): " REDIS_INPUT
if [ -z "$REDIS_INPUT" ]; then
    REDIS_PASSWORD=""
else
    REDIS_PASSWORD=$REDIS_INPUT
fi

echo ""
echo "==================================================================================================="
echo "                          Dominios"
echo "==================================================================================================="

read -p "Dominio principal (API): " API_DOMAIN
read -p "Dominio do Frontend: " FRONTEND_DOMAIN

echo ""
echo "==================================================================================================="
echo "                          Dados do Administrador"
echo "==================================================================================================="

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
rm -f evo-crm-stack/.env
cp -r evo-crm-community/evo-auth-service-community evo-crm-stack/
cp -r evo-crm-community/evo-ai-crm-community evo-crm-stack/
cp -r evo-crm-community/evo-ai-core-service-community evo-crm-stack/
cp -r evo-crm-community/evo-ai-processor-community evo-crm-stack/
cp -r evo-crm-community/evo-bot-runtime evo-crm-stack/
cp -r evo-crm-community/evo-ai-frontend-community evo-crm-stack/

# Define variáveis do Redis para uso no compose
if [ -z "$REDIS_PASSWORD" ]; then
    REDIS_URL_EVO_AUTH="redis://redis:6379/1"
    REDIS_URL_EVO_CRM="redis://redis:6379/0"
    REDIS_URL_EVO_BOT="redis://redis:6379"
else
    REDIS_URL_EVO_AUTH="redis://:${REDIS_PASSWORD}@redis:6379/1"
    REDIS_URL_EVO_CRM="redis://:${REDIS_PASSWORD}@redis:6379/0"
    REDIS_URL_EVO_BOT="redis://:${REDIS_PASSWORD}@redis:6379"
fi

if [ -z "$REDIS_PASSWORD" ]; then
    REDIS_CMD="redis-server --appendonly yes"
else
    REDIS_CMD="redis-server --requirepass ${REDIS_PASSWORD} --appendonly yes"
fi

# Remove arquivo .env - todas as variáveis vão direto no compose
rm -f evo-crm-stack/.env

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
    command: ["sh", "-c", "${REDIS_CMD}"]
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
    environment:
      RAILS_ENV: production
      REDIS_URL: ${REDIS_URL_EVO_AUTH}
      POSTGRES_HOST: postgres
      SECRET_KEY_BASE: ${SECRET_KEY_BASE}
      JWT_SECRET_KEY: ${JWT_SECRET_KEY}
      DOORKEEPER_JWT_SECRET_KEY: ${DOORKEEPER_JWT_SECRET_KEY}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      FRONTEND_URL: https://${FRONTEND_DOMAIN}
      MAILER_SENDER_EMAIL: noreply@${FRONTEND_DOMAIN}
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
    environment:
      RAILS_ENV: production
      REDIS_URL: ${REDIS_URL_EVO_CRM}
      POSTGRES_HOST: postgres
      SECRET_KEY_BASE: ${SECRET_KEY_BASE}
      JWT_SECRET_KEY: ${JWT_SECRET_KEY}
      EVO_AUTH_SERVICE_URL: http://evo-auth:3001
      EVO_AI_CORE_SERVICE_URL: http://evo-core:5555
      BOT_RUNTIME_URL: http://evo-bot-runtime:8080
      BOT_RUNTIME_SECRET: ${BOT_RUNTIME_SECRET}
      BOT_RUNTIME_POSTBACK_BASE_URL: http://evo-crm:3000
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      ENABLE_ACCOUNT_SIGNUP: "true"
      DISABLE_TELEMETRY: "true"
      RAILS_LOG_TO_STDOUT: "true"
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
    environment:
      RAILS_ENV: production
      REDIS_URL: ${REDIS_URL_EVO_CRM}
      POSTGRES_HOST: postgres
      SECRET_KEY_BASE: ${SECRET_KEY_BASE}
      JWT_SECRET_KEY: ${JWT_SECRET_KEY}
      EVO_AUTH_SERVICE_URL: http://evo-auth:3001
      EVO_AI_CORE_SERVICE_URL: http://evo-core:5555
      BOT_RUNTIME_URL: http://evo-bot-runtime:8080
      BOT_RUNTIME_SECRET: ${BOT_RUNTIME_SECRET}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
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
      JWT_SECRET_KEY: ${JWT_SECRET_KEY}
      ENCRYPTION_KEY: ${ENCRYPTION_KEY}
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
      EVOAI_CRM_API_TOKEN: ${EVOAI_CRM_API_TOKEN}
      ENCRYPTION_KEY: ${ENCRYPTION_KEY}
      APP_URL: https://${API_DOMAIN}
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
    environment:
      LISTEN_ADDR: 0.0.0.0:8080
      REDIS_URL: ${REDIS_URL_EVO_BOT}
      AI_PROCESSOR_URL: http://evo-processor:8000
      BOT_RUNTIME_SECRET: ${BOT_RUNTIME_SECRET}
      AI_PROCESSOR_API_KEY: ${EVOAI_CRM_API_TOKEN}
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
echo "==================================================================================================="
echo "                           FAZENDO DEPLOY DA STACK"
echo "==================================================================================================="

echo "Entrando na pasta da stack..."
cd evo-crm-stack

echo "Fazendo deploy com docker stack..."
docker stack deploy -c docker-compose.yaml evo_crm --prune 2>&1

echo ""
echo "==================================================================================================="
echo "                           INSTALACAO CONCLUIDA COM SUCESSO!"

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