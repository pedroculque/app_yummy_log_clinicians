# YummyLog for Clinicians - Comandos do Cursor

Comandos interativos para gerenciar o desenvolvimento do YummyLog for Clinicians (app do clínico).

## Como Usar

No chat do Cursor, digite `/` seguido do nome do comando:

```
/dev
/status
/implement auth
/finalize
/fix-analyze
/docs list
/docs-sync
/debug [problema]
/release minor
```

## Comandos Disponíveis

| Comando | Descrição |
|---------|-----------|
| `/dev` | Menu principal de desenvolvimento |
| `/status` | Ver status do projeto |
| `/implement [módulo]` | Iniciar implementação de módulo |
| `/finalize` | Finalizar feature com verificações |
| `/docs [ação]` | Gerenciar documentação |
| `/docs-sync` | Sincronizar toda a documentação com a implementação (verificação e atualização em lote) |
| `/debug [problema]` | Debug e troubleshooting |
| `/release [tipo]` | Preparar release |
| `/fix-analyze` | Zerar problemas do dart analyze (sem usar ignore) |

## Fluxo Típico de Desenvolvimento

```
1. /status           → Ver onde estamos
2. /implement auth   → Iniciar módulo auth
3. [implementar...]
4. /finalize         → Verificar e commitar
5. /release minor    → Preparar release
```

## Exemplos

### Ver Status
```
/status
```

### Implementar Auth
```
/implement auth
```

### Debug de Problema
```
/debug Build failing on iOS
```

### Preparar Release
```
/release minor
```

### Zerar problemas do analyze
```
/fix-analyze
```
Corrige todos os issues do `dart analyze` até zerar, sem usar `// ignore`.

### Sincronizar documentação com o código
```
/docs-sync
```
Verifica e atualiza READMEs e docs de todos os módulos (estrutura, cubits, widgets, dependências ui_kit, rotas em ARCHITECTURE.md, module-structure, etc.).

## Documentação Relacionada

- `docs/ROADMAP.md` - Fases do projeto
- `docs/ARCHITECTURE.md` - Arquitetura
- `.cursor/rules/` - Padrões de código
