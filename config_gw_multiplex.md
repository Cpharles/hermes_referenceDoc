# Configuração do Gateway Hermes Agent — Padrão Multiplex

> Guia passo a passo para configuração do zero com perfil default + um profile adicional,
> registrando no Windows Scheduled Task/Startup e migrando para o padrão multiplex.

---

## Visão Geral

O **gateway** é o processo que mantém conexão com as plataformas de mensageria (Telegram, Slack, Discord, etc.) e recebe/envia mensagens. A partir da versão que introduziu o **multiplex**, um único gateway host pode servir múltiplos perfis ao invés de cada profile ter seu próprio gateway rodando isoladamente.

**Vantagens do multiplex:**
- Um único processo Python para todos os perfis (menos RAM/CPU)
- Um único pollador Telegram com o token (evita ban por múltiplas conexões)
- Sem conflito de portas do API server
- Um único ponto de reinício (`hermes gateway restart`)
- Perfis novos são descobertos automaticamente (rescans a cada 30s)

---

## Cenário do Guia

Vamos configurar:

| Step | Ação | Perfil(s) envolvido(s) |
|---|---|---|
| 1 | Instalar Hermes (já instalado — pular) | — |
| 2 | Criar config.yaml da raiz (default) | `default` |
| 3 | Criar um profile adicional (ex: `meu-novo-profile`) | `meu-novo-profile` |
| 4 | Configurar Telegram em ambos os perfis (opcional) | ambos |
| 5 | Registar o gateway default no Windows (Scheduled Task ou Startup) | `default` |
| 6 | Iniciar o gateway | `default` |
| 7 | Migrar para multiplex | todos |
| 8 | Verificar status | todos |

---

## 1. Pré-requisitos

- Hermes Agent instalado (via installer ou manual)
- Acesso ao terminal com o `hermes` no PATH
- Se for usar Telegram: bot token do @BotFather e chat_id do grupo/DM

---

## 2. Criar/Verificar o config.yaml do perfil default

O perfil default usa a raiz do hermes home (`$HOME/AppData/Local/hermes` no Windows).

```bash
# Verificar se existe
type %LOCALAPPDATA%\hermes\config.yaml
```

Se não existir, criá-lo com o mínimo essencial:

```yaml
# %LOCALAPPDATA%\hermes\config.yaml
model:
  default: upstage/solar-pro4:free
  provider: nous
  base_url: https://inference-api.nousresearch.com/v1
database:
  journal_mode: wal
runtime:
  nofile_soft_limit: 4096
agent:
  max_turns: 500
  fast_auto_seconds: 60
  verbose: false
  reasoning_effort: medium
terminal:
  backend: local
  cwd: C:\Users\Charles\Documents\Codando\Hermes
  timeout: 180
  home_mode: auto
  lifetime_seconds: 300
display:
  skin: default
  streaming: true
timezone: America/Sao_Paulo
_config_version: 46
```

> **Nota:** O config.yaml da raiz não precisa ter `platforms:` se você vai usar o multiplex — os profiles individuais têm suas próprias seções `platforms:`.

### Arquivo .env da raiz (opcional)

```bash
# %LOCALAPPDATA%\hermes\.env
OPENROUTER_API_KEY=sk-or-...
# outras chaves globais se necessário
```

---

## 3. Criar o profile adicional

```bash
# Criar o profile (substituir "meu-novo-profile" pelo nome desejado)
hermes profile create meu-novo-profile
```

Isso cria a estrutura:

```
%LOCALAPPDATA%\hermes\profiles\meu-novo-profile\
├── config.yaml          # configurações específicas do profile
├── .env                # credenciais/chaves do profile
├── auth.json           # autenticações
└── ...
```

### Configurar o config.yaml do profile

Edite `%LOCALAPPDATA%\hermes\profiles\meu-novo-profile\config.yaml`:

```yaml
model:
  default: poolside/laguna-s-2.1:free
  provider: openrouter
  base_url: https://openrouter.ai/api/v1
  api_mode: chat_completions
database:
  journal_mode: wal
runtime:
  nofile_soft_limit: 4096
agent:
  max_turns: 500
  fast_auto_seconds: 60
  verbose: false
  reasoning_effort: medium
terminal:
  backend: local
  cwd: C:\Users\Charles\Documents\MeuProjeto
  timeout: 180
  home_mode: auto
  lifetime_seconds: 300
display:
  skin: default
  personality: helpful
  streaming: true
timezone: America/Sao_Paulo
_config_version: 46
```

### Configurar o .env do profile

```bash
# %LOCALAPPDATA%\hermes\profiles\meu-novo-profile\.env
OPENROUTER_API_KEY=sk-or-...
# outras chaves específicas do profile
```

---

## 4. Configurar Telegram nos perfis (opcional)

Se for usar Telegram em algum dos perfis, o bloco `platforms:` deve estar presente no config.yaml do **profile** (não na raiz) e deve conter `home_channel` com `chat_id`.

### No config.yaml do profile (ex: `pesquisador-vet/config.yaml`):

```yaml
# ... outras configurações ...

platforms:
  telegram:
    enabled: true
    home_channel:
      platform: telegram
      chat_id: "758543036"
```

### No .env do profile:

```bash
# %LOCALAPPDATA%\hermes\profiles\meu-novo-profile\.env
TELEGRAM_BOT_TOKEN=8991670939:YOUR_TOKEN_HERE
TELEGRAM_ALLOWED_USERS=758543036
TELEGRAM_HOME_CHANNEL=758543036
TELEGRAM_HOME_CHANNEL_NAME=NomeDoBot
```

> **⚠️ Importante:** Um `home_channel` incompleto (com apenas `platform:` e sem `chat_id`) causa `KeyError: 'chat_id'` e impede o gateway de iniciar. Ou o bloco está completo, ou não está presente (se Telegram não for usar).

---

## 5. Registar o Gateway no Windows (Scheduled Task / Startup)

Antes da migração para multiplex, o gateway do perfil default precisa ser registrado para iniciar automaticamente no login do Windows.

### Opção A — Instalar via comando Hermes (recomendado)

```bash
# No PowerShell ou CMD, na raiz do hermes home:
cd %LOCALAPPDATA%\hermes

# Instalar o gateway como serviço Windows (requer elevação/admin se usar Scheduled Task)
hermes gateway install

# Ou iniciar via Startup folder (sem necessidade de admin):
hermes gateway restart
```

O comando `hermes gateway install` cria:
- **Scheduled Task**: `Hermes_Gateway` na pasta de tarefas do Windows
- **ou** um atalho na pasta Startup:  
  `C:\Users\<user>\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Hermes_Gateway.vbs`

Se o comando detetar que UAC está bloqueando o Scheduled Task, ele recorre automaticamente ao Startup folder.

### Opção B — Registar manualmente no Startup folder

Criar um arquivo `Hermes_Gateway.vbs` na pasta:

```
C:\Users\Charles\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\
```

Com conteúdo:

```vbscript
Set WshShell = CreateObject("WScript.Shell")
WshShell.Run "cmd.exe /c C:\Users\Charles\AppData\Local\hermes\bin\hermes gateway run", 0, False
```

> Isso inicia o gateway em background quando o Windows faz login.

### Verificar se está registado

```bash
# Listar gateways ativos
hermes gateway list

# Verificar se há entrada no Startup
dir "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\Hermes_Gateway*"
```

---

## 6. Iniciar o Gateway

```bash
cd %LOCALAPPDATA%\hermes
hermes gateway restart
```

Saída esperada:

```
✓ Gateway stopped (drained cleanly)
✓ Gateway started via direct spawn (PID: <número>)
```

---

## 7. Migrar para o Padrão Multiplex

Com todos os profiles configurados (com ou sem Telegram), executar a migração:

```bash
cd %LOCALAPPDATA%\hermes
hermes gateway migrate --multiplex
```

O comando mostra o plano e pede confirmação:

```
Migration plan
  default home: C:\Users\Charles\AppData\Local\hermes

  profile          gateway pid   service
  default          <pid>          Windows scheduled task
  pesquisador-vet  -              none
  meu-novo-profile -              none
  ...

Steps:
  - <profiles com gateway próprio>: stop pid + uninstall Windows scheduled task
  - default: set gateway.multiplex_profiles: true in config.yaml
  - default: restart the gateway via windows, verify it serves <N> profiles
  - record the previous state in gateway_migration.json

⚠ This SIGTERMs running gateway process(es): ...
Apply this migration now? [Y/n]:
```

Confirmar com `y` (ou Enter).

> **O que o migration faz:**
> 1. Para os gateways individuais dos profiles que os tinham
> 2. Desinstala as tarefas agendadas por-profile
> 3. Adiciona `gateway.multiplex_profiles: true` ao config.yaml da raiz
> 4. Reinicia o gateway default
> 5. O gateway host agora served todos os profiles

### O que muda no config.yaml da raiz após migração

```yaml
# %LOCALAPPDATA%\hermes\config.yaml
# ... outras configurações ...

gateway:
  # ... outras chaves ...
  multiplex_profiles: true       # ← adicionado pelo migration
  startup_watchdog: true
  # etc.
```

---

## 8. Verificar o Status

```bash
hermes gateway list
```

Saída esperada com multiplex ativo:

```
Gateways:
  ✓ default (current)        — PID <número>
  ✓ pesquisador-vet          — served by the default multiplexer
  ✓ time-comercial           — served by the default multiplexer
  ✓ meu-novo-profile         — served by the default multiplexer
  ...
```

Todos os profiles mostram `served by the default multiplexer`.

---

## 9. Para Criar Novos Profiles no Futuro

Com o multiplex já ativo, o fluxo simplifica:

```bash
# 1. Criar o profile
hermes profile create nome-do-novo-profile

# 2. Editar config.yaml do profile
#    %LOCALAPPDATA%\hermes\profiles\nome-do-novo-profile\config.yaml

# 3. Configurar .env se necessário
#    %LOCALAPPDATA%\hermes\profiles\nome-do-novo-profile\.env

# 4. O gateway host descobre automaticamente (rescans a cada 30s)
#    Ou forçar rescans:
hermes gateway rescan-profiles
```

**Não é necessário:**
- Registrar Scheduled Task ou Startup para cada profile
- Rodar `hermes -p <profile> gateway install/restart`
- Preocupar-se com conflito de portas ou tokens

---

## 10. Troubleshooting

### Gateway não sobe / crash na inicialização

Verificar logs:

```bash
type %LOCALAPPDATA%\hermes\logs\gateway-exit-diag.log
type %LOCALAPPDATA%\hermes\logs\gateway-stdio.log
```

Se aparecer `KeyError: 'chat_id'`, verificar se algum config.yaml de profile tem `home_channel` incompleto:

```bash
# Buscar home_channel em todos os configs
findstr /s /i "home_channel" "%LOCALAPPDATA%\hermes\profiles\*\config.yaml"
```

Correção: remover o `home_channel` parcial ou completá-lo com `chat_id`.

### Um profile não está sendo servido

```bash
# Verificar se o profile existe
dir %LOCALAPPDATA%\hermes\profiles\nome-do-profile\

# Verificar config.yaml do profile
type %LOCALAPPDATA%\hermes\profiles\nome-do-profile\config.yaml

# Forçar rescans
hermes gateway rescan-profiles

# Ver gateway state
type %LOCALAPPDATA%\hermes\gateway_state.json
```

### Desfazer a migração (se necessário)

```bash
# O migration grava um arquivo de rollback
type %LOCALAPPDATA%\hermes\gateway_migration.json

# Reverter manualmente: remover gateway.multiplex_profiles do config.yaml
# e reiniciar gateways individuais com --force
```

---

## Resumo dos Comandos

| Ação | Comando |
|---|---|
| Criar profile | `hermes profile create <nome>` |
| Instalar gateway no Windows | `hermes gateway install` |
| Iniciar/restart gateway | `hermes gateway restart` |
| Listar gateways | `hermes gateway list` |
| Migrar para multiplex | `hermes gateway migrate --multiplex` |
| Forçar rescans de profiles | `hermes gateway rescan-profiles` |
| Ver logs de crash | `type %LOCALAPPDATA%\hermes\logs\gateway-exit-diag.log` |

---

*Documentação de referência para configuração do Hermes Agent com multiplex.*
*Atualizado em 2026-09-24.*
