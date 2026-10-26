# Spec do sistema

Cada arquivo desta pasta descreve uma **capacidade** do sistema (cadastro,
autenticação, faturamento...) do jeito que ela funciona **hoje**.

| Onde | Responde |
|---|---|
| `specs/NNN-slug/` | o que uma mudança alterou, e por quê (histórico) |
| `sistema/<capacidade>.md` | o que o sistema faz agora (vigente) |

Quando uma feature fica pronta, os requisitos dela são consolidados aqui
(`/sdd:sistema consolidar`). Para entender o sistema, leia esta pasta; para
entender uma decisão, siga a `origem:` de cada item até a feature.

Use `sdd-sistema listar` para ver as capacidades.
