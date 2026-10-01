# HERMES AGENT  

![banner](./img/banner2.png)

## EXEMPLO DE PROJETOS COM APLICAÇÃO REAL

## Objetivo deste Documento

Navegando na web eu pude entrontrar vários entusiastas de automação comentando sobre a utilização do **Hermes Agent da Nous Research**, mas a grande maioria esta abordando o mesmo asunto que é a instalação e configurações básicas, que também é fundamental para quem esta tendo o primeiro contato com esta ferramenta (agente), mas esta carente de demostração e documentação com explicação detalhada de como colocar em uso.

Pensando nisso e partindo de uma necessidade pessoal, descidi documentar algumas aplicações de uso do Hermes Agent em projetos reais conforme eu vou estudando, tanto para minha consulta futura assim como, compartirlhar com outros que querem ter uma documentação prática com caso de uso.
Para ficarmos na mesma página vou fazer uma descrição objetiva do meu ponto de vista do que se trata e o que é o **Hermes Agent**.

> [!NOTE]
> ➩ Criando multiplos Profiles e controlando pelo Telegram: [multi_agent-Telegram.md](multi_agent-Telegram.md)
> ➩ Configurando a Identidade e a Descrição dos Profiles: [profile_identity_describe.md](profile_identity_describe.md)
> ➩ Configurando memória persistente: Em breve

> Documentação Oficial:
    - Pagina oficial do projeto no GitHub: [Hermes-Agent](https://github.com/NousResearch/hermes-agent)
    - Recomendo consultar a documentação oficial do Hermes Agent: [Docs](https://hermes-agent.nousresearch.com/docs)
</br>

---

## Entendendo o Hermes Agent

Lendo alguns artigos sobre o assunto, observei que alguns estão chamando o Hermes Agent de **Frameworks**, mas quero registrar uma distinção importante sobre esta afirmação.
O Hermes Agent pode ser chamado de framework, mas arquiteturalmente ele é mais bem entendido como uma **plataforma/runtime de agente autônomo** que incorpora um **framework de ferramentas, memória, skills e execução**.
A própria literatura do Hermes Agent da Nous Research já afirma isso quando afirma e apresnta que é dotado de CLI, memória persistente, skills, ferramentas, MCP, subagentes, automações e diferentes backends de execução.

### 1. Por que o Hermes Agent pode ser considerado um framework?

Um framework não é simplesmente uma aplicação pronta. Ele fornece uma estrutura arquitetural reutilizável para construir ou executar aplicações de determinado tipo.
No Hermes, temos vários componentes que formam essa infraestrutura:

```text
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

### 2. Conceito do Que é Agente

#### Agente

Em uma frase: Um Agente é um funcionário de IA — um cargo configurado com um cargo específico.

A analogia: Criar um agente com abilidades de um corretor, de um empreiteiro, de um programador, etc... Você não apenas insere "uma IA", que é o cerebro do agente — você define o cargo, descreve pelo que ela é responsável, dá as ferramentas de que precisa, diz para quem responde e outros atributos.

Por que o Agente existe: Sem agentes, não temos ninguém para fazer o trabalho. A camada de agente é o que transforma um objetivo em ação. Cada agente tem um papel claramente definido para que vários agentes possam colaborar sem confusão sobre quem é responsável por quê.
