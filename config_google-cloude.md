# Configuração do Google Cloud Platform

## Conteúdo
<!-- toc -->

<!-- tocstop -->

> **Antes de começar:** Além disso, o Hermes avisa que o Google Drive não aceita o cadastro OAuth automático: é preciso criar um cliente OAuth próprio. [Google: configuração dos servidores MCP](https://developers.google.com/workspace/guides/configure-mcp-servers) · [Hermes: integração MCP e Google Drive](https://hermes-agent.nousresearch.com/docs/user-guide/features/mcp)

## Step 1 — Preparar o Google

1. **Acessando a Google Cloud Platform**  
   Acesse [Google Cloud](https://cloud.google.com/), faça o login

2. **Crie ou selecione um projeto no Google Cloud.**
   Acesse o menu lateral esquerdo em `GOOGLE CLOUD -> IAM e admin -> Criar um projeto`
   * Dê o nome para o seu projeto e confirme em `criar`

3. **Habilite os serviços do Google que pretende conectar.** 
   Acesse o menu lateral esquerdo em `GOOGLE CLOUD -> APIs e serviços -> APIs e serviços ativados`
   Na parte superior da tela clique no botão `+ Ativar APIs e serviços`
   Para começar só com Drive, habilite a **Google Drive API**. Cada produto tem suas próprias APIs. Para Gmail, Docs, Sheets e Calendar, habilite os serviços correspondentes quando for adicioná-los. [Lista oficial de APIs e serviços](https://developers.google.com/workspace/guides/configure-mcp-servers)
   Depois clique na parte superior em retornar em `Bibliotéca de APIs`

4. **Configure a tela de consentimento OAuth.**
   Acesse novamente o menu lateral esquerdo em `GOOGLE CLOUD -> APIs e serviços -> Credênciais`
   Será mostrado um aviso solicitando a configuração da tela de permissão OAuth, clique no botão `Configurar tela de concentimento`
   No Google Cloud, abra **Google Auth Platform** e configure `Informações do App, Público, Contact Information`.
   - Informação do App
      * Nome do app: Hermes
      * Email para suporte do usuário: cadastre o seu
         * clique em avançar
   - Público
      * Selecione **Externo**
         * clique em avançar
   - Dados de contato
      * insira o seu endereço de email
         * clique em avançar
   - Concluir
      * marque a caixa para aceitar os termos
         * clique em avançar
         * criar

5. **Criando as Credenciais**
Acesse novamente o menu lateral esquerdo em `GOOGLE CLOUD -> APIs e serviços -> Credênciais`
   - Na parte superior da tela clique no botão `Criar credenciais` e escolha `ID do cliente OAuth`
   - No campo `Tipo de aplicativo` selecione a opção `App para computador`
   - Em seguida de um nome a esta credencial `Hermes` e depois clique em `criar`
   - Agora será apresntado o **ID do Cliente** e o **Chave secreta do cliente**, faça o download do arquivo `JSON`

> [!WARNING] Não revele estas informações é um Token de acesso

6. **Status de publicação**
Queros configurar um usuário como teste, pois não vamos publicar este app, será para uso interno.
- Acesse novamente o menu lateral esquerdo em `GOOGLE CLOUD -> APIs e serviços -> Tela de permisão OAuth` e depois clique em `Público-alvo` no menu lateral
- Role a pagina até encontrar `Usuário de teste` e clique em `+ Add users`
- adicione o seu email e precione `Enter` para confirmar e em seguida salvar


## Step 2 — Conectar o Drive ao Hermes

6. **Abra o arquivo de configuração do Hermes** em um editor de texto:

   ```text
   %USERPROFILE%\.hermes\config.yaml
   ```

   Se você usa um perfil Hermes específico, a configuração pode estar na pasta desse perfil. Faça uma cópia de segurança do arquivo antes de editar.

7. **Adicione esta configuração**, substituindo os dois valores entre `< >` pelas credenciais do seu cliente OAuth:

   ```yaml
   mcp_servers:
     googledrive:
       url: "https://drivemcp.googleapis.com/mcp/v1"
       auth: oauth
       oauth:
         client_id: "<SEU_CLIENT_ID>"
         client_secret: "<SEU_CLIENT_SECRET>"
   ```

   Essa é a estrutura que o Hermes documenta para o servidor oficial do Drive quando se usa um cliente OAuth próprio. [Exemplo de configuração no Hermes](https://hermes-agent.nousresearch.com/docs/user-guide/features/mcp)

8. **Salve o arquivo e abra um terminal novo.**  
   Execute:

   ```powershell
   hermes mcp login googledrive
   ```

   O Hermes deve abrir uma página do Google para você entrar e autorizar o acesso. Confira a conta Google exibida antes de aprovar.

9. **Teste com uma pergunta simples**, por exemplo:  
   “Liste alguns arquivos do meu Google Drive.”  
   Para o primeiro teste, prefira uma consulta de leitura. Depois, confirme no Hermes que as ferramentas do Drive estão disponíveis.

## Step 3 — Adicionar outros serviços

10. **Repita a configuração para cada produto**, dando a cada servidor um nome próprio. Por exemplo, para Google Calendar:

   ```yaml
   mcp_servers:
     googlecalendar:
       url: "https://calendarmcp.googleapis.com/mcp/v1"
       auth: oauth
       oauth:
         client_id: "<SEU_CLIENT_ID>"
         client_secret: "<SEU_CLIENT_SECRET>"
   ```

   O Google publica servidores separados para [Gmail, Drive, Docs, Sheets, Slides e Calendar](https://developers.google.com/workspace/guides/configure-mcp-servers). Só adicione os que você realmente pretende usar.

### Se aparecer um erro

- **Erro ao obter o token ou cadastrar o cliente:** confira se o Client ID e o Secret foram copiados corretamente e se o cliente OAuth está configurado.
- **A tela do Google abre, mas as ferramentas não funcionam:** o login pode não ter concluído a autorização. Rode `hermes mcp login googledrive` de novo em um terminal novo.
- **Você não encontra os serviços MCP no Google Cloud:** confirme a inscrição na prévia e se escolheu o projeto certo.

O Hermes avisa que uma conexão pode parecer instalada mesmo quando a autenticação não terminou; por isso, o teste final é pedir uma leitura real ao Drive. Para sua conta, recomendo começar com **Drive e Docs**, e conectar Gmail ou Calendar só depois de confirmar que essa etapa funciona.