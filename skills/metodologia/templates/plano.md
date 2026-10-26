# Plano {{FEATURE}}: {{TITULO}}

| Campo | Valor |
|---|---|
| Spec | [spec.md](./spec.md) |
| Situação | rascunho |

> O plano responde **COMO**. Toda decisão atende a um requisito da spec e
> respeita a constituição. Nada de regra de negócio implementada aqui: só
> arquitetura, contratos e decisões.

## 1. Checagem contra a constituição

| Regra da constituição | Atendida? | Como, ou qual exceção |
|---|---|---|
| {{ex.: domínio sem dependência de infraestrutura}} | sim | {{...}} |

## 2. Visão da solução

{{Dois a quatro parágrafos: a abordagem escolhida e por quê.}}

## 3. Componentes

| Componente | Responsabilidade | Novo ou alterado | Requisitos |
|---|---|---|---|
| {{...}} | {{...}} | novo | RF-001 |

## 4. Contratos

O detalhe fica em `contratos/`. Resumo:

- **Entidades e objetos de valor:** {{...}}
- **Interfaces de domínio:** {{...}}
- **API (OpenAPI ou rotas):** {{...}}
- **Persistência (DDL ou migrations):** {{...}}
- **Eventos e mensageria:** {{...}}

Os contratos ficam **congelados durante a implementação**. Mudar um contrato
exige voltar à spec ou ao plano, com aprovação.

## 5. Fluxo principal

{{sequência de chamadas ou diagrama Mermaid}}

## 6. Erros e casos de borda

| Situação | Comportamento | CA |
|---|---|---|

## 7. Dependências

| Dependência | Versão | Por que é necessária | Alternativa descartada |
|---|---|---|---|

## 8. Estratégia de testes

- **Unitários:** {{...}}
- **Integração:** {{...}}
- **Dados de teste:** {{...}}

## 9. Ameaças e mitigação (segurança desde o desenho)

| Ameaça | Onde | Mitigação no desenho |
|---|---|---|
| {{ex.: enumeração de usuários}} | {{rota}} | {{resposta genérica}} |

Dados pessoais tratados: {{quais, com finalidade e retenção, ou "nenhum"}}

## 10. Implantação e rollback

- **Migrations:** {{quais, e como revertê-las}}
- **Configuração e segredos novos:** {{...}}
- **Ordem de implantação:** {{ex.: migration antes do código; feature flag desligada}}
- **Rollback:** {{como voltar atrás sem perda de dados}}

## 11. Observabilidade

- **Logs:** {{eventos novos, sem dados pessoais em claro}}
- **Métricas e alertas:** {{o que medir para saber que está funcionando em produção}}

## 12. Decisões (ADRs)

- {{ADR-NNNN: título}}, ou "nenhuma decisão durável nesta feature"

## 13. Riscos técnicos e mitigação

- {{...}}
