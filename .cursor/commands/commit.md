# /commit - Criar Commit com Conventional Commits

Analisa as mudanças e cria um commit seguindo o padrão Conventional Commits em Português (pt-BR).

## Uso

```
/commit
```

## Instruções

1. **Analise as mudanças** do repositório:
   - Execute `git status` para ver arquivos modificados
   - Execute `git diff` (staged e unstaged) para entender as mudanças
   - Execute `git log --oneline -5` para ver o estilo dos commits recentes

2. **Classifique o tipo** da mudança:
   | Tipo | Quando usar |
   |------|-------------|
   | `feat` | Nova funcionalidade |
   | `fix` | Correção de bug |
   | `refactor` | Refatoração sem mudar comportamento |
   | `chore` | Tarefas de manutenção, deps, configs |
   | `docs` | Apenas documentação |
   | `style` | Formatação, lint, sem mudança de lógica |
   | `test` | Adição ou correção de testes |
   | `perf` | Melhoria de performance |
   | `ci` | Mudanças em CI/CD |
   | `build` | Mudanças no build ou dependências |

3. **Identifique o escopo** (módulo afetado):
   - `app` - App principal (yummy_log)
   - `auth` - module_auth / package_auth
   - `growth` - module_growth_standards
   - `calendar` - module_calendar
   - `sync` - module_sync / package_sync
   - `core` - module_core
   - `home` - module_home
   - `deps` - dependências gerais
   - `l10n` - internacionalização
   - `design` - ui_kit
   - `analytics` - package_analytics
   - Outro escopo relevante

4. **Monte a mensagem** seguindo o formato:

```
tipo(escopo): descrição curta em português

- Detalhe 1 das mudanças
- Detalhe 2 das mudanças
- Detalhe 3 das mudanças
```

5. **Faça o stage** dos arquivos relevantes (se necessário)

6. **Crie o commit** usando heredoc para preservar formatação:

```bash
git commit -m "$(cat <<'EOF'
tipo(escopo): descrição curta

- Detalhe 1
- Detalhe 2

EOF
)"
```

7. **Verifique** com `git status` após o commit

## Regras

1. **Descrição sempre em Português (pt-BR)**
2. **Primeira linha** com no máximo 72 caracteres
3. **Letra minúscula** no início da descrição (após o `:`)
4. **Sem ponto final** na primeira linha
5. **Corpo do commit** com detalhes das mudanças quando houver mais de uma alteração
6. **Não commitar** arquivos sensíveis (.env, credentials, secrets)
7. **Não commitar** se não houver mudanças
8. **Não fazer push** automaticamente - apenas o commit
9. Se houver arquivos unstaged que fazem parte da mesma mudança, fazer `git add` antes

## Exemplos

```
feat(growth): adicionar cálculo de IMC por idade

- Implementa serviço de cálculo baseado nas tabelas OMS
- Adiciona widget de exibição do resultado
- Inclui testes unitários para os cálculos
```

```
fix(deps): corrigir conflito de versão do pacote intl para 0.20.2

- Atualiza intl em commons_dependencies, module_calendar e module_growth_standards
- Configura l10n.yaml com synthetic-package: false
```

```
refactor(auth): extrair lógica de login para service dedicado
```

```
chore(deps): atualizar dependências do flutter SDK
```

## Responda em Português (pt-BR)
