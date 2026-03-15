# /fix-analyze - Zerar problemas do dart analyze

Analisa o projeto com `dart analyze`, identifica todos os problemas e corrige um a um até **zerar**, usando **melhores práticas**. É **proibido** usar `// ignore` para qualquer regra.

## Uso

```
/fix-analyze
```

## Instruções

1. **Rodar a análise**
   - Execute `dart analyze` (ou `flutter analyze`) no root do projeto.
   - Capture a saída completa (arquivo, linha, regra e mensagem).

2. **Enquanto houver issues (count > 0)**
   - Para **cada** problema listado:
     - Abra o arquivo na linha indicada.
     - Corrija seguindo a **regra** e as **melhores práticas** do projeto (veja regras em `.cursor/rules/`, em especial `dart-line-length.mdc` e `dart-style.mdc`).
     - **Não** use `// ignore: nome_da_regra` em nenhum caso.
   - Tratamento por tipo de regra:
     - **lines_longer_than_80_chars**: quebrar a linha (funções, listas, strings, comentários) ou encurtar texto; usar trailing comma em listas multi-linha.
     - **outras regras do linter**: aplicar a correção sugerida pela mensagem (ex.: prefer_single_quotes, avoid_print, missing_required_param, etc.).
   - Após corrigir um lote (ou todos de um arquivo), rode `dart analyze` de novo e repita até **0 issues**.

3. **Critério de conclusão**
   - Só encerre quando a saída for: `No issues found!` (ou equivalente com 0 issues).

## Regras obrigatórias

| Regra | Ação |
|-------|------|
| **Nunca usar ignore** | Proibido `// ignore: ...` para contornar qualquer problema. Sempre corrigir o código. |
| **Line length (80)** | Quebrar linhas longas; encurtar comentários; usar múltiplas linhas em chamadas com muitos argumentos. |
| **Padrões do projeto** | Respeitar `.cursor/rules/dart-style.mdc` e `dart-line-length.mdc`. |
| **Um problema por vez** | Corrigir, rodar analyze de novo, e só então passar ao próximo se ainda houver issues. |

## Fluxo resumido

```
1. dart analyze → listar issues
2. Se 0 issues → fim. Caso contrário:
3. Para cada issue: abrir arquivo, corrigir sem ignore, salvar
4. dart analyze de novo
5. Voltar ao passo 2
```

## Output esperado ao final

```
✅ Analyze zerado

dart analyze → No issues found!

Arquivos alterados: [lista]
Problemas corrigidos: [lista por regra]
```

## Responda em Português (pt-BR)
