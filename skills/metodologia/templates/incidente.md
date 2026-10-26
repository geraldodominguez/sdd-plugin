# {{INCIDENTE}}: {{TITULO}}

| Campo | Valor |
|---|---|
| Severidade | {{SEVERIDADE}} |
| Situação | aberto |
| Aberto em | {{AGORA}} |
| Detectado por | {{quem ou qual alerta}} |
| Feature relacionada | {{FEATURE}} |
| Release relacionada | {{RELEASE}} |
| Correção | nenhuma ainda |

> Severidade: S1 (sistema fora do ar ou perda de dados), S2 (função crítica
> indisponível, sem contorno), S3 (função degradada, com contorno), S4
> (incômodo, sem impacto relevante). Situações: aberto, mitigado (o impacto
> parou, a causa ainda não foi corrigida), resolvido (causa corrigida em
> produção), encerrado (post-mortem concluído).

## Impacto

{{quem foi afetado, quantos, desde quando, o que deixou de funcionar}}

## Linha do tempo

> Uma linha por evento, gravada pelo `sdd-incidente` e completada à mão.

- {{AGORA}} aberto: {{TITULO}}

## Mitigação

{{o que foi feito para parar o impacto: rollback, desligar a função, contorno}}

## Post-mortem

> Sem culpados. Preencha depois que o incidente estiver resolvido.

### O que aconteceu

{{narrativa curta}}

### Causa raiz

{{por que aconteceu; pergunte "por quê" até chegar no processo, não na pessoa}}

### Por que o processo não pegou

{{qual etapa deveria ter pegado (spec, testes, segurança, auditoria, homologação, monitoramento) e por que não pegou}}

### Ações

| # | Ação | Tipo | Item de backlog |
|---|---|---|---|
| 1 | {{...}} | {{corretiva, preventiva ou de detecção}} | {{B-NNN}} |
