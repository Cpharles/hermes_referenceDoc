# Migre o Hermes Agent para outra máquina sem perder memória

## Por que você só tem uma chance com uma migração do Hermes

Um Hermes Agent que funciona é bem mais do que o binário. São meses de entradas de memória, um `SOUL.md` personalizado, uma pequena biblioteca de skills próprias, uma tabela de cron com os digests que você realmente usa, um índice vetorial do ChromaDB que o agente vem construindo em silêncio e uma sessão do Telegram que já sabe quem você é. Reinstale o Hermes em uma máquina nova e nada disso vai junto. Você acaba com um estranho que compartilha o seu nome de usuário.

É contra esse cenário que este guia foi escrito. Se o seu laptop está morrendo, você está saindo do Docker no desktop para um VPS de verdade, subindo a classe da sua instância na Hetzner ou fazendo uma restauração limpa depois de uma falha de disco, o processo é o mesmo: capture toda a árvore `~/.hermes/` na máquina antiga, mova para a nova, rode `hermes import` e verifique. Feito na ordem certa é um trabalho de quinze minutos. Feito na ordem errada, ou você perde dados ou passa a noite reautenticando providers, IMAP e Telegram.

Se você ainda está comparando self-hosting com um setup gerenciado, leia antes *self-hosting vs Hermes Agent gerenciado*, porque a Hermify cuida das migrações por você e este guia deixa de fazer sentido. Se você vai rodar você mesmo, siga em frente.

---

## O que o `hermes backup` empacota de verdade

O comando `hermes backup` gera um arquivo com timestamp parecido com `hermes-backup-2026-06-01-101955.zip`. Ele captura o conteúdo de `~/.hermes/`, que é onde o Hermes guarda tudo o que faz o seu agente ser seu. Em uma instalação madura, essa árvore inclui:

- **O banco de estado** (`state.db` e arquivos relacionados): a fonte de verdade para sessões, histórico de chamadas de ferramentas e filas de jobs.
- **O vector store do ChromaDB**: o índice de memória semântica que o agente consulta toda vez que precisa lembrar de algo. É um diretório de arquivos binários, não um JSON solto, e precisa se mover como uma unidade.
- **`SOUL.md`, `AGENTS.md`, `USER.md`, `MEMORY.md`**: a personalidade, as regras da casa, o perfil do usuário e a memória de longo prazo em prosa. São markdown puro, mas o agente espera encontrá-los em caminhos exatos.
- **O diretório `skills/`**: cada skill que você escreveu ou instalou. Skill é só uma pasta com um `SKILL.md` e os arquivos que ela usa, mas uma skill faltando é uma capacidade que o agente perde em silêncio.
- **O diretório `identity/`**: a configuração da persona, o avatar e os presets do modo voz.
- **A tabela de cron**: as tarefas agendadas vivem dentro de `~/.hermes/`, não no crontab do sistema. Perdê-las significa que o seu digest da manhã simplesmente para de chegar.
- **Segredos e config**: `config.yaml`, chaves de API de providers, o token do bot do Telegram, credenciais de IMAP/SMTP, segredos de assinatura de webhooks e qualquer trecho `.env` criptografado que o agente tenha consumido.

Dois flags importam:

- `hermes backup --quick` pula o scan completo de arquivos e inclui só config, sessões, chaves e auth. É mais rápido e menor, mas **não leva memória nem skills**, então só serve para clonar a identidade do agente em uma máquina que vai construir sua própria memória do zero.
- Para uma migração de verdade, rode `hermes backup` sem flags e deixe ele levar o tempo necessário.

---

## Passo 1 — Congele a origem

Antes de tirar o backup, silencie o agente. Se o Hermes estiver escrevendo no `state.db` na hora do arquivo, você pode acabar com um banco corrompido dentro do zip.

```bash
# Se você roda o Hermes como serviço systemd
sudo systemctl stop hermes

# Ou se roda via Docker
docker compose stop hermes

# Ou se você lançou interativamente, saia limpo com Ctrl+C no shell onde ele está rodando
```

Quando nada mais estiver segurando o banco de estado, tire o backup:

```bash
hermes backup
# escreve ~/.hermes/backups/hermes-backup-2026-07-18-102301.zip
```

Anote o caminho completo que ele imprime. É esse o arquivo que você vai mover.

---

## Passo 2 — Mova o arquivo com cuidado

O backup contém segredos. Trate como uma chave SSH.

- Não suba para um link público, um anexo do Discord ou um DM do Slack para você mesmo.
- Prefira `scp` ou `rsync` sobre SSH, ou uma pasta do syncthing em que você já confia.
- Se precisar passar por um laptop como salto intermediário, apague a cópia local no instante em que a transferência terminar.

Uma transferência segura de um VPS antigo para um novo fica assim:

```bash
# Da máquina nova
scp vps-antigo:~/.hermes/backups/hermes-backup-2026-07-18-102301.zip ~/
```

Se está movendo de um laptop pessoal para um VPS, faça o contrário e empurre a partir da origem. De qualquer forma, deixe o arquivo no home do usuário de destino, **não em `/tmp`** nem em um caminho compartilhado.

---

## Passo 3 — Instale o Hermes no destino

Instale o Hermes na máquina nova do mesmo jeito que faria em um setup limpo. Isso significa Linux, macOS, WSL2 no Windows ou Termux no celular, que são os alvos oficialmente suportados. Siga a rota de instalação que combina com como você vai rodar a longo prazo, seja Hermes Agent no Docker, uma instalação nativa no Linux ou Windows via WSL2.

**Não inicie o agente ainda.** Se ele subir uma vez com `~/.hermes/` vazio, vai escrever um `state.db` novo e a config padrão, o que vai colidir com o import no próximo passo. Instale o binário, confirme que `hermes --version` imprime a mesma versão maior da máquina de origem e pare por aí.

---

## Passo 4 — Importe e reindexe

Com o arquivo no lugar e o binário instalado mas sem rodar:

```bash
hermes import ~/hermes-backup-2026-07-18-102301.zip
```

O importador descompacta o arquivo dentro de `~/.hermes/`, restaura o banco de estado e coloca skills, memória, cron, identidade e segredos nos seus lugares. Ao terminar, reconstrua o índice vetorial para que a busca semântica ordene os resultados com o modelo atual e não com o que a máquina antiga usava:

```bash
hermes memory reindex
```

Se o backup foi tirado em uma versão bem mais antiga do Hermes, o payload de memória pode estar em um formato legado. Nesse caso, extraia as memórias separadamente com um export em JSON e importe de novo explicitamente:

```bash
hermes memory import --legacy ~/memories.json
```

O flag `--legacy` diz ao Hermes para aceitar o esquema antigo e atualizá-lo na hora. `hermes memory export --output ~/memories.json` na origem é o comando irmão, útil quando você só quer migrar a memória e reconstruir o resto a partir de uma instalação limpa.

---

## Passo 5 — Verifique antes de confiar

Aqui dois comandos ganham o pão:

```bash
hermes doctor   # config, dependências, alcance dos providers, permissões de disco
hermes status   # saúde do gateway, contagem de memória, integrações ativas
```

O `hermes doctor` deve retornar verde em config, banco de dados, ChromaDB e credenciais de provider. O `hermes status` deve mostrar uma contagem de memória parecida com a que você tinha na origem, a integração do Telegram como conectada e qualquer tarefa agendada de longa duração na fila. Se algum deles marcar alguma coisa, resolva antes de religar o gateway.

Depois, inicie o agente e mande do Telegram uma mensagem que precise puxar memória. *"O que a gente decidiu sobre o lançamento do Q3?"* é um bom teste. Se ele responder com contexto, a memória migrou. Se disser que não sabe, rode `hermes memory search "lançamento Q3"` na CLI: a memória pode estar lá, mas o índice vetorial ainda pode estar terminando de reconstruir.

---

## Os detalhes que ninguém avisa

Mesmo um import limpo deixa umas arestas. Passe por essa lista antes de considerar a migração fechada.

- **Segredos criptografados precisam da chave de descriptografia.** Se a máquina de origem usava um cofre de segredos criptografado (o Hermes suporta `pass`, `gnome-keyring` ou um keyfile), o arquivo contém o texto cifrado mas não a chave. Transfira o keyfile separado ou desbloqueie o cofre na máquina nova antes do primeiro run do agente.
- **Credenciais de IMAP e SMTP podem pedir reautenticação.** App passwords amarradas à impressão digital do dispositivo às vezes recusam autenticar de um IP novo. Google Workspace e Fastmail são os suspeitos de sempre. Gere uma nova app password se a integração de e-mail ficar muda depois do import.
- **A sessão do Telegram pode desviar.** O token do bot do Telegram é portável, mas se você também usava uma sessão em modo usuário para ler chats, o arquivo de sessão pode estar amarrado ao dispositivo antigo. Apague `~/.hermes/telegram/session.session` e deixe o agente reautenticar no próximo start.
- **Jobs de cron reiniciam no próximo tick agendado, não na hora.** Se o seu `daily-digest` estava marcado para 07:00 e você termina a migração às 07:05, ele só dispara amanhã. Rode manualmente uma vez com `hermes cron run daily-digest` para confirmar que está de pé.
- **Rotacione qualquer coisa que o arquivo tocou.** Mesmo com uma transferência cuidadosa, um arquivo com tokens de bot e chaves de provider já morou em mais máquinas do que os dois pontos. Se a migração foi resposta a um comprometimento, ou se o arquivo passou por um armazenamento compartilhado, rotacione a chave de OpenAI/Anthropic/OpenRouter e reemita o token do bot no BotFather.

---

## Quando você não quer fazer tudo isso sozinho

Todo o ritual (congelar, backup, transferir, instalar, importar, reindexar, verificar, rotacionar) é o que um host gerenciado faz automaticamente. A Hermify roda um Hermes Agent gerenciado em um VPS que nós operamos, faz backups criptografados diários e te dá restauração com um clique se um VPS precisar ser substituído. No dia a dia do usuário não existe um passo de "mudar de máquina", porque a máquina é o nosso problema, não o seu.

Se decidir que isso combina mais com você do que rodar essa migração a cada ano ou dois, comece com a Hermify: seu agente entra no Telegram em cerca de um minuto, sua memória continua sua e a próxima troca de hardware acontece invisível para você.

---

## Resumo rápido dos comandos

```bash
# 1. Congelar a origem
sudo systemctl stop hermes          # ou: docker compose stop hermes

# 2. Backup completo
hermes backup

# 3. Transferir o arquivo com segurança
scp vps-antigo:~/.hermes/backups/hermes-backup-YYYY-MM-DD-HHMMSS.zip ~/

# 4. Instalar (sem iniciar) o Hermes na máquina nova
hermes --version

# 5. Importar e reindexar
hermes import ~/hermes-backup-YYYY-MM-DD-HHMMSS.zip
hermes memory reindex

# 6. Verificar
hermes doctor
hermes status
hermes memory search "termo de teste"

# 7. Testar cron manualmente (se aplicável)
hermes cron run daily-digest
```

---

## Referências

- **Artigo original:** [Migre o Hermes Agent para outra máquina sem perder memória](https://www.hermify.io/pt/blog/hermes-agent-migrate-to-new-machine)
- **Tópicos relacionados:** self-hosting vs Hermes Agent gerenciado, Hermes Agent no Docker, instalação nativa no Linux, Windows via WSL2
- **Plataformas suportadas:** Linux, macOS, WSL2 (Windows), Termux (Android)

---

*Documento gerado a partir do artigo original da Hermify Team. Última atualização do conteúdo-fonte: 2026-07-18.*