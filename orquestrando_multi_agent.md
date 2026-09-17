# PROJETO DE MULTIPLOS AGENTES

## Objetivo

Construir um projeto com 5 Agentes com um bot orquestrador das atividades, aplicando recursos de intareção via Telegram e registros no Notion.

## Recursos Nescessários

Para a execução deste projeto é necessário ter os seguintes recursos:

> [!IMPORTANT]
> √ Ter uma VPS (ideal para rodar 24/7) ou utilize o seu PC local (preferencialmente no Docker)
> √ Hermes Agent instalado
> √ Disponibilidade de algum modelo LLM da sua preferencia
> √ Uma conta no Telegram para criarmos os bot (agentes)
> √ Uma conta no Notion para registrarmos a execução do trabalho dos agentes

## Estrutura do Projeto

Para a implantação de um sistema de orquestração com multiplos agentes, vamos adodar a seguinte estrutura de Agentes

```mermaid
graph TD;
    A("Agente_Gerente")
    B("Agente Performance")
    C("Agente Pedagógico")
    D("Agente de CS")
    E("Agente Comercial")
    F("Agente de Conteúdo")
    A-->B;
    A-->C;
    A-->D;
    A-->E;
    A-->F;
    style B color:#ffffff,fill:#4472C4,stroke:#2F528F
    style C color:#ffffff,fill:#70AD47,stroke:#507E32
    style D color:#ffffff,fill:#ED7D31,stroke:#AE5A21
    style E color:#ffffff,fill:#E6B33D,stroke:#c08600
    style F color:#ffffff,fill:#995052,stroke:#772729
```

OS AgenteS terão as seguntes funções dentro da estrutura:

**- Agente Performance:**
Responsável por planejar, executar e otimizar campanhas de mídia paga (como Google Ads e Meta Ads). Monitora métricas como ROI, CPA e conversões, ajustando estratégias para maximizar o retorno sobre o investimento e reduzir custos.

**- Agente Pedagógico:**
Responsável pela estruturação e validação de conteúdos educacionais. Garante a qualidade didática, a progressão lógica do aprendizado e a adequação da linguagem ao público-alvo, assegurando que os materiais cumpram os objetivos de ensino.

**- Agente Customer Service_CS:**
Responsável pelo atendimento e suporte aos clientes. Resolve dúvidas, soluciona problemas, gerencia reclamações e garante a satisfação do usuário, atuando como o principal ponto de contato entre a empresa e o público.

**- Agente Comercial:**
Responsável pela prospecção e conversão de leads em clientes. Realiza vendas, negociações, apresenta propostas e mantém o relacionamento com o cliente para fechar contratos e atingir as metas de receita.

**- Agente de Conteúdo:**
Responsável pela criação, curadoria e distribuição de conteúdo (textos, vídeos, imagens). Produz materiais relevantes para atrair, engajar e educar o público, alinhando a comunicação da marca às estratégias de marketing.

---

## 1. Configurações no Telegram

### Step 1. Identificando seu ID no Telegram

Temos que identificar o ID do nosso Telegram, pois será a partir deste ID que nós estaremos conversando com os bots e vise versa.
> [!TIP]
> Caso tenha mais alguém que também vai interagir com os bots através do Telegram, então será necessário que este usuário recupere o número do ID dele para ser cadastrado.

Na barra de pesquisa do Telegram, busque por **`User Info`** e clique em ==@userinfobot==, será aberto uma janela de chat.

![id](./img/userinfo.png)
  
Neste chat, digite `/start`

![id2](./img/userinfo2.png)

Agora podemos ver que o bot retornou o nosso nome de usuário **@username** e logo abaixo temos o **id:XXXXXXXXX**

* Antes de proceguir vamos preencher uma tabela com os dados gerados, vamos precisar deles mais a frente para rodar o script de cadastro dos profiles dentro do Hermes.

* Abra a planilha [dados_profiles.xlsx](dados_profiles.xlsx):

    ![planilha](./img/planilha.png)

### Step 2. Ciando os Bots no Telegram

Temos que criar um **Bot** para cada **Agente** utilizando o `@BotFather` do Telegram.
Cada agente é um setor ou seja um departamento dentro de uma empresa

1. Abra o telegram e pesquise por BotFather na aba **Apps**.

    ![bf1](./img/botfather.png)  
  
2. Clique em `Create a New Bot`.

    ![bf2](./img/botfather2.png)
  
3. Dê um nome usando a referncia criada na planilha para o seu bot no campo **Bot name**, caso queira fazer uma descrição deste bot utilize a proxima linha. Em seguida dê um **username** (Obs: o username do bot **"deve"** terminar com ==**_bot**==) , ao clicar em criar, será gerado um token especifico para este bot. É com este token que usaremos para efetuar um Resquest via API HTTP

    ![bf3](./img/botfather3.png)
  
Ao termino da criação de todos os agentes teremos uma planilha com os Tokens e o ID do Orquestrador (neste caso você com o nome de Agente CEO)

![planilha2](./img/planilha1.png)

Se selecionarmos a aba **Apps** no Telegram e depois clicar em **BotFather**, podemos ver que temos a seguinte estrutura de Bots

![bf4](./img/botfather4.png)

### Step 3. Ativar todos os bots

Agora vamos ativar (acordar) os bots no Telegram, cada um precisa receber um comando `/start` e assim, começar um chat com este agente.
Temos dois caminhos para acordar os bots:

1. Pela barra de pesquisa:
    1. Abra o seu Telegram e busque pela aba **Chats**, clique em perquisa e digite o **Username Bot**

        ![startbot1](./img/start_bot1.png)

    2. Selecione o bot e o chat deste bot vai ser carregado
    3. Clique no botão `START`
2. Pelo BotFather:
    1. Abra o seu Telegram e busqu8e pela aba **Apps**, clique ou busque por **BotFather**, será aberto a janela do botfather com a lista dos seus bots.
    2. Clique no bot que será acordado e em seguida clique no **PROFILE_NAME** (neste caso: `@agente_content_bot`)
        ![startbo2](./img/start_bot2.png)
    3. Note que a janela de chat deste bot é carregada, então finalize clicando no botão `START`

## 2. Configuração dos Profiles no Hermes

### Step 1. Criando Profiles Hermes

Temos que criar os profiles de cada agente dentro do Hermes com seu respectivo Token junto com o ID do orquestrador, e para isso vamos rodar um script no terminal para completar esta configuração.

> [!WARNING] Para entendendo o que cada linha do script faz, leia os seguintes arquivos:
    ⇒ [create-profile_win.md](./scripts/create-profile_win.md)
    Ou exponha estes arquivos para uma IA e peça as explicações e verificações de segurança.

* Para sistemas operacionais Windows utilize o arquivo [create-profile_win.sh](./scripts/create-profile_win.sh)
* Para sistemas operacionais Linux utilize o arquivo [create-profile_lin.sh](./scripts/create-profile_lin.sh)

Os comando podem ser diferentes conforme o sistema operacional. Como neste caso eu estou rodando em uma máquina local e a maioria das pessoas utiliza Windows, vou dar o exemplo utilizando comando para o OS Windows, mas a lógica continua a mesma para qualque OS.

### Step 2. Verificando o status dos profiles no Hermes

1. Abra o terminal **Git Bash** ou o terminal CLI local do seu VPS na seção do Hermes (para acessa-lo é necessário ter o [Git instalado](https://git-scm.com/install/windows))
2. Execute o seguinte comando no terminal: `hermes profile list`
    Podemos verificar que temos inicialmente somente o profile padrão que é chamado de **default**

    ![status1](./img/status_profile1.png)

    Nosso objetivo é no final da configuração dos profiles termos uma estrutura:

    ```text
                 default
                    │
            ~/AppData/Local/hermes/
                    │
            ┌───────┴────────┐
            │                │
          GLOBAL          profiles/
            │                │
            │                ├───────────────────────────┬────────────┬...
         Profile          Agente1/                    Agente2/
            │                │                           │
          .env             .env                        .env
       config.yaml      config.yaml                 config.yaml
         SOUL.md          SOUL.md                     SOUL.md
            │                 │                           │
            │        Telegram + OpenRouter       Telegram + OpenRouter
            │                 │                           │
            ▼                 ▼                           ▼
        gateway run       gateway run                 gateway run
            │                 │                           │
            ▼                 ▼                           ▼
          running          running                     running
    ```

3. Agora abra o arquivo [create-profile_win.sh](./scripts/create-profile_win.sh) em um editor de coódigo como o Visual Studio Code ou outro editor de código, e coloque **NOME**, **MEU_ID**, **TOKEN** que se encontra no início do script (use a planilha [daddos_profile.xlsx](dados_profiles.xlsx) para auxiliar).
Exemplo:

    ```bash
    NOME=time-perfomance
    MEU_ID=(gerado no item 1 ao rodar o @userinfobot)
    TOKEN=(gerado no item 2 quando criado o bot)
    ```

4. Salve o arquivo e depois retorne ao terminal Bash;
5. Navegue pelo terminal até a pasta onde se encontra os arquivos;
6. Execute o script com o seguinte comando:  
    `bash create-profile_win.sh`
7. Aguarde o processor finalizar acompanhando os outputs no terminal;
8. Depois, abra novamente o arquivo e altere os dados para o próximo agente e repita a execução do script;
9. Continue repetindo este processo até cadastrar todos os profiles.
10. Para conferirmos se todos os agentes foram cadastrados no Hermes, execute o comando no terminal `hermes profile list`
    Vamos ter algo como:

    ![status2](./img/status_profile2.png)

11. Para ambiente windows localmente não podemos fechar o terminal, caso contrario os processos dos gateways dos profiles serão encerrados. Já para ambiente VPS isso não oscorre pois o sistema fica rodando 24/7 e só será necessário reiniciar caso seja realmente necessário.

### Step 3. Reativando os Gateways dos Profiles

Sempre que você estiver rodando localmente em ambiente Windows/linux será necessário a reativação dos gateways para os profiles de forma manual.
Primeiramente executar o comando (`hermes profile list`) para verificar que somente o profile default esta com status "running" os outros profile estão com gateway na condição **stopped**.

```text
              Hermes Gateway
                    │
                    │
          ┌─────────┴─────────┐
          │                   │
       default             profiles
       running             stopped
```

>[!WARNING] Se você estiver em um servidor e o mesmo foi reiniciado, este procedimento de reativação dos gateway dos profiles, também será necessário.

Abra o terminal e execute o comando para cada profile ou execute o script:

1. ⟹ Para sistemas operacionais Windows utilize:

    Executando por comando

    ```bash
    hermes -p time-perfomance gateway run --replace > /tmp/<profile_name>-gateway.log 2>&1 &
    sleep 8
    hermes gateway list
    ```

    Executando por Script -> [wakeup-gateway_win.sh](./scripts/wakeuo-gateway_win.sh)
    Em seguida confirmamos o status dos perfil utilizando o comando `hermes profile list`
    E para ver as portas que cada Gateway esta rodando utilize o comando `hermes gateway list`
        ![statusgateway](./img/status_profile3.png)
    <br/>
2. ⟹ Para sistemas operacionais Linux utilize:

    Executando por comando

    ```bash
    setsid hermes -p time-perfomance gateway run --replace > /tmp/<profile_name>-gateway.log 2>&1 &
    sleep 8
    hermes gateway list
    ```

    Executando por escript -> [wakeup-gateway_lin.sh](./scripts/wakeup-gateway_lin.sh)
    Em seguida confirmamos o status dos perfil utilizando o comando `hermes profile list`
    E para ver as portas que cada Gateway esta rodando utilize o comando `hermes gateway list`

> [!NOTE] **Ordem importa**:
    - o .env é gravado antes do gateway subir;
    - se inverter, dois profiles disputam o mesmo token e o bot fica mudo.
    - Cole um bloco de cada vez e espere os 8 segundos do sleep.
    - “Errno 98” na porta 8643 é normal: o primeiro gateway pega a porta de métricas, os outros reclamam e seguem.
    - A reativação é uma linha por profile de propósito, o shell do Hermes recusa for/done.
    - Se algum profile não subir, consulte o log localizado no diretório do próprio profile que está em **`profiles/<profile_name>/logs/gateway.log`**

## 3. Organizar a empresa no Telegram

Agora vamos organizar a estrutura da nossa empresa dentro do Telegram onde teremos uma pasta da empresa, um grupo por time, e o bot do agente dentro de cada grupo.
A lógica da organização:

* Cada grupo é um andar de um prédio;
* a pasta da empresa é o que junta os andares num prédio só;
* e cada agente entra no seu andar.

    ![organizando](./img/organizando1.png)

### Step 1. Criar um grupo por time

Vamos criar um grupo pra cada setor da empresa: Performance, SAC, Comercial, Conteúdo, Pedagógico.

1. No Telegram selecione a aba **Unread** (mas pode ser outra) e clique no icone de um lápis no rodapé da tela
2. Um menu será mostrado, clique em **New Group**
    ![grupo1](./img/grupo1.png) ![grupo2](./img/grupo2.png)
3. Nesta nova janela localise no rodapé uma seta, clique sobre ela e podemos ver agora uma janela para entrarmos com o nome deste novo grupo (neste exemplo estou entrando com o nome do "Time de Performance"), finalise clicando na seta no rodapé da pagina
    ![grupo3](./img/grupo3.png)
4. Podemos observar que foi carregado um chat vazio com o nome do nosso grupo na parte superior
    ![grupo4](./img/grupo4.png)
5. Agora repita os passos para criar os outros grupos
    ![grupo5](./img/grupo5.png)

### Step 2. Criar a Pasta da Empresa

1. No Telegram posicione o ponteiro do mouse sobre a aba **All** e clique com o botão direito do mouse e clique em **Edit folders**, em seguida clique em **CRIAR PASTA**

    ![pasta1](./img/pasta1.png) ![pasta2](./img/pasta2.png)
2. Dê o nome da dua empresa ou do departamento principal, responssável pelos grupos.
3. Em seguida adicione todos os grupos que criamos para esta pasta, confirme no tick no canto superior direito
    ![pasta3](./img/pasta3.png) ![pasta4](./img/pasta4.png)
4. Verifique se todos os grupos foram incluidos e confirme a criação da pasta clicando no tick no canto superior direito.
    ![pasta5](./img/pasta5.png) ![pasta6](./img/pasta6.png)
5. Agora podemos observar que a pasta da empresa foi criada e se encontra como uma aba logo abaico da barra de pesquisa.
    ![pasta7](./img/pasta7.png) ![pasta8](./img/pasta8.png)

### Step 3. Adcionar o Agente de Cada Grupo

1. Vamos adicionar cada Agente no seu respectivo Grupo, selecione e clique em um agente (neste caso será o Agente de Performance), será carregado o chat deste agente
2. Clique nos 3 pontinhos que esta no canto superior direito e selecione **Adicionar para Grupo**
    ![ag->grp1](./img/ag_to_grp1.png)
3. Na próxima janela teremos a lista com os grupos para onde o agente será adicionado, neste caso selecione o drupo Time de Performance e confirme.
4. Agora entre no grupo do Time de Performance e clique sobre o título do grupo, perceba que será apresentado um popup "Grupo Info" onde temos 2 membros e o Agente de Performance
    ![ag->grp2](./img/ag_to_grp2.png)
5. Clique sobre o lápis para editar o grupo e role para baixo até encontrar a opção **Administrators** (Administradores), neste caso só temos 1, que é você, mas queremos que o nosso agente passe a ser o administrador deste grupo também e para isso clique em Administrador
6. Uma nova janela é apresentada e confirma que temos somente um administrador, agora clique em adicionar no botão na parte inferior direita (1) e depois selecione o agente (2)
    ![ag->grp3](./img/ag_to_grp3.png) ![ag->grp4](./img/ag_to_grp4.png)
7. É apresentado a janela com as opções de administrador, teremos que ativar a opção **Add New Admins** (1) (Adcionar Novo Administrador) e em seguida comfirmar (2)
    ![AG->GRP5](./img/ag_to_grp5.png)
8. Retorne atá a tela de chat, deppois clique novamente sobre o nome do grupo para entrar na tela da informação do grupo, repare que agora o nosso agente esta como **admin** e se você verificar a imagem no item 4, verá que esta opção não estava ativa para o nosso agente.
    ![ag->grp6](./img/ag_to_grp6.png)
9. Repita todos os passos anteriores para fazer o mesmo para os outros agentes