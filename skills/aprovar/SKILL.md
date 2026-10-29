---
name: aprovar
description: O gate formal de cada fase da feature. Mostra o que está sendo aprovado, pede a sua confirmação e registra a aprovação no histórico (quem, quando e o hash do artefato), avançando a feature; ao chegar a pronta, conduz a consolidação na spec do sistema.
argument-hint: "[artefato] [nota]"
disable-model-invocation: true
allowed-tools: Bash(sdd-gitflow *), Bash(sdd-estado *), Bash(sdd-rastrear *), Bash(sdd-status *), Bash(sdd-sistema *), Read, Glob, Grep, Edit, Bash(sdd-backlog *), Bash(gh pr create *)
---

# /sdd:aprovar

Argumentos: `$ARGUMENTS`

A aprovação é o ato humano que transforma um artefato em fonte de verdade. Ela
fica no `historico.md` da feature com o hash do artefato: se ele mudar depois,
o `sdd-estado aprovado`, os comandos seguintes e os revisores percebem.

Os gates da **release** (aceite do negócio, go/no-go) não passam por aqui: são
do `/sdd:release`.

## Processo

1. **Veja a fase.** `sdd-estado ver`. Sem feature ativa, diga para escolher
   uma (`sdd-estado usar NNN-slug`) e pare. Feature em `pronta`, `homologacao`
   ou `producao`: diga que o caminho agora é o `/sdd:release`, e pare.

2. **Descubra o que está em jogo:**

   Feature com `adocao=transicao` (veio de outro processo) aprova primeiro a
   **transição**, em qualquer fase: o `transicao.md`, e com ele a spec, o
   plano e as tarefas convertidos que a fase de destino pressupõe. Ela vai
   para a fase de destino escrita no `transicao.md`.

   | Fase | O que se aprova | Para onde vai |
   |---|---|---|
   | qualquer, em transição | `transicao.md` (e `spec.md`, `plano.md`, `tarefas.md`, conforme o destino) | a fase de destino: `especificacao`, `plano`, `tarefas` ou `red` |
   | `especificacao`, `clarificacao` | `spec.md` | `plano` (nível 2) ou `tarefas` (nível 1) |
   | `plano` | `plano.md` e `contratos/` | `tarefas` |
   | `tarefas` | `tarefas.md` | `red` |
   | `red` | os testes marcados `sdd:NNN:` | `green` |
   | `green`, nível 1 sem revisão de segurança obrigatória | a entrega | `pronta` |
   | `green`, nível 2 ou com segurança obrigatória | nada: diga para rodar `/sdd:seguranca` | |
   | `green`, hotfix | primeiro a spec retroativa (`spec.md`), depois a entrega | `pronta` |
   | `seguranca` | a decisão sobre `seguranca.md` | `auditoria` (nível 2), `pronta` (nível 1) ou `green` (corrigir) |
   | `auditoria` | a decisão sobre `auditoria.md` | `pronta` ou `green` (corrigir) |

3. **Apresente um resumo para a decisão**, curto e honesto:
   - **transição:** o "como era" e o "como vai ficar" do `transicao.md` lado a
     lado (arquivos, requisitos, tarefas), quantas tarefas ficam `[O]` (feitas
     fora do plugin, sem gate) e quantas `[ ]` (o plugin continua daqui), o
     que ficou de fora e a fase de destino com a evidência;
   - **spec:** objetivo, quantidade de RFs e CAs, fora do escopo, capacidade, e
     alerta se houver `[PRECISA ESCLARECER]` em aberto;
   - **plano:** abordagem, contratos, dependências novas, ADRs, ameaças e plano de implantação;
   - **tarefas:** IDs e títulos, e o resultado do `sdd-rastrear`;
   - **testes:** cada teste e o CA que cobre, e a execução falhando pelo motivo certo;
   - **entrega:** tarefas concluídas, suíte verde, `sdd-rastrear` sem lacunas;
   - **segurança:** veredito e achados críticos e altos;
   - **auditoria:** veredito, desvios e a delta spec, se houver.

   Se algo impede uma aprovação responsável, diga isso antes de pedir.

4. **Peça a confirmação explícita** ("Aprova a spec da 004?"). Só com um "sim"
   claro, rode `sdd-estado aprovar` (com `--nota "..."` se o usuário quiser).
   Sem confirmação, não registre nada.

5. **Decisões da revisão de segurança** (fase `seguranca`):

   | Decisão | Comando |
   |---|---|
   | Aprovar | `sdd-estado aprovar --decisao aprovar` |
   | Aceitar o risco | `sdd-estado aprovar --decisao aceitar-risco --nota "quem aceitou, por quê, prazo"`, e registre a correção futura com `sdd-backlog adicionar` |
   | Corrigir | `sdd-estado aprovar --decisao corrigir` (volta ao green) |

6. **Decisões da auditoria** (fase `auditoria`):

   | Decisão | Comandos |
   |---|---|
   | Aprovar | `sdd-estado aprovar --decisao aprovar` |
   | Aprovar a delta spec | aplique `delta-spec.md` na `spec.md`, mude a situação da delta para "aprovada", rode `sdd-estado aprovar spec.md --sem-avancar --nota "delta da auditoria"`; se a delta trouxe testes novos, `sdd-estado aprovar testes --sem-avancar`; por fim `sdd-estado aprovar --decisao delta` |
   | Corrigir | `sdd-estado aprovar --decisao corrigir` (volta ao green) |

7. **Quando a feature fica pronta**, o utilitário confere que spec, testes,
   plano (nível 2) e revisão de segurança (se obrigatória) estão aprovados e
   inalterados, e recusa com a lista do que falta. Com a feature pronta:
   - conduza a **consolidação na spec do sistema** como no `/sdd:sistema`
     (edite `sistema/<capacidade>.md`, mostre, e rode `sdd-sistema consolidar`);
   - **Git Flow** (com `gitflow: ativo`; não vale para hotfix, que vai para
     `main` pela release de correção): primeiro, proponha o commit do que a
     aprovação e a consolidação mudaram, na branch da feature
     (`docs(NNN): feature pronta`), porque o merge exige tudo commitado. Depois
     leve a feature para `develop` conforme a chave `integracao` do config,
     **perguntando antes**:

     | `integracao` | O que fazer |
     |---|---|
     | `local` | `sdd-gitflow integrar NNN-slug` (merge `--no-ff` em `develop`); ofereça `--apagar` para a branch local e diga o `git push origin develop` |
     | `pr` | proponha `gh pr create --base develop --head feature/NNN-slug` com o título da feature e o resumo da spec |

     Conflito: pare e resolva com o usuário.
   - diga o próximo passo: entrar numa release (`/sdd:release preparar`).

8. **Mostre o resultado**: a linha registrada, a fase nova e o próximo comando.

## Não faça

- Nunca registre uma aprovação sem um "sim" explícito do usuário nesta conversa.
- Não edite o `historico.md` nem o `estado` à mão (o hook bloqueia).
- Não aprove em nome de outra pessoa.

## Pronto quando

- O `historico.md` da feature tem a linha de aprovação com o hash, a fase avançou (ou não, se o usuário recusou), e o usuário sabe o próximo comando.
