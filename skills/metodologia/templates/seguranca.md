# Revisão de segurança {{FEATURE}}: {{TITULO}}

| Campo | Valor |
|---|---|
| Revisada em | {{DATA}} |
| Base da comparação | {{commit ou branch base}} até {{HEAD}} |
| Veredito | aprovada, aprovada com riscos aceitos, ou reprovada |

> Escrita pelo subagent `revisor-de-seguranca`, com contexto limpo. Ele não
> corrige nada: aponta os riscos e recomenda. A decisão (aprovar, aceitar o
> risco ou corrigir) é humana, pelo `/sdd:aprovar`.

## 1. Superfície de ataque

| Entrada | Quem alcança | Dados que trafegam | Validação |
|---|---|---|---|

## 2. Modelagem de ameaças (STRIDE)

| Ameaça | Categoria | Onde | Mitigação existente | Situação |
|---|---|---|---|---|

Categorias: falsificação de identidade, adulteração, repúdio, vazamento de
informação, negação de serviço, elevação de privilégio.

## 3. Varreduras automáticas

| Varredura | Comando | Resultado |
|---|---|---|
| Dependências vulneráveis | {{ex.: npm audit --omit=dev}} | {{...}} |
| Segredos no código | {{ex.: gitleaks detect}} | {{...}} |
| Análise estática | {{ex.: semgrep --config auto}} | {{...}} |

## 4. Dados pessoais (LGPD)

| Dado | Finalidade | Base legal | Retenção | Proteção |
|---|---|---|---|---|

## 5. Achados

| # | Gravidade | Achado | Onde (arquivo:linha) | Recomendação |
|---|---|---|---|---|

Gravidade: crítica, alta, média, baixa.

## 6. Conformidade com a constituição (seção de segurança)

| Regra | Situação | Evidência |
|---|---|---|

## 7. Recomendação

{{aprovar; aprovar aceitando os riscos listados (com dono e prazo); ou corrigir os achados #N}}
