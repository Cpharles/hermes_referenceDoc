#!/usr/bin/env bash

# ============================================================
# Hermes Agent - Criar e configurar Profile
# Ambiente: Windows + Git Bash
# ============================================================

set -u

# ============================================================
# 1. CONFIGURAÇÃO DO NOVO PROFILE
# ============================================================

NOME="time-performance"
MEU_ID="758543036"
TOKEN="88...."


# ============================================================
# 2. CAMINHOS
# ============================================================

HERMES_HOME="$HOME/AppData/Local/hermes"
GLOBAL_ENV="$HERMES_HOME/.env"
PROFILE_DIR="$HERMES_HOME/profiles/$NOME"
ENV_FILE="$PROFILE_DIR/.env"
LOG_FILE="/tmp/$NOME-gateway.log"


# ============================================================
# 3. FUNÇÕES AUXILIARES
# ============================================================

erro() {
    echo
    echo "❌ ERRO: $1"
    exit 1
}

ok() {
    echo "✓ $1"
}


# ============================================================
# 4. VALIDAR CONFIGURAÇÕES
# ============================================================

echo
echo "============================================================"
echo " Hermes Agent - Criação de Profile"
echo "============================================================"
echo

echo "Profile: $NOME"
echo "Telegram ID: $MEU_ID"
echo

[[ -n "$NOME" ]] || erro "NOME não foi definido."
[[ -n "$MEU_ID" ]] || erro "MEU_ID não foi definido."
[[ -n "$TOKEN" ]] || erro "TOKEN do Telegram não foi definido."

ok "Variáveis básicas encontradas."


# ============================================================
# 5. VALIDAR INSTALAÇÃO DO HERMES
# ============================================================

if ! command -v hermes >/dev/null 2>&1; then
    erro "Comando 'hermes' não encontrado no PATH."
fi

ok "Hermes encontrado."


# ============================================================
# 6. VALIDAR .ENV GLOBAL
# ============================================================

if [[ ! -f "$GLOBAL_ENV" ]]; then
    erro "Arquivo global do Hermes não encontrado:

$GLOBAL_ENV"
fi

ok "Arquivo global do Hermes encontrado."


# ============================================================
# 7. OBTER OPENROUTER_API_KEY DO .ENV GLOBAL
# ============================================================

OPENROUTER_API_KEY=$(
    grep '^OPENROUTER_API_KEY=' "$GLOBAL_ENV" \
    | head -1 \
    | cut -d= -f2-
)

if [[ -z "$OPENROUTER_API_KEY" ]]; then
    erro "OPENROUTER_API_KEY não encontrada em:

$GLOBAL_ENV"
fi

ok "OPENROUTER_API_KEY encontrada no .env global."


# ============================================================
# 8. VERIFICAR SE O PROFILE JÁ EXISTE
# ============================================================

if [[ -d "$PROFILE_DIR" ]]; then

    echo
    echo "⚠ O profile '$NOME' já existe:"
    echo "$PROFILE_DIR"
    echo

    echo "Para evitar sobrescrever configurações existentes,"
    echo "o script será encerrado."

    echo
    echo "Se deseja recriá-lo, execute:"
    echo
    echo "    hermes profile delete $NOME"
    echo

    exit 1
fi


# ============================================================
# 9. CRIAR PROFILE
# ============================================================

echo
echo "→ Criando profile '$NOME'..."

if ! hermes profile create "$NOME" --clone-from default; then
    erro "Falha ao criar o profile."
fi

ok "Profile criado."


# ============================================================
# 10. VALIDAR .ENV DO PROFILE
# ============================================================

if [[ ! -f "$ENV_FILE" ]]; then
    erro "O .env do novo profile não foi encontrado:

$ENV_FILE"
fi

ok "Arquivo .env do profile encontrado."


# ============================================================
# 11. CONFIGURAR API E TELEGRAM
# ============================================================

echo
echo "→ Configurando API OpenRouter e Telegram..."


# Remover configurações anteriores destas variáveis.
# O restante do .env permanece intacto.

sed -i '/^OPENROUTER_API_KEY=/d' "$ENV_FILE"
sed -i '/^TELEGRAM_ALLOWED_USERS=/d' "$ENV_FILE"
sed -i '/^TELEGRAM_HOME_CHANNEL=/d' "$ENV_FILE"
sed -i '/^TELEGRAM_BOT_TOKEN=/d' "$ENV_FILE"


# Adicionar configurações do novo profile.

printf '%s\n' \
    "OPENROUTER_API_KEY=$OPENROUTER_API_KEY" \
    "TELEGRAM_ALLOWED_USERS=$MEU_ID" \
    "TELEGRAM_HOME_CHANNEL=$MEU_ID" \
    "TELEGRAM_BOT_TOKEN=$TOKEN" \
    >> "$ENV_FILE"

ok "Configurações adicionadas."


# ============================================================
# 12. VALIDAR CONFIGURAÇÕES DO PROFILE
# ============================================================

echo
echo "→ Validando configuração..."

grep -q '^OPENROUTER_API_KEY=' "$ENV_FILE" \
    || erro "OPENROUTER_API_KEY não foi configurada."

grep -q '^TELEGRAM_ALLOWED_USERS=' "$ENV_FILE" \
    || erro "TELEGRAM_ALLOWED_USERS não foi configurada."

grep -q '^TELEGRAM_HOME_CHANNEL=' "$ENV_FILE" \
    || erro "TELEGRAM_HOME_CHANNEL não foi configurada."

grep -q '^TELEGRAM_BOT_TOKEN=' "$ENV_FILE" \
    || erro "TELEGRAM_BOT_TOKEN não foi configurada."

ok "Configuração validada."


# ============================================================
# 13. MOSTRAR CONFIGURAÇÃO SEM EXPOR SECRETS
# ============================================================

echo
echo "Configuração do profile:"
echo "----------------------------------------"

echo "Profile: $NOME"
echo "ENV:     $ENV_FILE"

grep '^OPENROUTER_API_KEY=' "$ENV_FILE" \
    | sed 's/=.*/=***REDACTED***/'

grep '^TELEGRAM_ALLOWED_USERS=' "$ENV_FILE"

grep '^TELEGRAM_HOME_CHANNEL=' "$ENV_FILE"

grep '^TELEGRAM_BOT_TOKEN=' "$ENV_FILE" \
    | sed 's/=.*/=***REDACTED***/'

echo "----------------------------------------"


# ============================================================
# 14. INICIAR GATEWAY DO PROFILE
# ============================================================

echo
echo "→ Iniciando gateway do profile..."

# Windows + Git Bash:
# NÃO utilizar setsid.

hermes -p "$NOME" gateway run --replace \
    > "$LOG_FILE" 2>&1 &

GATEWAY_PID=$!

echo "Gateway iniciado."
echo "PID: $GATEWAY_PID"
echo "Log: $LOG_FILE"


# ============================================================
# 15. AGUARDAR INICIALIZAÇÃO
# ============================================================

echo
echo "→ Aguardando inicialização..."

sleep 8


# ============================================================
# 16. VERIFICAR GATEWAY
# ============================================================

echo
echo "→ Verificando profiles..."

PROFILE_STATUS=$(
    hermes profile list 2>/dev/null \
    | awk -v profile="$NOME" '$1 == profile {print $3}'
)


# ============================================================
# 17. RESULTADO
# ============================================================

echo

if [[ "$PROFILE_STATUS" == "running" ]]; then

    echo "============================================================"
    echo " ✅ PROFILE CRIADO E ATIVO"
    echo "============================================================"
    echo
    echo "Profile : $NOME"
    echo "Status  : running"
    echo "PID     : $GATEWAY_PID"
    echo "Log     : $LOG_FILE"
    echo

else

    echo "============================================================"
    echo " ❌ PROFILE NÃO ESTÁ RUNNING"
    echo "============================================================"
    echo
    echo "Status detectado: ${PROFILE_STATUS:-desconhecido}"
    echo
    echo "Últimas 30 linhas do log:"
    echo "------------------------------------------------------------"

    if [[ -f "$LOG_FILE" ]]; then
        tail -30 "$LOG_FILE"
    else
        echo "Log não encontrado: $LOG_FILE"
    fi

    echo "------------------------------------------------------------"
    echo

    echo "Verifique também:"
    echo
    echo "    hermes profile list"
    echo "    hermes gateway status"
    echo

    exit 1
fi