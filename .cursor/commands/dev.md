# /dev - Yummy Log Development Workflow

Você é um assistente de desenvolvimento para o projeto Yummy Log. Este é um comando interativo para gerenciar o ciclo de desenvolvimento.

## Instruções

Ao receber este comando, você deve:

1. **Ler o contexto atual** do projeto
2. **Apresentar o menu interativo**
3. **Guiar o desenvolvedor** através do fluxo escolhido

## Arquivos para Consultar

### Documentação Principal
- `docs/ROADMAP.md` - Fases e status
- `docs/ARCHITECTURE.md` - Arquitetura geral
- `docs/AUTH.md` - Autenticação
- `docs/SYNC.md` - Sincronização
- `docs/SUBSCRIPTION.md` - Assinaturas
- `docs/MONETIZATION.md` - Monetização

### Rules (Padrões)
- `.cursor/rules/dev-workflow.mdc` - Este workflow
- `.cursor/rules/dart-style.mdc` - Estilo Dart
- `.cursor/rules/flutter-architecture.mdc` - Arquitetura
- `.cursor/rules/bloc-cubit.mdc` - BLoC/Cubit
- `.cursor/rules/flutter-modular.mdc` - Modular

### Módulos
- `module_*/README.md` - Visão geral
- `module_*/docs/architecture.md` - Arquitetura
- `module_*/docs/features.md` - Features

## Menu Principal

Apresente este menu:

```
🚀 Yummy Log Development Workflow

Status Atual: [ler de docs/ROADMAP.md]

Escolha uma opção:

1. 📊 Ver Status do Projeto
2. 🎯 Iniciar Nova Feature  
3. 🔄 Continuar Feature em Andamento
4. ✅ Finalizar Feature
5. 📝 Atualizar Documentação
6. 🐛 Debug/Troubleshooting
7. 📦 Preparar Release

Digite o número:
```

## Fluxos por Opção

### 1. Ver Status
- Leia `docs/ROADMAP.md`
- Liste módulos e status
- Mostre últimos commits (`git log --oneline -5`)

### 2. Iniciar Feature
- Liste módulos planejados (🔴)
- Pergunte qual implementar
- Leia docs do módulo escolhido
- Crie plano de implementação com checkboxes
- Pergunte se quer começar

### 3. Continuar Feature
- Verifique `git status`
- Verifique `git branch`
- Identifique feature em andamento
- Pergunte onde parou
- Continue implementação

### 4. Finalizar Feature
- Rode `flutter analyze`
- Rode `flutter test` no módulo
- Verifique docs atualizadas
- Prepare commit seguindo padrões
- Pergunte se quer PR

### 5. Atualizar Docs
- Liste docs existentes
- Pergunte qual atualizar
- Faça atualizações
- Commit

### 6. Debug
- Pergunte o problema
- Analise código relevante
- Consulte docs
- Sugira soluções

### 7. Release
- Leia versão de `pubspec.yaml`
- Liste commits desde última tag
- Sugira nova versão
- Atualize CHANGELOG
- Prepare build

## Regras Importantes

1. **Sempre leia a documentação** antes de implementar
2. **Siga os padrões** das rules
3. **Commits pequenos** e descritivos
4. **Testes** para cada feature
5. **Atualize docs** ao finalizar

## Responda em Português (pt-BR)
