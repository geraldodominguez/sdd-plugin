# EARS: Easy Approach to Requirements Syntax

EARS é um conjunto pequeno de padrões de frase para requisitos. Elimina
ambiguidade sem exigir linguagem formal. Em português, use as palavras-chave
em maiúsculas.

## Os cinco padrões

| Padrão | Estrutura | Quando usar |
|---|---|---|
| **Ubíquo** | O SISTEMA DEVE {resposta}. | Comportamento sempre válido |
| **Por evento** | QUANDO {gatilho}, O SISTEMA DEVE {resposta}. | Reação a um evento |
| **Por estado** | ENQUANTO {estado}, O SISTEMA DEVE {resposta}. | Comportamento contínuo num estado |
| **Indesejado** | SE {condição indesejada}, ENTÃO O SISTEMA DEVE {resposta}. | Erros, falhas, abuso |
| **Opcional** | ONDE {funcionalidade presente}, O SISTEMA DEVE {resposta}. | Variações de produto ou configuração |

Os padrões combinam: "ENQUANTO o usuário estiver autenticado, QUANDO ele
solicitar a exportação, O SISTEMA DEVE gerar o arquivo em até 10 s."

## Exemplos

- **RF-001**: QUANDO o usuário solicitar a redefinição de senha, O SISTEMA DEVE enviar um link de uso único para o e-mail cadastrado.
- **RF-002**: SE o link de redefinição tiver mais de 30 minutos, ENTÃO O SISTEMA DEVE recusá-lo e oferecer o envio de um novo link.
- **RNF-001**: O SISTEMA DEVE responder à solicitação de redefinição em até 500 ms no percentil 95.
- **RF-003**: ENQUANTO houver 5 tentativas falhas na última hora, O SISTEMA DEVE bloquear novas solicitações para o mesmo e-mail.

## Armadilhas comuns

| Ruim | Problema | Melhor |
|---|---|---|
| "O sistema deve ser rápido." | Não é verificável | "...em até 500 ms (p95)." |
| "O sistema deve lidar com erros." | Que erro? Que resposta? | "SE o provedor de e-mail falhar, ENTÃO..." |
| "O usuário pode redefinir a senha por e-mail ou SMS e ver o histórico." | Três requisitos em um | Separar em RF-001, RF-002 e RF-003 |
| "O sistema deve usar Redis como cache." | Isso é COMO, e vai para o plano | "...em até 50 ms para leituras repetidas." |

## Um bom requisito

- [ ] Descreve um único comportamento
- [ ] É verificável por teste
- [ ] Não tem termo vago (rápido, fácil, adequado, robusto, amigável)
- [ ] Não cita tecnologia, salvo restrição real de negócio
- [ ] Tem ID único (`RF-NNN` ou `RNF-NNN`)
