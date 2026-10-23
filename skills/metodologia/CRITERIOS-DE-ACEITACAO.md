# Critérios de aceitação

O critério de aceitação (CA) é a ponte entre a spec e o teste. Se não dá para
escrever um teste a partir dele, ele não está pronto.

## Formato: Dado, Quando, Então

```
- **CA-003** (valida RF-002)
  - **Dado** um link de redefinição gerado há 31 minutos
  - **Quando** o usuário abre o link
  - **Então** o sistema mostra "link expirado"
  - **E** oferece o botão "enviar novo link"
  - **E** o link antigo continua inválido
```

- **Dado:** um estado inicial concreto (dados, usuário, configuração).
- **Quando:** uma única ação.
- **Então:** um resultado observável de fora (resposta, tela, registro, evento), nunca um detalhe interno ("chama o método X").

## Cobertura mínima de cada requisito

1. **Caminho feliz:** o comportamento principal.
2. **Erro esperado:** entrada inválida, recurso inexistente, permissão negada.
3. **Borda:** limites (zero, máximo, exatamente no limite, logo depois dele).

Requisito não funcional também tem CA: "Dado 100 requisições simultâneas,
quando..., então o p95 fica abaixo de 500 ms."

## Do CA ao teste: a marca de rastreabilidade

Todo teste que valida um CA leva a marca `sdd:<NNN>:<CA-ID>` no nome ou num
comentário logo acima. `<NNN>` é o número da feature.

```ts
// sdd:004:CA-003
it('recusa link de redefinição com mais de 30 minutos', () => { ... })
```

```python
def test_recusa_link_expirado():  # sdd:004:CA-003
    ...
```

O `sdd-rastrear` procura essas marcas para confirmar que nenhum CA ficou sem teste.

## Sinais de CA ruim

| Sinal | Correção |
|---|---|
| "Então funciona corretamente." | Diga o que é "corretamente" |
| Mais de um "Quando" | Divida em CAs diferentes |
| Depende de outro CA ter rodado antes | Torne o "Dado" explícito |
| Descreve implementação | Reescreva como comportamento observável |
