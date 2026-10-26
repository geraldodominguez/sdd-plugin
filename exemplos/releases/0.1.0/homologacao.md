# Homologação da release 0.1.0

| Campo | Valor |
|---|---|
| Ambiente | https://homolog.loja-acme.exemplo |
| Responsável pelo aceite | Bia Rocha, dona do produto (ACME) |
| Início | 2026-10-29 |

> Roteiro de aceite **em linguagem de negócio**, gerado a partir dos critérios
> de aceitação das features. Quem homologa executa cada passo e marca o
> resultado: `aprovado`, `reprovado` ou `pendente`. O aceite só é registrado
> (`sdd-release aceitar`) quando não houver nenhum passo pendente ou reprovado.

## Roteiro

| Passo | Feature | Critério | Como testar | Resultado esperado | Resultado |
|---|---|---|---|---|---|
| H-001 | 001 | CA-001 | Na tela de entrada, clique em "Esqueci a senha" e informe o seu e-mail. | Aparece "Se houver uma conta com este e-mail, enviaremos um link". O e-mail chega em até 1 minuto. | aprovado |
| H-002 | 001 | CA-002 | Repita com um e-mail que não tem conta. | Aparece exatamente a mesma mensagem. Nenhum e-mail chega. | aprovado |
| H-003 | 001 | CA-004 | Abra o link recebido e defina uma senha nova. Entre com ela. | A senha nova funciona. Em outro navegador onde você estava logado, a sessão foi encerrada. | aprovado |
| H-004 | 001 | CA-005 | Abra o mesmo link de novo. | Aparece "Este link já foi usado" e a opção de pedir outro. | aprovado |
| H-005 | 001 | CA-003 | Peça um link e espere 31 minutos antes de abrir. | Aparece "Este link expirou" e a opção de pedir outro. | aprovado |
| H-006 | 002 | CA-001 | Entre no sistema e abra o seu perfil. | Aparece "Último acesso" com a data e a hora da entrada anterior. | aprovado |

## Observações de quem homologou

- A mensagem de link expirado poderia dizer quanto tempo o link vale. Não impede o aceite; anotado para a próxima versão.
