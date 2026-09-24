# IDENTIDADE E DESCRIÇÃO DO AGENTE

## Entendendo a diferença entre "Identidade" e "Descrição"

Quando criamos os profiles o proprio Hermes já se encarrega de criar tanto a **Identidade** (Personalidade/Identidade) como a **Descrição** para o novo Agente (Profile). No caso da identidade, basicamente ele copía do profile **default** que é uma identidade genérica. Já para a descrição o Hermes presume a partir da analise do nome, mas nem sempre é realmente o que queremos. Portanto a melhor forma de termos controle sobre como o agente vai trabalhar é dando uma boa identidade e descrição de sua função, quase como a descrição de cargos e funções dentro de uma empresa.

Em um sistema multi-agente como o Hermes, um **Profile** é a configuração completa que define um agente.
Ele possui dois componentes distintos que operam em níveis diferentes do sistema:

### 1. Identidade (SOUL.md) — quem o agente *é***

> [!TIP]
> :brain: **Documentação oficial:**
> [Identidade - SOUL.md](https://hermes-agent.nousresearch.com/docs/user-guide/features/personality)

- É o conteúdo carregado como **slot #1 do system prompt**, ou seja, entra na janela de contexto do modelo a cada execução;
- Define **comportamento interno**: personalidade, valores, instruções operacionais, limites, tom de voz e método de trabalho;
- Responde à pergunta: *"como este agente pensa e age?"*;
- Só é vista pelo **modelo de linguagem** — nem o orquestrador nem outros agentes a leem;
- Formato: arquivo markdown livre (`~/.hermes/profiles/<profile_name>/SOUL.md`), sem limite prático de extensão;
- Impacta diretamente a **qualidade da execução** das tarefas.

### 2. Descrição (profile.yaml) — o que o agente *faz***

> [!TIP]
> :brain: **Documentação oficial:**
> [Descrição de um Profile](https://hermes-agent.nousresearch.com/docs/reference/profile-commands#hermes-profile-describe)
> [Configuração do Profile](https://hermes-agent.nousresearch.com/docs/user-guide/profiles)
> [Configuração de um Agente](https://hermes-agent.nousresearch.com/docs/user-guide/configuration)

- É um **campo de metadados** (`description` no `profile.yaml`), tipicamente 1–2 frases curtas;
- Responde à pergunta: *"para que serve este agente?"*;
- É lida pelo **orquestrador kanban** para decidir **roteamento**: qual perfil recebe cada tarefa com base em sua especialidade;
- Também aparece em listagens (`hermes profile list`) e na documentação de time;
- Nunca entra no prompt do modelo — o agente não conhece a própria descrição;
- Formato: arquivo yaml (`~/.hermes/profiles/<profile_name>/profile.yaml`), ideal que seja no máximo em 2 frases.
- Impacta diretamente a **eficiência da delegação** de tarefas.

| Arquivo | O que guarda |
|---|---|
| `SOUL.md` | Identidade completa do agente (personalidade, instruções, limites) — slot #1 do system prompt |
| `profile.yaml` | Descrição curta (1-2 frases) para roteamento do orquestrador |

**Síntese em uma frase:**
> **Identidade** é a persona operacional que o modelo executa;
> **Descrição** é o rótulo de especialidade que o sistema usa para distribuir trabalho.

**Consequência prática:**
As duas devem ser consistentes — a descrição promete uma especialidade (ex.: "otimiza campanhas focando em ROI e CPA") que a identidade precisa saber cumprir. Uma descrição inflada com competências ausentes no SOUL.md gera roteamento correto mas execução ruim; o inverso, um ótimo agente subutilizado porque o orquestrador não sabe delegar a ele.

## Atualizando - Identidade

Podemos atualizar via **CLI** - (terminal) ou editando o arquivo diretamente com um editor de texto.

## Atualizando - Descrição

Podemos atualizar via **CLI** - (terminal) ou editando o arquivo diretamente com um editor de texto.

1. Via CLI (terminal):

    1. Iniciamos com a listagem de todos os profiles para verificarmos os nomes corretos:

        ```bash
        hermes profile list
        ```

    2. Verifique qual foi a descrição criada pelo próprio Hermes, executamos:

        1. Ver a descrição especifica de um profile

            ```bash
            hermes profile describe <profile_name>
            ```

        2. Ver a descrição de todos os profiles cadastrado no Hermes

            ```bash
            hermes profile describe --all
            ```

    3. Registrando uma nova descrição para o agente

        ```bash
        hermes profile describe <profile_name> --text "<TEXTO>" --overwrite
        ```

        > [!NOTE]
        > A descrição é persistida ali para sobreviver a reboots e ser compartilhada com o gateway.
        > A descrição é consumida pelo **orquestrador kanban** para rotear tarefas com base no papel de cada perfil.

