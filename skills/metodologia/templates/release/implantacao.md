# Plano de implantação da release {{VERSAO}}

| Campo | Valor |
|---|---|
| Janela | {{data e horário}} |
| Responsável | {{quem executa}} |
| Duração estimada | {{minutos}} |
| Indisponibilidade | {{nenhuma, ou quanto tempo}} |

> Preenchido antes do go/no-go (`sdd-release autorizar`). Nada aqui é executado
> sem confirmação humana em cada etapa crítica.

## Pré-requisitos

- [ ] Backup de {{banco, arquivos}} feito e testado
- [ ] Variáveis de ambiente e segredos novos configurados: {{lista ou "nenhum"}}
- [ ] Migrations revisadas e reversíveis: {{lista ou "nenhuma"}}
- [ ] Comunicação a usuários, se houver indisponibilidade

## Passos

| # | Passo | Comando ou ação | Responsável |
|---|---|---|---|
| 1 | {{...}} | {{...}} | {{...}} |

## Verificação pós-implantação

| Verificação | Como | Esperado |
|---|---|---|
| {{ex.: health check}} | {{ex.: curl https://.../health}} | {{200}} |
| {{fluxo crítico}} | {{...}} | {{...}} |

## Rollback

**Quando acionar:** {{critérios objetivos, ex.: erro 5xx acima de 2% por 5 minutos}}

| # | Passo | Comando ou ação |
|---|---|---|
| 1 | {{...}} | {{...}} |

## Monitoramento nas primeiras horas

- {{métricas, alertas e logs a acompanhar, e por quanto tempo}}
