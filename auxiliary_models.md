# Auxiliary Models

O objetivo deste documento é selecionar modelos adequados para **tarefas auxiliares de agentes**, evitando usar um modelo caro para operações que podem ser executadas por modelos menores, rápidos e especializados.

A lógica é separar o **modelo orquestrador principal** das tarefas de apoio. O auxiliar deve ser escolhido principalmente por:

- **custo por token**;
- **latência e throughput**;
- **structured output / JSON**;
- **function calling / tool use**;
- **multimodalidade** quando necessária;
- **contexto**;
- **estabilidade e disponibilidade do provedor**;
- **possibilidade de execução local**.

> **Atualização:** 02/10/2026  
> **Base:** preços, modelos e disponibilidade verificados em outubro de 2026.  
> **Importante:** preços e variantes mudam rapidamente; confirme o preço efetivo no provedor ou no OpenRouter antes de fixar uma arquitetura de produção.

---

## 1. LLMs pagos com melhor custo-benefício para tarefas auxiliares

### Princípio central

Para tarefas auxiliares, normalmente vale mais um modelo **rápido e econômico com saída controlada** do que um modelo de fronteira usado indiscriminadamente.

Vamos incluem nesta análise os modelos de baixo custo como: **GPT-6 Luna**, **Gemini 3.1 Flash-Lite** e **DeepSeek V4.1 Flash**. O **Claude Haiku 4.5** continua relevante quando a qualidade de raciocínio, coding e tool use justificar o custo adicional.

### 1.1 Modelos de referência

| Modelo | Uso principal | Preço de referência* | Contexto | Structured output / tools | Observação |
|---|---|---:|---:|---|---|
| **OpenAI GPT-6 Luna** (`openai/gpt-6-luna`) | Workhorse geral, classificação, triagem, MCP leve | **$0.10 / $0.50** | ~1.05M | ✅ / ✅ | Excelente equilíbrio entre custo, velocidade e capacidade geral |
| **Google Gemini 3.1 Flash-Lite Preview** (`google/gemini-3.1-flash-lite-preview`) | Alto volume, extração, triagem, Vision | **$0.25 / $1.50** | ~1M | ✅ / ✅ | Projetado para tarefas agentivas de alto volume; possui thinking configurável |
| **DeepSeek V4.1 Flash** (`deepseek/deepseek-flash`) | Reasoning barato, revisão, Vision e tool use | **$0.15 / $0.60** | ~1M | ✅ / ✅ | Multimodal e muito competitivo em custo; tem preço off-peak reduzido no API oficial |
| **OpenAI GPT-5 Nano** (`openai/gpt-5-nano`) | Microtarefas, classificação e roteamento | **$0.05 / $0.40** | 400K | ✅ / ✅ | Opção de custo extremamente baixo dentro da família GPT |
| **Anthropic Claude Haiku 4.5** (`anthropic/claude-haiku-4.5`) | Review, coding, tool use e subagentes | **$1.00 / $5.00** | 200K | ✅ / ✅ | Usar quando a qualidade adicional justificar o custo |
| **OpenAI GPT-5 Mini** (`openai/gpt-5-mini`) | Reasoning intermediário e tarefas agentivas | **$0.25 / $2.00** | 400K | ✅ / ✅ | Continua útil quando Nano é limitado e Luna não é a melhor opção |

\* Valores de referência por **1 milhão de tokens de entrada / saída**. O preço real pode variar por provedor, cache, batch, região e nível (tier) de processamento.

### 1.2 Mapeamento por tarefa

| Tarefa | Modelo recomendado | Alternativa | Escalar quando |
|---|---|---|---|
| **Vision / OCR / screenshots** | **Gemini 3.1 Flash-Lite** | DeepSeek V4.1 Flash / GPT-6 Luna | PDF muito complexo, análise visual sofisticada ou baixa confiança |
| **Compression / summarization** | **GPT-6 Luna** | Gemini 3.1 Flash-Lite / DeepSeek V4.1 Flash | Contexto excepcionalmente complexo ou síntese com forte raciocínio |
| **Skills hub / classificação de intenção** | **GPT-6 Luna** ou Gemini 3.1 Flash-Lite | GPT-5 Nano | Classificador apresentar baixa confiança |
| **Approval / policy check** | **GPT-6 Luna** | Claude Haiku 4.5 | A decisão exigir interpretação mais profunda ou maior sensibilidade |
| **MCP routing / tool selection** | **GPT-6 Luna** | Claude Haiku 4.5 / DeepSeek V4.1 Flash | Muitas tools encadeadas ou ambiguidades de seleção |
| **Title generation** | **GPT-5 Nano** | Gemini 3.1 Flash-Lite | Praticamente nunca |
| **Review técnico / código** | **DeepSeek V4.1 Flash** | Claude Haiku 4.5 | Código ou lógica com elevada criticidade |
| **Triage / classificação rápida** | **GPT-5 Nano** | GPT-6 Luna / Gemini 3.1 Flash-Lite | Casos ambíguos ou baixa confiança |
| **Kanban decomposer** | **GPT-6 Luna** | Gemini 3.1 Flash-Lite / DeepSeek V4.1 Flash | Requisitos grandes, conflitantes ou pouco especificados |
| **Profile describer** | **GPT-5 Nano** | Gemini 3.1 Flash-Lite | Praticamente nunca |
| **Curator / síntese** | **DeepSeek V4.1 Flash** | GPT-6 Luna / Claude Haiku 4.5 | Curadoria com forte necessidade de julgamento |
| **Extração estritamente estruturada** | **Gemini 3.1 Flash-Lite** | GPT-6 Luna / modelos especializados de extração | Schema muito complexo ou dados críticos |

---

### 2. Modelos especializados que merecem atenção

Nem toda tarefa auxiliar precisa de um LLM generalista.

#### Schematron V2 Turbo

Modelo especializado em **HTML → JSON / extração estruturada**, disponível no OpenRouter, com preço de referência de cerca de $0.03/M (input) e $0.15/M (output).

Ele faz sentido quando a tarefa é essencialmente:

```text
documento → campos definidos → JSON
```

e não exige raciocínio aberto.

Para pipelines com grande volume de extração, um modelo especializado pode reduzir custo e latência em comparação com um LLM geral.

### 3. Stacks recomendadas

#### 3.1 Single-provider: OpenAI

Uma arquitetura simples baseada apenas no ecossistema OpenAI:

```text
GPT-5 Nano
├── title generation
├── triage
├── classificação
└── microtarefas

GPT-6 Luna
├── MCP routing
├── decomposição
├── compression
├── review leve
└── agente auxiliar geral
```

**Vantagens**

- uma API principal;
- integração uniforme;
- structured output e tool use;
- menor complexidade operacional.

**Desvantagem principal**

- concentração de dependência em um único provedor.

#### 3.2 Single-provider: Google

Arquitetura adequada quando **Vision + contexto longo + alto volume** são importantes:

```text
Gemini 3.1 Flash-Lite
├── Vision
├── OCR
├── extraction
├── triage
├── title generation
└── classificação

Gemini 3.x Flash
└── tarefas auxiliares que exigem mais raciocínio
```

Para novos projetos, o Google recomenda a geração mais recente dos modelos Flash/Lite; o **Gemini 2.5 Flash-Lite** continua disponível para workloads existentes, mas não deve ser tratado como primeira opção para uma arquitetura nova.

#### 3.3 Multi-provider via OpenRouter

Para uma arquitetura baseada em router:

```text
                         ┌── GPT-5 Nano
                         │
                         ├── GPT-6 Luna
                         │
Request → Router ────────┼── Gemini 3.1 Flash-Lite
                         │
                         ├── DeepSeek V4.1 Flash
                         │
                         └── Claude Haiku 4.5
```

**Vantagens**

- fallback entre provedores;
- escolha por custo;
- escolha por latência;
- acesso a múltiplos modelos por uma API;
- possibilidade de trocar o modelo sem reescrever toda a aplicação.

Para o cenário do Hermes Agent + OpenRouter, esta estratégia é particularmente interessante porque permite manter uma única camada de acesso e modificar apenas o `model`.

#### 3.4 Cascata por confiança

A arquitetura mais eficiente para agentes com muitas chamadas auxiliares é:

```text
               ┌── sucesso → retorna
Request ───────┤
               └── baixa confiança / erro JSON
                         ↓
                    modelo superior
                         ↓
                     sucesso
```

Exemplo:

```text
Triage:
GPT-5 Nano
   ↓ falha
GPT-6 Luna
   ↓ falha
Claude Haiku 4.5
```

Outro exemplo:

```text
Review:
DeepSeek V4.1 Flash
   ↓ baixa confiança
Claude Haiku 4.5
   ↓ ainda crítico
Modelo orquestrador principal
```

#### Regra prática

Não escale simplesmente por "erro". Escale por **sinais observáveis**:

- JSON inválido;
- schema incompleto;
- confidence abaixo do threshold;
- número excessivo de retries;
- classificação `ambiguous`;
- conflito entre fontes;
- requisito de raciocínio acima do nível da tarefa;
- ferramenta selecionada incorretamente.

### 4. Onde está a economia real

A escolha do modelo importa, mas **a engenharia da chamada costuma importar tanto quanto o modelo**.

#### 4.1 Output controlado

Em tarefas auxiliares:

```text
temperature baixa
max_tokens pequeno
JSON schema restrito
enums quando possível
```

Evite pedir:

```text
"Explique detalhadamente sua análise..."
```

quando basta:

```json
{
  "status": "approved",
  "confidence": 0.94
}
```

O objetivo é produzir apenas o artefato que a próxima etapa realmente precisa.

#### 4.2 Prompt caching

Quando o agente repete:

- system prompt;
- regras;
- exemplos;
- schemas;
- definições de tools;

o cache pode reduzir significativamente o custo efetivo.

Isso é especialmente importante em:

- MCP;
- agentes com muitas tools;
- pipelines com prompt fixo;
- revisão de documentos com instruções padronizadas.

#### 4.3 Batch

Para tarefas que não precisam de resposta imediata:

```text
title generation
document classification
profile enrichment
curation
embedding jobs
dataset preprocessing
```

Batch pode ser mais barato que chamadas síncronas. A OpenAI documenta **50% de desconto** no Batch API, com processamento assíncrono de até 24 horas.

#### 4.4 Compression em cascata

Compression não deve ser tratada apenas como "resumir".

Uma boa etapa de compression pode reduzir:

```text
Contexto original
      ↓
Contexto comprimido
      ↓
MCP
      ↓
Review
      ↓
Orquestrador
```

Cada token eliminado antes das etapas seguintes reduz potencialmente o custo de todas elas.

### 5. Exemplo de um Custo Real

Considere:

```text
5.000 chamadas auxiliares/dia
800 tokens de entrada
150 tokens de saída
30 dias
```

Isso produz aproximadamente:

```text
120 milhões de tokens de entrada/mês
22,5 milhões de tokens de saída/mês
```

#### Exemplo: GPT-5 Nano

```text
120M × $0.05 = $6.00
22.5M × $0.40 = $9.00

≈ $15/mês
```

#### Exemplo: GPT-6 Luna

```text
120M × $0.10 = $12.00
22.5M × $0.50 = $11.25

≈ $23,25/mês
```

#### Exemplo: Gemini 3.1 Flash-Lite

```text
120M × $0.25 = $30.00
22.5M × $1.50 = $33.75

≈ $63,75/mês
```

#### Exemplo: DeepSeek V4.1 Flash

No preço nominal:

```text
120M × $0.15 = $18.00
22.5M × $0.60 = $13.50

≈ $31,50/mês
```

Esses cálculos são **ilustrativos** e não consideram cache, descontos, batch, retries ou diferenças de uso por modalidade.

---

## 2. Melhores opções gratuitas / free tier

Agora vamos considerar as opções "Grátis" pode significar três coisas diferentes:

1. **API com free tier**;
2. **variante gratuita em um router**;
3. **modelo open-weight executado localmente**.

Essas três modalidades não devem ser tratadas como equivalentes.

### 2.1 API gratuita

#### Gemini 3.1 Flash-Lite

O Google oferece **Free Tier** para o Gemini 3.1 Flash-Lite.

É especialmente interessante para:

- classificação;
- extração;
- triage;
- pequenas transformações;
- Vision;
- tarefas agentivas de alto volume.

#### OpenRouter Free Models

O OpenRouter mantém variantes gratuitas e também disponibiliza:

```text
openrouter/free
```

Esse router escolhe dinamicamente um modelo gratuito compatível com os requisitos da chamada.

**Atenção:** por ser dinâmico, `openrouter/free` é adequado principalmente para:

- prototipagem;
- testes;
- aplicações de baixo risco;
- workloads em que a variabilidade do modelo é aceitável.

Para produção, prefira fixar um modelo específico quando a consistência for importante.

### 2.2. Mapeamento gratuito por tarefa

| Tarefa | API gratuita | Open-weight / local |
|---|---|---|
| **Vision** | Gemini 3.1 Flash-Lite | Gemma 4 E4B / E2B |
| **Compression** | Gemini 3.1 Flash-Lite | Gemma 4 E4B / E2B |
| **Skills hub** | Gemini 3.1 Flash-Lite | Qwen3-Embedding-0.6B + LLM local |
| **Approval** | Gemini 3.1 Flash-Lite | Gemma 4 E4B / 12B |
| **MCP** | Gemini 3.1 Flash-Lite | Gemma 4 / GPT-OSS 20B |
| **Title gen** | Gemini 3.1 Flash-Lite | Gemma 4 E2B |
| **Review** | OpenRouter free variants | GPT-OSS 20B / Gemma 4 12B |
| **Triage** | Gemini 3.1 Flash-Lite | Gemma 4 E2B / E4B |
| **Kanban decomposer** | Gemini 3.1 Flash-Lite | GPT-OSS 20B / Gemma 4 12B |
| **Profile describer** | Gemini 3.1 Flash-Lite | Gemma 4 E2B |
| **Curator** | OpenRouter free variants | Gemma 4 12B / 26B A4B |

### 3. Open-weight recomendados para execução local

#### 3.1 OpenAI GPT-OSS 20B

**Modelo:**

```text
openai/gpt-oss-20b
```

Características relevantes:

- open-weight;
- Apache 2.0;
- MoE;
- 131K de contexto;
- function calling;
- structured output;
- adequado para inferência de menor latência.

No OpenRouter, a referência observada é aproximadamente:

```text
$0.02/M input
$0.10/M output
```

Quando hospedado no Groq, o modelo também está disponível em infraestrutura de inferência de alta velocidade.

É uma opção especialmente interessante para:

```text
MCP
triage
classificação
review leve
automação
```

#### 3.2 Gemma 4 E2B / E4B

Os modelos Gemma 4 incluem:

- multimodalidade;
- reasoning;
- function calling;
- coding;
- document understanding.

O **Gemma 4 E2B** é particularmente interessante para máquinas com recursos limitados, enquanto E4B é uma opção intermediária.

O Gemma 4 também inclui modelos maiores, como:

```text
Gemma 4 12B
Gemma 4 26B A4B
Gemma 4 31B
```

O **26B A4B** é MoE e ativa aproximadamente 3,8B parâmetros por token, mas o arquivo completo é significativamente maior e não deve ser presumido como adequado para uma GPU pequena.

#### 3.3 Qwen3-Embedding-0.6B

Para **Skills hub / RAG / memória vetorial**, não use um LLM generativo apenas para gerar embeddings.

Uma opção open-weight compacta atual é:

```text
Qwen/Qwen3-Embedding-0.6B
```

Ele pode ser utilizado diretamente com `sentence-transformers` e tem pouco mais de 1 GB em formato de pesos publicado.

Outra opção madura permanece:

```text
BAAI/bge-m3
```

O BGE-M3 continua interessante principalmente quando se deseja uma solução multilíngue e flexível de retrieval.

---

## 3. Arquitetura recomendada para o seu cenário

Para um sistema de múltiplos agentes com **Hermes Agent + OpenRouter**, a melhoropção seria estruturar a camada auxiliar em quatro níveis:

```text
┌──────────────────────────────────────────────┐
│             ORQUESTRADOR PRINCIPAL           │
│       modelo de maior capacidade/raciocínio   │
└───────────────────────┬──────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────┐
│              AUXILIAR — NÍVEL 1              │
│ GPT-5 Nano / modelo ultrabarato               │
│ title • triage • classificação • routing      │
└───────────────────────┬──────────────────────┘
                        │
                 baixa confiança
                        ▼
┌──────────────────────────────────────────────┐
│              AUXILIAR — NÍVEL 2              │
│ GPT-6 Luna / Gemini 3.1 Flash-Lite            │
│ MCP • decomposição • compression • Vision     │
└───────────────────────┬──────────────────────┘
                        │
                 tarefa complexa
                        ▼
┌──────────────────────────────────────────────┐
│              AUXILIAR — NÍVEL 3              │
│ DeepSeek V4.1 Flash / Claude Haiku 4.5        │
│ review • coding • reasoning • julgamento      │
└──────────────────────────────────────────────┘
```

#### Configuração-base sugerida

| Função | Modelo-base |
|---|---|
| Microtarefas | **GPT-5 Nano** |
| Workhorse auxiliar | **GPT-6 Luna** |
| Vision / multimodal | **Gemini 3.1 Flash-Lite** |
| Reasoning econômico | **DeepSeek V4.1 Flash** |
| Review mais exigente | **Claude Haiku 4.5** |
| Local / open-weight | **GPT-OSS 20B ou Gemma 4 E4B** |
| Embeddings | **Qwen3-Embedding-0.6B** |

---

## 4. Regras operacionais

### Para alta frequência

Priorize:

```text
latência
custo
saída curta
determinismo
```

### Para MCP

Priorize:

```text
function calling
structured output
seleção correta de tools
schema pequeno
cache
```

### Para Vision

Priorize:

```text
multimodalidade nativa
OCR
document understanding
custo por imagem/token
```

### Para Review

Priorize:

```text
raciocínio
consistência
detecção de inconsistência
capacidade de seguir critérios
```

### Para processamento local

Priorize:

```text
licença
tamanho do modelo
RAM/VRAM
quantização disponível
latência
privacidade
```

---

## 5. Conclusão

A estratégia mais eficiente em 2026 não é procurar **um único "melhor modelo auxiliar"**.

É construir uma **camada auxiliar especializada e em cascata**:

```text
microtarefa
    ↓
GPT-5 Nano
    ↓
GPT-6 Luna / Gemini 3.1 Flash-Lite
    ↓
DeepSeek V4.1 Flash
    ↓
Claude Haiku 4.5
    ↓
orquestrador principal
```

A principal decisão arquitetural deve ser:

> **usar o modelo mais barato que consiga executar a tarefa com confiabilidade suficiente.**

Para o cenário de agentes, a economia mais significativa tende a vir da combinação:

```text
modelo adequado
+ output curto
+ structured output
+ cache
+ batch
+ routing
+ fallback
+ confidence threshold
```

E não apenas da escolha de um modelo barato.

---

## 6. Fontes consultadas

- OpenAI API Pricing: https://platform.openai.com/pricing
- OpenAI GPT-5: https://openai.com/pt-BR/index/introducing-gpt-5-for-developers/
- Google Gemini API Pricing: https://ai.google.dev/gemini-api/docs/pricing
- Google Gemini 3 Guide: https://ai.google.dev/gemini-api/docs/gemini-3
- DeepSeek Models & Pricing: https://api-docs.deepseek.com/quick_start/pricing/
- DeepSeek V4.1 Flash: https://api-docs.deepseek.com/news/news260910/
- OpenRouter Models: https://openrouter.ai/models
- OpenRouter Free Models: https://openrouter.ai/collections/free-models
- Anthropic Models: https://docs.anthropic.com/en/docs/about-claude/models/overview
- Anthropic Pricing: https://docs.anthropic.com/en/docs/about-claude/pricing
- Groq Supported Models: https://console.groq.com/docs/models
- Groq Rate Limits: https://console.groq.com/docs/rate-limits
- Google Gemma 4: https://ai.google.dev/gemma/docs/core/model_card_4
- Qwen3 Embedding: https://huggingface.co/Qwen/Qwen3-Embedding-0.6B
- BGE-M3: https://huggingface.co/BAAI/bge-m3
