# Entendendo o Bloco de Comando

## Comando para Cadastro dos Agentes

```bash
NOME=time-perfomance
TOKEN=gerado no item 2 quando criado o bot
MEU_ID=gerado no item 1 ao rodar o @userinfobot

hermes profile create "$NOME" --clone-from default 2>/dev/null || echo "→ profile já existia, seguindo"
printf 'TELEGRAM_ALLOWED_USERS=%s\nTELEGRAM_HOME_CHANNEL=%s\nTELEGRAM_BOT_TOKEN=%s\n' "$MEU_ID" "$MEU_ID" "$TOKEN" >> ~/profiles/"$NOME"/.env
setsid hermes -p "$NOME" gateway run --replace > "/tmp/$NOME.log" 2>&1 &
sleep 8 && hermes gateway status && tail -5 "/tmp/$NOME.log"
```

Esse bloco de comandos faz **3 coisas principais**:

- cria um perfil do Hermes;
- configura as variáveis do Telegram;
- inicia o Gateway em segundo plano.

### Step 1 — Criar o perfil

```bash
hermes profile create "$NOME" --clone-from default 2>/dev/null || echo "→ profile já existia, seguindo"
```

* `"$NOME"` → nome do novo perfil.
* `--clone-from default` → copia a configuração do perfil `default`.
* `2>/dev/null` → oculta mensagens de erro.
* `|| echo ...` → se o perfil já existir, apenas informa e continua.

---

### Step 2 — Criar o `.env` do perfil

```bash
printf 'TELEGRAM_ALLOWED_USERS=%s\nTELEGRAM_HOME_CHANNEL=%s\nTELEGRAM_BOT_TOKEN=%s\n' "$MEU_ID" "$MEU_ID" "$TOKEN" >> ~/profiles/"$NOME"/.env
```

Caso não exista o arquivo .env ele é criado ou somente adiciona as novas informações ao final do arquivo:

```text
~/profiles/$NOME/.env
```

Com três variáveis:

```env
TELEGRAM_ALLOWED_USERS=SEU_ID
TELEGRAM_HOME_CHANNEL=SEU_ID
TELEGRAM_BOT_TOKEN=SEU_TOKEN
```

As variáveis utilizadas são:

| Variável  | Origem      | Função                       |
| --------- | ----------- | ---------------------------- |
| `$NOME`   | você define | Nome do perfil               |
| `$MEU_ID` | você define | ID permitido/canal principal |
| `$TOKEN`  | você define | Token do bot Telegram        |

---

### Step 3 — Iniciar o Gateway

```bash
setsid hermes -p "$NOME" gateway run --replace > "/tmp/$NOME.log" 2>&1 &
```

Aqui o Hermes é iniciado usando o perfil criado.

* `-p "$NOME"` → utiliza esse perfil.
* `gateway run` → inicia o Gateway.
* `--replace` → substitui uma instância existente.
* `> "/tmp/$NOME.log"` → grava a saída no log.
* `2>&1` → grava erros no mesmo log.
* `&` → executa em segundo plano.
* `setsid` → mantém o processo independente do terminal.

O log ficará em:

```text
/tmp/$NOME.log
```

---

### Step 4 — Esperar o Gateway iniciar

```bash
sleep 8
```

Aguarda **8 segundos** para dar tempo ao Gateway de inicializar.

---

### Step 5 — Verificar o status

```bash
hermes gateway status
```

Verifica se o Gateway está funcionando.

---

### Step 6 — Ver as últimas mensagens do log

```bash
tail -5 "/tmp/$NOME.log"
```

Mostra as **5 últimas linhas** do log.

Isso é útil para identificar rapidamente erros de inicialização.

---

### Fluxo completo

Em termos simples:

```text
$NOME
  │
  ▼
Criar perfil Hermes
  │
  ▼
~/profiles/$NOME/
  │
  ├── .env
  │     ├── TELEGRAM_ALLOWED_USERS
  │     ├── TELEGRAM_HOME_CHANNEL
  │     └── TELEGRAM_BOT_TOKEN
  │
  ▼
Iniciar Gateway
  │
  ▼
/tmp/$NOME.log
  │
  ▼
Aguardar 8s
  │
  ├── hermes gateway status
  │
  └── tail -5 log
```

### Antes de executar

Você precisa ter definido:

```bash
NOME="meu-perfil"
MEU_ID="123456789"
TOKEN="seu_token_do_bot"
```

Depois pode executar o bloco completo.

---

## Comando para Reativar o Gateway

Esse snippet inicia 6 processos independentes do Hermes Gateway em background, cada um associado a um profile diferente, aguarda 8 segundos para dar tempo de inicialização e, por fim, lista os gateways ativos.

### 1. Estrutura geral

Todas as linhas seguem este padrão:

```bash
setsid hermes -p <PROFILE> gateway run --replace > /tmp/<LOG>.log 2>&1 &
```

Por exemplo:

```bash
setsid hermes -p default gateway run --replace > /tmp/default-gateway.log 2>&1 &
```

Significa:

| Parte                      | Função                                                                           |
| -------------------------- | -------------------------------------------------------------------------------- |
| `setsid`                   | Executa o processo em uma nova sessão, tornando-o independente do terminal atual |
| `hermes`                   | Executa o Hermes                                                                 |
| `-p default`               | Seleciona o profile `default`                                                    |
| `gateway run`              | Inicia o Gateway desse profile                                                   |
| `--replace`                | Substitui/reinicia um Gateway existente para aquele profile                      |
| `>`                        | Redireciona a saída normal para um arquivo                                       |
| `/tmp/default-gateway.log` | Arquivo onde o log será gravado                                                  |
| `2>&1`                     | Envia também os erros (`stderr`) para o mesmo arquivo                            |
| `&`                        | Executa o processo em background                                                 |

---

### 2. O que acontece com cada profile

O comando inicia:

```text
default
    ↓
Gateway
    ↓
/tmp/default-gateway.log
```

Depois:

```text
time-perfomance
    ↓
Gateway
    ↓
/tmp/time-perfomance-gateway.log
```

E assim por diante:

```text
time-pedagogico
time-cs
time-comercial
time-conteudo
```

Portanto, ao final existem potencialmente **6 Gateways Hermes rodando simultaneamente**.
Uma representação seria:

```text
                    ┌─ default ──────────────── Gateway
                    │
                    ├─ time-perfomance ──────── Gateway
Hermes ── profiles ─┼─ time-pedagogico ──────── Gateway
                    │
                    ├─ time-cs ──────────────── Gateway
                    │
                    ├─ time-comercial ───────── Gateway
                    │
                    └─ time-conteudo ────────── Gateway
```

### 3. Por que usar `setsid`?

Essa parte é importante:

```bash
setsid hermes ...
```

`setsid` cria uma **nova sessão Linux** para o processo. Isso ajuda a evitar que o Gateway fique diretamente vinculado ao terminal que executou o comando.
Sem `setsid`, você poderia simplesmente fazer:

```bash
hermes -p default gateway run &
```

Com:

```bash
setsid hermes -p default gateway run &
```

O processo fica mais independente da sessão do shell. Isso é especialmente útil quando você está iniciando serviços que devem continuar funcionando depois que o terminal é fechado.

**Atenção:** 
Se você estiver rodando este processo a partir de uma VPS o `setsid` não transforma o processo em um serviço do `systemd`. Para operação permanente em servidor rodando Docker ou outro process manager, substitua o  `setsid` por `systemd`,  normalmente é mais apropriado.

---

### 4. O que significa `--replace`

Esta parte:

```bash
gateway run --replace
```

indica que o Hermes deve **substituir/reiniciar um Gateway existente** para aquele profile, em vez de simplesmente falhar porque já existe um Gateway em execução.
Isso torna o script mais idempotente para inicialização:

```text
Gateway já existe?
       │
       ├── Sim → substitui/reinicia
       │
       └── Não → inicia
```

Isso é particularmente útil se você executar o snippet novamente.

---

### 5. Os logs

Cada Gateway possui seu próprio arquivo:

```text
/tmp/default-gateway.log
/tmp/time-perfomance-gateway.log
/tmp/time-pedagogico-gateway.log
/tmp/time-cs-gateway.log
/tmp/time-comercial-gateway.log
/tmp/time-conteudo-gateway.log
```

Por exemplo:

```bash
tail -f /tmp/time-cs-gateway.log
```

permite acompanhar o Gateway `time-cs` em tempo real.

Para verificar rapidamente todos:

```bash
ls -lh /tmp/*gateway.log
```

Ou:

```bash
tail -n 20 /tmp/*gateway.log
```

---

### 6. Por que existe o `sleep 8`?

Depois de iniciar os seis processos:

```bash
sleep 8
```

o shell espera **8 segundos**.

Isso dá tempo para os Gateways iniciarem antes de executar:

```bash
hermes gateway list
```

Sem essa espera, poderia acontecer:

```text
inicia Gateway
inicia Gateway
...
imediatamente executa "gateway list"
              ↓
alguns Gateways ainda estão inicializando
              ↓
lista incompleta ou estados intermediários
```

Com os 8 segundos:

```text
Inicia 6 Gateways
       ↓
   espera 8 s
       ↓
hermes gateway list
       ↓
verifica o estado
```

---

### 7. O último comando

```bash
hermes gateway list
```

é usado para **listar os Gateways conhecidos/ativos pelo Hermes**.

É basicamente uma verificação:

> "Depois de iniciar os seis profiles, quais Gateways estão disponíveis e em que estado estão?"

---

### Resumo

O snippet funciona como um pequeno **script de inicialização de múltiplos Gateways Hermes**:

```text
                 ┌─ default
                 ├─ time-perfomance
                 ├─ time-pedagogico
                 ├─ time-cs
                 ├─ time-comercial
                 └─ time-conteudo
                        │
                        ▼
              inicia em background
                        │
                        ▼
                 grava logs
                        │
                        ▼
                  espera 8 s
                        │
                        ▼
             hermes gateway list
```

> Também vale observar que **cada profile precisa existir previamente** para que essa estratégia funcione como esperado.
