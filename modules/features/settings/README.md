# settings_feature

Feature Configurações do Yummy Log: tela de configurações com login (Google/Apple), estado de autenticação e acesso à conexão com nutricionista.

## Funcionalidades

- **Tela Configurações:** opções de conta (login/logout), link para Conectar com nutricionista, tema e preferências.
- **Login:** integração com `auth_foundation` (Google Sign-In, Sign in with Apple); exibição de nome e avatar quando logado.
- **Estado deslogado:** CTA para entrar na conta; estado genérico no cabeçalho do Diário quando não logado (R14).
- **Migração de dados:** ao fazer login, migração dos registros locais para a conta (via `AuthCubit` + `MealEntryRepository`).

## Quick Start

```dart
// Requer auth_foundation e diary_feature (MealEntryRepository) registrados
final feature = SettingsFeature();
feature.registerDependencies(getIt);
final routes = feature.getRoutes(getIt);

// Rota: /settings
```

## Documentação

| Documento | Descrição |
|-----------|-----------|
| (a criar) | docs/architecture.md – AuthCubit, dependências |
| (a criar) | docs/features.md – fluxo login, migração |

## Estrutura

```
lib/
├── settings_feature.dart       # Barrel
└── src/
    ├── settings_feature.dart   # YummyLogFeature: deps + rota /settings
    ├── cubit/                  # AuthCubit (auth + migração)
    └── pages/                  # SettingsPage
```

## Dependências

- `auth_foundation` – `AuthRepository`
- `diary_feature` – `MealEntryRepository` (para migração pós-login)
- `feature_contract`, `ui_kit`, `yummy_log_l10n`, `go_router`, `flutter_bloc`

## Referências

- [REQUIREMENTS.md](../../../REQUIREMENTS.md) – R1 (tab Configurações), R14, v3 (Auth)
- [docs/ROADMAP.md](../../../docs/ROADMAP.md) – fases do produto
