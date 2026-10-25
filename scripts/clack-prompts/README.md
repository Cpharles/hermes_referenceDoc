# EXECUTANDO O SCRIPT

## Conteúdo
<!-- toc -->

## 1. Executando dentro de um Conteiner - Docker

### 1. Via Terminal SSH
Abra o terminal e execute:
```bash
# Acessando o servidor
ssh <user_name>@<IP_servidor>

# Verificando o ID do conteiner
docker ps

# Acesse o shell do container (recomendado)
docker exec -it <nome_ou_id_do_container> /bin/bash
```

### 2. Ativando o Ambiente Virtual

**Entendendo**
Ao abrir um shell externo dentro do container (como via docker com SSH), o ambiente virtual Python (venv) onde o executável do Hermes está instalado pode não ser ativado automaticamente.

> [!NOTE]
> Para verificar se o ambiente foi ativado automaticamente digite `hermes --help`, se retornar os comandos significa que foi bem sucedido a ativação e não será necessário executar os próximos passos.

Só para entendermos porque isso acontece, temos o processo principal do container (entrypoint) ativa o venv, mas shells externos não passam por esse processo, e o caminho /opt/hermes/.venv/bin não está no PATH padrão do sistema.
Para evitar que nosso script não funcione, temos dois caminhos para ativar.

1. Ative o venv manualmente
```bash
source /opt/hermes/.venv/bin/activate
hermes --version
```
2. Corrija permanentemente (se você gerencia a imagem)
Se você constrói ou pode modificar a imagem Docker, adicione ao Dockerfile:
```yaml
ENV PATH="/opt/hermes/.venv/bin:$PATH"
```
Isso garante que o binário esteja no PATH para qualquer shell, incluindo os criados por docker exec . Em versões mais recentes da imagem oficial, esse ajuste já foi incorporado , então atualizar a imagem também pode resolver.

### 3. Crie uma pasta com os arquivos
```text
create-profile.mjs
package-lock.json
package.json
```
>[!NOTE]
> Pode ser em qualquer diretório, mas dê preferência para criar dentro da pasta onde esta o profile standard do Hermes.
> `./opt/data` pasta home (Linux)
> `%LOCALAPPDATA%\hermes` pasta home (Windows)

### 4. Instalando as dependências:
Após a instalação das dependências, podemos ver a criação de uma pasta com o nome `node_modules`
```bash
npm install @clack/prompts js-yaml chalk dotenv
```
> [!NOTE]
> A instalação das dependência é feito somente uma vez

### 5. Executando o Script

Para facilitar o preenchimento das variáveis do script, crie uma arquivo ou planilha já com os seguintes informações.

| Variável | Descrição |
|---|---|
| TELEGRAM_BOT_TOKEN                      | Token do bot criado pelo BotFather                                 |
| PROFILE_NAME_RAW="&lt;profile_name>"    | Nome do profile                                                    |
| CHANNEL_NAME="&lt;bot_name>"            | Nome amigável do bot (TELEGRAM_HOME_CHANNEL_NAME)                  |
| USER_ID="&lt;user_id>"                  | User ID do Telegram (DM) — pode adicionar vários separando por `,` |
| DIRETORIO_HERMES="&lt;local_do_hermes>" | Caminho onde está o diretório do Hermes                            |
| Padrão para os diretórios (sertifique onde foi instalado) | padrão para Windows em `%LOCALAPPDATA%\hermes`<br>padrão para Linux Descktop em `$HOME/<user>/.hermes`<br>padrão para Linux Server em `/opt/data/` |

**Step 1.** Informando o `Token do Bot` e execute o comando;

> **Exemplo de execução:**
    - Somente terminal Linux ou Git Bash:
        `export TELEGRAM_BOT_TOKEN="123456:ABCDEF..."`
    - Somente para Windows PowerShell (usando WSL):
        `$env:TELEGRAM_BOT_TOKEN="123456:ABCDEF..."`

```bash
$env:TELEGRAM_BOT_TOKEN="SEU_TOKEN_AQUI"
node create-profile.mjs
```

**Step 2.** Informando o `Nome do Profile`

**Step 3.** Informando o `Nome do Bot`

**Step 4.** Informando o `User_ID`

**Step 5.** Informando o `Diretório do Hermes`

Aguarde o processo finalizar, ao termino teremos uma tela:

![script](script.png)
<br>

---

## 2. Configurando skills para um profile

Verifique se já foi instalado as dependências, caso contrário, faça primeiro

### 1. Crie uma pasta com os arquivos

```text
skill-config.mjs
package-lock.json
package.json
```

>[!NOTE]
> Pode ser em qualquer diretório, mas dê preferência para criar dentro da pasta onde esta o profile standard do Hermes.
> `./opt/data` pasta home (Linux)
> `%LOCALAPPDATA%\hermes` pasta home (Windows)

### 2. Instalando as dependências:

Após a instalação das dependências, podemos ver a criação de uma pasta com o nome `node_modules`

```bash
npm install @clack/prompts js-yaml chalk dotenv
```

> [!NOTE]
> A instalação das dependência é feito somente uma vez

Depois é só execute o comando e seguir as instruções

```bash
npm run skill-config
```

O script permite escolher um profile, marcar as skills que devem permanecer habilitadas e confirmar a alteração. As skills desmarcadas são gravadas em `skills.disabled` no `config.yaml` desse profile. Ao final, a lista atualizada de skills é exibida pelo Hermes.
