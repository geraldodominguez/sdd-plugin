# Spec {{FEATURE}}: {{TITULO}}

| Campo | Valor |
|---|---|
| Nível | {{NIVEL}} (completo) |
| Situação | rascunho |
| Criada em | {{DATA}} |
| Contexto | [contexto.md](./contexto.md) (projetos existentes) |
| Origem | {{ORIGEM}} |

> **Esta spec descreve O QUÊ e POR QUÊ, nunca o COMO.**
> Tecnologia, arquitetura e estrutura de código ficam no `plano.md`.
> Toda dúvida que o contexto não resolve vira um marcador
> `[PRECISA ESCLARECER: pergunta]`, nunca uma suposição silenciosa.

## 1. Contexto e objetivo

**Problema:** {{a dor ou necessidade que existe hoje}}

**Objetivo:** {{o resultado que esta feature entrega}}

**Quem se beneficia:** {{papéis ou usuários}}

**Indicador de sucesso:** {{como saberemos que funcionou, com número quando possível}}

## 2. Histórias de usuário

- **US-001**: Como {{papel}}, quero {{ação}}, para {{benefício}}.

## 3. Requisitos funcionais

Use a notação EARS quando ajudar (ver o `EARS.md` da skill metodologia):

- **RF-001**: QUANDO {{evento}}, O SISTEMA DEVE {{resposta}}.
- **RF-002**: {{...}}

## 4. Requisitos não funcionais

- **RNF-001**: {{desempenho, segurança, disponibilidade ou conformidade, com número}}

## 5. Critérios de aceitação

Cada critério é verificável por um teste automatizado e indica qual requisito
ele valida.

- **CA-001** (valida RF-001)
  - **Dado** {{estado inicial}}
  - **Quando** {{ação}}
  - **Então** {{resultado observável}}

- **CA-002** (valida RF-001, caso de erro)
  - **Dado** {{...}}
  - **Quando** {{...}}
  - **Então** {{...}}

## 6. Escopo

**Dentro do escopo:**
- {{...}}

**Fora do escopo (explicitamente):**
- {{...}}

## 7. Restrições e premissas

- {{restrições de negócio, legais, de prazo ou de integração}}

## 8. Riscos e dependências

- {{...}}

## 9. Dúvidas em aberto

- [PRECISA ESCLARECER: {{pergunta}}]

## 10. Histórico de clarificação

| Data | Pergunta | Resposta | Seção alterada |
|---|---|---|---|
