# O auditor só aponta e propõe; quem decide é a pessoa

## Decisão

O `auditor-de-drift` escreve apenas a `auditoria.md` da feature. Quando um
desvio parece correto, ele propõe uma **delta spec** dentro do relatório. Ele
não edita código nem spec. A pessoa escolhe entre aprovar, aprovar a delta ou
corrigir o código, e a sessão principal aplica a escolha.

## Por quê

Se o auditor corrigisse o código, viraria mais um implementador. Se
reescrevesse a spec para bater com o código, legitimaria o drift em vez de
detectá-lo. Nos dois casos, a independência que justifica a auditoria
desaparece.

## Consequências

- A skill `auditar` não passa justificativas ao auditor, e o proíbe de suavizar achados.
- O ciclo pode voltar à fase green ou à spec, sempre com decisão humana.
