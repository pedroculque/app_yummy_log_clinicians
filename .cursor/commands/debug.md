# /debug [problema] - Debug e Troubleshooting

Ajuda a debugar problemas no projeto.

## Uso

```
/debug [descrição do problema]
/debug build error
/debug test failing
/debug runtime error
```

## Instruções

1. **Analise o problema** descrito
2. **Consulte documentação** relevante
3. **Verifique código** relacionado
4. **Sugira soluções** ordenadas por probabilidade

## Fluxo de Debug

### 1. Coleta de Informações

```
🐛 Debug Mode

Problema: [descrição]

Coletando informações...

- Flutter version: [flutter --version]
- Dart version: [dart --version]
- Últimos commits: [git log --oneline -3]
- Arquivos modificados: [git status]
```

### 2. Análise

```
## Análise

### Possíveis Causas
1. [Causa mais provável]
2. [Segunda causa]
3. [Terceira causa]

### Arquivos Relevantes
- [arquivo1.dart]
- [arquivo2.dart]

### Documentação Relacionada
- [doc1.md]
- [doc2.md]
```

### 3. Soluções

```
## Soluções Sugeridas

### Solução 1 (mais provável)
[Descrição]
[Código/comandos]

### Solução 2
[Descrição]
[Código/comandos]

### Solução 3
[Descrição]
[Código/comandos]

Qual solução tentar primeiro?
```

## Problemas Comuns

### Build Errors

1. Verifique `flutter pub get`
2. Verifique `flutter clean`
3. Verifique dependências em `pubspec.yaml`
4. Verifique imports

### Test Failures

1. Leia mensagem de erro
2. Verifique mocks
3. Verifique setup/teardown
4. Rode teste isolado

### Runtime Errors

1. Verifique stack trace
2. Identifique arquivo/linha
3. Verifique null safety
4. Verifique async/await

### Modular Errors

1. Verifique binds registrados
2. Verifique imports do módulo
3. Verifique ordem de inicialização

### Firebase Errors

1. Verifique configuração
2. Verifique google-services.json / GoogleService-Info.plist
3. Verifique permissões

## Comandos Úteis

```bash
# Limpar e rebuildar
flutter clean && flutter pub get

# Verificar dependências
flutter pub deps

# Analisar código
flutter analyze

# Rodar teste específico
flutter test path/to/test.dart

# Logs detalhados
flutter run --verbose

# iOS específico
cd ios && pod install --repo-update

# Android específico
cd android && ./gradlew clean
```

## Responda em Português (pt-BR)
