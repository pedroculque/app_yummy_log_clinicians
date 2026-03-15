# /release [tipo] - Preparar Release

Prepara uma nova release do app.

## Uso

```
/release patch   - Bug fixes (1.0.0 → 1.0.1)
/release minor   - New features (1.0.0 → 1.1.0)
/release major   - Breaking changes (1.0.0 → 2.0.0)
```

## Instruções

### 1. Verificar Estado Atual

```bash
# Versão atual
grep "version:" pubspec.yaml

# Commits desde última tag
git log $(git describe --tags --abbrev=0)..HEAD --oneline

# Status do repo
git status
```

### 2. Checklist Pré-Release

```
📦 Preparando Release

## Checklist

### Código
- [ ] Todos os testes passando
- [ ] Sem erros de lint
- [ ] Sem TODOs críticos
- [ ] Code review feito

### Documentação
- [ ] CHANGELOG atualizado
- [ ] README atualizado
- [ ] Docs de módulos atualizadas

### Configuração
- [ ] Versão incrementada
- [ ] Build number incrementado
- [ ] Remote Config atualizado (se necessário)

### Build
- [ ] Build Android funciona
- [ ] Build iOS funciona
- [ ] Testado em device real
```

### 3. Atualizar Versão

```yaml
# pubspec.yaml
version: X.Y.Z+BUILD
```

Onde:
- X = Major (breaking changes)
- Y = Minor (new features)
- Z = Patch (bug fixes)
- BUILD = Número incremental

### 4. Atualizar CHANGELOG

```markdown
# Changelog

## [X.Y.Z] - YYYY-MM-DD

### Added
- Nova feature 1
- Nova feature 2

### Changed
- Mudança 1
- Mudança 2

### Fixed
- Bug fix 1
- Bug fix 2

### Removed
- Item removido
```

### 5. Criar Tag e Release

```bash
# Commit da versão
git add -A
git commit -m "chore: bump version to X.Y.Z"

# Criar tag
git tag -a vX.Y.Z -m "Release X.Y.Z"

# Push
git push origin main --tags
```

### 6. Build

```bash
# Android
flutter build apk --flavor production --release
flutter build appbundle --flavor production --release

# iOS
flutter build ios --flavor production --release
```

## Output Esperado

```
📦 Release vX.Y.Z

## Versão
- Anterior: A.B.C+N
- Nova: X.Y.Z+M

## Mudanças desde última release
[Lista de commits]

## CHANGELOG
[Conteúdo sugerido]

## Próximos Passos
1. Atualizar pubspec.yaml
2. Atualizar CHANGELOG.md
3. Commit e tag
4. Build e deploy

Continuar? (s/n)
```

## Ambientes

| Flavor | Bundle ID Suffix | Uso |
|--------|------------------|-----|
| development | .dev | Desenvolvimento |
| staging | .stg | Testes internos |
| production | (nenhum) | Produção |

## Scripts Úteis

```bash
# Incrementar build number
./increment_build_number.sh

# Deploy (se configurado)
./deploy.sh [flavor]
```

## Responda em Português (pt-BR)
