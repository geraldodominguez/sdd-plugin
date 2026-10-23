# Fases que avançam sozinhas

Pedidos para que o agente encadeie as fases sem parar ("rode especificar,
planejar, tarefas e implementar de uma vez") estão fora do escopo.

## Por que está fora do escopo

O gate é o mecanismo central do método. A spec só vira fonte de verdade quando
uma pessoa a lê e aprova; um plano só é confiável quando alguém conferiu que ele
atende à spec. Encadear as fases tira exatamente esse ponto de controle e
devolve o problema que o plugin existe para resolver: um agente produzindo algo
plausível que ninguém conferiu.

Para mudanças pequenas, o caminho já existe: os níveis de rigor 0 e 1 encurtam
o fluxo sem tirar o gate da spec.

Se você quer uma execução sem gates no seu projeto, escreva isso no seu
`CLAUDE.md`. O plugin não vai oferecer.
