# /finalize - Finalizar Feature

Finaliza a feature atual com verificações e commit.

## Instruções

1. Execute verificações:
   ```bash
   flutter analyze
   flutter test
   ```

2. Verifique documentação atualizada

3. Prepare commit seguindo padrões

4. Pergunte se quer criar PR

## Output Esperado

```
✅ Finalizando Feature

## Verificações

### Análise de Código
[Resultado de flutter analyze]

### Testes
[Resultado de flutter test]

### Documentação
- [ ] README.md atualizado
- [ ] docs/architecture.md atualizado
- [ ] docs/features.md atualizado
- [ ] ROADMAP.md status atualizado

## Arquivos Modificados
[git status]

## Commit Sugerido

```
feat(módulo): descrição da feature

- Item 1
- Item 2
- Item 3
```

Fazer commit? (s/n)
```

## Após Commit

```
## Push e PR

Branch atual: [git branch --show-current]

Quer criar PR? (s/n)

Se sim:
- Push para remote
- Criar PR com gh cli
- Retornar URL do PR
```

## Responda em Português (pt-BR)
