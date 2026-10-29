# Configuração do Google Workspace

## Conteúdo
<!-- toc -->

<!-- tocstop -->


Claro. Vamos fazer como uma aula: **primeiro conectar um serviço**, confirmar que funciona e depois adicionar os outros. Para começar, sugiro o Google Drive; Gmail e Calendar podem esperar.

> **Antes de começar:** os servidores oficiais MCP do Google Workspace ainda estão em *Developer Preview*. Você precisa estar inscrito no programa de prévia e ter um projeto no Google Cloud. Além disso, o Hermes avisa que o Google Drive não aceita o cadastro OAuth automático: é preciso criar um cliente OAuth próprio. [Google: configuração dos servidores MCP](https://developers.google.com/workspace/guides/configure-mcp-servers) · [Hermes: integração MCP e Google Drive](https://hermes-agent.nousresearch.com/docs/user-guide/features/mcp)

## Aula 1 — Preparar o Google

1. **Confirme que sua conta pode usar a prévia.**  
   Se a conta for administrada pela sua empresa, talvez o administrador precise habilitar o acesso.

2. **Crie ou selecione um projeto no Google Cloud.**  
   Anote o **ID do projeto**; você vai usá-lo para habilitar os serviços.

3. **Habilite os serviços do Google que pretende conectar.**  
   Para começar só com Drive, habilite a **Google Drive API** e a **Google Drive MCP API**. Cada produto tem seu próprio servidor MCP e suas próprias APIs. Para Gmail, Docs, Sheets e Calendar, habilite os serviços correspondentes quando for adicioná-los. [Lista oficial de APIs e serviços](https://developers.google.com/workspace/guides/configure-mcp-servers)

4. **Configure a tela de consentimento OAuth.**  
   No Google Cloud, abra **Google Auth Platform** e configure Branding, Audience e Data Access. Se o uso for só dentro da organização, escolha **Internal** quando essa opção estiver disponível. Use apenas os escopos dos serviços que pretende conectar.

5. **Crie um cliente OAuth.**  
   Em **Google Auth Platform → Clients**, crie o cliente e guarde o **Client ID** e o **Client Secret** em local seguro. Não os cole aqui, nem os coloque em instruções do Hermes.

## Aula 2 — Conectar o Drive ao Hermes

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

## Aula 3 — Adicionar outros serviços

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