# Checke List - Criação de Agente no Hemres

## Objetivo

Criar um check list com os passos necessários para a criação de um profile pronto para a produção.

## Check List
### 1. Profiles
    
- [ ] Criar a pasta do projeto
- [ ] Criar um arquivo `profiles.md` e definir:
    - [ ] Definir a estrutura dos Agentes: quantos e quais são
    - [ ] Definir os nomes dos agentes
    - [ ] Definir o objetivo principal dos agentes em uma linha
    - [ ] Criar Prompt para criação do arquivo `SOUL.md` e `describe.md`
        - [ ] Gerar os arquivos `SOUL.md` e `describe.md`
        - [ ] Describe e `SOUL.md` e `describe.md` revisados
        * Usar referência user-guide: [Personality & SOUL.md](https://hermes-agent.nousresearch.com/docs/user-guide/features/personality), [Context Files (SOUL.md, AGENTS.md)](https://hermes-agent.nousresearch.com/docs/user-guide/configuration#context-files-soulmd-agentsmd)
        - [ ] Gerar o Workflow dos agentes. Proposito: Instruções, convenções e arquitetura do projeto
        * Usar referência user-guide: [Diferença entre o Context Files](https://hermes-agent.nousresearch.com/docs/user-guide/features/context-files#supported-context-files)
            - [ ] Gerar os arquivos `AGENTS.md`
            - [ ] Describe e `AGENTS.md` revisados
    - [ ] Definir os canais de comunicação com os agentes:
        - [ ] Telegram
            - [ ] Definir BOT_NAME (nome do bot no Chart)
            - [ ] USERNAME_BOT (nome do bot no Telegram)
            - [ ] PROFILE_NAME (nome do profile no Hermes)
            - [ ] Criar os Bots
            - [ ] Salvar o BOT_TOKEN
            - [ ] Criar um grupo e adicionar os Bot ao grupo
        - [ ] Slack, Discord, Whatsapp...

### 2. Criar o Profile Principal
- [ ] Crie um profile como sendo o principal, o que esta no topo da estrurura hierárquica
- [ ] Configure provide de modelo
- [ ] Carregar o arquivo `SOUL.md` para o diretório `/opt/data/profiles/<profile_name>` do profile ou pelo dashboard `PROFILES -> 3pontos -> EDIT SOUL.md`
- [ ] Carregar a descrição do profile pelo dashboard `PROFILES -> 3pontos -> EDIT DESCRIPTION`
- [ ] Copiar o arquivo `AGENTS.md`para o  diretório `/opt/data/profiles/<profile_name>`

**1.  Canal de comunicação**
- [ ] Habilite o canal de comunicação
- [ ] Teste o canal de comunicação

2. **Workspace**
- [ ] Definir o diretório de trabalho dos agentes

3. **Configurar as ferramentas (tools)**
Definir o que o agente pode executar, consultar, criar ou modificar.
- [ ] Provider (router de modelos) e Modelo validados
- [ ] Listar/verificar as ferramentas necessárias das habilitadas

4. **Criar e selecionar Skills**
Transformar procedimentos recorrentes em métodos reutilizáveis.
- [ ] Skills essenciais criadas e validadas
- [ ] Criar e adcionar as insttuções operacionais de uso no arquivo `HERMES.md` para o profile que vai utilizar

5. **Integrar sistemas e agentes**
Configurar MCP, APIs, plugins e colaboração entre profiles quando necessário.
- [ ] Selecionar MCPs e APIs, quando necessários
- [ ] MCPs e APIs testado e validados

6. **Configurar a memória**
Preservar contexto útil, decisões, preferências e aprendizados.
- [ ] Definir o tipo de memória 
- [ ] Memória configurada
- [ ] Memória testada

7. **Configurar Serviço Cloud**
    1. GitHub
        - [ ] Criar Repositório no GitHub
        - [ ] Configurar GitHub CLI
        - [ ] Habilite o GitHub para o agente
    
    2. Google Cloud
        - [ ] Configuração do [Google Cloud Plstform](https://cloud.google.com/)
        - [ ] Configurar o Google Drive
        - [ ] Configurar o Google gmail

### 3. Criar outros Profiles - clonar do principal
- [ ] Criar a clonagem do profile principal

### 4. Turnkey dos Profiles, Testar, avaliar e monitorar
Verificar a qualidade das respostas, a execução de tarefas e o consumo de recursos.
- [ ] Criar arquivo `turnkey.md`
    - [ ] Definir estrutura de perguntas de start do agente, dando instruções de como iniciar
    - [ ] Executar o **Turnkey**
- [ ] Bateria de testes aprovada
- [ ] Consumo de contexto e custo avaliados
- [ ] Logs, backup e monitoramento planejados
- [ ] Rotinas e delegação validadas, quando necessárias

### 5. Definir regras de operação e segurança
Estabelecer limites, validações, permissões e condições de escalonamento.
- [ ] Permissões e autonomia definidas
- [ ] Credenciais protegidas

    
