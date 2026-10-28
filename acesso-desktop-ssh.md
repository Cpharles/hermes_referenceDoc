# ACESSONDO O HERMES DE FORMA SEGURA

## Conteúdo
<!-- toc -->

<!-- tocstop -->

## 1. Introdução

É fato que muitos usuários não se preocupam com isso e simplesmente instalam o Hermes Desktop diretamente no sistema de trabalho local, colocando desta forma sua privacidade em termos de documentos que tem arquivos sensíveis com senhas e informações confidenciais em risco. Por este motivo segue a descrição de uma forma segura de configuração que evita colocar em risco nosso ambient de trabalho, dando acesso ao Hermes somente o queremos que ele veja.
As formas de configurar e trabalhar com o Hermes para impedir que os agentes acessem as pastas local do nosso sistema, que são:
- Rodar o Hermes localmnte mas dentro de um Docker com configuração do workspace em modo docker, assim os agentes ficam confinados dentro do conteiner criado para eles
- Rodar o Hermes em um servidor, assim ele tem acesso somente o que é gerado neste servidor, e mesmo assim podemos criar barreiras e impedir que ele acesse o sistema do servidor.

Nas duas opções podemos ainda aproveitar todos os recursos gráficos do Hermes Desktop para operar o Hermes no ambiente controlado, configurando desta forma os agentes do Hermes não rodam nem acessam diretamente a sua máquina local. Neste caso o Hermes Desktop atua apenas como um **cliente gráfico** (a interface de chat); o “cérebro” do agente (runtime, ferramentas, memória, credenciais e execução de comandos) fica no **backend**, que será o container dentro da sua propria máquina ou no servidor.

Abaixo, seguem o passo a passo para a conexão remota e para o compartilhamento de pastas.

---

### 🔌 2. Passo a passo: conectar o Hermes Desktop ao servidor

O objetivo é fazer o aplicativo no Windows “conversar” com o backend que está rodando no container da VM.

**No servidor (VM Ubuntu / container Hermes):**

1.  **Inicie o backend com as flags corretas.** O comando precisa expor o serviço na rede e habilitar o chat (TUI). O exemplo abaixo usa a porta `9119` e o host `0.0.0.0` (todas as interfaces):
    ```bash
    # Defina um token fixo para não precisar reconfigurar a cada reinício
    export HERMES_DASHBOARD_SESSION_TOKEN="$(openssl rand -base64 32)"
    
    # Inicie o serviço (ou 'hermes dashboard' se quiser também a interface web)
    hermes serve --host 0.0.0.0 --port 9119 --tui
    ```
    *Anote o token gerado; ele será usado no Desktop.*

2.  **Libere a porta no firewall (se aplicável).** Na VM Ubuntu, garanta que a porta `9119` esteja acessível a partir do seu PC Windows (ex.: `sudo ufw allow 9119/tcp`).

**No PC Windows (Hermes Desktop):**

3.  **Abra as configurações de conexão.** No Hermes Desktop, vá em **Settings (Configurações) → Gateways** e selecione a opção **Remote gateway** (Gateway Remoto).
4.  **Preencha os dados da conexão:**
    *   **Remote URL:** `http://<IP-da-VM-Ubuntu>:9119` (substitua `<IP-da-VM-Ubuntu>` pelo endereço IP real da máquina virtual).
    *   **Session token:** Cole o valor exato que você definiu na variável `HERMES_DASHBOARD_SESSION_TOKEN` no passo 1.
5.  **Teste.** Salve e tente enviar uma mensagem simples no chat do Desktop. Se a conexão for bem-sucedida, o agente responderá usando o backend do container.

---

### 📂 3. Compartilhar uma pasta entre o container Hermes e o SO raiz do servidor

Como o Hermes está em um container Docker, o compartilhamento é feito via **bind mount** (montagem de diretório) do Docker. Você “espelha” uma pasta do sistema de arquivos da VM para dentro do container.

**Opção A: Se você gerencia o container via `docker run`**
Inclua a flag `-v` (ou `--mount`) no comando de inicialização. O formato é `-v /caminho/no/host:/caminho/no/container`.
```bash
# Exemplo: monta a pasta /home/ubuntu/hermes_shared da VM em /shared dentro do container
docker run -d \
  --name hermes \
  -v /home/ubuntu/hermes_shared:/shared \
  nousresearch/hermes-agent:latest
```
*   Use a opção `:ro` no final (ex.: `-v /host:/shared:ro`) se quiser que o container apenas leia os arquivos, sem modificá-los.

**Opção B: Se você usa Docker Compose ou Dokploy**
Adicione a seção `volumes` no serviço do Hermes no arquivo `docker-compose.yml`. O Dokploy geralmente permite editar esse arquivo ou a configuração de volumes pela interface.
```yaml
services:
  hermes:
    image: nousresearch/hermes-agent:latest
    volumes:
      - /home/ubuntu/hermes_shared:/shared   # Pasta compartilhada
      - /home/ubuntu/hermes_data:/opt/data   # Diretório de dados persistentes do Hermes (recomendado)
```
*   A pasta `/opt/data` é o local padrão onde o Hermes guarda configurações, sessões e memória; montá-la no host é essencial para não perder dados ao recriar o container.

**⚠️ Atenção à permissão de arquivos:**
Por padrão, o container roda como `root` (UID 0) e os arquivos criados na pasta compartilhada pertencerão ao `root` no host. Se você precisar editar esses arquivos na VM com seu usuário normal, pode:
*   Ajustar as permissões da pasta no host (`sudo chown -R ubuntu:ubuntu /home/ubuntu/hermes_shared`).
*   Ou, se estiver usando o backend Docker interno do Hermes, ativar a opção `docker_run_as_host_user: true` na configuração do Hermes para que os arquivos sejam criados com o UID do seu usuário.

Resumindo: o Desktop é o controle remoto; o trabalho pesado e o acesso a arquivos acontecem no backend. O compartilhamento de pastas é a ponte segura entre o mundo do container e o sistema de arquivos da sua VM.