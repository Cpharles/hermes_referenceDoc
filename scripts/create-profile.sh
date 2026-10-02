#!/usr/bin/env bash

# ============================================================
# Hermes Agent - Criar e configurar Profile
# Ambientes: Windows ou Linux (Ubuntu / Debian)
# ============================================================

set -uo pipefail

# ============================================================
# 0. COMO UTILIZAR O SCRIPT
# ============================================================
# Abra o terminal de sua preferência (Git Bash, PowerShell, CMD) e navegue até o diretório onde está o script. 
# MANDATÓRIO: Antes de executar o script rode o comando para carregar o TOKEN em uma variável de ambiente para o shell:  export TELEGRAM_BOT_TOKEN="<token>"
# Exemplo de execução:
#   export TELEGRAM_BOT_TOKEN="123456:ABCDEF"
#   bash create-profile_win.sh


# ============================================================
# 1. CONFIGURAÇÃO DO NOVO PROFILE
# ============================================================

# ALTERAR SOMENTE ESTAS VARIÁVEIS PARA CRIAR UM NOVO PROFILE:
# ↧------------------------------↧
PROFILE_NAME_RAW="<profile_name>"       # Nome do profile
CHANNEL_NAME="<bot_name>"               # Nome amigável do bot (TELEGRAM_HOME_CHANNEL_NAME)
USER_ID="<user_id>"                     # User ID do Telegram (DM) — pode adicionar vários separando por ,
DIRETORIO_HERMES="<local_do_hermes>"    # Caminho onde está o diretório do Hermes
# (padrão para Windows em $HOME/AppData/Local/hermes)
# (padrão para Linux em $HOME/<user>/.hermes)
# ↥------------------------------↥


# ⚠ NÃO coloque o token no script.
BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}"     # Token do bot do Telegram (TELEGRAM_BOT_TOKEN)
PLATFORM="telegram"                     # Plataforma alvo
HOME_CHANNEL_ID="$USER_ID"              # Chat ID para HOME_CHANNEL (normalmente = USER_ID em DM)
CLONE_FROM="${CLONE_FROM:-default}"     # Profile base para clonar

# -------- Normalização: PROFILE_NAME sempre em minúsculo --------
PROFILE_NAME="$(printf '%s' "$PROFILE_NAME_RAW" | tr '[:upper:]' '[:lower:]')"

# Valida caracteres permitidos (letras, números, _ e -)
if [[ ! "$PROFILE_NAME" =~ ^[a-z0-9_-]+$ ]]; then
    echo
    echo "❌ ERRO: PROFILE_NAME contém caracteres inválidos: '$PROFILE_NAME'" >&2
    echo "   Permitido: letras minúsculas, números, '_' e '-'." >&2
    exit 1
fi
# ----------------------------------------------------------------

# ============================================================
# 2. CAMINHOS
# ============================================================

HERMES_HOME="$DIRETORIO_HERMES"
PROFILE_DIR="$HERMES_HOME/profiles/$PROFILE_NAME"
ENV_FILE="$PROFILE_DIR/.env"
CONFIG_FILE="$PROFILE_DIR/config.yaml"
SOUL_FILE="$PROFILE_DIR/SOUL.md"

# ============================================================
# 3. FUNÇÕES AUXILIARES
# ============================================================

erro() {
    echo
    echo "❌ ERRO: $1" >&2
    exit 1
}

ok() {
    echo "✓ $1"
}

aviso() {
    echo "⚠ $1"
}

backup_file() {
    local f="$1"
    [[ -f "$f" ]] || return 0
    local stamp
    stamp="$(date +%Y%m%d_%H%M%S)"
    cp -n "$f" "${f}.bak.${stamp}" 2>/dev/null || true
}

normalize_lf() {
    local f="$1"
    [[ -f "$f" ]] || return 0
    if grep -q $'\r' "$f" 2>/dev/null; then
        sed -i 's/\r$//' "$f"
    fi
}

# ============================================================
# 4. VALIDAÇÕES INICIAIS
# ============================================================
echo
echo "============================================================"
echo " Hermes Agent - Criação de Profile"
echo "============================================================"
echo
echo "Profile: $PROFILE_NAME"
echo

command -v hermes >/dev/null 2>&1 || erro "'hermes' não encontrado no PATH."

[[ -n "$PROFILE_NAME"    ]] || erro "PROFILE_NAME não foi definido."
[[ -n "$CHANNEL_NAME"    ]] || erro "CHANNEL_NAME não foi definido."
[[ -n "$USER_ID"         ]] || erro "USER_ID não foi definido."
[[ -n "$HOME_CHANNEL_ID" ]] || erro "HOME_CHANNEL_ID não foi definido."
[[ -n "$PLATFORM"        ]] || erro "PLATFORM não foi definido."
[[ -n "$BOT_TOKEN"       ]] || erro "BOT_TOKEN não definido. Exporte TELEGRAM_BOT_TOKEN antes de rodar."

ok "Variáveis básicas encontradas."
ok "Comando 'hermes' disponível."

# ============================================================
# 5. VERIFICAR SE O PROFILE JÁ EXISTE
# ============================================================

if [[ -d "$PROFILE_DIR" ]]; then
    echo
    aviso "O profile '$PROFILE_NAME' já existe:"
    echo "    $PROFILE_DIR"
    echo
    echo "Para evitar sobrescrever configurações existentes,"
    echo "o script será encerrado."
    echo
    echo "Se deseja recriá-lo, apague antes com:"
    echo
    echo "    hermes profile delete $PROFILE_NAME"
    echo
    echo "Ou escolha outro nome em PROFILE_NAME_RAW no início do script."
    exit 1
fi

# ============================================================
# 6. CRIAR PROFILE
# ============================================================
echo
echo "╭⎯⎯  Criando profile: '$PROFILE_NAME' (clone de '$CLONE_FROM')...  ⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯╮"

if ! hermes profile create "$PROFILE_NAME" --clone-from "$CLONE_FROM"; then
    erro "Falha ao criar o profile."
fi
echo "╰⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯╯"

ok "Profile criado."

# ============================================================
# 7. VALIDAR PRINCIPAIS ARQUIVOS DO PROFILE
# ============================================================

[[ -f "$ENV_FILE"    ]] || erro "Arquivo .env não encontrado:
$ENV_FILE"
ok "Arquivo .env encontrado."

[[ -f "$CONFIG_FILE" ]] || erro "Arquivo config.yaml não encontrado:
$CONFIG_FILE"
ok "Arquivo config.yaml encontrado."

[[ -f "$SOUL_FILE"   ]] || erro "Arquivo SOUL.md não encontrado:
$SOUL_FILE"
ok "Arquivo SOUL.md encontrado."

normalize_lf "$ENV_FILE"
normalize_lf "$CONFIG_FILE"
backup_file "$ENV_FILE"
backup_file "$CONFIG_FILE"
ok "Backups criados (se aplicável)."

# ============================================================
# 8. REGISTRAR DADOS DO TELEGRAM
# ============================================================
echo
echo "→ Configurando parâmetros do Telegram..."

# -------- 8a. .env --------
awk '
    !/^TELEGRAM_(HOME_CHANNEL_NAME|ALLOWED_USERS|HOME_CHANNEL|BOT_TOKEN)=/
' "$ENV_FILE" > "$ENV_FILE.tmp" && mv "$ENV_FILE.tmp" "$ENV_FILE"

{
    printf 'TELEGRAM_HOME_CHANNEL_NAME=%s\n' "$CHANNEL_NAME"
    printf 'TELEGRAM_ALLOWED_USERS=%s\n'     "$USER_ID"
    printf 'TELEGRAM_HOME_CHANNEL=%s\n'      "$HOME_CHANNEL_ID"
    printf 'TELEGRAM_BOT_TOKEN=%s\n'         "$BOT_TOKEN"
} >> "$ENV_FILE"

ok "Variáveis do Telegram gravadas em .env."

# -------- 8b. config.yaml --------
# Se não encontrado o bloco 'platforms.telegram', adciona ao final do arquivo
if ! grep -q '^platforms:' "$CONFIG_FILE"; then
    cat <<EOL >> "$CONFIG_FILE"
platforms:
  telegram:
    enabled: true
    extra:
      allow_admin_from: "$USER_ID"
      user_allowed_commands: []
    home_channel:
      platform: telegram
      chat_id: "$HOME_CHANNEL_ID"
EOL
    ok "Seção 'platforms.telegram' adicionada ao config.yaml."

# Se encontrado 'platforms:' mas não 'telegram:', adiciona subseção 'telegram' dentro de 'platforms'
elif ! grep -q '^[[:space:]]\{2,\}telegram:[[:space:]]*$' "$CONFIG_FILE"; then
    awk -v id="$HOME_CHANNEL_ID" '
        BEGIN { inserted = 0 }
        {
            print
            if (!inserted && $0 ~ /^platforms:[[:space:]]*$/) {
                print "  telegram:"
                print "    enabled: true"
                print "    extra:"
                print "      allow_admin_from: \"" ENVIRON["USER_ID"] "\""
                print "      user_allowed_commands: []"
                print "    home_channel:"
                print "      platform: telegram"
                print "      chat_id: \"" id "\""
                inserted = 1
            }
        }
    ' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    ok "Subseção 'telegram' inserida dentro de 'platforms'."

# Se encontrado 'platforms.telegram', atualiza os valores de 'enabled' e 'chat_id'
else
    awk -v id="$HOME_CHANNEL_ID" '
        BEGIN { in_platforms=0; in_telegram=0; tg_indent=0 }
        /^platforms:[[:space:]]*$/ { in_platforms=1; print; next }

        in_platforms && /^[^[:space:]]/ { in_platforms=0; in_telegram=0 }

        in_platforms && match($0, /^[[:space:]]+telegram:[[:space:]]*$/) {
            in_telegram=1
            tg_indent = match($0, /[^ ]/) - 1
            print; next
        }

        in_telegram {
            cur_indent = match($0, /[^ ]/) - 1
            if ($0 !~ /^[[:space:]]*$/ && cur_indent <= tg_indent && $0 ~ /^[[:space:]]*[A-Za-z0-9_]+:/) {
                in_telegram=0
            } else {
                if ($0 ~ /^[[:space:]]*enabled:/) {
                    sub(/enabled:[[:space:]]*.*/, "enabled: true")
                }
                if ($0 ~ /^[[:space:]]*chat_id:/) {
                    sub(/chat_id:[[:space:]]*.*/, "chat_id: \"" id "\"")
                }
                if ($0 ~ /^[[:space:]]*allow_admin_from:/) {
                    sub(/allow_admin_from:[[:space:]]*.*/, "allow_admin_from: \"" ENVIRON["USER_ID"] "\"")
                }
                if ($0 ~ /^[[:space:]]*user_allowed_commands:/) {
                    sub(/user_allowed_commands:[[:space:]]*.*/, "user_allowed_commands: []")
                }
            }
        }
        { print }
    ' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    ok "Configurações do 'telegram' atualizadas no config.yaml."
fi

# ============================================================
# 9. VALIDAR CONFIGURAÇÕES DO PROFILE
# ============================================================
echo
echo "→ Confirmando e validando a configuração do Telegram..."

grep -q '^TELEGRAM_HOME_CHANNEL_NAME=' "$ENV_FILE" || erro "TELEGRAM_HOME_CHANNEL_NAME não configurada."
grep -q '^TELEGRAM_ALLOWED_USERS='     "$ENV_FILE" || erro "TELEGRAM_ALLOWED_USERS não configurada."
grep -q '^TELEGRAM_HOME_CHANNEL='      "$ENV_FILE" || erro "TELEGRAM_HOME_CHANNEL não configurada."
grep -q '^TELEGRAM_BOT_TOKEN='         "$ENV_FILE" || erro "TELEGRAM_BOT_TOKEN não configurada."

grep -q '^platforms:'                               "$CONFIG_FILE" || erro "Seção 'platforms' ausente no config.yaml."
grep -q '^[[:space:]]\{2,\}telegram:[[:space:]]*$'  "$CONFIG_FILE" || erro "Seção 'telegram' ausente no config.yaml."

ok "Configuração validada."

# ============================================================
# 10. RESUMO DA CONFIGURAÇÃO (SEM EXPOR TOKEN)
# ============================================================
echo
echo "----------------------------------------"
echo "Resumo da Configuração do profile:"
echo "----------------------------------------"
echo "Profile:       $PROFILE_NAME"
echo ".env file:     $ENV_FILE"
echo "config file:   $CONFIG_FILE"
echo
echo "Arquivo das variáveis --- .env ---"
grep '^TELEGRAM_HOME_CHANNEL_NAME=' "$ENV_FILE"
grep '^TELEGRAM_ALLOWED_USERS='     "$ENV_FILE"
grep '^TELEGRAM_HOME_CHANNEL='      "$ENV_FILE"
grep '^TELEGRAM_BOT_TOKEN='         "$ENV_FILE" \
    | sed -E 's/(=[0-9]+:)[A-Za-z0-9_-]+/\1***REDACTED***/'

extract_platform_block() {
    local file="$1" platform="$2"
    awk -v target="$platform" '
        /^platforms:[[:space:]]*$/ { in_platforms = 1; next }
        in_platforms && /^[^[:space:]]/ { in_platforms = 0 }

        in_platforms && match($0, /^[[:space:]]+[A-Za-z0-9_]+:[[:space:]]*$/) {
            line = $0
            sub(/^[[:space:]]+/, "", line)
            sub(/:.*$/, "", line)
            if (line == target) {
                found = 1
                indent = match($0, /[^ ]/) - 1
                print $0
                next
            }
            if (found) {
                cur_indent = match($0, /[^ ]/) - 1
                if (cur_indent <= indent && $0 ~ /^[[:space:]]*[A-Za-z0-9_]+:/) exit
            }
        }

        found && !/^[[:space:]]*$/ {
            cur_indent = match($0, /[^ ]/) - 1
            if (cur_indent > indent) print $0
            else if ($0 ~ /^[[:space:]]*[A-Za-z0-9_]+:/) exit
        }
    ' "$file"
}

echo
echo "--- config.yaml (plataforma '$PLATFORM') ---"
block="$(extract_platform_block "$CONFIG_FILE" "$PLATFORM")"
echo "$block"

enabled="$(printf '%s\n' "$block"  | awk -F': *' '/^[[:space:]]*enabled:/{print $2; exit}')"
platform="$(printf '%s\n' "$block" | awk -F': *' '/^[[:space:]]*platform:/{print $2; exit}')"
chat_id="$(printf '%s\n' "$block"  | awk -F'"'   '/chat_id:/{print $2; exit}')"

if [[ -z "$enabled" || -z "$platform" || -z "$chat_id" ]]; then
    aviso "Não foi possível extrair todas as chaves da plataforma '$PLATFORM'."
fi

if [[ ${#chat_id} -ge 6 ]]; then
    chat_id_masked="${chat_id:0:3}***${chat_id: -2}"
else
    chat_id_masked="$chat_id"
fi

echo "----------------------------------------"

# ============================================================
# 11. RESULTADO
# ============================================================
echo
echo "============================================================"
echo " ✅ PROFILE CRIADO COM SUCESSO!"
echo "============================================================"
echo
echo "Profile Name (Agente) : $PROFILE_NAME"
echo
echo "------------------------------------------------------------"
echo
echo "Próximos passos:"
echo
echo "    hermes profile list"
echo "    hermes gateway status"
echo