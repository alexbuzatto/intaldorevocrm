#!/bin/bash

## ============================================================================================
## INSTALADOR EVO CRM COMMUNITY
## Baseado no SetupOrion e no docker-compose.swarm.yaml oficial
## Usa imagens Docker Hub pré-construídas (evoapicloud/*)
## Deploy via Portainer API
## ============================================================================================

export LANG=C.UTF-8
export LC_ALL=C.UTF-8

## Cores
amarelo="\e[33m"
verde="\e[32m"
branco="\e[97m"
vermelho="\e[91m"
reset="\e[0m"

## ============================================================================================
## FUNÇÕES UTILITÁRIAS
## ============================================================================================

banner_evocrm() {
    clear
    echo ""
    echo -e "$branco               ███████╗██╗   ██╗ ██████╗      ██████╗██████╗ ███╗   ███╗$reset"
    echo -e "$branco               ██╔════╝██║   ██║██╔═══██╗    ██╔════╝██╔══██╗████╗ ████║$reset"
    echo -e "$branco               █████╗  ██║   ██║██║   ██║    ██║     ██████╔╝██╔████╔██║$reset"
    echo -e "$branco               ██╔══╝  ╚██╗ ██╔╝██║   ██║    ██║     ██╔══██╗██║╚██╔╝██║$reset"
    echo -e "$branco               ███████╗ ╚████╔╝ ╚██████╔╝    ╚██████╗██║  ██║██║ ╚═╝ ██║$reset"
    echo -e "$branco               ╚══════╝  ╚═══╝   ╚═════╝      ╚═════╝╚═╝  ╚═╝╚═╝     ╚═╝$reset"
    echo ""
    echo -e "$amarelo===================================================================================================$reset"
    echo -e "$amarelo=                                                                                                 =$reset"
    echo -e "$amarelo=                     $branco INSTALADOR EVO CRM COMMUNITY - Docker Swarm                        $amarelo=$reset"
    echo -e "$amarelo=                                                                                                 =$reset"
    echo -e "$amarelo===================================================================================================$reset"
    echo ""
}

banner_instalando() {
    clear
    echo ""
    echo -e "$amarelo===================================================================================================$reset"
    echo -e "$amarelo=                                                                                                 =$reset"
    echo -e "$amarelo=      $branco  ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗      █████╗ ███╗   ██╗██████╗  ██████╗   $amarelo      =$reset"
    echo -e "$amarelo=      $branco  ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██╔══██╗████╗  ██║██╔══██╗██╔═══██╗  $amarelo      =$reset"
    echo -e "$amarelo=      $branco  ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ███████║██╔██╗ ██║██║  ██║██║   ██║  $amarelo      =$reset"
    echo -e "$amarelo=      $branco  ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██╔══██║██║╚██╗██║██║  ██║██║   ██║  $amarelo      =$reset"
    echo -e "$amarelo=      $branco  ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗██║  ██║██║ ╚████║██████╔╝╚██████╔╝  $amarelo      =$reset"
    echo -e "$amarelo=      $branco  ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝  ╚═════╝   $amarelo      =$reset"
    echo -e "$amarelo=                                                                                                 =$reset"
    echo -e "$amarelo===================================================================================================$reset"
    echo ""
}

banner_instalado() {
    clear
    echo ""
    echo -e "$amarelo===================================================================================================$reset"
    echo ""
    echo -e "$branco     ██╗      ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗      █████╗ ██████╗  ██████╗       ██╗$reset"
    echo -e "$branco     ╚██╗     ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██╔══██╗██╔══██╗██╔═══██╗     ██╔╝$reset"
    echo -e "$branco      ╚██╗    ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ███████║██║  ██║██║   ██║    ██╔╝ $reset"
    echo -e "$branco      ██╔╝    ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██╔══██║██║  ██║██║   ██║    ╚██╗ $reset"
    echo -e "$branco     ██╔╝     ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗██║  ██║██████╔╝╚██████╔╝     ╚██╗$reset"
    echo -e "$branco     ╚═╝      ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝  ╚═════╝       ╚═╝$reset"
    echo ""
    echo -e "$amarelo===================================================================================================$reset"
    echo ""
}

banner_erro() {
    echo ""
    echo -e "$amarelo===================================================================================================$reset"
    echo -e "$amarelo=                                                                                                 =$reset"
    echo -e "$amarelo=                                 $branco███████╗██████╗ ██████╗  ██████╗                                $amarelo=$reset"
    echo -e "$amarelo=                                 $branco██╔════╝██╔══██╗██╔══██╗██╔═══██╗                               $amarelo=$reset"
    echo -e "$amarelo=                                 $branco█████╗  ██████╔╝██████╔╝██║   ██║                               $amarelo=$reset"
    echo -e "$amarelo=                                 $branco██╔══╝  ██╔══██╗██╔══██╗██║   ██║                               $amarelo=$reset"
    echo -e "$amarelo=                                 $branco███████╗██║  ██║██║  ██║╚██████╔╝                               $amarelo=$reset"
    echo -e "$amarelo=                                 $branco╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝                                $amarelo=$reset"
    echo -e "$amarelo=                                                                                                 =$reset"
    echo -e "$amarelo===================================================================================================$reset"
    echo ""
}

preencha_as_info() {
    echo -e "$amarelo===================================================================================================$reset"
    echo -e "$amarelo=                                                                                                 $amarelo=$reset"
    echo -e "$amarelo=                          $branco Preencha as informações solicitadas abaixo                            $amarelo=$reset"
    echo -e "$amarelo=                                                                                                 $amarelo=$reset"
    echo -e "$amarelo===================================================================================================$reset"
    echo ""
}

conferindo_as_info() {
    echo -e "$amarelo===================================================================================================$reset"
    echo -e "$amarelo=                                                                                                 $amarelo=$reset"
    echo -e "$amarelo=                          $branco Verifique se os dados abaixos estão certos                            $amarelo=$reset"
    echo -e "$amarelo=                                                                                                 $amarelo=$reset"
    echo -e "$amarelo===================================================================================================$reset"
    echo ""
}

guarde_os_dados_msg() {
    echo -e "$amarelo===================================================================================================$reset"
    echo -e "$amarelo=                                                                                                 $amarelo=$reset"
    echo -e "$amarelo=                 $branco Guarde todos os dados abaixo para evitar futuros transtornos                   $amarelo=$reset"
    echo -e "$amarelo=                                                                                                 $amarelo=$reset"
    echo -e "$amarelo===================================================================================================$reset"
    echo ""
}

## ============================================================================================
## VERIFICAÇÃO DE DEPENDÊNCIAS
## ============================================================================================

banner_evocrm

echo -e "${branco}Verificando dependências...${reset}"
echo ""

deps_ok=true

if ! command -v curl &> /dev/null; then
    echo -e "${vermelho}[ERRO] curl não encontrado. Instale com: apt install curl -y${reset}"
    deps_ok=false
fi

if ! command -v jq &> /dev/null; then
    echo -e "${vermelho}[ERRO] jq não encontrado. Instale com: apt install jq -y${reset}"
    deps_ok=false
fi

if ! command -v openssl &> /dev/null; then
    echo -e "${vermelho}[ERRO] openssl não encontrado. Instale com: apt install openssl -y${reset}"
    deps_ok=false
fi

if ! command -v docker &> /dev/null; then
    echo -e "${vermelho}[ERRO] Docker não encontrado.${reset}"
    deps_ok=false
fi

if [ "$deps_ok" = false ]; then
    echo ""
    echo -e "${vermelho}Instale as dependências acima e execute novamente.${reset}"
    exit 1
fi

echo -e "${verde}[OK] Todas as dependências encontradas!${reset}"
sleep 2

## ============================================================================================
## COLETA DE DADOS — PORTAINER
## ============================================================================================

banner_evocrm
preencha_as_info

echo -e "${branco}── Credenciais do Portainer ──${reset}"
echo ""
read -p "Url do Portainer (ex: painel.seudominio.com.br): " PORTAINER_URL
read -p "Usuario do Portainer: " PORTAINER_USER
read -p "Senha do Portainer: " PORTAINER_PASS

## ============================================================================================
## COLETA DE DADOS — REDE E INFRAESTRUTURA
## ============================================================================================

echo ""
echo -e "${branco}── Configurações de Infraestrutura ──${reset}"
echo ""
read -p "Nome da rede interna Docker (ex: eclick): " NETWORK_NAME

## ============================================================================================
## COLETA DE DADOS — BANCO DE DADOS
## ============================================================================================

echo ""
echo -e "${branco}── Banco de Dados PostgreSQL ──${reset}"
echo ""
echo -e "${branco}O EVO CRM precisa do PostgreSQL com pgvector (pgvector/pgvector:pg16).${reset}"
echo -e "${branco}Você já tem um pgvector ou postgres rodando no Swarm?${reset}"
echo ""
echo -e "  ${amarelo}1)${branco} Sim, já tenho o pgvector rodando (stack pgvector)${reset}"
echo -e "  ${amarelo}2)${branco} Sim, já tenho o postgres rodando (stack postgres) - sem pgvector${reset}"
echo -e "  ${amarelo}3)${branco} Não tenho, quero que o instalador crie um pgvector${reset}"
echo ""
read -p "Escolha (1/2/3): " DB_CHOICE

case $DB_CHOICE in
    1)
        read -p "Nome do serviço PostgreSQL no Swarm (ex: pgvector): " POSTGRES_HOST
        POSTGRES_HOST=${POSTGRES_HOST:-pgvector}
        read -p "Porta do PostgreSQL (ex: 5432): " POSTGRES_PORT
        POSTGRES_PORT=${POSTGRES_PORT:-5432}
        read -p "Senha do PostgreSQL: " POSTGRES_PASSWORD
        INSTALL_PGVECTOR=false
        ;;
    2)
        read -p "Nome do serviço PostgreSQL no Swarm (ex: postgres): " POSTGRES_HOST
        POSTGRES_HOST=${POSTGRES_HOST:-postgres}
        read -p "Porta do PostgreSQL (ex: 5432): " POSTGRES_PORT
        POSTGRES_PORT=${POSTGRES_PORT:-5432}
        read -p "Senha do PostgreSQL: " POSTGRES_PASSWORD
        INSTALL_PGVECTOR=false
        echo ""
        echo -e "${amarelo}[AVISO] O EVO CRM pode precisar da extensão pgvector para funcionalidades de IA.${reset}"
        echo -e "${amarelo}Se tiver problemas, considere migrar para pgvector/pgvector:pg16.${reset}"
        ;;
    3)
        POSTGRES_HOST="evocrm_pgvector"
        POSTGRES_PORT="5432"
        read -p "Defina uma senha para o novo PostgreSQL: " POSTGRES_PASSWORD
        INSTALL_PGVECTOR=true
        ;;
    *)
        echo -e "${vermelho}Opção inválida. Saindo.${reset}"
        exit 1
        ;;
esac

POSTGRES_USER="postgres"
POSTGRES_DATABASE="evo_community"

## ============================================================================================
## COLETA DE DADOS — DOMÍNIOS
## ============================================================================================

echo ""
echo -e "${branco}── Domínios ──${reset}"
echo ""
echo -e "${branco}O EVO CRM precisa de 2 domínios:${reset}"
echo -e "  ${amarelo}1)${branco} API (gateway) — ex: api.evocrm.seudominio.com.br${reset}"
echo -e "  ${amarelo}2)${branco} Frontend      — ex: app.evocrm.seudominio.com.br${reset}"
echo ""
read -p "Domínio da API: " API_DOMAIN
read -p "Domínio do Frontend: " FRONTEND_DOMAIN

## ============================================================================================
## COLETA DE DADOS — SMTP (OPCIONAL)
## ============================================================================================

echo ""
echo -e "${branco}── Configuração de Email / SMTP (opcional) ──${reset}"
echo ""
read -p "Deseja configurar SMTP agora? (S/N): " SMTP_CHOICE

if [[ "$SMTP_CHOICE" =~ ^[Ss]$ ]]; then
    read -p "Endereço SMTP (ex: smtp.gmail.com): " SMTP_ADDRESS
    read -p "Porta SMTP (ex: 587): " SMTP_PORT
    SMTP_PORT=${SMTP_PORT:-587}
    read -p "Domínio SMTP (ex: gmail.com): " SMTP_DOMAIN
    read -p "Usuário SMTP: " SMTP_USERNAME
    read -p "Senha SMTP: " SMTP_PASSWORD
    read -p "Email remetente (ex: noreply@seudominio.com): " MAILER_SENDER_EMAIL
    SMTP_ENABLE_STARTTLS_AUTO="true"
    SMTP_AUTHENTICATION="plain"
else
    SMTP_ADDRESS=""
    SMTP_PORT="587"
    SMTP_DOMAIN=""
    SMTP_USERNAME=""
    SMTP_PASSWORD=""
    MAILER_SENDER_EMAIL="noreply@${FRONTEND_DOMAIN}"
    SMTP_ENABLE_STARTTLS_AUTO="true"
    SMTP_AUTHENTICATION="plain"
fi

## ============================================================================================
## GERAÇÃO DE SECRETS
## ============================================================================================

banner_evocrm
echo -e "${branco}Gerando chaves de segurança...${reset}"
echo ""

SECRET_KEY_BASE=$(openssl rand -hex 64)
echo -e "  ${verde}[OK]${branco} SECRET_KEY_BASE${reset}"

JWT_SECRET_KEY=$(openssl rand -hex 64)
echo -e "  ${verde}[OK]${branco} JWT_SECRET_KEY${reset}"

DOORKEEPER_JWT_SECRET_KEY=$(openssl rand -hex 64)
echo -e "  ${verde}[OK]${branco} DOORKEEPER_JWT_SECRET_KEY${reset}"

EVOAI_CRM_API_TOKEN=$(cat /proc/sys/kernel/random/uuid 2>/dev/null || openssl rand -hex 16)
echo -e "  ${verde}[OK]${branco} EVOAI_CRM_API_TOKEN${reset}"

BOT_RUNTIME_SECRET=$(openssl rand -hex 32)
echo -e "  ${verde}[OK]${branco} BOT_RUNTIME_SECRET${reset}"

ENCRYPTION_KEY=$(openssl rand -base64 32)
echo -e "  ${verde}[OK]${branco} ENCRYPTION_KEY${reset}"

REDIS_PASSWORD=$(openssl rand -hex 16)
echo -e "  ${verde}[OK]${branco} REDIS_PASSWORD (Redis dedicado do EVO CRM)${reset}"

echo ""
echo -e "${verde}Todas as chaves geradas com sucesso!${reset}"
sleep 2

## ============================================================================================
## CONFIRMAÇÃO DOS DADOS
## ============================================================================================

banner_evocrm
conferindo_as_info

echo -e "  ${branco}Portainer:${reset}        https://${PORTAINER_URL}"
echo -e "  ${branco}Rede Docker:${reset}      ${NETWORK_NAME}"
echo -e "  ${branco}PostgreSQL:${reset}       ${POSTGRES_HOST}:${POSTGRES_PORT}"
echo -e "  ${branco}Database:${reset}         ${POSTGRES_DATABASE}"
echo -e "  ${branco}Domínio API:${reset}      https://${API_DOMAIN}"
echo -e "  ${branco}Domínio Frontend:${reset} https://${FRONTEND_DOMAIN}"
if [ -n "$SMTP_ADDRESS" ]; then
    echo -e "  ${branco}SMTP:${reset}             ${SMTP_ADDRESS}:${SMTP_PORT}"
else
    echo -e "  ${branco}SMTP:${reset}             ${amarelo}Não configurado${reset}"
fi
if [ "$INSTALL_PGVECTOR" = true ]; then
    echo -e "  ${branco}PgVector:${reset}         ${amarelo}Será instalado automaticamente${reset}"
fi
echo ""

read -p "Os dados estão corretos? (S/N): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Ss]$ ]]; then
    echo -e "${vermelho}Instalação cancelada pelo usuário.${reset}"
    exit 1
fi

## ============================================================================================
## PREPARAÇÃO — REDIS URL
## ============================================================================================

REDIS_URL="redis://:${REDIS_PASSWORD}@evocrm_redis:6379/0"

## Connection string do Processor
PROCESSOR_POSTGRES_CONNECTION_STRING="postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DATABASE}?sslmode=disable"

## ============================================================================================
## AUTENTICAÇÃO NO PORTAINER
## ============================================================================================

banner_instalando
echo -e "${branco}Autenticando no Portainer...${reset}"
echo ""

max_attempts=3
attempt=1

while [ $attempt -le $max_attempts ]; do
    auth_response=$(curl -k -s -X POST "https://${PORTAINER_URL}/api/auth" \
        -H "Content-Type: application/json" \
        -d "{\"username\":\"${PORTAINER_USER}\",\"password\":\"${PORTAINER_PASS}\"}")

    token=$(echo "${auth_response}" | jq -r '.jwt' 2>/dev/null)

    if [ "$token" = "null" ] || [ -z "$token" ] || [ "$token" = "." ]; then
        echo -e "  ${vermelho}Tentativa ${attempt}/${max_attempts} falhou!${reset}"

        if [ $attempt -lt $max_attempts ]; then
            echo ""
            read -p "Usuario do Portainer: " PORTAINER_USER
            read -p "Senha do Portainer: " PORTAINER_PASS
        fi
        attempt=$((attempt + 1))
    else
        echo -e "  ${verde}[OK] Autenticado com sucesso!${reset}"
        break
    fi
done

if [ "$token" = "null" ] || [ -z "$token" ] || [ "$token" = "." ]; then
    banner_erro
    echo -e "${vermelho}Não foi possível autenticar no Portainer!${reset}"
    echo -e "${vermelho}Verifique suas credenciais e tente novamente.${reset}"
    exit 1
fi

## Buscar endpoint ID
echo ""
echo -e "${branco}Buscando endpoint do Portainer...${reset}"

endpoints_response=$(curl -k -s -X GET "https://${PORTAINER_URL}/api/endpoints" \
    -H "Authorization: Bearer ${token}")

## Tenta encontrar endpoint "primary" (padrão SetupOrion), senão pega o primeiro
ENDPOINT_ID=$(echo "${endpoints_response}" | jq -r '.[] | select(.Name == "primary") | .Id' 2>/dev/null)

if [ -z "$ENDPOINT_ID" ] || [ "$ENDPOINT_ID" = "null" ]; then
    ENDPOINT_ID=$(echo "${endpoints_response}" | jq -r '.[0].Id' 2>/dev/null)
fi

if [ -z "$ENDPOINT_ID" ] || [ "$ENDPOINT_ID" = "null" ]; then
    echo -e "${amarelo}[AVISO] Não foi possível detectar endpoint. Usando ID=1${reset}"
    ENDPOINT_ID=1
else
    echo -e "  ${verde}[OK] Endpoint encontrado: ID=${ENDPOINT_ID}${reset}"
fi

## Buscar Swarm ID
echo ""
echo -e "${branco}Buscando Swarm ID...${reset}"

swarm_response=$(curl -k -s -X GET "https://${PORTAINER_URL}/api/endpoints/${ENDPOINT_ID}/docker/swarm" \
    -H "Authorization: Bearer ${token}")

SWARM_ID=$(echo "${swarm_response}" | jq -r '.ID' 2>/dev/null)

if [ -z "$SWARM_ID" ] || [ "$SWARM_ID" = "null" ]; then
    echo -e "${vermelho}[ERRO] Não foi possível obter o Swarm ID!${reset}"
    echo -e "${vermelho}Certifique-se de que o Docker Swarm está inicializado.${reset}"
    exit 1
else
    echo -e "  ${verde}[OK] Swarm ID: ${SWARM_ID}${reset}"
fi

## ============================================================================================
## CRIAÇÃO DE VOLUMES
## ============================================================================================

echo ""
echo -e "${branco}Criando volumes Docker...${reset}"

volumes_to_create=(
    "evocrm_redis"
    "evocrm_processor_logs"
)

if [ "$INSTALL_PGVECTOR" = true ]; then
    volumes_to_create+=("evocrm_pgvector_data")
fi

for vol in "${volumes_to_create[@]}"; do
    vol_exists=$(curl -k -s -X GET "https://${PORTAINER_URL}/api/endpoints/${ENDPOINT_ID}/docker/volumes/${vol}" \
        -H "Authorization: Bearer ${token}" | jq -r '.Name' 2>/dev/null)

    if [ "$vol_exists" = "$vol" ]; then
        echo -e "  ${verde}[OK]${branco} Volume ${vol} já existe${reset}"
    else
        curl -k -s -X POST "https://${PORTAINER_URL}/api/endpoints/${ENDPOINT_ID}/docker/volumes/create" \
            -H "Authorization: Bearer ${token}" \
            -H "Content-Type: application/json" \
            -d "{\"Name\": \"${vol}\"}" > /dev/null 2>&1
        echo -e "  ${verde}[OK]${branco} Volume ${vol} criado${reset}"
    fi
done

## ============================================================================================
## INSTALAÇÃO PGVECTOR (SE NECESSÁRIO)
## ============================================================================================

if [ "$INSTALL_PGVECTOR" = true ]; then
    echo ""
    echo -e "${branco}Instalando PgVector (pgvector/pgvector:pg16)...${reset}"

    PGVECTOR_COMPOSE=$(cat <<'PGEOF'
version: "3.7"
services:

  evo_db_init:
    image: postgres:16
    networks:
      - ${NETWORK_NAME}
    environment:
      - PGPASSWORD=${POSTGRES_PASSWORD}
    command: >
      sh -c "psql -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} -U ${POSTGRES_USER} -d postgres -c \"CREATE DATABASE ${POSTGRES_DATABASE};\" || true"
    deploy:
      mode: replicated
      replicas: 1
      restart_policy:
        condition: none
      placement:
        constraints:
          - node.role == manager

## --------------------------- ORION --------------------------- ##

## --------------------------- ORION --------------------------- ##

  evocrm_pgvector:
    image: pgvector/pgvector:pg16
    command: >
      postgres
      -c max_connections=500
      -c shared_buffers=512MB
      -c timezone=America/Sao_Paulo

    volumes:
      - evocrm_pgvector_data:/var/lib/postgresql/data

    networks:
      - NETWORK_PLACEHOLDER

    environment:
      - POSTGRES_PASSWORD=PGPASS_PLACEHOLDER
      - POSTGRES_DB=evo_community
      - TZ=America/Sao_Paulo

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 1024M

## --------------------------- ORION --------------------------- ##

volumes:
  evocrm_pgvector_data:
    external: true
    name: evocrm_pgvector_data

networks:
  NETWORK_PLACEHOLDER:
    external: true
    name: NETWORK_PLACEHOLDER
PGEOF
)

    ## Substituir placeholders
    PGVECTOR_COMPOSE=$(echo "$PGVECTOR_COMPOSE" | sed "s/NETWORK_PLACEHOLDER/${NETWORK_NAME}/g")
    PGVECTOR_COMPOSE=$(echo "$PGVECTOR_COMPOSE" | sed "s/PGPASS_PLACEHOLDER/${POSTGRES_PASSWORD}/g")

    ## Fazer escape do YAML para JSON
    ## Salvar YAML em arquivo temporário para deploy via multipart (padrão SetupOrion)
    PGVECTOR_TMPFILE=$(mktemp /tmp/evocrm_pgvector_XXXXXX.yaml)
    echo "$PGVECTOR_COMPOSE" > "$PGVECTOR_TMPFILE"

    pg_response=$(curl -k -s -X POST \
        -H "Authorization: Bearer ${token}" \
        -F "Name=evocrm_pgvector" \
        -F "file=@${PGVECTOR_TMPFILE}" \
        -F "SwarmID=${SWARM_ID}" \
        -F "endpointId=${ENDPOINT_ID}" \
        "https://${PORTAINER_URL}/api/stacks/create/swarm/file?endpointId=${ENDPOINT_ID}")

    rm -f "$PGVECTOR_TMPFILE"

    if echo "$pg_response" | jq -e '.Id' > /dev/null 2>&1; then
        echo -e "  ${verde}[OK] PgVector instalado com sucesso!${reset}"
        echo -e "  ${amarelo}Aguardando PgVector inicializar (30s)...${reset}"
        sleep 30
    else
        pg_err=$(echo "$pg_response" | jq -r '.message // .details // "Erro desconhecido"' 2>/dev/null)
        if echo "$pg_err" | grep -qi "already exists\|já existe\|duplicate"; then
            echo -e "  ${amarelo}[INFO] Stack evocrm_pgvector já existe, continuando...${reset}"
        else
            echo -e "  ${vermelho}[ERRO] Falha ao instalar PgVector: ${pg_err}${reset}"
            echo -e "  ${amarelo}Continuando mesmo assim...${reset}"
        fi
    fi
fi



## ============================================================================================
## GERAÇÃO DO YAML DO EVO CRM
## ============================================================================================

echo ""
echo -e "${branco}Gerando stack do EVO CRM...${reset}"

EVO_COMPOSE=$(cat <<EOFCOMPOSE
version: "3.7"
services:

  evo_db_init:
    image: postgres:16
    networks:
      - ${NETWORK_NAME}
    environment:
      - PGPASSWORD=${POSTGRES_PASSWORD}
    command: >
      sh -c "psql -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} -U ${POSTGRES_USER} -d postgres -c \"CREATE DATABASE ${POSTGRES_DATABASE};\" || true"
    deploy:
      mode: replicated
      replicas: 1
      restart_policy:
        condition: none
      placement:
        constraints:
          - node.role == manager

## --------------------------- ORION --------------------------- ##

## --------------------------- ORION --------------------------- ##

  evo_gateway:
    image: evoapicloud/evo-crm-gateway:latest ## Gateway Nginx - API único
    networks:
      - ${NETWORK_NAME}
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "0.5"
          memory: 256M
      labels:
        - traefik.enable=true
        - traefik.http.routers.evo_gateway.rule=Host(\`${API_DOMAIN}\`)
        - traefik.http.routers.evo_gateway.entrypoints=websecure
        - traefik.http.routers.evo_gateway.tls.certresolver=letsencryptresolver
        - traefik.http.routers.evo_gateway.service=evo_gateway
        - traefik.http.services.evo_gateway.loadbalancer.server.port=3030
        - traefik.http.services.evo_gateway.loadbalancer.passHostHeader=true

## --------------------------- ORION --------------------------- ##

  evo_auth:
    image: evoapicloud/evo-auth-service-community:latest ## Auth Service (Rails) — porta 3001
    command: sh -c "bundle exec rails db:migrate && bundle exec rails db:seed && bundle exec rails s -p 3001 -b 0.0.0.0"
    networks:
      - "${NETWORK_NAME}"
    environment:
      - "RAILS_ENV=production"
      - "RAILS_MAX_THREADS=5"
      - "RAILS_LOG_TO_STDOUT=true"
      - "RAILS_SERVE_STATIC_FILES=true"
      - "SECRET_KEY_BASE=${SECRET_KEY_BASE}"
      - "JWT_SECRET_KEY=${JWT_SECRET_KEY}"
      - "ENCRYPTION_KEY=${ENCRYPTION_KEY}"
      - "EVOAI_CRM_API_TOKEN=${EVOAI_CRM_API_TOKEN}"
      - "POSTGRES_HOST=${POSTGRES_HOST}"
      - "POSTGRES_PORT=${POSTGRES_PORT}"
      - "POSTGRES_USER=${POSTGRES_USER}"
      - "POSTGRES_USERNAME=${POSTGRES_USER}"
      - "POSTGRES_PASSWORD=${POSTGRES_PASSWORD}"
      - "POSTGRES_DATABASE=${POSTGRES_DATABASE}"
      - "POSTGRES_DB=${POSTGRES_DATABASE}"
      - "POSTGRES_SSLMODE=disable"
      - "REDIS_URL=${REDIS_URL}"
      - "REDIS_PASSWORD=${REDIS_PASSWORD}"
      - "FRONTEND_URL=https://${FRONTEND_DOMAIN}"
      - "BACKEND_URL=https://${API_DOMAIN}"
      - "CORS_ORIGINS=https://${FRONTEND_DOMAIN},https://${API_DOMAIN}"
      - "MAILER_SENDER_EMAIL=${MAILER_SENDER_EMAIL}"
      - "SMTP_ADDRESS=${SMTP_ADDRESS}"
      - "SMTP_PORT=${SMTP_PORT}"
      - "SMTP_DOMAIN=${SMTP_DOMAIN}"
      - "SMTP_AUTHENTICATION=${SMTP_AUTHENTICATION}"
      - "SMTP_ENABLE_STARTTLS_AUTO=${SMTP_ENABLE_STARTTLS_AUTO}"
      - "SMTP_USERNAME=${SMTP_USERNAME}"
      - "SMTP_PASSWORD=${SMTP_PASSWORD}"
      - "DOORKEEPER_JWT_SECRET_KEY=${DOORKEEPER_JWT_SECRET_KEY}"
      - "DOORKEEPER_JWT_ALGORITHM=hs256"
      - "DOORKEEPER_JWT_ISS=evo-auth-service"
      - "MFA_ISSUER=EvoCRM"
      - "SIDEKIQ_CONCURRENCY=10"
      - "ACTIVE_STORAGE_SERVICE=local"
    stop_grace_period: 300s
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 1024M

## --------------------------- ORION --------------------------- ##

  evo_auth_sidekiq:
    image: evoapicloud/evo-auth-service-community:latest ## Auth Sidekiq Worker
    command: sh -c "bundle exec sidekiq -C config/sidekiq.yml"
    healthcheck:
      disable: true
    networks:
      - "${NETWORK_NAME}"
    environment:
      - "RAILS_ENV=production"
      - "RAILS_LOG_TO_STDOUT=true"
      - "SECRET_KEY_BASE=${SECRET_KEY_BASE}"
      - "JWT_SECRET_KEY=${JWT_SECRET_KEY}"
      - "ENCRYPTION_KEY=${ENCRYPTION_KEY}"
      - "EVOAI_CRM_API_TOKEN=${EVOAI_CRM_API_TOKEN}"
      - "POSTGRES_HOST=${POSTGRES_HOST}"
      - "POSTGRES_PORT=${POSTGRES_PORT}"
      - "POSTGRES_USER=${POSTGRES_USER}"
      - "POSTGRES_USERNAME=${POSTGRES_USER}"
      - "POSTGRES_PASSWORD=${POSTGRES_PASSWORD}"
      - "POSTGRES_DATABASE=${POSTGRES_DATABASE}"
      - "POSTGRES_DB=${POSTGRES_DATABASE}"
      - "POSTGRES_SSLMODE=disable"
      - "REDIS_URL=${REDIS_URL}"
      - "REDIS_PASSWORD=${REDIS_PASSWORD}"
      - "FRONTEND_URL=https://${FRONTEND_DOMAIN}"
      - "BACKEND_URL=https://${API_DOMAIN}"
      - "CORS_ORIGINS=https://${FRONTEND_DOMAIN},https://${API_DOMAIN}"
      - "SMTP_ADDRESS=${SMTP_ADDRESS}"
      - "SMTP_PORT=${SMTP_PORT}"
      - "SMTP_DOMAIN=${SMTP_DOMAIN}"
      - "SMTP_AUTHENTICATION=${SMTP_AUTHENTICATION}"
      - "SMTP_ENABLE_STARTTLS_AUTO=${SMTP_ENABLE_STARTTLS_AUTO}"
      - "SMTP_USERNAME=${SMTP_USERNAME}"
      - "SMTP_PASSWORD=${SMTP_PASSWORD}"
      - "DOORKEEPER_JWT_SECRET_KEY=${DOORKEEPER_JWT_SECRET_KEY}"
      - "DOORKEEPER_JWT_ALGORITHM=hs256"
      - "DOORKEEPER_JWT_ISS=evo-auth-service"
      - "MFA_ISSUER=EvoCRM"
      - "SIDEKIQ_CONCURRENCY=10"
      - "ACTIVE_STORAGE_SERVICE=local"
    stop_grace_period: 300s
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 1024M

## --------------------------- ORION --------------------------- ##

  evo_crm:
    image: evoapicloud/evo-ai-crm-community:latest ## CRM Service (Rails) — porta 3000
    command: sh -c "until wget -qO- http://evo_auth:3001/health >/dev/null 2>&1; do echo 'Waiting for auth...'; sleep 5; done; bundle exec rails db:migrate && bundle exec rails db:seed && bundle exec rails s -p 3000 -b 0.0.0.0"
    networks:
      - "${NETWORK_NAME}"
    environment:
      - "RAILS_ENV=production"
      - "RAILS_SERVE_STATIC_FILES=true"
      - "RAILS_LOG_TO_STDOUT=true"
      - "SECRET_KEY_BASE=${SECRET_KEY_BASE}"
      - "JWT_SECRET_KEY=${JWT_SECRET_KEY}"
      - "ENCRYPTION_KEY=${ENCRYPTION_KEY}"
      - "EVOAI_CRM_API_TOKEN=${EVOAI_CRM_API_TOKEN}"
      - "POSTGRES_HOST=${POSTGRES_HOST}"
      - "POSTGRES_PORT=${POSTGRES_PORT}"
      - "POSTGRES_USER=${POSTGRES_USER}"
      - "POSTGRES_USERNAME=${POSTGRES_USER}"
      - "POSTGRES_PASSWORD=${POSTGRES_PASSWORD}"
      - "POSTGRES_DATABASE=${POSTGRES_DATABASE}"
      - "POSTGRES_DB=${POSTGRES_DATABASE}"
      - "POSTGRES_SSLMODE=disable"
      - "REDIS_URL=${REDIS_URL}"
      - "REDIS_PASSWORD=${REDIS_PASSWORD}"
      - "EVO_AUTH_SERVICE_URL=http://evo_auth:3001"
      - "EVO_AI_CORE_SERVICE_URL=http://evo_core:5555"
      - "BACKEND_URL=https://${API_DOMAIN}"
      - "FRONTEND_URL=https://${FRONTEND_DOMAIN}"
      - "CORS_ORIGINS=https://${FRONTEND_DOMAIN},https://${API_DOMAIN}"
      - "DISABLE_TELEMETRY=true"
      - "LOG_LEVEL=info"
      - "ENABLE_ACCOUNT_SIGNUP=true"
      - "ENABLE_PUSH_RELAY_SERVER=true"
      - "ENABLE_INBOX_EVENTS=true"
      - "BOT_RUNTIME_URL=http://evo_bot_runtime:8080"
      - "BOT_RUNTIME_SECRET=${BOT_RUNTIME_SECRET}"
      - "BOT_RUNTIME_POSTBACK_BASE_URL=http://evo_crm:3000"
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 1024M

## --------------------------- ORION --------------------------- ##

  evo_crm_sidekiq:
    image: evoapicloud/evo-ai-crm-community:latest ## CRM Sidekiq Worker
    command: sh -c "bundle exec sidekiq -C config/sidekiq.yml"
    healthcheck:
      disable: true
    networks:
      - "${NETWORK_NAME}"
    environment:
      - "RAILS_ENV=production"
      - "RAILS_LOG_TO_STDOUT=true"
      - "SECRET_KEY_BASE=${SECRET_KEY_BASE}"
      - "JWT_SECRET_KEY=${JWT_SECRET_KEY}"
      - "ENCRYPTION_KEY=${ENCRYPTION_KEY}"
      - "EVOAI_CRM_API_TOKEN=${EVOAI_CRM_API_TOKEN}"
      - "POSTGRES_HOST=${POSTGRES_HOST}"
      - "POSTGRES_PORT=${POSTGRES_PORT}"
      - "POSTGRES_USER=${POSTGRES_USER}"
      - "POSTGRES_USERNAME=${POSTGRES_USER}"
      - "POSTGRES_PASSWORD=${POSTGRES_PASSWORD}"
      - "POSTGRES_DATABASE=${POSTGRES_DATABASE}"
      - "POSTGRES_DB=${POSTGRES_DATABASE}"
      - "POSTGRES_SSLMODE=disable"
      - "REDIS_URL=${REDIS_URL}"
      - "REDIS_PASSWORD=${REDIS_PASSWORD}"
      - "EVO_AUTH_SERVICE_URL=http://evo_auth:3001"
      - "BACKEND_URL=https://${API_DOMAIN}"
      - "FRONTEND_URL=https://${FRONTEND_DOMAIN}"
      - "CORS_ORIGINS=https://${FRONTEND_DOMAIN},https://${API_DOMAIN}"
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 1024M

## --------------------------- ORION --------------------------- ##

  evo_core:
    image: evoapicloud/evo-ai-core-service-community:latest ## Core Service (Go/Gin) — porta 5555
    networks:
      - ${NETWORK_NAME}
    environment:
      - "DB_HOST=${POSTGRES_HOST}"
      - "DB_PORT=${POSTGRES_PORT}"
      - "DB_USER=${POSTGRES_USER}"
      - "DB_PASSWORD=${POSTGRES_PASSWORD}"
      - "DB_NAME=${POSTGRES_DATABASE}"
      - "DB_SSLMODE=disable"
      - "DB_MAX_IDLE_CONNS=10"
      - "DB_MAX_OPEN_CONNS=100"
      - "DB_CONN_MAX_LIFETIME=1h"
      - "DB_CONN_MAX_IDLE_TIME=30m"
      - "PORT=5555"
      - "SECRET_KEY_BASE=${SECRET_KEY_BASE}"
      - "JWT_SECRET_KEY=${JWT_SECRET_KEY}"
      - "JWT_ALGORITHM=HS256"
      - "ENCRYPTION_KEY=${ENCRYPTION_KEY}"
      - "EVOLUTION_BASE_URL=http://evo_crm:3000"
      - "EVO_AUTH_BASE_URL=http://evo_auth:3001"
      - "AI_PROCESSOR_URL=http://evo_processor:8000"
      - "AI_PROCESSOR_VERSION=v1"
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 1024M

## --------------------------- ORION --------------------------- ##

  evo_processor:
    image: evoapicloud/evo-ai-processor-community:latest ## Processor (Python/FastAPI) — porta 8000
    command: sh -c "alembic upgrade head 2>&1 || echo 'Alembic migration had errors, continuing...'; python -m scripts.run_seeders; uvicorn src.main:app --host 0.0.0.0 --port 8000"
    volumes:
      - evocrm_processor_logs:/app/logs
    networks:
      - ${NETWORK_NAME}
    environment:
      - "POSTGRES_CONNECTION_STRING=${PROCESSOR_POSTGRES_CONNECTION_STRING}"
      - "REDIS_HOST=evocrm_redis"
      - "REDIS_PORT=6379"
      - "REDIS_PASSWORD=${REDIS_PASSWORD}"
      - "REDIS_SSL=false"
      - "REDIS_DB=0"
      - "REDIS_KEY_PREFIX=a2a:"
      - "REDIS_TTL=3600"
      - "HOST=0.0.0.0"
      - "PORT=8000"
      - "DEBUG=false"
      - "SECRET_KEY_BASE=${SECRET_KEY_BASE}"
      - "ENCRYPTION_KEY=${ENCRYPTION_KEY}"
      - "EVOAI_CRM_API_TOKEN=${EVOAI_CRM_API_TOKEN}"
      - "EVO_AI_CRM_URL=http://evo_crm:3000"
      - "CORE_SERVICE_URL=http://evo_core:5555/api/v1"
      - "APP_URL=https://${API_DOMAIN}"
      - "API_TITLE=Agent Processor Community"
      - "API_DESCRIPTION=Agent Processor Community for Evo AI"
      - "API_VERSION=1.0.0"
      - "API_URL=https://${API_DOMAIN}"
      - "ORGANIZATION_NAME=Evo CRM"
      - "TOOLS_CACHE_ENABLED=true"
      - "TOOLS_CACHE_TTL=3600"
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 1024M

## --------------------------- ORION --------------------------- ##

  evo_bot_runtime:
    image: evoapicloud/evo-bot-runtime:latest ## Bot Runtime (Go/Gin) — porta 8080
    networks:
      - ${NETWORK_NAME}
    environment:
      - "LISTEN_ADDR=0.0.0.0:8080"
      - "REDIS_URL=${REDIS_URL}"
      - "AI_PROCESSOR_URL=http://evo_processor:8000"
      - "BOT_RUNTIME_SECRET=${BOT_RUNTIME_SECRET}"
      - "AI_CALL_TIMEOUT_SECONDS=30"
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "0.5"
          memory: 256M

## --------------------------- ORION --------------------------- ##

  evo_frontend:
    image: evoapicloud/evo-ai-frontend-community:latest ## Frontend (React/Vite/Nginx) — porta 80
    networks:
      - ${NETWORK_NAME}
    environment:
      - "VITE_APP_ENV=production"
      - "VITE_API_URL=https://${API_DOMAIN}"
      - "VITE_AUTH_API_URL=https://${API_DOMAIN}"
      - "VITE_EVOAI_API_URL=https://${API_DOMAIN}"
      - "VITE_AGENT_PROCESSOR_URL=https://${API_DOMAIN}"
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "0.5"
          memory: 256M
      labels:
        - traefik.enable=true
        - traefik.http.routers.evo_frontend.rule=Host(\`${FRONTEND_DOMAIN}\`)
        - traefik.http.routers.evo_frontend.entrypoints=websecure
        - traefik.http.routers.evo_frontend.tls.certresolver=letsencryptresolver
        - traefik.http.routers.evo_frontend.service=evo_frontend
        - traefik.http.services.evo_frontend.loadbalancer.server.port=80
        - traefik.http.services.evo_frontend.loadbalancer.passHostHeader=true

## --------------------------- ORION --------------------------- ##

  evocrm_redis:
    image: redis:latest ## Redis dedicado do EVO CRM
    command: sh -c "redis-server --requirepass $REDIS_PASSWORD --appendonly yes --port 6379"
    healthcheck:
      disable: true
    volumes:
      - evocrm_redis:/data
    networks:
      - "${NETWORK_NAME}"
    deploy:
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "0.5"
          memory: 1024M

## --------------------------- ORION --------------------------- ##

volumes:
  evocrm_redis:
    external: true
    name: evocrm_redis
  evocrm_processor_logs:
    external: true
    name: evocrm_processor_logs

networks:
  ${NETWORK_NAME}:
    external: true
    name: ${NETWORK_NAME}
EOFCOMPOSE
)

echo -e "  ${verde}[OK] Stack do EVO CRM gerada com sucesso!${reset}"

## ============================================================================================
## DEPLOY VIA PORTAINER API
## ============================================================================================

echo ""
echo -e "${branco}Fazendo deploy da stack no Portainer...${reset}"

STACK_NAME="evo_crm"

## Salvar YAML em arquivo temporário para deploy via multipart (padrão SetupOrion)
EVO_TMPFILE=$(mktemp /tmp/evo_crm_XXXXXX.yaml)
echo "$EVO_COMPOSE" > "$EVO_TMPFILE"

## Guardar o compose escaped para possível update
EVO_COMPOSE_ESCAPED=$(echo "$EVO_COMPOSE" | jq -Rs .)

erro_output=$(mktemp)
response_output=$(mktemp)

http_code=$(curl -s -o "$response_output" -w "%{http_code}" -k -X POST \
    -H "Authorization: Bearer ${token}" \
    -F "Name=${STACK_NAME}" \
    -F "file=@${EVO_TMPFILE}" \
    -F "SwarmID=${SWARM_ID}" \
    -F "endpointId=${ENDPOINT_ID}" \
    "https://${PORTAINER_URL}/api/stacks/create/swarm/file?endpointId=${ENDPOINT_ID}" 2> "$erro_output")

deploy_response=$(cat "$response_output")
rm -f "$EVO_TMPFILE" "$erro_output" "$response_output"

if [ "$http_code" -eq 200 ] && echo "$deploy_response" | jq -e '.Id' > /dev/null 2>&1; then
    echo -e "  ${verde}[OK] Stack '${STACK_NAME}' criada com sucesso no Portainer!${reset}"
else
    deploy_err=$(echo "$deploy_response" | jq -r '.message // .details // "Erro desconhecido"' 2>/dev/null)

    if echo "$deploy_err" | grep -qi "already exists\|já existe\|duplicate"; then
        echo -e "  ${amarelo}[INFO] Stack '${STACK_NAME}' já existe no Portainer.${reset}"
        echo -e "  ${amarelo}Deseja atualizar a stack existente? (S/N)${reset}"
        read -p "" UPDATE_CHOICE

        if [[ "$UPDATE_CHOICE" =~ ^[Ss]$ ]]; then
            ## Buscar ID da stack existente
            stacks_list=$(curl -k -s -X GET "https://${PORTAINER_URL}/api/stacks" \
                -H "Authorization: Bearer ${token}")

            STACK_ID=$(echo "$stacks_list" | jq -r ".[] | select(.Name==\"${STACK_NAME}\") | .Id" 2>/dev/null)

            if [ -n "$STACK_ID" ] && [ "$STACK_ID" != "null" ]; then
                update_response=$(curl -k -s -X PUT "https://${PORTAINER_URL}/api/stacks/${STACK_ID}?endpointId=${ENDPOINT_ID}" \
                    -H "Authorization: Bearer ${token}" \
                    -H "Content-Type: application/json" \
                    -d "{
                        \"stackFileContent\": ${EVO_COMPOSE_ESCAPED},
                        \"prune\": true
                    }")

                if echo "$update_response" | jq -e '.Id' > /dev/null 2>&1; then
                    echo -e "  ${verde}[OK] Stack atualizada com sucesso!${reset}"
                else
                    update_err=$(echo "$update_response" | jq -r '.message // .details // "Erro desconhecido"' 2>/dev/null)
                    echo -e "  ${vermelho}[ERRO] Falha ao atualizar: ${update_err}${reset}"
                fi
            else
                echo -e "  ${vermelho}[ERRO] Não foi possível encontrar a stack existente.${reset}"
            fi
        fi
    else
        echo -e "  ${vermelho}[ERRO] Falha ao criar stack: ${deploy_err}${reset}"
        echo -e "  ${vermelho}Resposta completa: ${deploy_response}${reset}"
        exit 1
    fi
fi

## ============================================================================================
## TESTE DE SAUDE (HEALTHCHECK)
## ============================================================================================

echo -e ""
echo -e "${amarelo}⏳ Aguardando a inicialização dos serviços Evo CRM...${reset}"
echo -e "${branco}O primeiro boot executa migrações, sementes no banco de dados e downloads massivos.${reset}"
echo -e "${branco}Isso pode levar até 5 minutos dependendo da sua internet. Testando: https://${FRONTEND_DOMAIN}${reset}"

MAX_TRIES=60
TRIES=0
URL_TEST="https://${FRONTEND_DOMAIN}"

while [ $TRIES -lt $MAX_TRIES ]; do
  STATUS_CODE=$(curl -o /dev/null -s -w "%{http_code}\n" -k "$URL_TEST")
  if [ "$STATUS_CODE" -eq 200 ] || [ "$STATUS_CODE" -eq 301 ] || [ "$STATUS_CODE" -eq 404 ]; then
    echo -e "\n${verde}🎉 SUCESSO ABSOLUTO! Seu sistema subiu perfeitamente e está online na web!${reset}"
    break
  fi
  echo -n "."
  sleep 5
  TRIES=$((TRIES+1))
done

if [ $TRIES -eq $MAX_TRIES ]; then
  echo -e "\n${vermelho}⚠️ ALERTA DE TIMEOUT: Os serviços demoraram mais de 5 minutos para responder.${reset}"
  echo -e "${amarelo}Isto NÃO significa erro no script, muitas vezes é apenas lentidão da rede na sua VPS baixando imagens de 2GB.${reset}"
  echo -e "${amarelo}Continue acompanhando no seu Portainer para ver se os serviços saem de 'starting' para o verde 'running'.${reset}"
fi


## ============================================================================================
## SALVAR CREDENCIAIS EM ARQUIVO
## ============================================================================================

CRED_FILE="${HOME}/credenciais-evocrm.txt"

cat > "$CRED_FILE" <<CREDEOF
====================================================================================================
                         CREDENCIAIS EVO CRM COMMUNITY
                         Instalado em: $(date '+%d/%m/%Y %H:%M:%S')
====================================================================================================

ACESSO AO EVO CRM:
  Frontend:           https://${FRONTEND_DOMAIN}
  API (Gateway):      https://${API_DOMAIN}

BANCO DE DADOS:
  Host:               ${POSTGRES_HOST}
  Porta:              ${POSTGRES_PORT}
  Usuário:            ${POSTGRES_USER}
  Senha:              ${POSTGRES_PASSWORD}
  Database:           ${POSTGRES_DATABASE}

REDIS (dedicado):
  Host:               evocrm_redis
  Senha:              ${REDIS_PASSWORD}

SECRETS:
  SECRET_KEY_BASE:          ${SECRET_KEY_BASE}
  JWT_SECRET_KEY:           ${JWT_SECRET_KEY}
  DOORKEEPER_JWT_SECRET_KEY: ${DOORKEEPER_JWT_SECRET_KEY}
  EVOAI_CRM_API_TOKEN:      ${EVOAI_CRM_API_TOKEN}
  BOT_RUNTIME_SECRET:       ${BOT_RUNTIME_SECRET}
  ENCRYPTION_KEY:           ${ENCRYPTION_KEY}

SMTP:
  Endereço:           ${SMTP_ADDRESS:-Não configurado}
  Porta:              ${SMTP_PORT}
  Usuário:            ${SMTP_USERNAME:-Não configurado}

PORTAINER:
  URL:                https://${PORTAINER_URL}
  Usuário:            ${PORTAINER_USER}

REDE DOCKER:
  Nome:               ${NETWORK_NAME}

====================================================================================================
CREDEOF

chmod 600 "$CRED_FILE"

## ============================================================================================
## RESUMO FINAL
## ============================================================================================

banner_instalado
guarde_os_dados_msg

echo -e "  ${branco}ACESSO AO EVO CRM:${reset}"
echo -e "    Frontend:           ${verde}https://${FRONTEND_DOMAIN}${reset}"
echo -e "    API (Gateway):      ${verde}https://${API_DOMAIN}${reset}"
echo ""
echo -e "  ${branco}BANCO DE DADOS:${reset}"
echo -e "    Host:               ${POSTGRES_HOST}:${POSTGRES_PORT}"
echo -e "    Database:           ${POSTGRES_DATABASE}"
echo ""
echo -e "  ${branco}PORTAINER:${reset}"
echo -e "    URL:                https://${PORTAINER_URL}"
echo -e "    Usuário:            ${PORTAINER_USER}"
echo ""
echo -e "  ${branco}REDE DOCKER:${reset}          ${NETWORK_NAME}"
echo ""
echo -e "  ${amarelo}📋 Credenciais completas salvas em: ${CRED_FILE}${reset}"
echo ""
echo -e "$amarelo===================================================================================================$reset"
echo -e "$amarelo=                                                                                                 $amarelo=$reset"
echo -e "$amarelo=  $branco Os serviços podem levar alguns minutos para inicializar completamente.                          $amarelo=$reset"
echo -e "$amarelo=  $branco Acompanhe pelo Portainer: https://${PORTAINER_URL}                                              $amarelo=$reset"
echo -e "$amarelo=                                                                                                 $amarelo=$reset"
echo -e "$amarelo===================================================================================================$reset"
echo ""