#!/usr/bin/env python3
"""Acha construções que o bash 3.2 (o do macOS) não entende e que um bash mais
novo aceita, então passam despercebidas nos outros testes.

1. Um "case" com padrões sem "(" dentro de uma substituição de comando $( ):
   no bash 3.2, o ")" do padrão fecha o $( ), e o script quebra com erro de
   sintaxe. Use o padrão com "(" à esquerda, ou tire o case do $( ) (uma função).
2. Recursos do bash 4 ou mais novo: arrays associativos, mapfile, ${v,,}...

Uso: bash32.py <arquivos...>. Saída 1 com problemas.
"""
import re
import sys

BASH4 = re.compile(r'declare -A|local -A|\bmapfile\b|\breadarray\b|\$\{[A-Za-z_]+(,,|\^\^)\}|&>>|;;&|\bcoproc\b|wait -n')


def casos_em_subst(texto):
    """Linhas de um ")" de padrão de case dentro de $( )."""
    achados = []
    pilha = [{"tipo": "topo", "casos": [], "parens": 0, "pendente": False}]
    i, n, linha = 0, len(texto), 1
    palavra = ""
    inicio_palavra = True

    def fecha_palavra():
        nonlocal palavra
        topo = pilha[-1]
        if topo["tipo"] != "aspas" and palavra:
            if palavra == "case":
                topo["pendente"] = True
            elif palavra == "in" and topo["pendente"]:
                topo["casos"].append(0)
                topo["pendente"] = False
            elif palavra == "esac" and topo["casos"]:
                topo["casos"].pop()
        palavra = ""

    while i < n:
        c = texto[i]
        topo = pilha[-1]
        if c == "\n":
            linha += 1
        if topo["tipo"] == "aspas":
            if c == "\\":
                i += 2
                continue
            if c == '"':
                pilha.pop()
                i += 1
                continue
            if texto.startswith("$((", i):
                pilha.append({"tipo": "arit", "nivel": 2})
                i += 3
                continue
            if texto.startswith("$(", i):
                pilha.append({"tipo": "subst", "casos": [], "parens": 0, "pendente": False})
                i += 2
                continue
            i += 1
            continue
        if topo["tipo"] == "arit":
            if c == "(":
                topo["nivel"] += 1
            elif c == ")":
                topo["nivel"] -= 1
                if topo["nivel"] == 0:
                    pilha.pop()
            i += 1
            continue
        # contexto de comando (topo ou subst)
        if re.match(r"[A-Za-z_0-9]", c):
            palavra += c
            i += 1
            continue
        fecha_palavra()
        if c == "#" and (i == 0 or texto[i - 1] in " \t\n;|&("):
            while i < n and texto[i] != "\n":
                i += 1
            continue
        if c == "\\":
            i += 2
            continue
        if c == "'":
            j = texto.find("'", i + 1)
            linha += texto.count("\n", i, j if j >= 0 else n)
            i = (j + 1) if j >= 0 else n
            continue
        if c == '"':
            pilha.append({"tipo": "aspas"})
            i += 1
            continue
        if texto.startswith("$((", i):
            pilha.append({"tipo": "arit", "nivel": 2})
            i += 3
            continue
        if texto.startswith("$(", i):
            pilha.append({"tipo": "subst", "casos": [], "parens": 0, "pendente": False})
            i += 2
            continue
        if c == "(":
            if topo["casos"]:
                topo["casos"][-1] += 1
            else:
                topo["parens"] += 1
        elif c == ")":
            if topo["casos"] and topo["casos"][-1] > 0:
                topo["casos"][-1] -= 1
            elif topo["casos"]:
                if any(f["tipo"] == "subst" for f in pilha):
                    achados.append(linha)
            elif topo["parens"] > 0:
                topo["parens"] -= 1
            elif topo["tipo"] == "subst":
                pilha.pop()
        i += 1
    return achados


def main(arquivos):
    problemas = 0
    for arq in arquivos:
        texto = open(arq, encoding="utf-8").read()
        for ln in casos_em_subst(texto):
            print(f"{arq}:{ln}: padrão de case sem '(' dentro de $( ): o bash 3.2 do macOS quebra aqui")
            problemas += 1
        for n_linha, conteudo in enumerate(texto.splitlines(), 1):
            if not conteudo.lstrip().startswith("#") and BASH4.search(conteudo):
                print(f"{arq}:{n_linha}: recurso do bash 4 ou mais novo: {conteudo.strip()[:80]}")
                problemas += 1
    return 1 if problemas else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
