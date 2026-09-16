# Perfomance · time-perfomance
NOME=time-perfomance
TOKEN=gerado no item 2 quando criado o bot
MEU_ID=gerado no item 1 ao rodar o @userinfobot
hermes profile create "$NOME" --clone-from default 2>/dev/null || echo "→ profile já existia, seguindo"
printf 'TELEGRAM_ALLOWED_USERS=%s\nTELEGRAM_HOME_CHANNEL=%s\nTELEGRAM_BOT_TOKEN=%s\n' "$MEU_ID" "$MEU_ID" "$TOKEN" >> ~/profiles/"$NOME"/.env
setsid hermes -p "$NOME" gateway run --replace > "/tmp/$NOME.log" 2>&1 &
sleep 8 && hermes gateway status && tail -5 "/tmp/$NOME.log"



# Pedagógico · time-pedagogico
NOME=time-pedagogico
TOKEN=gerado no item 2 quando criado o bot
MEU_ID=gerado no item 1 ao rodar o @userinfobot
hermes profile create "$NOME" --clone-from default 2>/dev/null || echo "→ profile já existia, seguindo"
printf 'TELEGRAM_ALLOWED_USERS=%s\nTELEGRAM_HOME_CHANNEL=%s\nTELEGRAM_BOT_TOKEN=%s\n' "$MEU_ID" "$MEU_ID" "$TOKEN" >> ~/profiles/"$NOME"/.env
setsid hermes -p "$NOME" gateway run --replace > "/tmp/$NOME.log" 2>&1 &
sleep 8 && hermes gateway status && tail -5 "/tmp/$NOME.log"



# CS · time-cs
NOME=time-cs
TOKEN=gerado no item 2 quando criado o bot
MEU_ID=gerado no item 1 ao rodar o @userinfobot
hermes profile create "$NOME" --clone-from default 2>/dev/null || echo "→ profile já existia, seguindo"
printf 'TELEGRAM_ALLOWED_USERS=%s\nTELEGRAM_HOME_CHANNEL=%s\nTELEGRAM_BOT_TOKEN=%s\n' "$MEU_ID" "$MEU_ID" "$TOKEN" >> ~/profiles/"$NOME"/.env
setsid hermes -p "$NOME" gateway run --replace > "/tmp/$NOME.log" 2>&1 &
sleep 8 && hermes gateway status && tail -5 "/tmp/$NOME.log"



# Comercial · time-comercial
NOME=time-comercial
TOKEN=gerado no item 2 quando criado o bot
MEU_ID=gerado no item 1 ao rodar o @userinfobot
hermes profile create "$NOME" --clone-from default 2>/dev/null || echo "→ profile já existia, seguindo"
printf 'TELEGRAM_ALLOWED_USERS=%s\nTELEGRAM_HOME_CHANNEL=%s\nTELEGRAM_BOT_TOKEN=%s\n' "$MEU_ID" "$MEU_ID" "$TOKEN" >> ~/profiles/"$NOME"/.env
setsid hermes -p "$NOME" gateway run --replace > "/tmp/$NOME.log" 2>&1 &
sleep 8 && hermes gateway status && tail -5 "/tmp/$NOME.log"



# Conteúdo · time-conteudo
NOME=time-conteudo
TOKEN=gerado no item 2 quando criado o bot
MEU_ID=gerado no item 1 ao rodar o @userinfobot
hermes profile create "$NOME" --clone-from default 2>/dev/null || echo "→ profile já existia, seguindo"
printf 'TELEGRAM_ALLOWED_USERS=%s\nTELEGRAM_HOME_CHANNEL=%s\nTELEGRAM_BOT_TOKEN=%s\n' "$MEU_ID" "$MEU_ID" "$TOKEN" >> ~/profiles/"$NOME"/.env
setsid hermes -p "$NOME" gateway run --replace > "/tmp/$NOME.log" 2>&1 &
sleep 8 && hermes gateway status && tail -5 "/tmp/$NOME.log"



# reativar todos os profiles
setsid hermes -p default gateway run --replace > /tmp/default-gateway.log 2>&1 &
setsid hermes -p time-perfomance gateway run --replace > /tmp/time-perfomance-gateway.log 2>&1 &
setsid hermes -p time-pedagogico gateway run --replace > /tmp/time-pedagogico-gateway.log 2>&1 &
setsid hermes -p time-cs gateway run --replace > /tmp/time-cs-gateway.log 2>&1 &
setsid hermes -p time-comercial gateway run --replace > /tmp/time-comercial-gateway.log 2>&1 &
setsid hermes -p time-conteudo gateway run --replace > /tmp/time-conteudo-gateway.log 2>&1 &
sleep 8
hermes gateway list