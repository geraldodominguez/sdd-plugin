# O pipeline consulta o go; a segurança tem revisor próprio

Dois buracos sobravam depois da auditoria. O primeiro: o pipeline implantava
qualquer tag criada, com ou sem homologação e decisão de ir para produção. O
segundo: o auditor de drift confere o código contra a spec, mas uma spec
correta não garante uma mudança segura, e ninguém olhava a mudança como um
atacante.

## Decisão

- O passo de produção do pipeline gerado pelo `/sdd:pipeline` roda `sdd-release pode-implantar <tag>` e só segue com saída 0, isto é, com o go registrado.
- O `sdd-verificar` roda em todo push e falha com lacuna de rastreabilidade, aprovação ausente ou invalidada em feature pronta, ou release inconsistente.
- A revisão de segurança é uma fase própria (`seguranca`), entre o green e a auditoria, feita pelo subagent `revisor-de-seguranca`, com contexto limpo, que não corrige nada.
- É obrigatória no nível 2 e em qualquer feature que toque `areas_sensiveis`, detectado pelo `sdd-estado sensivel` no fim do green.
- A pessoa decide: aprovar, aceitar o risco (registrado) ou corrigir (volta ao green). `seguranca.md` aprovado e inalterado é condição para a feature ficar pronta.

## Por quê

Gate que o pipeline ignora é sugestão. Verificar o go no próprio pipeline, com o
mesmo utilitário que registrou o go, fecha o caminho entre a decisão e o
deploy. Na segurança, o mesmo argumento do escritor de testes e do auditor:
quem escreveu a mudança é a pior pessoa para encontrar o que ela abriu.

## Consequências

- O pipeline precisa do plugin no CI (clonado numa versão fixa) e do histórico da release no repositório.
- Uma feature de nível 1 pode virar de revisão obrigatória sem mudar de nível, só por tocar uma área sensível.
- O auditor de drift confere também a aprovação de `seguranca.md` quando a revisão é obrigatória.
