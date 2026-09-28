# `create-profile_win.sh` — Como funciona

Documento destinado a quem deseja entender o que o script faz, por que faz, e — principalmente — **por que ele é seguro e não é malicioso**.

---

## 1. O que o script faz, em uma frase

Cria um novo profile do **Hermes Agent** clonando o profile `default`, configura as credenciais do **Telegram** (token, ID, canal) nos arquivos do profile, e exibe um resumo final **sem vazar o token**.

---

## 2. Pré-requisitos

| Requisito | Por quê |
|---|---|
| Windows 10 + Git Bash | O script usa utilitários POSIX (`awk`, `sed`, `grep`, `tr`, `printf`, `cp`, `mv`, `date`). |
| `hermes` no `PATH` | É o CLI que cria o profile. |
| Variável `TELEGRAM_BOT_TOKEN` exportada | Para o token **não** ficar hardcoded no script. |

Exemplo de uso:

```bash
export TELEGRAM_BOT_TOKEN="1234567890:ABC..."
bash create-profile_win.sh
```

---

## 3. Estrutura do script (seções 1 a 11)

| Seção | O que faz |
|---|---|
| 0 | Como executar o script. |
| 1 | Define variáveis (nome do profile, IDs, token via env). |
| 2 | Define caminhos (`HERMES_HOME`, `PROFILE_DIR`, `.env`, `config.yaml`, `soul.md`). |
| 3 | Define funções auxiliares (`erro`, `ok`, `aviso`, `backup_file`, `normalize_lf`). |
| 4 | Valida pré-requisitos (comando `hermes`, variáveis obrigatórias). |
| 5 | Aborta se o profile já existe (evita sobrescrever). |
| 6 | Cria o profile com `hermes profile create ... --clone-from default`. |
| 7 | Verifica se os arquivos do profile existem; normaliza CRLF; faz backup. |
| 8 | Grava credenciais no `.env` e ajusta o `config.yaml`. |
| 9 | Revalida que tudo foi gravado corretamente. |
| 10 | Mostra um resumo ao usuário (token e chat_id mascarados). |
| 11 | Mensagem final com próximos passos. |

---

## 4. O que acontece quando você executa

### Passo 1 — Normalização do nome do profile

O nome é forçado para **minúsculo**:

```bash
PROFILE_NAME="$(printf '%s' "$PROFILE_NAME_RAW" | tr '[:upper:]' '[:lower:]')"
```

Também é feita uma validação por regex (`^[a-z0-9_-]+$`) para evitar nomes com **carcteres especiais**, espaços ou acentos que quebrariam caminhos.

### Passo 2 — Validação de pré-requisitos

O script:

- Verifica se `hermes` existe no `PATH` (`command -v hermes`), garantindo que o comando de execução `hermes` esta presente no sistema.
- Confere se as variáveis obrigatórias estão preenchidas.
- **Aborta** se o token não estiver definido — ele **não** tem valor padrão hardcoded.

### Passo 3 — Checagem de existência do profile

Se a pasta `$PROFILE_DIR` já existe, o script **para** e sugere:

```bash
hermes profile delete <nome>
```

Isso evita sobrescrever configurações que você possa ter feito manualmente.

### Passo 4 — Criação do profile

Executa exatamente:

```bash
hermes profile create "$PROFILE_NAME" --clone-from default
```

Ou seja: **quem cria o profile é o Hermes**. O script só orquestra.

### Passo 5 — Verificação dos arquivos do profile

Confere que estes três arquivos existem:

```text
$HOME/AppData/Local/hermes/profiles/<nome>/.env
$HOME/AppData/Local/hermes/profiles/<nome>/config.yaml
$HOME/AppData/Local/hermes/profiles/<nome>/soul.md
```

Faz também:

- **Normalização CRLF → LF** (Windows costuma criar `.env` com `\r` no fim, o que quebra `sed`/`grep`).
- **Backup** dos arquivos antes de editá-los, no formato `<arquivo>.bak.YYYYMMDD_HHMMSS`.

### Passo 6 — Gravação das credenciais

**No `.env`:** remove linhas antigas de `TELEGRAM_*` e regrava:

```text
TELEGRAM_HOME_CHANNEL_NAME=...
TELEGRAM_ALLOWED_USERS=...
TELEGRAM_HOME_CHANNEL=...
TELEGRAM_BOT_TOKEN=...
```

**No `config.yaml`:** garante que exista o bloco:

```yaml
platforms:
  telegram:
    enabled: true
    home_channel:
      platform: telegram
      chat_id: "..."
```

Três casos tratados:

| Situação | Ação |
|---|---|
| `platforms:` não existe | Adiciona o bloco inteiro no fim. |
| `platforms:` existe mas `telegram:` não | Insere `telegram:` logo após `platforms:` (via `awk`, respeitando indentação). |
| `platforms.telegram` já existe | Atualiza `enabled` e `chat_id` no lugar certo. |

### Passo 7 — Revalidação

Confirma com `grep` que cada variável e cada chave foram realmente gravadas. Se algo falhou, o script **avisa e sai**.

### Passo 8 — Resumo final

Mostra o conteúdo do `.env` com o **token mascarado**:

```text
TELEGRAM_BOT_TOKEN=8338735925:***REDACTED***
```

E o `chat_id` parcialmente mascarado (`758***36`).

### Passo 9 — Mensagem final

Sugere dois comandos de verificação:

```bash
hermes profile list
hermes gateway status
```

Nada é executado automaticamente — o controle é seu.

---

## 5. Por que este script **não é malicioso**

Pergunta legítima. A tabela abaixo mapeia cada operação do script ao que ela faz, e o que ela **não** faz.

| Operação no script | O que faz | O que **não** faz |
|---|---|---|
| `hermes profile create` | Chama o CLI oficial do Hermes. | Não baixa nem executa binários externos. |
| `mkdir` / `cp` / `mv` / `sed` | Manipula arquivos dentro de `$PROFILE_DIR`. | Não escreve fora de `$HOME/AppData/Local/hermes`. |
| `awk` / `grep` | Lê e edita `.env` e `config.yaml`. | Não envia conteúdo pela rede. |
| `backup_file` | Cria cópia `.bak.<timestamp>` antes de editar. | Não apaga os originais. |
| Token via `$TELEGRAM_BOT_TOKEN` | Recebe o segredo por variável de ambiente. | Não armazena o token em texto plano no próprio script. |
| Resumo final | Imprime dados mascarados. | Não imprime o token completo. |

**Não há:**

- `curl`, `wget`, `nc`, `ssh`, `scp` — nenhum acesso à rede.
- `eval` de conteúdo externo.
- `sudo` / `runas` — nenhum pedido de elevação.
- `rm -rf` — nenhuma remoção destrutiva.
- `base64 -d | bash` — nenhum payload ofuscado.
- Escrita fora da pasta do profile.
- Persistência (`crontab`, `~/.bashrc`, `Task Scheduler`).

**Como você mesmo pode verificar** (sem rodar):

```bash
# Procurar qualquer chamada de rede ou execução dinâmica
grep -nE 'curl|wget|nc |ssh|scp|eval|base64|/dev/tcp' create-profile_win.sh

# Ver todos os comandos externos usados
grep -nE '^\s*(command -v|[a-z]+\s)' create-profile_win.sh | grep -vE '^\s*#'

# Confirmar que nada escreve fora da pasta do profile
grep -n '>' create-profile_win.sh
```

A saída do primeiro `grep` deve ser **vazia**. O segundo mostrará apenas utilitários padrão (`tr`, `grep`, `sed`, `awk`, `printf`, `cp`, `mv`, `date`, `hermes`). O terceiro mostrará apenas redirecionamentos para `$ENV_FILE`, `$CONFIG_FILE` e seus temporários.

---

## 6. Onde o script escreve

Exatamente nestes caminhos:

```text
$HOME/AppData/Local/hermes/profiles/<nome>/.env
$HOME/AppData/Local/hermes/profiles/<nome>/config.yaml
$HOME/AppData/Local/hermes/profiles/<nome>/.env.bak.<timestamp>
$HOME/AppData/Local/hermes/profiles/<nome>/config.yaml.bak.<timestamp>
```

Nada além disso. Nenhum arquivo de sistema, nenhuma chave de registro, nenhuma pasta pessoal fora do Hermes.

---

## 7. Permissões e reversibilidade

- **Reversível:** para desfazer, apague o profile com `hermes profile delete <nome>`. Os backups `.bak.<timestamp>` podem ser restaurados manualmente se algo der errado.
- **Sem privilégios elevados:** roda com as permissões do usuário atual.
- **Sem segredos embutidos:** o token vem do ambiente em tempo de execução.

---

## 8. Checklist de auditoria rápida

Antes de rodar, se quiser conferir em 30 segundos:

- [ ] `grep -nE 'curl|wget|nc |ssh|scp|eval|base64' create-profile_win.sh` → vazio.
- [ ] `grep -n 'hermes ' create-profile_win.sh` → apenas `hermes profile create`.
- [ ] `grep -n '\$HOME\|\$PROFILE_DIR' create-profile_win.sh` → todos os caminhos ficam sob `$HOME/AppData/Local/hermes`.
- [ ] O token **não** aparece em texto plano no arquivo (`grep -n 'BOT_TOKEN' create-profile_win.sh`).
- [ ] Você mesmo exportou `TELEGRAM_BOT_TOKEN` antes de rodar.

---

## 9. O que o script **não** faz

Para deixar explícito:

- Não instala nada.
- Não atualiza dependências.
- Não modifica arquivos do sistema operacional.
- Não altera variáveis de ambiente permanentes.
- Não se registra para rodar no boot.
- Não abre conexões de rede.
- Não envia dados a serviços externos.
- Não lê arquivos fora da pasta do profile.

Se em algum momento quiser verificar o comportamento sem executar de fato, você pode:

```bash
bash -n create-profile_win.sh      # checagem de sintaxe, sem executar
bash -x create-profile_win.sh      # execução com trace (mostra cada comando)
```

O `-x` exibe cada comando **antes** de rodá-lo. É a forma mais direta de "ver o script pensando". Você pode interromper a qualquer momento com `Ctrl+C`.

---

## 10. Resumo final

O script é um **orquestrador local** que:

1. Valida pré-requisitos.
2. Chama o CLI oficial do Hermes para criar o profile.
3. Escreve quatro variáveis no `.env` do profile.
4. Ajusta o `config.yaml` do profile.
5. Faz backup antes de editar.
6. Mostra um resumo com dados sensíveis mascarados.

Tudo dentro de `$HOME/AppData/Local/hermes/profiles/<nome>/`, sem rede, sem elevação, sem persistência, sem segredos embutidos. É auditável em minutos e reversível com um único comando.