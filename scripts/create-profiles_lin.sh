NOME= # profile name
CHANNEL_NAME= # agent name
TOKEN= # token do bot
MEU_ID= # Telegram user id
echo
echo "→ Criando profile $NOME..."
hermes profile create "$NOME" --clone-from default 2>/dev/null || echo "→ profile já existia, seguindo"
ENV_FILE="$HOME/AppData/Local/hermes/profiles/$NOME/.env"
sed -i '/^OPENROUTER_API_KEY=/d' "$ENV_FILE"
sed -i '/^TELEGRAM_HOME_CHANNEL_NAME=/d' "$ENV_FILE"
sed -i '/^TELEGRAM_HOME_CHANNEL=/d' "$ENV_FILE"
sed -i '/^TELEGRAM_ALLOWED_USERS=/d' "$ENV_FILE"
sed -i '/^TELEGRAM_BOT_TOKEN=/d' "$ENV_FILE"
printf '%s\n' \
  "OPENROUTER_API_KEY=$OPENROUTER_API_KEY" \
  "TELEGRAM_HOME_CHANNEL_NAME=$CHANNEL_NAME" \
  "TELEGRAM_HOME_CHANNEL=$MEU_ID" \
  "TELEGRAM_ALLOWED_USERS=$MEU_ID" \
  "TELEGRAM_BOT_TOKEN=$TOKEN" \
  >> "$ENV_FILE"
echo
echo "→ Iniciando gateway do profile $NOME..."
setsid hermes -p "$NOME" gateway run --replace > "/tmp/$NOME.log" 2>&1 &
GATEWAY_PID=$!
echo "Gateway iniciado. PID: $GATEWAY_PID"
echo "→ Aguardando inicialização..."
sleep 8 
echo
echo "→ Status do gateway:"
hermes gateway status && tail -5 "/tmp/$NOME.log"


# reativar todos os profiles
setsid hermes -p default gateway run --replace > /tmp/default-gateway.log 2>&1 &
setsid hermes -p time-perfomance gateway run --replace > /tmp/<profile_name>.log 2>&1 &
sleep 8
hermes gateway list