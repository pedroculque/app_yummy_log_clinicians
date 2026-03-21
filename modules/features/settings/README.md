# settings_feature

Feature Configurações do YummyLog for Clinicians: tela de configurações com login (Google/Apple), estado de autenticação, gerenciamento de assinatura e preferências.

## Funcionalidades

- **Tela Configurações:** opções de conta (login/logout), assinatura, tema e preferências.
- **Seção Assinatura:** exibe plano atual (Gratuito/Pro), contagem de pacientes, barra de progresso e botão de upgrade.
- **Tela de Planos:** UI para upgrade com benefícios Pro, seletor Anual/Mensal e preços.
- **Login:** integração com `auth_foundation` (Google Sign-In, Sign in with Apple); exibição de nome e avatar quando logado.
- **Estado deslogado:** CTA para entrar na conta.
- **ID de Suporte:** Firebase UID do utilizador logado (copiar para área de transferência); alinhado ao `SessionLogger` e Sentry. Ver [docs/support-id.md](docs/support-id.md).

## Quick Start

```dart
// Requer auth_foundation registrado
final feature = SettingsFeature();
feature.registerDependencies(getIt);
final routes = feature.getRoutes(getIt);
final fullScreenRoutes = feature.getFullScreenRoutes(getIt, rootNavigatorKey: key);

// Rotas: /settings, /plans (full-screen)
```

## Documentação

| Documento | Descrição |
|-----------|-----------|
| [docs/support-id.md](docs/support-id.md) | ID de Suporte (UID), visibilidade, i18n, ligação ao Sentry |
| (a criar) | docs/architecture.md – AuthCubit, dependências |
| (a criar) | docs/features.md – fluxo login, assinatura |

## Estrutura

```
docs/
└── support-id.md               # ID de Suporte (UID), UI, i18n, Sentry
lib/
├── settings_feature.dart       # Barrel
└── src/
    ├── settings_feature.dart   # YummyLogFeature: deps + rotas
    ├── cubit/                  # AuthCubit
    └── pages/
        ├── settings_page.dart  # Tela principal + seção assinatura
        └── plans_page.dart     # Tela de planos (upgrade)
```

## Rotas

| Rota | Descrição | Tipo |
|------|-----------|------|
| `/settings` | Tela de configurações | Tab (dentro do shell) |
| `/plans` | Tela de planos Pro | Full-screen |

## Dependências

- `auth_foundation` – `AuthRepository`
- `cloud_firestore` – Para buscar contagem de pacientes
- `feature_contract`, `ui_kit`, `yummy_log_l10n`, `go_router`, `flutter_bloc`

## Referências

- [REQUIREMENTS.md](../../../REQUIREMENTS.md) – C9 (Configurações), C17-C20 (Monetização)
- [docs/ROADMAP.md](../../../docs/ROADMAP.md) – fases do produto
