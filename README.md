# Instalador EVO CRM Community

## Instalação Rápida

Execute o seguinte comando no seu servidor Linux:

```bash
bash <(curl -sSL https://raw.githubusercontent.com/alexbuzatto/intaldorevocrm/main/install-evo-crm.sh)
```

Ou em 2 passos:

```bash
curl -sSL https://raw.githubusercontent.com/alexbuzatto/intaldorevocrm/main/install-evo-crm.sh -o install-evo-crm.sh
bash install-evo-crm.sh
```

## O que o instalador solicita

1. **Credenciais do Portainer**
   - URL do Portainer (ex: painel.eclicksolucoes.com.br)
   - Usuário do Portainer
   - Senha do Portainer

2. **Configurações do Banco de Dados**
   - Nome da rede interna (ex: eclick)
   - Senha do PostgreSQL
   - Senha do Redis (ENTER = sem senha)

3. **Domínios**
   - Domínio principal da API (ex: evocrmapi.eclicksolucoes.com.br)
   - Domínio do Frontend (ex: evocrm.eclicksolucoes.com.br)

4. **Dados do Administrador**
   - Email do administrador
   - Nome do administrador
   - Senha do administrador (mínimo 8 caracteres)
   - Nome da organização

## O que é instalado

- **postgres** - Banco de dados PostgreSQL com pgvector
- **redis** - Cache/fila Redis
- **evo-auth** - Serviço de autenticação (porta 3001)
- **evo-auth-sidekiq** - Processador de jobs do auth
- **evo-crm** - API do CRM (porta 3000)
- **evo-crm-sidekiq** - Processador de jobs do CRM
- **evo-core** - Serviço de núcleo (porta 5555)
- **evo-processor** - Processador de agentes IA (porta 8000)
- **evo-bot-runtime** - Runtime de bots (porta 8080)
- **evo-frontend** - Interface web

## Acesso após instalação

- **Frontend**: https://seu-dominio-frontend
- **API**: https://seu-dominio-api
- **Portainer**: https://seu-portainer

## Requisitos

- Docker Swarm configurado
- Traefik configurado
- Portainer configurado
- Acesso à internet para baixar imagens

## Problemas Comuns

### Erro ao autenticar no Portainer
Verifique se o usuário e senha estão corretos.

###Rede não existe
Certifique-se que a rede interna já está criada no Docker Swarm.