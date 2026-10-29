#!/usr/bin/env bash
# simular-ciclo.sh: simula o ciclo de vida completo do SDD num projeto
# descartável, só com os utilitários (sem o Claude Code), e mostra cada etapa.
#
# Uso: tests/simular-ciclo.sh [--manter]
#   --manter  não apaga o projeto simulado no fim (mostra onde ficou)
#
# O que o agente e as pessoas fariam (escrever specs, testes, código, decidir)
# é simulado com arquivos mínimos. O objetivo é ver as transições, os gates e
# o quadro, do pedido à manutenção. Sai com 1 se alguma etapa não chegar ao
# estado esperado.
set -uo pipefail

PLUGIN="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="$PLUGIN/bin:$PATH"
unset CLAUDE_PROJECT_DIR CLAUDE_PLUGIN_ROOT

MANTER=0; [ "${1:-}" = "--manter" ] && MANTER=1
P="$(mktemp -d)/loja"
mkdir -p "$P/tests" "$P/src/auth"
cd "$P" || exit 1
git init -q && git symbolic-ref HEAD refs/heads/main
git config user.name "Ana (dev)" && git config user.email ana@exemplo.com

etapa() { printf '\n\033[1m== %s\033[0m\n' "$1"; }
espera() { # espera <descrição> <valor obtido> <valor esperado>
  if [ "$2" = "$3" ]; then printf '   ✓ %s: %s\n' "$1" "$2"; else printf '   ✗ %s: obtido "%s", esperado "%s"\n' "$1" "$2" "$3"; FALHOU=1; fi
}
fase() { grep -E '^fase=' "specs/$1/estado" | tail -1 | cut -d= -f2; }
branch() { git rev-parse --abbrev-ref HEAD; }
subst() { local e="$1" f; shift; for f in "$@"; do sed "$e" "$f" > "$f.tmp" && mv "$f.tmp" "$f"; done; }
FALHOU=0

etapa "0. Preparar o repositório (/sdd:iniciar, Git Flow)"
git commit -q --allow-empty -m "chore: início"
sdd-iniciar >/dev/null
subst 's#^areas_sensiveis:.*#areas_sensiveis: src/auth/**#' .sdd/config.yml
sdd-gitflow iniciar >/dev/null
espera "branch de trabalho" "$(branch)" develop
git add -A && git commit -qm "chore: sdd iniciado"
echo "   .sdd/, specs/, sistema/ e docs/adr/ criados; área sensível: src/auth/**; main e develop no padrão"

etapa "1. Análise: backlog, sprint, spec (/sdd:backlog, /sdd:sprint, /sdd:especificar)"
sdd-backlog adicionar "Redefinição de senha por e-mail" --prioridade alta --nivel 2 --origem "cliente ACME" >/dev/null
sdd-backlog adicionar "Relatório de vendas em CSV" --prioridade media --nivel 1 >/dev/null
sdd-sprint nova S1 --objetivo "Clientes recuperam o acesso sozinhos" --dias 14 >/dev/null
sdd-sprint incluir S1 B-001 >/dev/null && sdd-sprint iniciar S1 >/dev/null
sdd-estado nova "Redefinição de senha" --nivel 2 --origem B-001 --capacidade autenticacao >/dev/null
F=001-redefinicao-de-senha
sdd-gitflow feature "$F" >/dev/null
espera "branch da feature" "$(branch)" "feature/$F"
cat > "specs/$F/spec.md" <<'EOF'
# Spec 001-redefinicao-de-senha: Redefinição de senha
- **RF-001**: QUANDO o usuário pedir, O SISTEMA DEVE enviar um link de uso único.
- **RF-002**: SE o link tiver mais de 30 minutos, ENTÃO O SISTEMA DEVE recusá-lo.
- **CA-001** (valida RF-001)
- **CA-002** (valida RF-002)
EOF
echo "   [humano aprova a spec com /sdd:aprovar]"
sdd-estado aprovar >/dev/null
espera "fase depois da spec (nível 2)" "$(fase $F)" plano

etapa "2. Desenho: plano e contratos, tarefas (/sdd:planejar, /sdd:tarefas)"
mkdir -p "specs/$F/contratos"
printf '# Plano\nameaças, implantação e rollback, observabilidade\n' > "specs/$F/plano.md"
printf 'interface ResetTokenRepository {}\n' > "specs/$F/contratos/dominio.md"
sdd-estado aprovar >/dev/null
cat > "specs/$F/tarefas.md" <<'EOF'
- [ ] T-001 gerar token de uso único (atende: RF-001, CA-001; depende de: nada)
- [ ] T-002 recusar token expirado (atende: RF-002, CA-002; depende de: T-001)
EOF
sdd-estado aprovar >/dev/null
espera "fase depois das tarefas" "$(fase $F)" red

etapa "3. Construção: red, aprovar testes, green (/sdd:implementar)"
printf '// sdd:001:CA-001\nit("envia link de uso único")\n// sdd:001:CA-002\nit("recusa link expirado")\n' > tests/senha.test.js
sdd-estado aprovar >/dev/null
espera "fase depois dos testes" "$(fase $F)" green
echo "x" > src/auth/reset.js
subst 's/- \[ \]/- [x]/' "specs/$F/tarefas.md"
sdd-estado sensivel >/dev/null
espera "revisão de segurança" "$(grep '^seguranca=' "specs/$F/estado" | cut -d= -f2)" obrigatoria
sdd-rastrear "$F" --silencioso && echo "   ✓ rastreabilidade sem lacunas"

etapa "4. Segurança e auditoria (/sdd:seguranca, /sdd:auditar)"
sdd-estado definir fase=seguranca >/dev/null
printf '# Revisão de segurança\nVeredito: aprovada\n' > "specs/$F/seguranca.md"
echo "   [humano decide: aprovar]"
sdd-estado aprovar --decisao aprovar >/dev/null
espera "fase depois da segurança (nível 2)" "$(fase $F)" auditoria
printf '# Auditoria\nVeredito: aprovada\n' > "specs/$F/auditoria.md"
sdd-estado aprovar --decisao aprovar >/dev/null
espera "fase depois da auditoria" "$(fase $F)" pronta

etapa "5. Spec do sistema (/sdd:sistema consolidar)"
sdd-sistema nova autenticacao "Autenticação" >/dev/null
printf -- '- QUANDO o usuário pedir a redefinição, O SISTEMA DEVE enviar um link de uso único. (origem: 001/RF-001)\n- SE o link tiver mais de 30 minutos, ENTÃO O SISTEMA DEVE recusá-lo. (origem: 001/RF-002)\n' >> sistema/autenticacao.md
sdd-sistema consolidar "$F" >/dev/null
sdd-sistema consolidada "$F" && echo "   ✓ sistema/autenticacao.md descreve o comportamento vigente"
git add -A && git commit -qm "feat(001): T-001 T-002 redefinição de senha"
echo "   [humano autoriza a integração]"
sdd-gitflow integrar "$F" --apagar >/dev/null
espera "feature integrada, de volta em" "$(branch)" develop

etapa "6. Entrega: release, testes de sistema, homologação, go/no-go, produção (/sdd:release)"
V="$(sdd-release proxima minor)"
sdd-gitflow release "$V" >/dev/null
espera "branch da release" "$(branch)" "release/$V"
sdd-release nova "$V" --objetivo "Autoatendimento de senha" >/dev/null
sdd-release incluir "$V" "$F" >/dev/null
R="releases/$V"
echo "   [testador-de-sistema preenche testes.md; agente escreve o roteiro de homologação]"
subst 's/{{[^}]*}}/ok/g; s/| Resultado | ok |/| Resultado | aprovado |/' "$R/testes.md"
subst 's/{{[^}]*}}/ok/g' "$R/homologacao.md"
sdd-release homologar "$V" >/dev/null
espera "fase da feature" "$(fase $F)" homologacao
echo "   [Bia, dona do produto, executa o roteiro e aprova cada passo]"
subst 's/| pendente |/| aprovado |/' "$R/homologacao.md"
sdd-release aceitar "$V" --por "Bia, dona do produto" >/dev/null
echo "   [plano de implantação com rollback e notas escritos; humano diz: go]"
subst 's/{{[^}]*}}/ok/g' "$R/implantacao.md" "$R/notas.md"
sdd-release autorizar "$V" --nota "janela de terça" >/dev/null
git add -A && git commit -qm "chore(release): $V pronta para produção"
echo "   [com o go, a release vai para main com a tag]"
sdd-gitflow finalizar "$V" >/dev/null
espera "tag em main" "$(git describe --tags --exact-match main 2>/dev/null)" "v$V"
git merge-base --is-ancestor main develop && echo "   ✓ develop recebeu de volta o que foi para main"
sdd-release pode-implantar "v$V" >/dev/null && echo "   ✓ o pipeline aceita a tag v$V (go registrado)"
echo "   [deploy e verificação pós-implantação]"
sdd-release concluir "$V" --verificacao "health 200, fluxo de redefinição ok" >/dev/null
espera "fase da feature" "$(fase $F)" producao
git add -A && git commit -qm "chore(release): $V em produção"

etapa "7. DevOps: verificação do processo no CI (sdd-verificar)"
sdd-verificar --silencioso; espera "sdd-verificar" "$?" 0

etapa "8. Manutenção: incidente, hotfix, post-mortem (/sdd:incidente)"
sdd-incidente abrir "Link de redefinição aceito duas vezes" --severidade S2 --feature "$F" --release "$V" >/dev/null
sdd-incidente situacao INC-001 mitigado --nota "redefinição desligada por flag" >/dev/null
git add -A && git commit -qm "docs: INC-001 aberto e mitigado"
sdd-incidente hotfix INC-001 "Invalidar link após o uso" --capacidade autenticacao >/dev/null
H=002-invalidar-link-apos-o-uso
espera "hotfix nasce na fase" "$(fase $H)" red
git add -A ':!specs/' && git commit -qm "docs(002): INC-001 hotfix aberto"
sdd-gitflow feature "$H" >/dev/null
VH="$(branch)"; VH="${VH#hotfix/}"
espera "branch do hotfix (a partir de main)" "$(branch)" "hotfix/$VH"
printf '// sdd:002:CA-001\nit("recusa o link na segunda vez")\n' > tests/hotfix.test.js
sdd-estado aprovar >/dev/null
sdd-estado aprovar >/dev/null 2>&1 && echo "   ✗ entregou sem spec retroativa" || echo "   ✓ entrega recusada sem a spec retroativa"
printf '# Spec\n- **RF-001**: O SISTEMA DEVE recusar link já usado.\n- **CA-001** (valida RF-001)\n' > "specs/$H/spec.md"
sdd-estado aprovar spec.md >/dev/null
echo "x" >> src/auth/reset.js; sdd-estado sensivel >/dev/null
sdd-estado definir fase=seguranca >/dev/null; printf '# Revisão\naprovada\n' > "specs/$H/seguranca.md"
sdd-estado aprovar --decisao aprovar >/dev/null
espera "fase do hotfix" "$(fase $H)" pronta
printf -- '- O SISTEMA DEVE recusar link já usado. (origem: 002/RF-001)\n' >> sistema/autenticacao.md
sdd-sistema consolidar "$H" >/dev/null
sdd-release nova "$VH" --hotfix --objetivo "Correção do INC-001" >/dev/null && sdd-release incluir "$VH" "$H" >/dev/null
subst 's/{{[^}]*}}/ok/g; s/| Resultado | ok |/| Resultado | aprovado |/' "releases/$VH/testes.md" "releases/$VH/homologacao.md"
sdd-release homologar "$VH" >/dev/null
subst 's/| pendente |/| aprovado |/' "releases/$VH/homologacao.md"; subst 's/{{[^}]*}}/ok/g' "releases/$VH/implantacao.md" "releases/$VH/notas.md"
sdd-release aceitar "$VH" --por "Bia (homologação expressa)" >/dev/null && sdd-release autorizar "$VH" >/dev/null
git add -A && git commit -qm "fix(002): T-001 invalida o link após o uso"
sdd-gitflow finalizar "$VH" >/dev/null
espera "tag do hotfix em main" "$(git describe --tags --exact-match main 2>/dev/null)" "v$VH"
sdd-release concluir "$VH" --verificacao "link usado é recusado" >/dev/null
espera "hotfix em produção na" "$(fase $H)/$VH" "producao/$VH"
sdd-incidente situacao INC-001 resolvido --nota "release $VH" >/dev/null
awk '/^## Post-mortem/ { d = 1 } d { gsub(/\{\{[^}]*\}\}/, "ok") } { print }' incidentes/INC-001.md > i.tmp && mv i.tmp incidentes/INC-001.md
subst 's/^| 1 | ok | ok | ok |$/| 1 | teste de uso único na regressão | preventiva | B-003 |/' incidentes/INC-001.md
sdd-incidente encerrar INC-001 >/dev/null
espera "incidente" "$(grep '^| Situação |' incidentes/INC-001.md | sed 's/| Situação | \(.*\) |/\1/')" encerrado
git add -A && git commit -qm "chore: INC-001 encerrado"

etapa "9. Fim da sprint e o quadro (/sdd:sprint encerrar, /sdd:status)"
sdd-sprint encerrar S1 >/dev/null
git add -A && git commit -qm "chore: sprint S1 encerrada"
sdd-gitflow conferir >/dev/null && echo "   ✓ sdd-gitflow conferir: tudo no padrão ($(git branch --format='%(refname:short)' | tr '\n' ' '))"
grep -q 'Entregue: 1 de 1 itens' .sdd/sprints/S1.md && echo "   ✓ sprint S1: 1 de 1 itens entregues"
echo
sdd-status | sed 's/^/   /'

etapa "10. Adoção: trabalho que outro agente começou fora do plugin (/sdd:iniciar --adotar)"
mkdir -p docs/specs/exportar
printf '# Exportar pedidos\nO usuário exporta os pedidos em CSV e em PDF.\n' > docs/specs/exportar/requirements.md
printf -- '- [x] exportar CSV\n- [ ] exportar PDF\n' > docs/specs/exportar/tasks.md
git add -A && git commit -qm "docs: specs de outro agente"
espera "artefatos fora do padrão" "$(sdd-adotar contar)" 2
printf 'docs/specs/exportar/requirements.md -> feature:exportar-pedidos/spec.md\ndocs/specs/exportar/tasks.md -> feature:exportar-pedidos/tarefas.md\n' > .sdd/adocao-mapa.txt
sdd-adotar aplicar .sdd/adocao-mapa.txt >/dev/null && rm .sdd/adocao-mapa.txt
git add -A && git commit -qm "chore: adoção, arquivos no padrão"
X=""; for d in specs/*-exportar-pedidos; do X="${d#specs/}"; done; NX="${X%%-*}"
espera "situação da $X" "$(grep -E '^adocao=' "specs/$X/estado" | cut -d= -f2)" transicao
printf '# Spec\n- **RF-001**: O SISTEMA DEVE exportar os pedidos em CSV.\n- **RF-002**: O SISTEMA DEVE exportar os pedidos em PDF.\n- **CA-001** (valida RF-001)\n- **CA-002** (valida RF-002)\n' > "specs/$X/spec.md"
printf -- '- [O] T-001 exportar CSV (atende: RF-001, CA-001; depende de: nada)\n- [ ] T-002 exportar PDF (atende: RF-002, CA-002; depende de: nada)\n' > "specs/$X/tarefas.md"
awk '{ s = s $0 "\n" } END { while (match(s, /\{\{[^}]*\}\}/)) s = substr(s, 1, RSTART - 1) "ok" substr(s, RSTART + RLENGTH); printf "%s", s }' "specs/$X/transicao.md" > t.tmp && mv t.tmp "specs/$X/transicao.md"
subst 's/^| Fase de destino | .* |$/| Fase de destino | red |/' "specs/$X/transicao.md"
sdd-estado usar "$X" >/dev/null && sdd-gitflow feature "$X" >/dev/null
espera "branch da feature adotada" "$(branch)" "feature/$X"
sdd-estado aprovar >/dev/null
espera "transição aprovada, segue de" "$(fase "$X")" red
printf "// sdd:%s:CA-001\nit('CSV')\n// sdd:%s:CA-002\nit('PDF')\n" "$NX" "$NX" > tests/exportar.test.js
sdd-estado aprovar >/dev/null
subst 's/^- \[ \] T-002/- [x] T-002/' "specs/$X/tarefas.md"
sdd-estado aprovar >/dev/null
espera "feature adotada" "$(fase "$X")" pronta
echo "   T-001 ficou [O] (feita fora do plugin); T-002 foi feita no plugin [x]"
git add -A && git commit -qm "feat($NX): T-002 exportar PDF"
sdd-gitflow integrar "$X" --apagar >/dev/null
espera "feature adotada integrada, de volta em" "$(branch)" develop

etapa "11. Git Flow: o histórico do repositório"
espera "branches" "$(git branch --format='%(refname:short)' | grep -vE '^(main|develop|feature/[0-9]{3}-[a-z0-9-]+|release/[0-9.]+|hotfix/[0-9.]+)$' | wc -l | tr -d ' ')" 0
espera "tags em main" "$(git tag | tr '\n' ' ')" "v$V v$VH "
espera "marcas de conflito nos arquivos" "$(grep -rl '^<<<<<<<' --exclude-dir=.git . | wc -l | tr -d ' ')" 0
git log --oneline --graph --all | head -24 | sed 's/^/   /'

echo
if [ "$FALHOU" -eq 0 ]; then echo "Simulação concluída: todas as etapas chegaram ao estado esperado."; else echo "Simulação com falhas."; fi
if [ "$MANTER" -eq 1 ]; then echo "Projeto simulado em: $P"; else rm -rf "${P:?}"; fi
exit "$FALHOU"
