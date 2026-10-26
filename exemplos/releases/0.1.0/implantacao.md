# Plano de implantação da release 0.1.0

| Campo | Valor |
|---|---|
| Janela | terça, 2026-11-04, 14h às 15h |
| Responsável | Carla Mendes (operação) |
| Duração estimada | 20 minutos |
| Indisponibilidade | nenhuma |

> Preenchido antes do go/no-go (`sdd-release autorizar`). Nada aqui é executado
> sem confirmação humana em cada etapa crítica.

## Pré-requisitos

- [x] Backup do banco feito e restaurado num ambiente de teste
- [x] Variáveis de ambiente e segredos novos configurados: `RESET_LINK_BASE_URL`
- [x] Migrations revisadas e reversíveis: `20261021_password_reset_tokens` (só cria tabela), `20261024_last_login_at` (só cria coluna)
- [x] Comunicação a usuários: não há indisponibilidade

## Passos

| # | Passo | Comando ou ação | Responsável |
|---|---|---|---|
| 1 | Criar a tag | `git tag v0.1.0 && git push origin v0.1.0` | Carla |
| 2 | Pipeline confere o go e implanta | etapa `producao` do CI (`sdd-release pode-implantar v0.1.0`) | automático |
| 3 | Rodar as migrations | `npm run migrate:prod` | Carla |
| 4 | Ligar a flag `redefinicao_de_senha` | painel de flags | Carla |

## Verificação pós-implantação

| Verificação | Como | Esperado |
|---|---|---|
| Saúde da API | `curl https://api.loja-acme.exemplo/health` | 200 |
| Redefinição ponta a ponta | conta de teste `qa+prod@loja-acme.exemplo` | e-mail recebido, senha trocada |
| Último acesso | entrar com a conta de teste e abrir o perfil | data da entrada anterior |

## Rollback

**Quando acionar:** erro 5xx acima de 2% por 5 minutos, ou a redefinição ponta a
ponta falhar em produção.

| # | Passo | Comando ou ação |
|---|---|---|
| 1 | Desligar a flag `redefinicao_de_senha` | painel de flags (resolve só a 001) |
| 2 | Voltar a imagem anterior | `deploy rollback api --to v0.0.9` |
| 3 | Manter as migrations | são aditivas; a versão anterior ignora a tabela e a coluna novas |
| 4 | Registrar | `sdd-release reverter 0.1.0 --motivo "..."` e `/sdd:incidente abrir` |

## Monitoramento nas primeiras horas

- Taxa de 5xx em `/auth/*` e taxa de envio de e-mails, por 24 horas.
- Alerta já existente de fila de e-mail acima de 500 mensagens.
