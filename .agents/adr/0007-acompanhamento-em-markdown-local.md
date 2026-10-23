# Backlog e sprints em markdown dentro do repositório

O plugin ganhou backlog, sprints e um quadro de situação. Havia três lugares
possíveis para guardá-los: arquivos markdown no próprio repositório, GitHub
Issues e Projects, ou uma ferramenta de gestão como o Linear.

## Decisão

Backlog (`.sdd/backlog.md`) e sprints (`.sdd/sprints/<id>.md`) ficam em
markdown dentro do repositório, versionados junto com as specs. São a fonte de
verdade do acompanhamento. Uma sincronização com GitHub Issues ou Linear, se
vier, será um adaptador opcional, que lê e escreve nesses arquivos.

## Por quê

- Funciona em qualquer projeto, sem conta, token ou rede.
- O agente lê e escreve direto, sem depender de um conector.
- Fica versionado ao lado das specs: o histórico do git mostra quando um item entrou, quando virou feature e quando foi entregue.
- Amarrar o plugin a uma ferramenta paga ou a um provedor afastaria quem não a usa.

## Consequências

- O formato da linha do backlog é contrato público, lido pelos utilitários.
- Quem precisa mostrar o andamento a um cliente fora do repositório vai querer o adaptador; ele fica para uma versão futura.
