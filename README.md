# HERMES AGENT - PROJECTS REFERENCE DOCUMENTS

![1](./img/banner.png)

## Objetivo deste Documento

Navegando na web eu pude entrontrar vários entusiastas de automação comentando sobre a utilização do **Hermes Agent da Nous Research**, mas na grande maioria esta abordando o mesmo asunto que é a instalação e configurações básicas, que também é fundamental para quem esta tendo o primeiro contato com este ferramenta (agente), mas que esta carente de demostração e documentação com explicação detalhada de como colocar em uso.
Pensando nisso e partindo de uma necessidade pessoal, pois estou explorando a utilização do Hermes Agent, descidi documentar algumas aplicações de uso do Hermes Agent em projetos reais conforme eu vou estudando, tanto para minha consulta futura como para compartirlhar com outros que querenter uma documentação pratica com caso de uso.
Para ficarmos na mesma página vou fazer uma descrição objetiva do meu ponto de vista o que é o **Hermes Agent** e para que serve.
> Documentação Oficial:
    Para uma consulta mais apurada dos comandos, recomendo consultar a documentação oficial do Hermes Agent em ==[Docs](https://hermes-agent.nousresearch.com/docs)==
    Pagina oficial do projeto no ==[GitHub](https://github.com/NousResearch/hermes-agent)==

## Entendendo o Hermes Agent

Lendo alguns artigos sobre o assunto, observei que alguns estão chamando o Hermes Agent de **Frameworks**, mas quero registrar uma distinção importante sobre esta afirmação.
O Hermes Agent pode ser chamado de framework, mas arquiteturalmente ele é mais bem entendido como uma **plataforma/runtime de agente autônomo** que incorpora um **framework de ferramentas, memória, skills e execução**.

A propria literatura do Hermes Agent da Nous Research, é um projeto open source sob licença MIT e possui CLI, memória persistente, skills, ferramentas, MCP, subagentes, automações e diferentes backends de execução.

### 1. Por que o Hermes Agent é considerado um framework?

Um framework não é simplesmente uma aplicação pronta. Ele fornece uma estrutura arquitetural reutilizável para construir ou executar aplicações de determinado tipo.
No Hermes, temos vários componentes que formam essa infraestrutura:
```
                    HERMES AGENT
                         │
        ┌────────────────┼────────────────┐
        │                │                │
      Agent            Memory           Skills
        │                │                │
        ├──── Tools ─────┤                │
        │                │                │
       MCP          Persistent          Procedural
        │             Memory             Knowledge
        │                │                │
        └─────────── Execution ───────────┘
                         │
               ┌─────────┼─────────┐
               │         │         │
             Local     Docker     SSH
               │
          Cloud / VPS
```
