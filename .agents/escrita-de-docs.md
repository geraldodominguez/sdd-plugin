# Como escrever as páginas de documentação

Toda skill tem uma **página de documentação** para pessoas em
`docs/<nome>.md`. A página não é a skill nem uma cópia do `SKILL.md`.

Quase todas as skills deste plugin são **invocadas pelo usuário**: o agente
nunca as dispara por conta própria. Então *você* é o índice que precisa lembrar
que elas existem e quando usá-las. Essa memória é **carga cognitiva**. O papel
de uma página é aliviá-la: orientar um leitor sobre uma skill, para que ele a
guarde de cabeça, saiba quando recorrer a ela e veja onde ela se encaixa.

Crie ou ressincronize a página sempre que uma skill for adicionada, renomeada
ou mudar de comportamento. Uma renomeação move o arquivo junto.

## Estrutura

A página abre com um H1 com o comando (`# /sdd:especificar`) e segue o modelo
abaixo, nesta ordem. **O que faz**, **Quando usar** e **Onde se encaixa**
aparecem em toda página. **Pré-requisitos** e as seções do meio aparecem só
quando a skill precisa delas.

Quatro seções fazem a página valer a leitura: **O que faz**, **Quando usar**,
**Perguntas frequentes** e **Está funcionando se**. As duas primeiras orientam;
as duas últimas param de resumir a skill e passam a responder a situação do
leitor.

**Uma página não traz comandos de instalação.** Eles ficam no `README.md`,
copiados do [bloco de instalação](bloco-de-instalacao.md). Duas cópias
divergem.

<modelo-de-pagina>

## O que faz

Um ou dois parágrafos simples. Comece pelo trabalho da skill, numa frase, e
depois diga a **restrição que a define**: o único fato que a faz se comportar
diferente do óbvio (para `especificar`: ela não decide regra de negócio, marca
o que não sabe). Escreva como frase declarativa, nunca como um rótulo do tipo
"A restrição:". Esta é a linha mais valiosa da página; nunca a omita.

## Quando usar

Em dois tempos:

- **Modo de invocação.** Skill do usuário: "Você digita `/sdd:<nome>`; o agente não a usa por conta própria." Skill do modelo: "Digite `/sdd:<nome>`, ou o agente recorre a ela quando a tarefa pede."
- **Fronteira de uso.** "Use quando...". Se ela se confunde com uma vizinha, complete: "para X, use a outra skill", com link para a página dela.

## Pré-requisitos

Opcional. Só quando a skill precisa de algo pronto antes: o `/sdd:iniciar`
rodado, uma fase anterior concluída, um comando de teste configurado. Sem
pré-requisito, apague a seção.

## <meio livre>

De uma a três seções curtas, no vocabulário da própria skill, que façam a ideia
encaixar: o ciclo que ela roda, o artefato que produz, a bifurcação que decide.
Não há título obrigatório.

O único item inegociável: **revelar a palavra-chave da skill** (gate, drift,
delta spec, red e green, contrato congelado). Ela paga duas vezes: o leitor
aprende o que a skill *é*, e aprende a palavra com que vai pensar nela depois.

## Perguntas frequentes

As perguntas que leitores de fato fazem, cada uma em negrito, com a resposta
logo abaixo. Sem subtítulos. Pergunta observada vale mais que inventada:
procure nas issues do repositório e no `CHANGELOG.md` antes de escrever. A
quantidade acompanha a evidência; não encha uma página para igualar outra. Diga
a coisa desconfortável quando ela for verdade. Sem nada que valha responder,
apague a seção.

## Está funcionando se

Alguns itens com o que o leitor vê quando a skill faz o trabalho dela. Cada item
precisa ser conferível **sem abrir o `SKILL.md`**: um sinal no próprio trabalho
do leitor ou na sessão diante dele.

## Onde se encaixa

Sempre presente. Situe a skill em uma ou duas frases:

- **Papel:** passo do fluxo principal, configuração de uma vez, ou uso avulso.
- **Vizinhas:** as uma ou duas skills que importam, cada uma com um "porque".
- **O mapa:** aponte para a [ajuda](../docs/ajuda.md), o roteador sobre todos os comandos.

</modelo-de-pagina>

## Convenções

- Explique o **porquê**, não o processo. A página orienta e situa; nunca reproduz os passos do `SKILL.md`.
- Use as **palavras-chave** do plugin (as do [GLOSSARIO.md](../GLOSSARIO.md)), para que página e skill falem a mesma língua.
- **Bifurcações vão em tabela ou lista, nunca em parágrafo.** Quem lê procura a linha que corresponde à sua situação.
- **Links relativos.** As páginas são lidas no GitHub e em forks; um link relativo funciona nos dois.
- Sem travessões (ver `CLAUDE.md`).
- Mantenha a própria página leve. Mobília (títulos sobrando, links repetidos) é justamente o que ela combate.

## Pronta quando

- A página existe em `docs/<nome>.md`, e nenhuma página velha sobrevive a uma renomeação.
- Não traz comando de instalação.
- **O que faz** diz a restrição que define a skill, em prosa.
- **Quando usar** diz o modo de invocação e a fronteira de uso.
- **Onde se encaixa** diz o papel e aponta para a ajuda.
- O meio revela a palavra-chave.
- Toda bifurcação está em tabela ou lista.
- Todo item de **Está funcionando se** é conferível sem abrir o `SKILL.md`.
- As seções estão na ordem do modelo, e todo link resolve.
